import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';

abstract class AuthRepo {
  Future<UserModel?> getCachedUser(); // ملاحظة: فيها Future
  
  Future<Either<String, UserModel>> login({required String email, required String password});
  Future<Either<String, String>> sendPasswordResetEmail({required String email});
  Future<Either<String, String>> completeFirstLogin({required String newPassword});
  Future<Either<String, void>> logout();
  Future<void> initHive();
    // دالة جديدة لجلب بيانات المستخدم من الـ Firestore بناءً على الـ UID
  Future<Either<String, UserModel>> fetchUserData({required String uid});
}