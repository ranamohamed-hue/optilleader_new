import 'package:equatable/equatable.dart';

import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';

abstract class EmployeeCoursesState extends Equatable {
  const EmployeeCoursesState();

  @override
  List<Object?> get props => [];
}

// ============================================================
// Initial
// ============================================================

class EmployeeCoursesInitial
    extends EmployeeCoursesState {}

// ============================================================
// Loading
// ============================================================

class EmployeeCoursesLoading
    extends EmployeeCoursesState {}

// ============================================================
// Loaded
// ============================================================

class EmployeeCoursesLoaded
    extends EmployeeCoursesState {
  final List<EmployeeCourseModel> courses;

  const EmployeeCoursesLoaded(
    this.courses,
  );

  @override
  List<Object?> get props => [courses];
}

// ============================================================
// Uploading
// ============================================================

class EmployeeCoursesUploading
    extends EmployeeCoursesState {}

// ============================================================
// Action Success
// ============================================================

class EmployeeCoursesActionSuccess
    extends EmployeeCoursesState {
  final String message;

  const EmployeeCoursesActionSuccess(
    this.message,
  );

  @override
  List<Object?> get props => [message];
}

// ============================================================
// Error
// ============================================================

class EmployeeCoursesError
    extends EmployeeCoursesState {
  final String message;

  const EmployeeCoursesError(
    this.message,
  );

  @override
  List<Object?> get props => [message];
}