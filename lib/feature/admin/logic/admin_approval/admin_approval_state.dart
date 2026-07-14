import 'package:optialeader/feature/database_admin/data/models/doctor_profile_model.dart';

abstract class AdminApprovalState {}

class AdminApprovalInitial extends AdminApprovalState {}
class AdminApprovalLoading extends AdminApprovalState {}
class AdminApprovalLoaded extends AdminApprovalState {
  final List<DoctorProfileModel> doctorsWithPending;
  AdminApprovalLoaded(this.doctorsWithPending);
}
class AdminApprovalError extends AdminApprovalState {
  final String message;
  AdminApprovalError(this.message);
}
class AdminActionSuccess extends AdminApprovalState {}