import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

abstract class DoctorRepo {
  Future<Either<String, Unit>> saveDoctorData(DoctorProfileModel doctor);

  Future<Either<String, DoctorProfileModel?>> getDoctorProfile(String uid);
  Stream<List<DoctorProfileModel>> watchAllDoctors();
  Future<Either<String, Unit>> updateAccountStatus(String uid, bool isActive);

  Future<Either<String, Unit>> updateVacationStatus(
    String uid,
    bool isOnVacation,
  );

  Future<Either<String, String>> uploadFile(
    Uint8List fileBytes,
    String storagePath, {
    required String bucketName,
  });

  Future<Either<String, Unit>> updateDoctorImage(String uid, String imageUrl);
  Future<Either<String, Unit>> deleteDoctorAccount(String uid);
  Future<Either<String, Unit>> updateDoctorProfileData(
    String uid,
    Map<String, dynamic> updatedFields,
  );
    Future<Either<String, List<DoctorProfileModel>>> getAllDoctorsOnce();
}
