import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:optialeader/feature/admin/logic/employee_admin_approval/employee_course_approval_state.dart';

import 'package:optialeader/feature/admin/data/repo/admin_approval_employee/admin_approval_employee_repo.dart';

class EmployeeCourseApprovalCubit
    extends Cubit<EmployeeCourseApprovalState> {
  final EmployeeCourseApprovalRepo repo;

  EmployeeCourseApprovalCubit({
    required this.repo,
  }) : super(
          EmployeeCourseApprovalInitial(),
        );

  // ============================================================
  // LOAD PENDING COURSES
  // ============================================================

  Future<void> loadPendingCourses() async {
    emit(
      EmployeeCourseApprovalLoading(),
    );

    final result =
        await repo.getPendingCourses();

    result.fold(
      (error) {
        emit(
          EmployeeCourseApprovalError(
            error,
          ),
        );
      },
      (courses) {
        emit(
          EmployeeCourseApprovalLoaded(
            courses,
          ),
        );
      },
    );
  }

  // ============================================================
  // APPROVE COURSE
  // ============================================================

  Future<void> approveCourse({
    required String employeeUid,
    required String courseId,
    required String courseTitle,
  }) async {
    emit(
      EmployeeCourseApprovalActionLoading(),
    );

    final result =
        await repo.approveCourse(
      employeeUid: employeeUid,
      courseId: courseId,
      courseTitle: courseTitle,
    );

    result.fold(
      (error) {
        emit(
          EmployeeCourseApprovalError(
            error,
          ),
        );
      },
      (_) async {
        emit(
          const EmployeeCourseApprovalSuccess(
            'تم اعتماد الدورة بنجاح',
          ),
        );

        await loadPendingCourses();
      },
    );
  }

  // ============================================================
  // REJECT COURSE
  // ============================================================

  Future<void> rejectCourse({
    required String employeeUid,
    required String courseId,
    required String courseTitle,
    required String reason,
  }) async {
    emit(
      EmployeeCourseApprovalActionLoading(),
    );

    final result =
        await repo.rejectCourse(
      employeeUid: employeeUid,
      courseId: courseId,
      courseTitle: courseTitle,
      reason: reason,
    );

    result.fold(
      (error) {
        emit(
          EmployeeCourseApprovalError(
            error,
          ),
        );
      },
      (_) async {
        emit(
          const EmployeeCourseApprovalSuccess(
            'تم رفض الدورة',
          ),
        );

        await loadPendingCourses();
      },
    );
  }
}