import 'package:optialeader/feature/database_admin/logic/leadership_scoring_engine/leadership_criteria_engine.dart';

abstract class LeadershipState {}
class LeadershipInitial extends LeadershipState {}
class LeadershipLoading extends LeadershipState {}

// للصفحات التانية
class LeadershipScoreLoaded extends LeadershipState {
  final double coursePoints;
  LeadershipScoreLoaded({required this.coursePoints});
}

class Article22Loaded extends LeadershipState {
  final Map<String, double> participationMap;
  Article22Loaded({required this.participationMap});
}

class MandatoryCriteriaLoaded extends LeadershipState {
  final List<CriterionStatus> criteria;
  MandatoryCriteriaLoaded({required this.criteria});
}

// لصفحة التقديم
class NominationDataLoaded extends LeadershipState {
  final Map<String, dynamic> scores;
  final List<CriterionStatus> criteria;

  NominationDataLoaded({required this.scores, required this.criteria});
}

class LeadershipError extends LeadershipState {
  final String message;
  LeadershipError(this.message);
}