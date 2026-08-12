import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:optialeader/feature/admin/data/model/announcement_model.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model .dart';
import 'package:optialeader/feature/employee/data/repo/NominationRequestRepository/employee_nomination_repo.dart';
import 'package:optialeader/feature/employee/logic/EmployeenNominationCubit/employee_nomination_state.dart';
import 'package:optialeader/feature/notification/data/model/app_notification_model.dart';
import 'package:optialeader/feature/notification/data/repo/notification_repo.dart';

class EmployeeNominationCubit
    extends Cubit<EmployeeNominationState> {

  final EmployeeNominationRepository _repository;
  final NotificationRepo _notificationRepo;

  EmployeeNominationCubit(
    this._repository,
    this._notificationRepo,
  ) : super(EmployeeNominationInitial());
  // ============================================================
  // جلب طلبات الموظفين عند الأدمن
  // ============================================================

  void fetchAdminRequests({
    required String status,
  }) {
    emit(EmployeeNominationLoading());

    _repository
        .getAdminRequests(status: status)
        .listen(
      (requests) {
        emit(EmployeeNominationLoaded(requests));
      },
      onError: (e) {
        emit(
          EmployeeNominationError(
            'error_fetch_employee_requests',
          ),
        );
      },
    );
  }

  // ============================================================
  // جلب طلبات الموظفين عند المحكم
  // ============================================================

  void fetchEvaluatorRequests(
    String evaluatorId,
  ) {
    emit(EmployeeNominationLoading());

    _repository
        .getEvaluatorRequests(evaluatorId)
        .listen(
      (requests) {
        emit(EmployeeNominationLoaded(requests));
      },
      onError: (e) {
        emit(
          EmployeeNominationError(
            'error_fetch_employee_evaluator_requests',
          ),
        );
      },
    );
  }

  // ============================================================
  // إرسال طلب ترشح الموظف
  // ============================================================

  Future<void> submitNominationRequest({
    required AnnouncementModel announcement,
    required String employeeId,
    required String employeeName,
    String? employeeImageUrl,
    String? currentJob,
    String? sectorName,
    String? departmentName,
    String? visionStatement,
  }) async {
    emit(EmployeeNominationLoading());

    try {
      // ----------------------------------------------------------
      // منع الموظف من التقديم أكثر من مرة على نفس الإعلان
      // ----------------------------------------------------------

      final existingRequest = await FirebaseFirestore.instance
          .collection('nomination_requests')
          .where(
            'applicantType',
            isEqualTo: 'employee',
          )
          .where(
            'employeeId',
            isEqualTo: employeeId,
          )
          .where(
            'announcementId',
            isEqualTo: announcement.id,
          )
          .where(
            'status',
            whereIn: [
              EmployeeNominationRequestModel.statusPendingAdmin,
              EmployeeNominationRequestModel.statusPendingEvaluator,
              EmployeeNominationRequestModel.statusEvaluated,
            ],
          )
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        emit(
          EmployeeNominationError(
            'employee_nomination.error_duplicate_request',
          ),
        );
        return;
      }

      // ----------------------------------------------------------
      // إنشاء الطلب
      // ----------------------------------------------------------

      final request = EmployeeNominationRequestModel(
        employeeId: employeeId,
        employeeName: employeeName,
        employeeImageUrl: employeeImageUrl,
        currentJob: currentJob,
        sectorName: sectorName,
        departmentName: departmentName,

        announcementId: announcement.id ?? '',
        announcementTitle: announcement.title,
        targetRole: announcement.targetRole,

        visionStatement: visionStatement,

        applicantType: 'employee',

        status:
            EmployeeNominationRequestModel.statusPendingAdmin,

        createdAt: DateTime.now(),
      );

      // ----------------------------------------------------------
      // حفظ الطلب
      // ----------------------------------------------------------

      final result = await _repository.submitRequest(request);

      result.fold(
        (error) {
          emit(
            EmployeeNominationError(
              'error_submit_employee_nomination',
            ),
          );
        },
        (generatedId) {
          final savedRequest = request.copyWith(
            id: generatedId,
          );

          emit(
            EmployeeNominationActionSuccess(
              'employee_nomination.success',
            ),
          );

          // إشعار الأدمن
          _sendNewRequestNotification(
            savedRequest,
          );
        },
      );
    } catch (e) {
      emit(
        EmployeeNominationError(
          'error_unexpected',
        ),
      );
    }
  }

  // ============================================================
  // إجراء الأدمن
  // ============================================================

  Future<void> adminTakeAction({
    required EmployeeNominationRequestModel request,
    required String newStatus,
    String? rejectionReason,
    String? evaluatorId,
    String? evaluatorName,
    String? adminNotes,
  }) async {
    emit(EmployeeNominationLoading());

    try {
      final updatedRequest = request.copyWith(
        status: newStatus,
        rejectionReason: rejectionReason,
        evaluatorId: evaluatorId,
        evaluatorName: evaluatorName,
        adminNotes: adminNotes,
        updatedAt: DateTime.now(),
      );

      final result =
          await _repository.updateRequest(updatedRequest);

      result.fold(
        (error) {
          emit(
            EmployeeNominationError(
              'error_update_employee_request',
            ),
          );
        },
        (_) {
          emit(
            EmployeeNominationActionSuccess(
              'success_action_taken',
            ),
          );

          // تحويل للمحكم
          if (newStatus ==
              EmployeeNominationRequestModel
                  .statusPendingEvaluator) {
            _sendToEvaluatorNotification(
              updatedRequest,
            );
          }

          // رفض من الأدمن
          else if (newStatus ==
              EmployeeNominationRequestModel
                  .statusRejectedByAdmin) {
            _sendStatusUpdateToEmployee(
              updatedRequest,
              isAccepted: false,
            );
          }

          // تقييم انتهى
          else if (newStatus ==
              EmployeeNominationRequestModel.statusEvaluated) {
            _sendEvaluationDoneToAdmin(
              updatedRequest,
            );
          }

          // قبول نهائي
          else if (newStatus ==
              EmployeeNominationRequestModel.statusFinalApproved) {
            _sendStatusUpdateToEmployee(
              updatedRequest,
              isAccepted: true,
            );
          }

          // رفض نهائي
          else if (newStatus ==
              EmployeeNominationRequestModel.statusFinalRejected) {
            _sendStatusUpdateToEmployee(
              updatedRequest,
              isAccepted: false,
            );
          }
        },
      );
    } catch (e) {
      emit(
        EmployeeNominationError(
          'error_unexpected',
        ),
      );
    }
  }

  // ============================================================
  // تحديد موعد المقابلة
  // ============================================================

  Future<void> scheduleInterview({
    required EmployeeNominationRequestModel request,
    required DateTime interviewDate,
    required String location,
    required String time,
  }) async {
    emit(EmployeeNominationLoading());

    try {
      final updatedRequest = request.copyWith(
        interviewDate: interviewDate,
        interviewLocation: location,
        interviewTime: time,
        updatedAt: DateTime.now(),
      );

      final result =
          await _repository.updateRequest(updatedRequest);

      result.fold(
        (error) {
          emit(
            EmployeeNominationError(
              'error_schedule_interview',
            ),
          );
        },
        (_) {
          emit(
            EmployeeNominationActionSuccess(
              'success_interview_scheduled',
            ),
          );

          _sendInterviewScheduledNotification(
            updatedRequest,
          );
        },
      );
    } catch (e) {
      emit(
        EmployeeNominationError(
          'error_unexpected',
        ),
      );
    }
  }

  // ============================================================
  // جلب المحكمين
  // ============================================================

  Future<void> fetchEvaluators() async {
    emit(EmployeeEvaluatorsLoading());

    final result = await _repository.getEvaluators();

    result.fold(
      (failure) {
        emit(
          EmployeeEvaluatorsError(failure),
        );
      },
      (evaluators) {
        emit(
          EmployeeEvaluatorsLoaded(evaluators),
        );
      },
    );
  }

  // ============================================================
  // تقييم المحكم للموظف
  // ============================================================

  Future<void> submitEvaluation({
    required EmployeeNominationRequestModel request,
    required double points,
    String? notes,
    Map<String, dynamic>? evaluationData,
  }) async {
    emit(EmployeeNominationLoading());

    try {
      final updatedRequest = request.copyWith(
        status:
            EmployeeNominationRequestModel.statusEvaluated,
        evaluatorPoints: points,
        evaluatorNotes: notes,
        interviewEvaluation: evaluationData,
        updatedAt: DateTime.now(),
      );

      final result =
          await _repository.updateRequest(updatedRequest);

      result.fold(
        (error) {
          emit(
            EmployeeNominationError(
              'error_evaluation_submit',
            ),
          );
        },
        (_) async {
          emit(
            EmployeeNominationActionSuccess(
              'success_evaluation_submitted',
            ),
          );

          await _sendEvaluationDoneToAdmin(
            updatedRequest,
          );

          await _checkAndNotifyIfAllEvaluated(
            updatedRequest,
          );
        },
      );
    } catch (e) {
      emit(
        EmployeeNominationError(
          'error_evaluation_submit',
        ),
      );
    }
  }

  // ============================================================
  // إعلان النتائج
  // ============================================================

  Future<void> announceCompetitionResults({
    required String announcementId,
    required String announcementTitle,
  }) async {
    emit(EmployeeNominationLoading());

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('nomination_requests')
          .where(
            'applicantType',
            isEqualTo: 'employee',
          )
          .where(
            'announcementId',
            isEqualTo: announcementId,
          )
          .where(
            'status',
            isEqualTo:
                EmployeeNominationRequestModel.statusEvaluated,
          )
          .get();

      final requests = snapshot.docs
          .map(
            (doc) =>
                EmployeeNominationRequestModel.fromMap(
              doc.data(),
              doc.id,
            ),
          )
          .toList();

      if (requests.isEmpty) {
        emit(
          EmployeeNominationError(
            'لا توجد طلبات موظفين مُقيّمة',
          ),
        );
        return;
      }

      // ----------------------------------------------------------
      // ترتيب حسب درجة المحكم
      // ----------------------------------------------------------

      requests.sort(
        (a, b) => (b.evaluatorPoints ?? 0)
            .compareTo(a.evaluatorPoints ?? 0),
      );

      // ----------------------------------------------------------
      // أول 3 فائزين
      // ----------------------------------------------------------

      final topThree = requests.take(3).toList();

      final winnerIds =
          topThree.map((e) => e.id).toSet();

      // ----------------------------------------------------------
      // Batch تحديث الحالات
      // ----------------------------------------------------------

      final batch =
          FirebaseFirestore.instance.batch();

      for (final request in requests) {
        final newStatus = winnerIds.contains(request.id)
            ? EmployeeNominationRequestModel
                .statusFinalApproved
            : EmployeeNominationRequestModel
                .statusFinalRejected;

        batch.update(
          FirebaseFirestore.instance
              .collection('nomination_requests')
              .doc(request.id),
          {
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();

      // ----------------------------------------------------------
      // تحديث الإعلان
      // ----------------------------------------------------------

      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .update({
        'employeeWinners': topThree
            .asMap()
            .entries
            .map(
              (entry) {
                final index = entry.key;
                final request = entry.value;

                return {
                  'employeeId': request.employeeId,
                  'employeeName': request.employeeName,
                  'employeeImageUrl':
                      request.employeeImageUrl,
                  'totalScore':
                      request.evaluatorPoints ?? 0,
                  'rank': index + 1,
                };
              },
            )
            .toList(),
        'employeeResultsAnnounced': true,
        'employeeResultsAnnouncedAt':
            FieldValue.serverTimestamp(),
      });

      // ----------------------------------------------------------
      // إرسال إشعار لكل موظف
      // ----------------------------------------------------------

      final notificationBatch =
          FirebaseFirestore.instance.batch();

      final notificationCollection =
          FirebaseFirestore.instance.collection(
        'notifications',
      );

      for (final request in requests) {
        final isWinner =
            winnerIds.contains(request.id);

        final rank = isWinner
            ? topThree
                    .indexWhere(
                      (e) => e.id == request.id,
                    ) +
                1
            : 0;

        final message = isWinner
            ? '🎉 مبروك! حصلت على المركز $rank في مسابقة "$announcementTitle".'
            : 'نأسف، لم تكن من الفائزين في مسابقة "$announcementTitle".';

        final ref =
            notificationCollection.doc();

        notificationBatch.set(
          ref,
          {
            'title': '🏆 إعلان نتيجة المسابقة',
            'message': message,
            'type': 'competitionResult',
            'target': 'specificUser',
            'timestamp':
                FieldValue.serverTimestamp(),
            'receiverId': request.employeeId,
            'relatedId': announcementId,
            'isRead': false,
            'data': {
              'screen': 'competition_results',
              'announcementId': announcementId,
              'isWinner': isWinner,
              'rank': rank,
            },
          },
        );
      }

      await notificationBatch.commit();

      emit(
        EmployeeNominationActionSuccess(
          'تم إعلان النتيجة وإرسال الإشعارات بنجاح',
        ),
      );
    } catch (e) {
      emit(
        EmployeeNominationError(
          'فشل إعلان النتيجة: ${e.toString()}',
        ),
      );
    }
  }

  // ============================================================
  // إشعار طلب جديد للأدمن
  // ============================================================

  Future<void> _sendNewRequestNotification(
    EmployeeNominationRequestModel request,
  ) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: 'طلب ترشح موظف جديد',
        message:
            'قدم الموظف ${request.employeeName} على مسابقة "${request.announcementTitle}"',
        type: NotificationType.newDoctorRequest,
        target: NotificationTarget.adminOnly,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: request.id,
      );

      await _notificationRepo
          .sendRoleBasedNotification(notification);
    } catch (e) {
      print(
        'فشل إرسال إشعار طلب الموظف للأدمن: $e',
      );
    }
  }

  // ============================================================
  // إشعار المحكم
  // ============================================================

  Future<void> _sendToEvaluatorNotification(
    EmployeeNominationRequestModel request,
  ) async {
    try {
      if (request.evaluatorId == null ||
          request.evaluatorId!.isEmpty) {
        return;
      }

      final notification = AppNotificationModel(
        id: '',
        title: 'طلب تقييم موظف جديد',
        message:
            'تم تحويل طلب الموظف ${request.employeeName} إليك للتقييم',
        type: NotificationType.newArbitrationRequest,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.evaluatorId!,
        relatedId: request.id,
      );

      await _notificationRepo
          .sendNotification(notification);
    } catch (e) {
      print(
        'فشل إرسال إشعار للمحكم: $e',
      );
    }
  }

  // ============================================================
  // إشعار الموظف بالقبول / الرفض
  // ============================================================

  Future<void> _sendStatusUpdateToEmployee(
    EmployeeNominationRequestModel request, {
    required bool isAccepted,
  }) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: isAccepted
            ? 'قبول طلب الترشح'
            : 'رفض طلب الترشح',
        message: isAccepted
            ? 'تمت الموافقة النهائية على طلب ترشحك'
            : 'تم رفض طلب ترشحك. السبب: '
                '${request.rejectionReason ?? "غير محدد"}',
        type: NotificationType.requestStatusUpdate,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.employeeId,
        relatedId: request.id,
      );

      await _notificationRepo
          .sendNotification(notification);
    } catch (e) {
      print(
        'فشل إرسال إشعار للموظف: $e',
      );
    }
  }

  // ============================================================
  // إشعار الأدمن بانتهاء التقييم
  // ============================================================

  Future<void> _sendEvaluationDoneToAdmin(
    EmployeeNominationRequestModel request,
  ) async {
    try {
      final notification = AppNotificationModel(
        id: '',
        title: 'تم إنهاء تقييم موظف',
        message:
            'قام المحكم بتقييم طلب الموظف ${request.employeeName}',
        type: NotificationType.judgeRequestCompleted,
        target: NotificationTarget.adminOnly,
        timestamp: Timestamp.now(),
        receiverId: '',
        relatedId: request.id,
      );

      await _notificationRepo
          .sendRoleBasedNotification(notification);
    } catch (e) {
      print(
        'فشل إرسال إشعار للإدمن: $e',
      );
    }
  }

  // ============================================================
  // إشعار موعد المقابلة
  // ============================================================

  Future<void> _sendInterviewScheduledNotification(
    EmployeeNominationRequestModel request,
  ) async {
    try {
      if (request.interviewDate == null) {
        return;
      }

      final dateStr = DateFormat('yyyy-MM-dd')
          .format(request.interviewDate!);

      final notification = AppNotificationModel(
        id: '',
        title: 'تحديد موعد مقابلة',
        message:
            'تم تحديد مقابلتك بتاريخ $dateStr '
            'الساعة ${request.interviewTime ?? "-"} '
            'بمكان: ${request.interviewLocation ?? "-"}',
        type: NotificationType.requestStatusUpdate,
        target: NotificationTarget.specificUser,
        timestamp: Timestamp.now(),
        receiverId: request.employeeId,
        relatedId: request.id,
      );

      await _notificationRepo
          .sendNotification(notification);
    } catch (e) {
      print(
        'فشل إرسال إشعار الموعد: $e',
      );
    }
  }

  // ============================================================
  // التأكد من انتهاء كل التقييمات
  // ============================================================

  Future<void> _checkAndNotifyIfAllEvaluated(
    EmployeeNominationRequestModel evaluatedRequest,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('nomination_requests')
          .where(
            'applicantType',
            isEqualTo: 'employee',
          )
          .where(
            'announcementId',
            isEqualTo: evaluatedRequest.announcementId,
          )
          .where(
            'status',
            isEqualTo:
                EmployeeNominationRequestModel
                    .statusPendingEvaluator,
          )
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        final announcementDoc =
            await FirebaseFirestore.instance
                .collection('announcements')
                .doc(evaluatedRequest.announcementId)
                .get();

        final announcementTitle =
            announcementDoc.data()?['title'] ?? '';

        final notification = AppNotificationModel(
          id: '',
          title: '🏆 اكتملت تقييمات الموظفين',
          message:
              'تم تقييم جميع الموظفين المرشحين في مسابقة '
              '"$announcementTitle". يرجى مراجعة النتائج.',
          type: NotificationType.judgeRequestCompleted,
          target: NotificationTarget.adminOnly,
          timestamp: Timestamp.now(),
          receiverId: '',
          relatedId:
              evaluatedRequest.announcementId,
        );

        await _notificationRepo
            .sendRoleBasedNotification(notification);
      }
    } catch (e) {
      print(
        '⚠️ خطأ في فحص تقييمات الموظفين: $e',
      );
    }
  }
}