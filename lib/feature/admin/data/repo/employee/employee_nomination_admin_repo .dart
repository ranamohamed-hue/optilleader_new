import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model .dart';

abstract class EmployeeNominationAdminRepo {
  Future<List<EmployeeNominationRequestModel>>
  getPendingRequests();

  Future<void> approveAndSendToEvaluator({
    required String requestId,
    required String evaluatorId,
    required String evaluatorName,
  });

  Future<void> rejectRequest({
    required String requestId,
    required String reason,
  });
}