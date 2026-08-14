import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/admin/data/repo/employee/employee_nomination_admin_repo .dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';

class EmployeeNominationAdminRepoImpl
    implements EmployeeNominationAdminRepo {
  final FirebaseFirestore firestore;

  EmployeeNominationAdminRepoImpl(this.firestore);

  // ============================================================
  // GET PENDING ADMIN REQUESTS
  // ============================================================

  @override
  Future<List<EmployeeNominationRequestModel>>
      getPendingRequests() async {
    final snapshot = await firestore
        .collection('employee_nomination_requests')
        .where(
          'status',
          isEqualTo:
              EmployeeNominationRequestModel.statusPendingAdmin,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) => EmployeeNominationRequestModel.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }

  // ============================================================
  // APPROVE & SEND TO EVALUATOR
  // ============================================================

  @override
  Future<void> approveAndSendToEvaluator({
    required String requestId,
    required String evaluatorId,
    required String evaluatorName,
  }) async {
    if (requestId.trim().isEmpty) {
      throw Exception('Request ID is empty');
    }

    if (evaluatorId.trim().isEmpty) {
      throw Exception('Evaluator ID is empty');
    }

    if (evaluatorName.trim().isEmpty) {
      throw Exception('Evaluator name is empty');
    }

    await firestore
        .collection('employee_nomination_requests')
        .doc(requestId)
        .update({
      'status':
          EmployeeNominationRequestModel.statusPendingEvaluator,

      'evaluatorId': evaluatorId,

      'evaluatorName': evaluatorName,

      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // REJECT REQUEST
  // ============================================================

  @override
  Future<void> rejectRequest({
    required String requestId,
    required String reason,
  }) async {
    if (requestId.trim().isEmpty) {
      throw Exception('Request ID is empty');
    }

    if (reason.trim().isEmpty) {
      throw Exception('Rejection reason is empty');
    }

    await firestore
        .collection('employee_nomination_requests')
        .doc(requestId)
        .update({
      'status':
          EmployeeNominationRequestModel.statusRejectedByAdmin,

      'rejectionReason': reason.trim(),

      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}