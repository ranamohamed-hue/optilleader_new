// nomination_request_state.dart
import 'package:optialeader/feature/admin/data/model/nomination_request_model.dart';

abstract class NominationRequestState {}
class NominationRequestInitial extends NominationRequestState {}
class NominationRequestLoading extends NominationRequestState {}
class NominationRequestLoaded extends NominationRequestState {
  final List<NominationRequestModel> requests;
  NominationRequestLoaded(this.requests);
}
class NominationRequestActionSuccess extends NominationRequestState {
  final String message;
  NominationRequestActionSuccess(this.message);
}
class NominationRequestError extends NominationRequestState {
  final String message;
  NominationRequestError(this.message);
}
// ✅ States خاصة بجلب المحكمين
class EvaluatorsLoading extends NominationRequestState {}
class EvaluatorsLoaded extends NominationRequestState {
  final List<Map<String, dynamic>> evaluators;
  EvaluatorsLoaded(this.evaluators);
}
class EvaluatorsError extends NominationRequestState {
  final String message;
  EvaluatorsError(this.message);
}