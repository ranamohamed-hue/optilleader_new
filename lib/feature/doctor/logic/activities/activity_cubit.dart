import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/doctor/data/model/conferance_model.dart';
import 'package:optialeader/feature/doctor/data/model/courses_model.dart';
import 'package:optialeader/feature/doctor/data/model/exhibition_venue_model.dart';
import 'package:optialeader/feature/doctor/data/repo/activities/activity_repo.dart';
import 'package:optialeader/feature/doctor/logic/activities/acativity_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final ActivitiesRepo activitiesRepo;
  final NotificationRepo notificationRepo;

  ActivityCubit(this.activitiesRepo, this.notificationRepo)
      : super(ActivityInitial());

  // ============================================================
  // ============== دالة التحكم الرئيسية (الجديدة) =============
  // ============================================================
  Future<void> submitActivities(Future<void> Function() action) async {
    emit(ActivityLoading());
    try {
      await action();
      emit(ActivitySuccess());
    } catch (e) {
      emit(ActivityError(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ============================================================
  // ============== دوال المؤتمرات ==============================
  // ============================================================
  Future<void> addConference({
    required String doctorUid,
    required ConferenceModel conference,
    File? certFile,
  }) async {
    final result = await activitiesRepo.addConference(
      doctorUid,
      conference,
      certFile: certFile,
    );
    result.fold(
      (error) => throw Exception(error),
      (_) => _sendNotification(doctorUid, conference.title, 'مؤتمر'),
    );
  }

  Future<void> deleteConference({
    required String doctorUid,
    required String confId,
  }) async {
    emit(ActivityLoading());
    final result = await activitiesRepo.deleteConference(doctorUid, confId);
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  // ============================================================
  // ============== دوال الدورات ================================
  // ============================================================
  Future<void> addCourse({
    required String doctorUid,
    required CourseModel course,
    File? certFile,
  }) async {
    final result = await activitiesRepo.addCourse(
      doctorUid,
      course,
      certFile: certFile,
    );
    result.fold(
      (error) => throw Exception(error),
      (_) => _sendNotification(doctorUid, course.title, 'دورة تدريبية'),
    );
  }

  Future<void> deleteCourse({
    required String doctorUid,
    required String courseId,
  }) async {
    emit(ActivityLoading());
    final result = await activitiesRepo.deleteCourse(doctorUid, courseId);
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  // ============================================================
  // ============== دوال المعارض ================================
  // ============================================================
  Future<void> addExhibition({
    required String doctorUid,
    required ArtExhibitionModel exhibition,
    File? proofFile,
  }) async {
    final result = await activitiesRepo.addExhibition(
      doctorUid,
      exhibition,
      proofFile: proofFile,
    );
    result.fold(
      (error) => throw Exception(error),
      (_) => _sendNotification(doctorUid, exhibition.title, 'معرض فني'),
    );
  }

  Future<void> deleteExhibition({
    required String doctorUid,
    required String exhId,
  }) async {
    emit(ActivityLoading());
    final result = await activitiesRepo.deleteExhibition(doctorUid, exhId);
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  // ============================================================
  // ============== دوال الأنشطة الأكاديمية =====================
  // ============================================================
  Future<void> saveAcademicActivities({
    required String doctorUid,
    required Map<String, dynamic> activitiesMap,
  }) async {
    emit(ActivityLoading());
    final result = await activitiesRepo.saveAcademicActivities(
      doctorUid,
      activitiesMap,
    );
    result.fold(
      (error) => emit(ActivityError(error: error)),
      (_) => emit(ActivitySuccess()),
    );
  }

  // ============================================================
  // ============== إرسال الإشعارات =============================
  // ============================================================
  Future<void> _sendNotification(
    String doctorUid,
    String title,
    String type,
  ) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: 'طلب اعتماد $type جديد',
        message: 'تم إضافة $type بعنوان: "$title" يحتاج موافقتك',
        type: NotificationType.newActivitySubmitted,
        target: NotificationTarget.adminOnly,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: '',
        doctorUid: doctorUid,
      );
      await notificationRepo.sendRoleBasedNotification(notification);
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}