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

  AuthRepoImpl({required this.auth, required this.firestore, required this.hiveService});

  @override
  Future<UserModel?> getCachedUser() async {
    final hiveUser = await hiveService.getUser();
    return hiveUser?.toUserModel();
  }

  @override
  Future<Either<String, UserModel>> login({required String email, required String password}) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
      final user = credential.user;
      if (user == null) return const Left("فشل");
      
      final doc = await firestore.collection("users").doc(user.uid).get();
      final userModel = UserModel.fromFirestore(doc);
      await hiveService.saveUser(UserHiveModel.fromUserModel(userModel));
      
      return Right(userModel);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> completeFirstLogin({required String newPassword}) async {
    try {
      final user = auth.currentUser;
      if (user == null) return const Left("الجلسة انتهت");
      
      await user.updatePassword(newPassword.trim());
      await firestore.collection('users').doc(user.uid).update({'isFirstLogin': false});
      
      final cachedUser = await hiveService.getUser();
      if (cachedUser != null) {
        final updatedHiveUser = UserHiveModel(
          uid: cachedUser.uid, username: cachedUser.username, universityEmail: cachedUser.universityEmail,
          nationalId: cachedUser.nationalId, employeeId: cachedUser.employeeId, role: cachedUser.role, isFirstLogin: false, 
        );
        await hiveService.saveUser(updatedHiveUser);
      }
      return const Right("تم تعيين كلمة المرور بنجاح");
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? "فشل تحديث كلمة المرور");
    } catch (e) {
      return const Left("حدث خطأ أثناء التحديث");
    }
  }

  @override
  Future<Either<String, String>> sendPasswordResetEmail({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      return const Right("تم إرسال رابط إعادة التعيين");
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

  @override
  Future<void> initHive() async {
    await hiveService.init();
  }
    @override
  Future<Either<String, UserModel>> fetchUserData({required String uid}) async {
    try {
      final doc = await firestore.collection("users").doc(uid).get();
      if (!doc.exists) {
        return const Left("المستخدم غير موجود في قاعدة البيانات");
      }
      final userModel = UserModel.fromFirestore(doc);
      
      // نحفظ في الهايف بشكل آمن (لو حصل خطأ لا نوقف التطبيق)
      try {
        await hiveService.saveUser(UserHiveModel.fromUserModel(userModel));
      } catch (e) {
        print('⚠️ فشل تحديث الكاش في الهايف: $e');
      }
      
      return Right(userModel);
    } catch (e) {
      return Left("فشل جلب بيانات المستخدم");
    }
  }
}