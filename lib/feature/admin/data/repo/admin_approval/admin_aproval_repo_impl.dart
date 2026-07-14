import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_approval_repo.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/doctor/data/model/verefication_status.dart';
import 'package:optialeader/feature/doctor/data/repo/research_paper/research_paper_repo.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class AdminApprovalRepoImpl extends AdminApprovalRepo { 
  final FirebaseFirestore firebaseFirestore;
  final ResearchPaperRepo researchPaperRepo;
  final NotificationRepo notificationRepo;

  AdminApprovalRepoImpl({ 
    required this.firebaseFirestore,
    required this.researchPaperRepo,
    required this.notificationRepo,
  });

  @override
  Future<Either<String, List<DoctorProfileModel>>> getPendingRequests() async {
    try {
      final snapshot = await firebaseFirestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      
      final List<DoctorProfileModel> pendingDoctors = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final doctor = DoctorProfileModel.fromJson(data, doc.id);
        
        bool hasPendingResearch = doctor.researchPapers.any((p) => p.status == VerificationStatus.pending);
        bool hasPendingConferences = doctor.conferences.any((c) => c.status == VerificationStatus.pending);
        bool hasPendingExhibitions = doctor.exhibitions.any((e) => e.status == VerificationStatus.pending);
        bool hasPendingCourses = doctor.courses.any((c) => c.status == VerificationStatus.pending);
        
        bool hasPendingActivities = false;
        if (doctor.academicActivities != null) {
          final allCriteria = [
            ...doctor.academicActivities!.teachingCriteria,
            ...doctor.academicActivities!.researchCriteria,
            ...doctor.academicActivities!.communityCriteria,
          ];
          hasPendingActivities = allCriteria.any((c) => c.isSelected && c.proofStatus.name == 'pending');
        }
        
        if (hasPendingResearch || hasPendingConferences || hasPendingExhibitions || hasPendingCourses || hasPendingActivities) {
          pendingDoctors.add(doctor);
        }
      }
      
      return right(pendingDoctors);
    } catch (e) {
      return left("فشل جلب الطلبات: ${e.toString()}");
    }
  }

  // ====== الأبحاث ======
  @override
  Future<Either<String, Unit>> approveResearch(String doctorUid, String paperId, String paperTitle) async {
    final result = await researchPaperRepo.updatePaperStatus(doctorUid, paperId, VerificationStatus.approved);
    return result.fold(
      (error) => left(error),
      (_) {
        _sendStatusNotification(doctorUid: doctorUid, title: paperTitle, message: 'تمت الموافقة على بحثك', type: NotificationType.researchStatusUpdated, relatedId: paperId);
        return right(unit);
      },
    );
  }

  @override
  Future<Either<String, Unit>> rejectResearch(String doctorUid, String paperId, String paperTitle, String reason) async {
    final result = await researchPaperRepo.updatePaperStatus(doctorUid, paperId, VerificationStatus.rejected, rejectionReason: reason);
    return result.fold(
      (error) => left(error),
      (_) {
        _sendStatusNotification(doctorUid: doctorUid, title: paperTitle, message: 'تم رفض بحثك، السبب: $reason', type: NotificationType.researchStatusUpdated, relatedId: paperId);
        return right(unit);
      },
    );
  }

  // ====== المؤتمرات ======
  @override
  Future<Either<String, Unit>> approveConference(String doctorUid, String confId, String confTitle) async {
    return _updateSubListItemStatus(
      doctorUid: doctorUid, itemId: confId, title: confTitle, listPath: 'conferences', isApproved: true, type: NotificationType.activityStatusUpdated,
    );
  }

  @override
  Future<Either<String, Unit>> rejectConference(String doctorUid, String confId, String confTitle, String reason) async {
    return _updateSubListItemStatus(
      doctorUid: doctorUid, itemId: confId, title: confTitle, listPath: 'conferences', isApproved: false, reason: reason, type: NotificationType.activityStatusUpdated,
    );
  }

  // ====== المعارض ======
  @override
  Future<Either<String, Unit>> approveExhibition(String doctorUid, String exhId, String exhTitle) async {
    return _updateSubListItemStatus(
      doctorUid: doctorUid, itemId: exhId, title: exhTitle, listPath: 'exhibitions', isApproved: true, type: NotificationType.activityStatusUpdated,
    );
  }

  @override
  Future<Either<String, Unit>> rejectExhibition(String doctorUid, String exhId, String exhTitle, String reason) async {
    return _updateSubListItemStatus(
      doctorUid: doctorUid, itemId: exhId, title: exhTitle, listPath: 'exhibitions', isApproved: false, reason: reason, type: NotificationType.activityStatusUpdated,
    );
  }

  // ====== الدورات ======
  @override
  Future<Either<String, Unit>> approveCourse(String doctorUid, String courseId, String courseTitle) async {
    return _updateSubListItemStatus(
      doctorUid: doctorUid, itemId: courseId, title: courseTitle, listPath: 'courses', isApproved: true, type: NotificationType.activityStatusUpdated,
    );
  }

  @override
  Future<Either<String, Unit>> rejectCourse(String doctorUid, String courseId, String courseTitle, String reason) async {
    return _updateSubListItemStatus(
      doctorUid: doctorUid, itemId: courseId, title: courseTitle, listPath: 'courses', isApproved: false, reason: reason, type: NotificationType.activityStatusUpdated,
    );
  }

  // ====== الأنشطة الأكاديمية (الـ 20 درجة) ======
  @override
  Future<Either<String, Unit>> updateActivityCriterionStatus({
    required String doctorUid,
    required String criterionKey,
    required bool isApproved,
    String? adminNote,
  }) async {
    try {
      final docRef = firebaseFirestore.collection('users').doc(doctorUid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return left("المستخدم غير موجود");

      final data = docSnap.data() as Map<String, dynamic>;
      final scientificWork = data['scientific_work'] as Map<String, dynamic>? ?? {};
      final activities = scientificWork['academic_activities'] as Map<String, dynamic>? ?? {};

      // تحديث الـ 3 محاور
      for (var axis in ['teachingCriteria', 'researchCriteria', 'communityCriteria']) {
        final list = activities[axis] as List<dynamic>? ?? [];
        for (int i = 0; i < list.length; i++) {
          if (list[i]['key'] == criterionKey) {
            list[i]['proofStatus'] = isApproved ? 'approved' : 'rejected';
            if (adminNote != null) list[i]['adminNote'] = adminNote;
            break;
          }
        }
        activities[axis] = list;
      }

      await docRef.update({'scientific_work.academic_activities': activities});
      return right(unit);
    } catch (e) {
      return left("فشل تحديث النشاط: ${e.toString()}");
    }
  }

  // ====== دالة مساعدة لتحديث الـ Arrays (مؤتمرات/معارض/دورات) ======
  Future<Either<String, Unit>> _updateSubListItemStatus({
    required String doctorUid,
    required String itemId,
    required String title,
    required String listPath, // 'conferences', 'exhibitions', 'courses'
    required bool isApproved,
    String? reason,
    required NotificationType type,
  }) async {
    try {
      final docRef = firebaseFirestore.collection('users').doc(doctorUid);
      final docSnap = await docRef.get();
      if (!docSnap.exists) return left("المستخدم غير موجود");

      final data = docSnap.data() as Map<String, dynamic>;
      final scientificWork = data['scientific_work'] as Map<String, dynamic>? ?? {};
      final list = scientificWork[listPath] as List<dynamic>? ?? [];

      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'] == itemId) {
          list[i]['status'] = isApproved ? VerificationStatus.approved.name : VerificationStatus.rejected.name;
          if (reason != null) {
            list[i]['rejectionReason'] = reason;
          } else {
            list[i].remove('rejectionReason');
          }
          break;
        }
      }

      await docRef.update({'scientific_work.$listPath': list});
      
      _sendStatusNotification(
        doctorUid: doctorUid,
        title: title,
        message: isApproved ? 'تمت الموافقة على نشاطك' : 'تم رفض نشاطك، السبب: $reason',
        type: type,
        relatedId: itemId,
      );
      
      return right(unit);
    } catch (e) {
      return left("فشل التحديث: ${e.toString()}");
    }
  }

  void _sendStatusNotification({
    required String doctorUid,
    required String title,
    required String message,
    required NotificationType type,
    required String relatedId,
  }) {
    notificationRepo.sendNotification(
      AppNotificationModel(
        id: '',
        title: 'تحديث حالة الطلب',
        message: '$message: $title',
        type: type,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        relatedId: relatedId,
        receiverId: doctorUid,
      ),
    );
  }
}