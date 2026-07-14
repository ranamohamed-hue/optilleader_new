import 'package:equatable/equatable.dart';

abstract class ResearchState extends Equatable {
  const ResearchState();
  @override
  List<Object?> get props => [];
}

class ResearchInitial extends ResearchState {}
class ResearchLoading extends ResearchState {}
class ResearchSuccess extends ResearchState {}

class ResearchError extends ResearchState {
  final String error;
  const ResearchError({required this.error});
  @override
  List<Object?> get props => [error];
}