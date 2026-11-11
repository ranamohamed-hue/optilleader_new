import 'package:equatable/equatable.dart';
import 'package:optialeader/feature/employee/data/models/employee_nomination_request_model.dart';

abstract class EmployeeNominationState extends Equatable {
  const EmployeeNominationState();
  
  @override
  List<Object?> get props => [];
}

class EmployeeNominationInitial extends EmployeeNominationState {}

class EmployeeNominationLoading extends EmployeeNominationState {}

class EmployeeNominationActionSuccess extends EmployeeNominationState {
  final String message;
  const EmployeeNominationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EmployeeNominationError extends EmployeeNominationState {
  final String message;
  const EmployeeNominationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ الكلاس ده هو اللي الشاشة بتدور عليه
class EmployeeNominationLoaded extends EmployeeNominationState {
  final List<EmployeeNominationRequestModel> requests;
  
  const EmployeeNominationLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}