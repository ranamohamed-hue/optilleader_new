import 'package:bloc/bloc.dart';
import 'package:optialeader/feature/admin/data/repo/admin_approval/admin_approval_repo.dart';
import 'package:optialeader/feature/admin/logic/admin_approval/admin_approval_state.dart';

class AdminApprovalCubit extends Cubit<AdminApprovalState> {
  final AdminApprovalRepo adminApprovalRepo;

  AdminApprovalCubit({required this.adminApprovalRepo})
    : super(AdminApprovalInitial());

  Future<void> getPendingRequests({bool showLoading = true}) async {
    if (showLoading) {
      emit(AdminApprovalLoading());
    }

    final result = await adminApprovalRepo.getPendingRequests();
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (doctors) => emit(AdminApprovalLoaded(doctors)),
    );
  }

  // ====== الأبحاث ======
  Future<void> approveResearch(String doctorUid, String paperId, String paperTitle) async {
    final result = await adminApprovalRepo.approveResearch(doctorUid, paperId, paperTitle);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }

  Future<void> rejectResearch(String doctorUid, String paperId, String paperTitle, String reason) async {
    final result = await adminApprovalRepo.rejectResearch(doctorUid, paperId, paperTitle, reason);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }

  // ====== المؤتمرات ======
  Future<void> approveConference(String doctorUid, String confId, String confTitle) async {
    final result = await adminApprovalRepo.approveConference(doctorUid, confId, confTitle);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }

  Future<void> rejectConference(String doctorUid, String confId, String confTitle, String reason) async {
    final result = await adminApprovalRepo.rejectConference(doctorUid, confId, confTitle, reason);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }

  // ====== المعارض ======
  Future<void> approveExhibition(String doctorUid, String exhId, String exhTitle) async {
    final result = await adminApprovalRepo.approveExhibition(doctorUid, exhId, exhTitle);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }

  Future<void> rejectExhibition(String doctorUid, String exhId, String exhTitle, String reason) async {
    final result = await adminApprovalRepo.rejectExhibition(doctorUid, exhId, exhTitle, reason);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }

  // ====== الدورات ======
  Future<void> approveCourse(String doctorUid, String courseId, String courseTitle) async {
    final result = await adminApprovalRepo.approveCourse(doctorUid, courseId, courseTitle);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }

  Future<void> rejectCourse(String doctorUid, String courseId, String courseTitle, String reason) async {
    final result = await adminApprovalRepo.rejectCourse(doctorUid, courseId, courseTitle, reason);
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }

  // ====== الأنشطة الأكاديمية ======
  Future<void> updateActivityCriterion({
    required String doctorUid,
    required String criterionKey,
    required bool isApproved,
    String? adminNote,
  }) async {
    final result = await adminApprovalRepo.updateActivityCriterionStatus(
      doctorUid: doctorUid,
      criterionKey: criterionKey,
      isApproved: isApproved,
      adminNote: adminNote,
    );
    result.fold(
      (error) => emit(AdminApprovalError(error)),
      (_) => getPendingRequests(showLoading: false),
    );
  }
}