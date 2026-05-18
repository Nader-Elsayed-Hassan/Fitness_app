part of 'workouts_cubit.dart';

abstract class WorkoutsState extends Equatable {
  const WorkoutsState();

  @override
  List<Object?> get props => [];
}

class WorkoutsInitial extends WorkoutsState {}

class WorkoutsLoading extends WorkoutsState {}

class WorkoutsLoaded extends WorkoutsState {
  final List<WorkoutEntity> workouts;
  final WorkoutCategory? selectedCategory;

  const WorkoutsLoaded({
    required this.workouts,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [workouts, selectedCategory];
}

class WorkoutsError extends WorkoutsState {
  final String message;

  const WorkoutsError(this.message);

  @override
  List<Object?> get props => [message];
}
