import 'package:optialeader/feature/database_admin/data/models/employee_model.dart';

abstract class EmployeeDataState {}

class EmployeeInitial extends EmployeeDataState {}

class EmployeeLoading extends EmployeeDataState {}

class EmployeeDeleting extends EmployeeDataState {}

class EmployeeSuccess extends EmployeeDataState {}

class EmployeeLoaded extends EmployeeDataState {
  final EmployeeModel employee;
  EmployeeLoaded({required this.employee});
}

class AllEmployeesLoaded extends EmployeeDataState {
  final List<EmployeeModel> employees;
  AllEmployeesLoaded({required this.employees});
}

class EmployeeError extends EmployeeDataState {
  final String error;
  EmployeeError({required this.error});
}