import 'package:optialeader/feature/admin/data/model/employee_course_approval_model.dart';
abstract class EmployeeCourseApprovalState {
  const EmployeeCourseApprovalState();
}

class EmployeeCourseApprovalInitial
    extends EmployeeCourseApprovalState {}

class EmployeeCourseApprovalLoading
    extends EmployeeCourseApprovalState {}

class EmployeeCourseApprovalActionLoading
    extends EmployeeCourseApprovalState {}

class EmployeeCourseApprovalLoaded
    extends EmployeeCourseApprovalState {
  final List<EmployeeCourseApprovalModel>
      courses;

  const EmployeeCourseApprovalLoaded(
    this.courses,
  );
}

class EmployeeCourseApprovalSuccess
    extends EmployeeCourseApprovalState {
  final String message;

  const EmployeeCourseApprovalSuccess(
    this.message,
  );
}

class EmployeeCourseApprovalError
    extends EmployeeCourseApprovalState {
  final String message;

  const EmployeeCourseApprovalError(
    this.message,
  );
}