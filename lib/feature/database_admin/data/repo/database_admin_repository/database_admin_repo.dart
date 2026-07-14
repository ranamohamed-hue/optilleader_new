import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';
import 'package:dartz/dartz.dart';

abstract class DatabaseAdminRepo {
  Future<Either<String, DatabaseAdminProfileModel>> getAdminProfile(String uid);
  Future<Either<String, Unit>> updateAdminInfo({
    required String uid,
    required String newPhone,
    required String addressAr,
    required String addressEn,
  });
  Future<Either<String, Unit>> updateProfileImage(String uid, String imageUrl);
    Future<Either<String, String>> uploadImageToSupabase(String uid, String filePath);

  Future<Map<String, int>> getUserCounts(); 
}
