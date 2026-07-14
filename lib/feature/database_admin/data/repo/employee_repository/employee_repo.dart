import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';

abstract class EmployeeRepo {
  Future<Either<String, Unit>> saveEmployeeData(EmployeeModel employee);
  
  Future<Either<String, EmployeeModel?>> getEmployeeProfile(String uid);
  
  Stream<List<EmployeeModel>> watchAllEmployees();
  
  Future<Either<String, List<EmployeeModel>>> getAllEmployeesOnce();
  
  Future<Either<String, Unit>> updateAccountStatus(String uid, bool isActive);
  
  Future<Either<String, Unit>> updateVacationStatus(String uid, bool isOnVacation);
  
  Future<Either<String, String>> uploadFile(
    Uint8List fileBytes,
    String storagePath, {
    required String bucketName,
  });
  
  Future<Either<String, Unit>> updateEmployeeImage(String uid, String imageUrl);
  
  Future<Either<String, Unit>> deleteEmployeeAccount(String uid);
  
  Future<Either<String, Unit>> updateEmployeeProfileData(
    String uid,
    Map<String, dynamic> updatedFields,
  );
}