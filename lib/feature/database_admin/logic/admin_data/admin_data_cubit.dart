import 'dart:async';
import 'dart:io'; // ✅ استيراد واحد فقط يكفي
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bloc/bloc.dart';
import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/admin_data/admin_data_state.dart';
import 'package:optialeader/feature/database_admin/data/repo/admin_repository/admin_repo.dart';
import 'package:optialeader/firebase_options.dart';
// ❌ تم إزالة flutter_image_compress من هنا لأن الضغط يتم في الـ Repository

class AdminDataCubit extends Cubit<AdminDataState> {
  final AdminRepo adminRepo;
  StreamSubscription? _adminsSubscription;

  AdminDataCubit(this.adminRepo) : super(AdminInitial());

  // جلب بيانات أدمن معين
 Future<void> getAdminProfile(String uid) async {
  try {
    print('========== CUBIT GET ADMIN ==========');
    print('UID: $uid');

    emit(AdminLoading());

    final result = await adminRepo.getAdminProfile(uid);

    await result.fold(
      (error) async {
        print('PROFILE ERROR: $error');
        emit(AdminError(error: error));
      },
      (admin) async {
        print('Admin profile loaded: ${admin.nameAr}');

        final counts = await adminRepo.getAdminDashboardCounts();

        print('Dashboard counts: $counts');

        emit(
          AdminLoaded(
            admin: admin,
            newRequestsCount: counts['newRequests'] ?? 0,
            underReviewCount: counts['underReview'] ?? 0,
          ),
        );

        print('AdminLoaded emitted successfully');
      },
    );
  } catch (e, stackTrace) {
    print('========== CUBIT GET ADMIN ERROR ==========');
    print('ERROR: $e');
    print('STACK TRACE: $stackTrace');

    emit(AdminError(error: e.toString()));
  }
}
  // حفظ وتحديث بيانات الادمن
  Future<void> saveAdminData(AdminProfileModel admin) async {
    emit(AdminLoading());
    final result = await adminRepo.saveAdminData(admin);
    result.fold(
      (error) => emit(AdminError(error: error)),
      (_) => emit(AdminSuccess()),
    );
  }

  /// إنشاء أدمن جديد (Auth + Firestore)
  Future<void> createNewAdmin(AdminProfileModel admin) async {
    emit(AdminLoading());
    UserCredential? credential;

    try {
      // 1. تهيئة النسخة الثانوية بأمان
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

      // 2. إنشاء الحساب
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: admin.email.trim(),
        password: admin.nationalId.trim(),
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        emit(AdminError(error: "ERROR_USER_CREATION_FAILED"));
        return;
      }

      final String newUid = firebaseUser.uid;
      final updatedAdmin = admin.copyWith(uid: newUid);

      try {
        final result = await adminRepo.saveAdminData(updatedAdmin);
        result.fold(
          (error) async {
            try { await firebaseUser.delete(); } catch (_) {}
            emit(AdminError(error: error));
          }, 
          (_) => emit(AdminSuccess()),
        );
      } catch (e) {
        try { await firebaseUser.delete(); } catch (_) {}
        emit(AdminError(error: e.toString()));
      }

    } on FirebaseAuthException catch (e) {
      String errorCode = "ERROR_AUTH_UNKNOWN";
      if (e.code == 'email-already-in-use') errorCode = "ERROR_EMAIL_ALREADY_IN_USE";
      if (e.code == 'weak-password') errorCode = "ERROR_WEAK_PASSWORD";
      emit(AdminError(error: errorCode));
    } catch (e) {
      emit(AdminError(error: e.toString()));
    } finally {
      try {
        final secondaryApp = Firebase.app('SecondaryApp');
        final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        await secondaryAuth.signOut();
      } catch (_) {}
    }
  }

  // مراقبة كل تحديثات الادمن
  void watchAllAdmins() {
    emit(AdminLoading());
    _adminsSubscription?.cancel();
    _adminsSubscription = adminRepo.watchAllAdmins().listen(
      (adminsList) {
        emit(AllAdminsLoaded(admins: adminsList));
      },
      onError: (error) {
        emit(AdminError(error: error.toString()));
      },
    );
  }

  // ✅ [تعديل] حذف الادمن مع محاولة حذف حساب الـ Auth الخاص به
  Future<void> deleteAdmin(String uid) async {
    emit(AdminDeleting());
    
    // 1. حذف البروفايل من Firestore والصورة من Supabase عبر الريبو
    final result = await adminRepo.deleteAdminAccount(uid);
    
    await result.fold(
      (error) async => emit(AdminError(error: error)),
      (_) async {
        // 2. محاولة حذف حساب الـ Auth (يتطلب صلاحيات Admin SDK)
        // ⚠️ ملاحظة هامة: لا يمكن حذف مستخدم آخر من الـ Auth باستخدام Firebase Client SDK العادي.
        // الطرق المتاحة:
        // أ) استخدام Firebase Cloud Functions (Admin SDK) - وهذا هو الأفضل والإنتاجي.
        // ب) تسجيل الدخول بحساب الادمن المراد حذفه ثم حذفه (غير عملي ويسبب تسجيل خروج).
        // ج) ترك حساب الـ Auth معلقاً (Orphan) ولكنه لن يتمكن من الدخول لعدم وجود بروفايل له.
        
        /* 
        // إذا كان لديك Cloud Function لحذف المستخدم، تستدعيها هنا.
        // مثال تخيلي:
        try {
          final functions = FirebaseFunctions.instance;
          await functions.httpsCallable('deleteUserAuth').call({'uid': uid});
        } catch (e) {
          print("Failed to delete Auth user via cloud function: $e");
        }
        */
        
        emit(AdminSuccess());
      },
    );
  }

  Future<void> updateAccountStatus(String uid, bool isActive) async {
    final result = await adminRepo.updateAccountStatus(uid, isActive);
    result.fold(
      (error) => emit(AdminError(error: error)),
      (_) => emit(AdminSuccess()),
    );
  }

  // ✅ [تعديل] تمرير مسار الصورة (String) بدلاً من كائن File
  Future<void> updateAdminProfileImage(String uid, File imageFile) async {
    emit(AdminLoading()); 

    // 1. رفع الصورة إلى Supabase (نمرر imageFile.path)
    final uploadResult = await adminRepo.uploadImageToSupabase(uid, imageFile.path);

    uploadResult.fold(
      (uploadError) {
        emit(AdminError(error: uploadError));
      },
      (imageUrl) async {
        // 2. حفظ الرابط في Firebase Firestore
        final updateResult = await adminRepo.updateAdminImage(uid, imageUrl);
         
        updateResult.fold(
          (updateError) => emit(AdminError(error: updateError)),
          (_) => emit(AdminSuccess()), 
        );
      },
    );
  }

  @override
  Future<void> close() {
    _adminsSubscription?.cancel();
    return super.close();
  }
}