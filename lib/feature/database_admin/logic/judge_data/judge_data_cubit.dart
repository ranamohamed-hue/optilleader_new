import 'dart:async';
import 'dart:io'; // ✅ ضروري لاستخدام File
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/judge_data/judge_data_state.dart';
import 'package:optialeader/feature/database_admin/data/repo/judge_repository/judge_repo.dart';
import 'package:optialeader/firebase_options.dart';

class JudgeDataCubit extends Cubit<JudgeDataState> {
  final JudgeRepo judgeRepo;
  StreamSubscription? _judgesSubscription;

  JudgeDataCubit(this.judgeRepo) : super(JudgeInitial());

  Future<void> getJudgeProfile(String uid) async {
    emit(JudgeLoading());
    final result = await judgeRepo.getJudgeProfile(uid);
    result.fold(
      (error) => emit(JudgeError(error: error)),
      (judge) => emit(JudgeLoaded(judge: judge)),
    );
  }

  Future<void> saveJudgeData(JudgeProfileModel judge) async {
    emit(JudgeLoading());
    final result = await judgeRepo.saveJudgeData(judge);
    result.fold(
      (error) => emit(JudgeError(error: error)),
      (_) => emit(JudgeSuccess()),
    );
  }

  /// 🟢 إنشاء محكم جديد (Auth + Firestore)
  Future<void> createNewJudge(JudgeProfileModel judge) async {
    emit(JudgeLoading());
    UserCredential? credential;

    try {
      FirebaseApp secondaryApp;
      final isSecondaryAppInitialized = Firebase.apps.any((app) => app.name == 'SecondaryApp');

      if (isSecondaryAppInitialized) {
        secondaryApp = Firebase.app('SecondaryApp');
      } else {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: judge.email.trim(),
        password: judge.nationalId.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(JudgeError(error: "ERROR_USER_CREATION_FAILED"));
        return;
      }

      final String newUid = firebaseUser.uid;
      final updatedJudge = judge.copyWith(uid: newUid);

      final result = await judgeRepo.saveJudgeData(updatedJudge);
      result.fold((error) async {
        try { await firebaseUser.delete(); } catch (_) {}
        emit(JudgeError(error: error));
      }, (_) => emit(JudgeSuccess()));
      
    } on FirebaseAuthException catch (e) {
      String errorCode = "ERROR_AUTH_UNKNOWN";
      if (e.code == 'email-already-in-use') errorCode = "ERROR_EMAIL_ALREADY_IN_USE";
      if (e.code == 'weak-password') errorCode = "ERROR_WEAK_PASSWORD";
      emit(JudgeError(error: errorCode));
    } catch (e) {
      try { await credential?.user?.delete(); } catch (_) {}
      emit(JudgeError(error: e.toString()));
    } finally {
      try {
        final secondaryApp = Firebase.app('SecondaryApp');
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        await secondaryAuth.signOut();
      } catch (_) {}
    }
  }

  void watchAllJudges() {
    emit(JudgeLoading());
    _judgesSubscription?.cancel();
    _judgesSubscription = judgeRepo.watchAllJudges().listen(
      (judgesList) => emit(AllJudgesLoaded(judges: judgesList)),
      onError: (error) => emit(JudgeError(error: error.toString())),
    );
  }

  // ✅ [تعديل] حذف المحكم مع محاولة حذف حساب الـ Auth
  Future<void> deleteJudge(String uid) async {
    emit(JudgeDeleting());
    
    // 1. حذف الصورة من Supabase والبروفايل من Firestore
    final result = await judgeRepo.deleteJudgeAccount(uid);
    
    await result.fold(
      (error) async => emit(JudgeError(error: error)),
      (_) async {
        // 2. محاولة حذف حساب الـ Auth
        // نفس ملاحظة الأدمن: لا يمكن حذف مستخدم آخر من الـ Client SDK العادي
        // يفضل استخدام Cloud Functions، أو ترك حساب الـ Auth معلقاً (Orphan)
        /*
        try {
          // استدعاء Cloud Function هنا إن وجدت
        } catch (e) {
          print("Failed to delete Auth user: $e");
        }
        */
        emit(JudgeSuccess());
      },
    );
  }

  // ✅ [إضافة] دالة تحديث صورة المحكم
  Future<void> updateJudgeProfileImage(String uid, File imageFile) async {
    emit(JudgeLoading()); 

    // 1. رفع الصورة إلى Supabase (نمرر المسار)
    final uploadResult = await judgeRepo.uploadImageToSupabase(uid, imageFile.path);

    uploadResult.fold(
      (uploadError) {
        emit(JudgeError(error: uploadError));
      },
      (imageUrl) async {
        // 2. حفظ الرابط في Firebase Firestore
        final updateResult = await judgeRepo.updateJudgeImage(uid, imageUrl);
         
        updateResult.fold(
          (updateError) => emit(JudgeError(error: updateError)),
          (_) => emit(JudgeSuccess()), 
        );
      },
    );
  }

  @override
  Future<void> close() {
    _judgesSubscription?.cancel();
    return super.close();
  }
}