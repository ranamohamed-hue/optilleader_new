import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';

abstract class EmployeeNominationState {}

class EmployeeNominationInitial extends EmployeeNominationState {}

class EmployeeNominationLoading extends EmployeeNominationState {}

class EmployeeNominationLoaded extends EmployeeNominationState {
  final List<EmployeeNominationRequestModel> requests;

  EmployeeNominationLoaded(this.requests);
}

class EmployeeNominationActionSuccess
    extends EmployeeNominationState {
  final String message;

  EmployeeNominationActionSuccess(this.message);
}

class EmployeeNominationError extends EmployeeNominationState {
  final String message;

  EmployeeNominationError(this.message);
}

class EmployeeEvaluatorsLoading
    extends EmployeeNominationState {}

class EmployeeEvaluatorsLoaded
    extends EmployeeNominationState {
  final List<Map<String, dynamic>> evaluators;

  EmployeeEvaluatorsLoaded(this.evaluators);
}

class EmployeeEvaluatorsError
    extends EmployeeNominationState {
  final String message;

  EmployeeEvaluatorsError(this.message);
}