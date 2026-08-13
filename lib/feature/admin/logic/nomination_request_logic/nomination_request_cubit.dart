import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:optialeader/feature/admin/data/repo/nomination_request/nomonation_request_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';
import 'package:optialeader/feature/admin/data/model/nomination_score_model.dart';
import 'package:optialeader/feature/admin/logic/nomination_request_logic/nomonation_request_state.dart';
import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';
import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_scoring_engine.dart';
import 'package:optialeader/feature/judge/data/model/interview_scoring_model.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';
import 'package:intl/intl.dart';

class NominationRequestCubit extends Cubit<NominationRequestState> {
  final NominationRequestRepository _repository;
  final NotificationRepo _notificationRepo;

  NominationRequestCubit(this._repository, this._notificationRepo)
      : super(NominationRequestInitial());

  void fetchAdminRequests({required String status}) {
    emit(NominationRequestLoading());
    _repository.getAdminRequests(status: status).listen(
          (requests) => emit(NominationRequestLoaded(requests)),
          onError: (e) => emit(NominationRequestError("error_fetch_requests")),
        );
  }

  void fetchEvaluatorRequests(String evaluatorId) {
    emit(NominationRequestLoading());
    _repository.getEvaluatorRequests(evaluatorId).listen(
          (requests) => emit(NominationRequestLoaded(requests)),
          onError: (e) =>
              emit(NominationRequestError("error_fetch_evaluator_requests")),
        );
  }

  Future<void> submitNominationRequest({
    required AnnouncementModel announcement,
    required DoctorProfileModel doctor,
    String? filePath,
  }) async {
    final doctorId = doctor.uid;
    final doctorName = doctor.nameAr;
    final doctorImageUrl = doctor.profileImage;

    if (doctorId == null || doctorId.isEmpty) {
      emit(NominationRequestError("error_invalid_doctor"));
      return;
    }

    final existingRequestSnapshot = await FirebaseFirestore.instance
        .collection('nomination_requests')
        .where('doctorId', isEqualTo: doctorId)
        .where('announcementId', isEqualTo: announcement.id!)
        .where('status', whereIn: [
          NominationRequestModel.statusPendingAdmin,
          NominationRequestModel.statusPendingEvaluator
        ])
        .limit(1)
        .get();

    if (existingRequestSnapshot.docs.isNotEmpty) {
      emit(NominationRequestError("nomination.error_duplicate_request"));
      return;
    }

    emit(NominationRequestLoading());
    try {
      String? fileUrl;
      if (filePath != null) {
        final uploadResult = await _repository.uploadDeclarationFile(filePath);
        if (uploadResult.isLeft()) {
          emit(NominationRequestError("error_upload_declaration"));
          return;
        }
        fileUrl = uploadResult.getOrElse(() => '');
      }

      final NominationScoreModel scores =
          LeadershipScoringEngine.buildScoreModel(doctor);

      final request = NominationRequestModel(
        doctorId: doctorId,
        doctorName: doctorName,
        doctorImageUrl: doctorImageUrl.isEmpty ? null : doctorImageUrl,
        announcementId: announcement.id!,
        targetRole: announcement.targetRole,
        collegeId: announcement.collegeId,
        collegeName: doctor.facultyAr,
        departmentId: announcement.departmentId,
        departmentName: doctor.departmentAr,
        scores: scores,
        declarationFileUrl: fileUrl,
        status: NominationRequestModel.statusPendingAdmin,
        createdAt: DateTime.now(),
      );

      final result = await _repository.submitRequest(request);
      result.fold(
        (error) => emit(NominationRequestError("error_submit_request")),
        (generatedId) {
          emit(NominationRequestActionSuccess("success_submit_request"));
          _sendNewRequestNotification(
            request.copyWith(id: generatedId),
            announcement.title,
          );
        },
      );
    } catch (e) {
      emit(NominationRequestError("error_unexpected"));
    }
  }

