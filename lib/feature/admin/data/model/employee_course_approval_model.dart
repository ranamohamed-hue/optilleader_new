
import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
class EmployeeCourseApprovalModel {
  final String employeeUid;
  final String employeeName;
  final String employeeId;
  final String department;

  final EmployeeCourseModel course;

  EmployeeCourseApprovalModel({
    required this.employeeUid,
    required this.employeeName,
    required this.employeeId,
    required this.department,
    required this.course,
  });
}