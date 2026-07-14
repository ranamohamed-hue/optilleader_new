import 'package:optialeader/feature/database_admin/data/models/judge_profile_model.dart';

abstract class JudgeDataState {}

class JudgeInitial extends JudgeDataState {}
class JudgeLoading extends JudgeDataState {}
class JudgeSuccess extends JudgeDataState {}
class JudgeDeleting extends JudgeDataState {}

// لعرض كل الحكام
class AllJudgesLoaded extends JudgeDataState {
  final List<JudgeProfileModel> judges;
  AllJudgesLoaded({required this.judges});
}

// لعرض بيانات حكم واحد
class JudgeLoaded extends JudgeDataState {
  final JudgeProfileModel? judge;
  JudgeLoaded({this.judge});
}

class JudgeError extends JudgeDataState {
  final String error;
  JudgeError({required this.error});
}