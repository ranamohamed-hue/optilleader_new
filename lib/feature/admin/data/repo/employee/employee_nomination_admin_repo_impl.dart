import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:optialeader/feature/admin/data/repo/employee/employee_nomination_admin_repo .dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model .dart';


class EmployeeNominationAdminRepoImpl
    implements EmployeeNominationAdminRepo {
  final FirebaseFirestore firestore;

  EmployeeNominationAdminRepoImpl(this.firestore);

  @override
  Future<List<EmployeeNominationRequestModel>>
  getPendingRequests() async {
    final snapshot = await firestore
        .collection('employee_nomination_requests')
        .where(
          'status',
          isEqualTo: EmployeeNominationRequestModel
              .statusPendingAdmin,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) => EmployeeNominationRequestModel
              .fromMap(
                doc.data(),
                doc.id,
              ),
        )
        .toList();
  }

  @override
  Future<void> approveAndSendToEvaluator({
    required String requestId,
    required String evaluatorId,
    required String evaluatorName,
  }) async {
    await firestore
        .collection(
          'employee_nomination_requests',
        )
        .doc(requestId)
        .update({
          'status':
              EmployeeNominationRequestModel
                  .statusPendingEvaluator,

          'evaluatorId': evaluatorId,

          'evaluatorName': evaluatorName,

          'updatedAt':
              Timestamp.fromDate(
                DateTime.now(),
              ),
        });
  }

  @override
  Future<void> rejectRequest({
    required String requestId,
    required String reason,
  }) async {
    await firestore
        .collection(
          'employee_nomination_requests',
        )
        .doc(requestId)
        .update({
          'status':
              EmployeeNominationRequestModel
                  .statusRejectedByAdmin,

          'rejectionReason': reason,

          'updatedAt':
              Timestamp.fromDate(
                DateTime.now(),
              ),
        });
  }
}