import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:optialeader/feature/employee/data/models/employee_course_model.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/admin/data/model/employee_course_approval_model.dart';
class EmployeeCourseApprovalRepo {
  final FirebaseFirestore firestore;
  final NotificationRepo notificationRepo;

  EmployeeCourseApprovalRepo({
    required this.firestore,
    required this.notificationRepo,
  });

  // ============================================================
  // Get Pending Courses
  // ============================================================

  Future<Either<String, List<EmployeeCourseApprovalModel>>>
      getPendingCourses() async {
    try {
      final usersSnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'admin_manager')
          .get();

      final List<EmployeeCourseApprovalModel>
          pendingCourses = [];

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();

        final coursesSnapshot = await userDoc.reference
            .collection('courses')
            .where('status', isEqualTo: 'pending')
            .get();

        for (final courseDoc
            in coursesSnapshot.docs) {
          final course =
              EmployeeCourseModel.fromMap(
            courseDoc.data(),
            courseDoc.id,
          );

          pendingCourses.add(
            EmployeeCourseApprovalModel(
              employeeUid: userDoc.id,
              employeeName:
                  userData['nameAr'] ??
                      userData['name'] ??
                      '',
              employeeId:
                  userData['employeeId'] ??
                      '',
              department:
                  userData['departmentAr'] ??
                      '',
              course: course,
            ),
          );
        }
      }

      return right(pendingCourses);
    } catch (e) {
      return left(
        'فشل جلب الدورات: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // Approve Course
  // ============================================================

  Future<Either<String, Unit>>
      approveCourse({
    required String employeeUid,
    required String courseId,
    required String courseTitle,
  }) async {
    try {
      await firestore
          .collection('users')
          .doc(employeeUid)
          .collection('courses')
          .doc(courseId)
          .update({
        'status': 'approved',
        'rejectionReason': null,
      });

      await notificationRepo.sendNotification(
        AppNotificationModel(
          id: '',
          title: 'اعتماد دورة',
          message:
              'تم اعتماد الدورة $courseTitle',
          receiverId: employeeUid,
          target:
              NotificationTarget.specificUser,
          type:
              NotificationType.activityStatusUpdated,
          timestamp: Timestamp.now(),
        ),
      );

      return right(unit);
    } catch (e) {
      return left(
        'فشل اعتماد الدورة: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // Reject Course
  // ============================================================

  Future<Either<String, Unit>>
      rejectCourse({
    required String employeeUid,
    required String courseId,
    required String courseTitle,
    required String reason,
  }) async {
    try {
      await firestore
          .collection('users')
          .doc(employeeUid)
          .collection('courses')
          .doc(courseId)
          .update({
        'status': 'rejected',
        'rejectionReason': reason,
      });

      await notificationRepo.sendNotification(
        AppNotificationModel(
          id: '',
          title: 'رفض دورة',
          message:
              'تم رفض الدورة $courseTitle\nالسبب: $reason',
          receiverId: employeeUid,
          target:
              NotificationTarget.specificUser,
          type:
              NotificationType.activityStatusUpdated,
          timestamp: Timestamp.now(),
        ),
      );

      return right(unit);
    } catch (e) {
      return left(
        'فشل رفض الدورة: ${e.toString()}',
      );
    }
  }
}