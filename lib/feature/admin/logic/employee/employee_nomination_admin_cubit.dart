import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/admin/data/repo/employee/employee_nomination_admin_repo .dart';
import 'package:optialeader/feature/admin/logic/employee/employee_nomination_admin_state .dart';

class EmployeeNominationAdminCubit
    extends Cubit<EmployeeNominationAdminState> {
  final EmployeeNominationAdminRepo repo;

  EmployeeNominationAdminCubit(this.repo)
      : super(EmployeeNominationAdminInitial());

  Future<void> getPendingRequests() async {
    emit(EmployeeNominationAdminLoading());

    try {
      final requests = await repo.getPendingRequests();

      emit(
        EmployeeNominationAdminLoaded(
          requests: requests,
        ),
      );
    } catch (e) {
      emit(
        EmployeeNominationAdminError(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> approveAndSendToEvaluator({
    required String requestId,
    required String evaluatorId,
    required String evaluatorName,
  }) async {
    emit(EmployeeNominationAdminActionLoading());

    try {
      await repo.approveAndSendToEvaluator(
        requestId: requestId,
        evaluatorId: evaluatorId,
        evaluatorName: evaluatorName,
      );

      emit(EmployeeNominationAdminActionSuccess());

      await getPendingRequests();
    } catch (e) {
      emit(
        EmployeeNominationAdminError(
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> rejectRequest({
    required String requestId,
    required String reason,
  }) async {
    emit(EmployeeNominationAdminActionLoading());

    try {
      await repo.rejectRequest(
        requestId: requestId,
        reason: reason,
      );

      emit(EmployeeNominationAdminActionSuccess());

      await getPendingRequests();
    } catch (e) {
      emit(
        EmployeeNominationAdminError(
          message: e.toString(),
        ),
      );
    }
  }
}