  Future<void> adminTakeAction({
    required NominationRequestModel request,
    required String newStatus,
    String? rejectionReason,
    String? evaluatorId,
    String? evaluatorName,
  }) async {
    final updatedRequest = request.copyWith(
      status: newStatus,
      rejectionReason: rejectionReason,
      evaluatorId: evaluatorId,
      evaluatorName: evaluatorName,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateRequest(updatedRequest);
    result.fold(
      (error) => emit(NominationRequestError("error_update_request")),
      (_) {
        emit(NominationRequestActionSuccess("success_action_taken"));

        if (newStatus == NominationRequestModel.statusPendingEvaluator) {
          _sendToEvaluatorNotification(updatedRequest);
        } else if (newStatus ==
            NominationRequestModel.statusRejectedByAdmin) {
          _sendStatusUpdateToDoctor(updatedRequest, isAccepted: false);
        } else if (newStatus ==
            NominationRequestModel.statusFinalApprovedPendingAnnouncement) {
          _sendEvaluationDoneToAdmin(updatedRequest);
        } else if (newStatus == NominationRequestModel.statusFinalApproved) {
          _sendStatusUpdateToDoctor(updatedRequest, isAccepted: true);
        } else if (newStatus == NominationRequestModel.statusFinalRejected) {
          _sendStatusUpdateToDoctor(updatedRequest, isAccepted: false);
        }
      },
    );
  }

  Future<void> scheduleInterview({
    required NominationRequestModel request,
    required DateTime interviewDate,
    required String location,
    required String time,
  }) async {
    emit(NominationRequestLoading());

    final updatedRequest = request.copyWith(
      interviewDate: interviewDate,
      interviewLocation: location,
      interviewTime: time,
      updatedAt: DateTime.now(),
    );

    final result = await _repository.updateRequest(updatedRequest);
    result.fold(
      (error) => emit(NominationRequestError("error_schedule_interview")),
      (_) {
        emit(NominationRequestActionSuccess("success_interview_scheduled"));
        _sendInterviewScheduledNotification(updatedRequest);
      },
    );
  }

  Future<void> fetchEvaluators() async {
    emit(EvaluatorsLoading());
    final result = await _repository.getEvaluators();
    result.fold(
      (failure) => emit(EvaluatorsError(failure)),
      (evaluators) => emit(EvaluatorsLoaded(evaluators)),
    );
  }

  Future<void> submitInterviewEvaluation({
    required NominationRequestModel request,
    required InterviewScoringModel evaluationModel,
  }) async {
    emit(NominationRequestLoading());

    try {
      final newStatus = evaluationModel.isDraft
          ? NominationRequestModel.statusPendingEvaluator
          : NominationRequestModel.statusEvaluated;

      final updatedScores = LeadershipScoringEngine.addInterviewScore(
        request.scores ?? NominationScoreModel(),
        evaluationModel,
      );

      final updatedRequest = request.copyWith(
        status: newStatus,
        scores: updatedScores,
        interviewDate: evaluationModel.interviewDate,
        evaluatorPoints: evaluationModel.totalScore,
        evaluatorNotes: evaluationModel.combinedNotes,
        interviewEvaluation: evaluationModel.toMap(),
        updatedAt: DateTime.now(),
      );

      final result = await _repository.updateRequest(updatedRequest);

      result.fold(
        (error) => emit(NominationRequestError('error_evaluation_submit')),
        (_) async { // ✅ مهم جداً نضيف async هنا
          emit(NominationRequestActionSuccess('success_evaluation_submitted'));
          if (!evaluationModel.isDraft) {
            _sendEvaluationDoneToAdmin(updatedRequest);
            
            // ✅✅✅ هنا الاستدعاء اللي كان ناقص
            await _checkAndNotifyIfAllEvaluated(updatedRequest);
          }
        },
      );
    } catch (e) {
      emit(NominationRequestError(e.toString()));
    }
  }
  // ================================================================
  // 🏆 دالة إعلان النتيجة النهائية
  // ================================================================
  Future<void> announceCompetitionResults({
    required String announcementId,
    required String announcementTitle,
  }) async {
    emit(NominationRequestLoading());

    try {
      // 1. جلب الطلبات المُقيّمة
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('nomination_requests')
          .where('announcementId', isEqualTo: announcementId)
          .where('status', whereIn: [
            NominationRequestModel.statusEvaluated,
            NominationRequestModel.statusFinalApproved,
          ])
          .get();

      final allRequests = requestsSnapshot.docs
          .map((doc) =>
              NominationRequestModel.fromMap(doc.data(), doc.id))
          .toList();

      if (allRequests.isEmpty) {
        emit(NominationRequestError(
            "لا يوجد طلبات مُقيّمة في هذه المسابقة"));
        return;
      }

      // 2. ترتيب تنازلي حسب المجموع
      allRequests.sort((a, b) {
        final totalA =
            (a.scores?.achievementsTotal ?? 0) + (a.evaluatorPoints ?? 0);
        final totalB =
            (b.scores?.achievementsTotal ?? 0) + (b.evaluatorPoints ?? 0);
        return totalB.compareTo(totalA);
      });

      // 3. تحديد أول 3
      final topThree = allRequests.take(3).toList();
      final topThreeIds = topThree.map((e) => e.id).toSet();
      final topThreeNames = topThree.map((e) => e.doctorName).toList();

      // 4. تحديث حالة جميع الطلبات (Batch Write)
      final statusBatch = FirebaseFirestore.instance.batch();
      for (final req in allRequests) {
        final newStatus = topThreeIds.contains(req.id)
            ? NominationRequestModel.statusFinalApproved
            : NominationRequestModel.statusFinalRejected;

        statusBatch.update(
          FirebaseFirestore.instance
              .collection('nomination_requests')
              .doc(req.id),
          {
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
      await statusBatch.commit();

      // 5. تحديث بيانات الإعلان
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .update({
        'winners': topThree
            .map((e) => {
                  'doctorName': e.doctorName,
                  'doctorId': e.doctorId,
                  'doctorImageUrl': e.doctorImageUrl,
                  'totalScore':
                      (e.scores?.achievementsTotal ?? 0) + (e.evaluatorPoints ?? 0),
                  'rank': topThreeIds.toList().indexOf(e.id) + 1,
                })
            .toList(),
        'isResultAnnounced': true,
        'resultsAnnouncedAt': FieldValue.serverTimestamp(),
        'allResultsSorted': allRequests
            .map((e) => {
                  'doctorName': e.doctorName,
                  'doctorId': e.doctorId,
                  'totalScore':
                      (e.scores?.achievementsTotal ?? 0) + (e.evaluatorPoints ?? 0),
                  'isWinner': topThreeIds.contains(e.id),
                })
            .toList(),
      });

      // 6. إنشاء إشعارات لكل مشارك
      final doctorIds = allRequests.map((e) => e.doctorId).toList();
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: doctorIds)
          .get();

      final userPlayerIds = <String, String?>{};
      for (final doc in usersSnapshot.docs) {
        userPlayerIds[doc.id] = doc.data()['onesignalPlayerId'];
      }

      final notifBatch = FirebaseFirestore.instance.batch();
      final notifCollection =
          FirebaseFirestore.instance.collection('notifications');

      for (final req in allRequests) {
        final isWinner = topThreeIds.contains(req.id);
        final rank = isWinner
            ? topThreeIds.toList().indexOf(req.id) + 1
            : 0;

        final bodyMessage = isWinner
            ? '🎉 مبروك! حصلت على المركز $rank في مسابقة "$announcementTitle". اضغط لمشاهدة النتائج.'
            : 'نأسف، لم تكن من الفائزين في مسابقة "$announcementTitle". لا تيأس، فرص قادمة بانتظارك!';

        final notifRef = notifCollection.doc();
        notifBatch.set(notifRef, {
          'title': '🏆 إعلان نتيجة المسابقة',
          'message': bodyMessage,
          'type': 'competitionResult',
          'target': 'specificUser',
          'timestamp': FieldValue.serverTimestamp(),
          'receiverId': req.doctorId,
          'relatedId': announcementId,
          'isRead': false,
          'data': {
            'screen': 'competition_results',
            'announcementId': announcementId,
            'isWinner': isWinner,
            'rank': rank,
            'topThreeNames': topThreeNames,
          },
        });
      }
      await notifBatch.commit();

      // 7. إرسال الإشعارات الفورية (OneSignal)
      await _sendResultsViaEdgeFunction(
        announcementId: announcementId,
        announcementTitle: announcementTitle,
        participants: allRequests
            .map((req) {
              return {
                'doctorId': req.doctorId,
                'doctorName': req.doctorName,
                'onesignalPlayerId': userPlayerIds[req.doctorId],
                'isWinner': topThreeIds.contains(req.id),
                'rank': topThreeIds.contains(req.id)
                    ? topThreeIds.toList().indexOf(req.id) + 1
                    : 0,
              };
            })
            .toList(),
        topThreeNames: topThreeNames,
      );

      emit(NominationRequestActionSuccess(
          "تم إعلان النتيجة وإرسال الإشعارات بنجاح"));
    } catch (e) {
      emit(NominationRequestError("فشل إعلان النتيجة: ${e.toString()}"));
    }
  }

  // ================================================================
  // 📡 استدعاء Supabase Edge Function
  // ================================================================
  Future<void> _sendResultsViaEdgeFunction({
    required String announcementId,
    required String announcementTitle,
    required List<Map<String, dynamic>> participants,
    required List<String> topThreeNames,
  }) async {
    try {
      final validParticipants = participants
          .where((p) => p['onesignalPlayerId'] != null)
          .toList();

      if (validParticipants.isEmpty) {
        print('⚠️ لا يوجد OneSignal Player IDs صالحة للإرسال');
        return;
      }

      final response = await Supabase.instance.client.functions.invoke(
        'super-action',
        body: {
          'announcementId': announcementId,
          'announcementTitle': announcementTitle,
          'participants': validParticipants,
          'topThreeNames': topThreeNames,
        },
      );

      if (response.status != 200) {
        print('⚠️ Edge Function أرجع كود: ${response.status}');
      } else {
        print('✅ تم إرسال الإشعارات بنجاح عبر Edge Function');
      }
    } catch (e) {
      print('⚠️ فشل استدعاء Edge Function: $e');
    }
  }

  // ====== الإشعارات ======
  Future _sendNewRequestNotification(
    NominationRequestModel request,
    String announcementTitle,
  ) async {
    print("🔴🔴🔥 1. جاري إرسال إشعار طلب ترشح جديد للأدمن");
    try {
      final notification = AppNotificationModel(
        id: '',
        title: 'طلب ترشح جديد',
        message: 'قدم د/ ${request.doctorName} على مسابقة "$announcementTitle"',
        type: NotificationType.newDoctorRequest,
        target: NotificationTarget.adminOnly,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: request.id,
      );
      
      print("🔴🔴🔥 2. بيانات الإشعار: ${notification.toMap()}");
      final result = await _notificationRepo.sendRoleBasedNotification(notification);
      
      // ✅ طباعة نتيجة الـ Either عشان نشوف لو فيه خطأ مخفي
      result.fold(
        (error) => print("🔴🔴🔥 3. فشل إرسال الإشعار للأدمن: $error"),
        (_) => print("🔴🔴🔥 3. تم إرسال الإشعار للأدمن بنجاح"),
      );
      
    } catch (e, stack) {
      print("🔴🔴🔥 ERROR في دالة الإشعار: $e");
      print("🔴🔴🔥 STACK: $stack");
    }
  }
  Future<void> _sendToEvaluatorNotification(
      NominationRequestModel request) async {
    try {
      if (request.evaluatorId == null || request.evaluatorId!.isEmpty) return;
      final notification = AppNotificationModel(
        id: '',
        title: 'طلب تقييم جديد',
        message:
            'تم تحويل طلب د/ ${request.doctorName} إليك للتقييم',
        type: NotificationType.newArbitrationRequest,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.evaluatorId!,
        relatedId: request.id,
      );
      await _notificationRepo.sendNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار للمحكم: $e");
    }
  }

  Future<void> _sendStatusUpdateToDoctor(
      NominationRequestModel request, {required bool isAccepted}) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: isAccepted ? 'قبول الطلب' : 'رفض الطلب',
        message: isAccepted
            ? 'تمت الموافقة النهائية على طلب ترشحك'
            : 'تم رفض طلب ترشحك. السبب: ${request.rejectionReason ?? "غير محدد"}',
        type: NotificationType.requestStatusUpdate,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.doctorId,
        relatedId: request.id,
      );
      await _notificationRepo.sendNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار للدكتور: $e");
    }
  }

