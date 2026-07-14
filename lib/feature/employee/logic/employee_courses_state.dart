import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';

abstract class EmployeeCoursesState {}

class EmployeeCoursesInitial extends EmployeeCoursesState {}

class EmployeeCoursesLoading extends EmployeeCoursesState {}

class EmployeeCoursesUploading extends EmployeeCoursesState {}

class EmployeeCoursesLoaded extends EmployeeCoursesState {
  final List<EmployeeCourseModel> courses;

  EmployeeCoursesLoaded(this.courses);
}

class EmployeeCoursesActionSuccess extends EmployeeCoursesState {
  final String message;

  EmployeeCoursesActionSuccess(this.message);
}

class EmployeeCoursesError extends EmployeeCoursesState {
  final String error;

  EmployeeCoursesError(this.error);
}