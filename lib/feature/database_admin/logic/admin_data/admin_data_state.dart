import 'package:optialeader/feature/database_admin/data/models/admin_profile_model.dart';

abstract class AdminDataState {}

class AdminInitial extends AdminDataState {}

class AdminLoading extends AdminDataState {}

class AdminSuccess extends AdminDataState {
  final String? message;
  AdminSuccess({this.message});
}

class AdminDeleting extends AdminDataState {}

// لعرض بيانات كل الأدمنز
class AllAdminsLoaded extends AdminDataState {
  final List<AdminProfileModel> admins;
  AllAdminsLoaded({required this.admins});
}

// لعرض بيانات أدمن معين (بروفايل)
class AdminLoaded extends AdminDataState {
  final AdminProfileModel? admin;
  final int newRequestsCount;
  final int underReviewCount;
  AdminLoaded({
    this.admin,
    this.newRequestsCount = 0,
    this.underReviewCount = 0,
  });
}

class AdminError extends AdminDataState {
  final String error;
  AdminError({required this.error});
}
