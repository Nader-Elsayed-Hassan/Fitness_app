part of 'progress_cubit.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();
  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final ProgressStats stats;
  const ProgressLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  @override
  List<Object?> get props => [message];
}
