import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model .dart';

abstract class EmployeeNominationAdminState {}

class EmployeeNominationAdminInitial
    extends EmployeeNominationAdminState {}

class EmployeeNominationAdminLoading
    extends EmployeeNominationAdminState {}

class EmployeeNominationAdminLoaded
    extends EmployeeNominationAdminState {
  final List<EmployeeNominationRequestModel> requests;

  EmployeeNominationAdminLoaded({
    required this.requests,
  });
}

class EmployeeNominationAdminActionLoading
    extends EmployeeNominationAdminState {}

class EmployeeNominationAdminActionSuccess
    extends EmployeeNominationAdminState {}

class EmployeeNominationAdminError
    extends EmployeeNominationAdminState {
  final String message;

  EmployeeNominationAdminError({
    required this.message,
  });
}