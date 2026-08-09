


import 'package:optialeader/feature/database_admin/data/models/database_admin_model.dart';

abstract class DatabaseAdminState {}

class DatabaseAdminInitial extends DatabaseAdminState {}
class DatabaseAdminLoading extends DatabaseAdminState {}

class DatabaseAdminSuccess extends DatabaseAdminState {
  final DatabaseAdminProfileModel profile;
  
  final int doctorsCount;
  final int judgesCount;
  final int adminsCount;
  final int employeesCount;

  DatabaseAdminSuccess(
    this.profile, {
    this.doctorsCount = 0, 
    this.judgesCount = 0,
    this.adminsCount = 0,
    required this.employeesCount, 

  });
}
class DatabaseAdminError extends DatabaseAdminState {
  final String message;
  DatabaseAdminError(this.message);
}
class DatabaseAdminUpdateSuccess extends DatabaseAdminState {}