import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/core/services/hive_service.dart';
import 'package:optialeader/feature/auth/data/models/user_hive_model.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final HiveService hiveService;

  AuthRepoImpl({
    required this.auth,
    required this.firestore,
    required this.hiveService,
  });
  // دالة عشان الـ Cubit يجيب البيانات المحفوظة
  @override
  UserModel? getCachedUser() {
    final hiveUser = hiveService.getUser();
    return hiveUser?.toUserModel(); // حولناه لـ UserModel عشان التطبيق يفهمه
  }

  //  تسجيل الدخول - هنا الباسورد هو الرقم القومي في أول مرة
  @override
 Future<Either<String, UserModel>> login({
  required String email,
  required String password,
}) async {
  try {
    print("STEP 1");

    final credential = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    print("STEP 2");

    final user = credential.user;

    if (user == null) {
      print("USER NULL");
      return const Left("فشل");
    }

    print("UID = ${user.uid}");

    print("STEP 3");

    final doc = await firestore.collection("users").doc(user.uid).get();

    print("STEP 4");

    final userModel = UserModel.fromFirestore(doc);

    print("STEP 5");

    await hiveService.saveUser(UserHiveModel.fromUserModel(userModel));

    print("STEP 6");

    return Right(userModel);
  } catch (e, s) {
    print(e);
    print(s);
    return Left(e.toString());
  }
}
  //  تحديث الباسورد وتحويل الرقم القومي لباسورد جديد خاص بالمستخدم
  @override
  Future<Either<String, String>> completeFirstLogin({
    required String newPassword,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return const Left("الجلسة انتهت، يرجى تسجيل الدخول مجدداً");
      }

      //  تحديث كلمة المرور في Firebase Auth
      await user.updatePassword(newPassword.trim());

      //  تحديث حالة isFirstLogin في Firestore
      await firestore.collection('users').doc(user.uid).update({
        'isFirstLogin': false,
        // اختياري: ممكن تخزني وقت التحديث
        'passwordUpdatedAt': FieldValue.serverTimestamp(),
      });
            // تحديث الـ Hive المحلي عشان يتعلم إن الباسورد اتغير وما يعرضش الشاشة دي تاني

      final cachedUser = hiveService.getUser();
      if (cachedUser != null) {
        final updatedHiveUser = UserHiveModel(
          uid: cachedUser.uid,
          username: cachedUser.username,
          universityEmail: cachedUser.universityEmail,
          nationalId: cachedUser.nationalId,
          employeeId: cachedUser.employeeId,
          role: cachedUser.role,
          isFirstLogin: false, 
        );
        await hiveService.saveUser(updatedHiveUser);
      }
      return const Right("تم تعيين كلمة المرور بنجاح");
    } on FirebaseAuthException catch (e) {
      // إذا انتهت الجلسة (Requires recent login)
      if (e.code == 'requires-recent-login') {
        return const Left(
          "للأمان، يرجى تسجيل الدخول مرة أخرى قبل تغيير كلمة المرور",
        );
      }
      return Left(e.message ?? "فشل تحديث كلمة المرور");
    } catch (e) {
      return const Left("حدث خطأ أثناء التحديث، حاول لاحقاً");
    }
  }

  @override
  Future<Either<String, String>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      return const Right("تم إرسال رابط إعادة التعيين لبريدك الإلكتروني");
    } on FirebaseAuthException catch (e) {
      return Left(_handleAuthError(e.code));
    } catch (e) {
      return const Left("فشل إرسال البريد");
    }
  }

  @override
  Future<Either<String, void>> logout() async {
    try {
      await auth.signOut();
      await hiveService.clearUser();

      return const Right(null);
    } catch (e) {
      return const Left("فشل تسجيل الخروج");
    }
  }

  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential': // النسخ الجديدة من Firebase بتستخدم ده للأمان
        return "البريد الإلكتروني أو كلمة المرور (الرقم القومي) غير صحيح";
      case 'wrong-password':
        return "كلمة المرور غير صحيحة";
      case 'invalid-email':
        return "تنسيق البريد الإلكتروني غير صحيح";
      case 'user-disabled':
        return "هذا الحساب تم تعطيله";
      case 'too-many-requests':
        return "محاولات كثيرة خاطئة، حاول لاحقاً";
      default:
        return "حدث خطأ في المصادقة، يرجى المحاولة مرة أخرى";
    }
  }
}