  Future<void> _sendEvaluationDoneToAdmin(
      NominationRequestModel request) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: 'تم إنهاء التقييم',
        message:
            'قام المحكم بتقييم طلب د/ ${request.doctorName} وإعادته لك',
        type: NotificationType.judgeRequestCompleted,
        target: NotificationTarget.adminOnly,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: request.id,
      );
      await _notificationRepo.sendRoleBasedNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار للإدمن: $e");
    }
  }

  Future<void> _sendInterviewScheduledNotification(
      NominationRequestModel request) async {
    try {
      if (request.interviewDate == null) return;
      final dateStr =
          DateFormat('yyyy-MM-dd').format(request.interviewDate!);
      final notification = AppNotificationModel(
        id: '',
        title: 'تحديد موعد مقابلة',
        message:
            'تم تحديد مقابلتك بتاريخ $dateStr الساعة ${request.interviewTime ?? "-"} بمكان: ${request.interviewLocation ?? "-"}',
        type: NotificationType.requestStatusUpdate,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.doctorId,
        relatedId: request.id,
      );
      await _notificationRepo.sendNotification(notification);
    } catch (e) {
      print("فشل إرسال إشعار الموعد: $e");
    }
  }

  // ✅ دالة فحص اكتمال تقييمات المسابقة وإرسال إشعار للأدمن
  Future<void> _checkAndNotifyIfAllEvaluated(NominationRequestModel evaluatedRequest) async {
    try {
      // 1. نبحث هل في طلبات تابعة لنفس المسابقة لسه حالةين Pending (معلقة)
      final snapshot = await FirebaseFirestore.instance
          .collection('nomination_requests')
          .where('announcementId', isEqualTo: evaluatedRequest.announcementId)
          .where('status', isEqualTo: NominationRequestModel.statusPendingEvaluator)
          .limit(1)
          .get();

      // 2. لو مفيش نتائج، يبقى الكل اتقيم
      if (snapshot.docs.isEmpty) {
        // نجيب عنوان المسابقة عشان نعرضه في الإشعار
        final announcementDoc = await FirebaseFirestore.instance
            .collection('announcements')
            .doc(evaluatedRequest.announcementId)
            .get();
        
        final announcementTitle = announcementDoc.exists ? (announcementDoc.data()?['title'] ?? '') : '';
        
        final notification = AppNotificationModel(
          id: '',
          title: '🏆 اكتملت تقييمات المسابقة',
          message: 'تم تقييم جميع المرشحين في مسابقة "$announcementTitle". يرجى مراجعة النتائج والإعلان عنها.',
          type: NotificationType.judgeRequestCompleted,
          target: NotificationTarget.adminOnly,
          timestamp: Timestamp.now(),
          receiverId: '',
          // ✅ هنا بنحط ID المسابقة عشان نستخدمه في الواجهة لما ندوس على الإشعار
          relatedId: evaluatedRequest.announcementId, 
        );
        
        await _notificationRepo.sendRoleBasedNotification(notification);
        print("✅ تم إرسال إشعار اكتمال تقييمات المسابقة للأدمن");
      }
    } catch (e) {
      print("⚠️ خطأ في فحص اكتمال التقييمات: $e");
    }
  }

}