import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/repo/employee/employee_nomination_admin_repo%20.dart';
import 'package:optialeader/feature/admin/logic/employee/employee_nomination_admin_state%20.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';
class EmployeeNominationAdminCubit
    extends Cubit<EmployeeNominationAdminState> {
  final EmployeeNominationAdminRepo repo;
  final NotificationRepo notificationRepo; // ✅ إضافة الـ NotificationRepo

  // ✅ تحديث الكونستركتور ليقبل الريبو الجديد
  EmployeeNominationAdminCubit({
    required this.repo,
    required this.notificationRepo,
  }) : super(EmployeeNominationAdminInitial());

  // ============================================================
  // GET PENDING REQUESTS
  // ============================================================

  Future<void> getPendingRequests() async {
    emit(EmployeeNominationAdminLoading());

    try {
      final requests = await repo.getPendingRequests();

      emit(
        EmployeeNominationAdminLoaded(
          requests: requests,
        ),
      );
    } catch (e) {
      emit(
        EmployeeNominationAdminError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // APPROVE REQUEST & SEND TO EVALUATOR
  // ============================================================

  Future<void> approveAndSendToEvaluator({
    required String requestId,
    required String evaluatorId,
    required String evaluatorName,
    required String employeeName, // ✅ إضافة لتخصيص رسالة الإشعار
    required String targetRole,   // ✅ إضافة لتخصيص رسالة الإشعار
    required String employeeId,   // ✅ إضافة لإرسال إشعار للموظف
  }) async {
    emit(EmployeeNominationAdminActionLoading());

    try {
      await repo.approveAndSendToEvaluator(
        requestId: requestId,
        evaluatorId: evaluatorId,
        evaluatorName: evaluatorName,
      );

      // ✅ 1. إرسال إشعار للمحكم بتكليفه بالطلب
      await notificationRepo.sendNotification(
        AppNotificationModel(
          id: '',
          title: 'طلب تقييم جديد',
          message: 'تم تخصيصك كمحكم لتقييم الموظف $employeeName لوظيفة $targetRole',
          receiverId: evaluatorId,
          target: NotificationTarget.specificUser,
          type: NotificationType.activityStatusUpdated,
          timestamp: Timestamp.now(),
        ),
      );

      // ✅ 2. إرسال إشعار للموظف بتحويل طلبه للمحكم
      await notificationRepo.sendNotification(
        AppNotificationModel(
          id: '',
          title: 'تم تحويل طلبك للمحكم',
          message: 'تم تحويل طلب ترشحك على وظيفة $targetRole للمحكم $evaluatorName لبدء تقييم المقابلة',
          receiverId: employeeId,
          target: NotificationTarget.specificUser,
          type: NotificationType.activityStatusUpdated,
          timestamp: Timestamp.now(),
        ),
      );

      emit(
        EmployeeNominationAdminActionSuccess(),
      );

      // تحديث قائمة الطلبات بعد نجاح العملية
      await getPendingRequests();
    } catch (e) {
      emit(
        EmployeeNominationAdminError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // REJECT REQUEST
  // ============================================================

  Future<void> rejectRequest({
    required String requestId,
    required String reason,
    required String employeeId,   // ✅ إضافة لإرسال إشعار للموظف
    required String targetRole,   // ✅ إضافة لتخصيص رسالة الإشعار
  }) async {
    emit(EmployeeNominationAdminActionLoading());

    try {
      await repo.rejectRequest(
        requestId: requestId,
        reason: reason,
      );

      // ✅ إرسال إشعار للموظف برفض طلبه
      await notificationRepo.sendNotification(
        AppNotificationModel(
          id: '',
          title: 'تم رفض طلب الترشح',
          message: 'تم رفض طلب ترشحك على وظيفة $targetRole. السبب: $reason',
          receiverId: employeeId,
          target: NotificationTarget.specificUser,
          type: NotificationType.activityStatusUpdated,
          timestamp: Timestamp.now(),
        ),
      );

      emit(
        EmployeeNominationAdminActionSuccess(),
      );

      // تحديث القائمة بعد الرفض
      await getPendingRequests();
    } catch (e) {
      emit(
        EmployeeNominationAdminError(
          message: e.toString(),
        ),
      );
    }
  }

  // ============================================================
  // ANNOUNCE COMPETITION RESULTS (للأدمن لإعلان النتائج)
  // ============================================================

   Future<void> announceCompetitionResults({
    required String announcementId,
    required String announcementTitle,
  }) async {
    emit(EmployeeNominationAdminActionLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('employee_nomination_requests')
          .where('announcementId', isEqualTo: announcementId)
          .where('status', whereIn: ['evaluated', 'final_approved'])
          .get();

      if (snapshot.docs.isEmpty) {
        emit( EmployeeNominationAdminError(message: 'لا يوجد نتائج للإعلان عنها'));
        return;
      }

      List<Map<String, dynamic>> allResults = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        double interviewPoints = (data['evaluatorPoints'] as num?)?.toDouble() ?? 0.0;
        if (interviewPoints == 0.0 && data['interviewEvaluation'] != null) {
          final interviewData = data['interviewEvaluation'] as Map<String, dynamic>;
          interviewPoints = (interviewData['totalScore'] as num?)?.toDouble() ?? 0.0;
        }

        allResults.add({
          'employeeId': data['employeeId'],
          'employeeName': data['employeeName'] ?? '',
          'employeeImageUrl': data['employeeImageUrl'],
          'totalScore': interviewPoints,
        });
      }

      allResults.sort((a, b) => (b['totalScore'] as double).compareTo(a['totalScore'] as double));

      List<Map<String, dynamic>> winners = [];
      int topCount = allResults.length > 3 ? 3 : allResults.length;
      
      // ✅ تجهيز قائمة بأسماء الفائزين الثلاثة
      String winnersNames = '';
      for (int i = 0; i < topCount; i++) {
        winners.add({
          ...allResults[i],
          'rank': i + 1,
          'isWinner': true,
        });
        winnersNames += 'المركز ${i + 1}: ${allResults[i]['employeeName']}';
        if (i < topCount - 1) winnersNames += '\n';
      }

      for (int i = 0; i < allResults.length; i++) {
         allResults[i]['isWinner'] = i < topCount;
      }

      await FirebaseFirestore.instance.collection('announcements').doc(announcementId).update({
        'isResultAnnounced': true,
        'winners': winners,
        'allResultsSorted': allResults,
      });

      // ✅ إرسال إشعار لكل الموظفين المشاركين (باسماء الفائزين)
      for (var participant in allResults) {
        await notificationRepo.sendNotification(
          AppNotificationModel(
            id: '',
            title: 'تم الإعلان عن نتائج المسابقة',
            message: 'تم الإعلان عن نتائج مسابقة "$announcementTitle"\n$winnersNames',
            receiverId: participant['employeeId'],
            target: NotificationTarget.specificUser,
            type: NotificationType.activityStatusUpdated,
            timestamp: Timestamp.now(),
          ),
        );
      }

      emit( EmployeeNominationAdminActionSuccess(message: 'تم الإعلان عن النتائج بنجاح'));
    } catch (e) {
      emit(EmployeeNominationAdminError(message: 'فشل الإعلان عن النتائج: ${e.toString()}'));
    }
  }
    // ============================================================
  // إعطاء القرار النهائي (موافقة/رفض بعد التقييم)
  // ============================================================
  Future<void> giveFinalDecision({
    required String requestId,
    required bool isApproved,
    String? rejectionReason,
  }) async {
    emit(EmployeeNominationAdminActionLoading());
    try {
      final newStatus = isApproved 
          ? EmployeeNominationRequestModel.statusFinalApproved 
          : EmployeeNominationRequestModel.statusFinalRejected;

      await FirebaseFirestore.instance
          .collection('employee_nomination_requests') // تأكد من اسم الكولكشن
          .doc(requestId)
          .update({
        'status': newStatus,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
        'updatedAt': DateTime.now(),
      });

      emit( EmployeeNominationAdminActionSuccess());
    } catch (e) {
      emit(EmployeeNominationAdminError(message: e.toString()));
    }
  }
}