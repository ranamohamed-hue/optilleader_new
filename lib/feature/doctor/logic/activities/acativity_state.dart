import 'package:equatable/equatable.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();
  @override
  List<Object?> get props => [];
}

class ActivityInitial extends ActivityState {}
class ActivityLoading extends ActivityState {}
class ActivitySuccess extends ActivityState {}

class ActivityError extends ActivityState {
  final String error;
  const ActivityError({required this.error});
  @override
  List<Object?> get props => [error];
}