part of 'workout_active_cubit.dart';

abstract class WorkoutActiveState extends Equatable {
  const WorkoutActiveState();
  @override
  List<Object?> get props => [];
}

class WorkoutActiveIdle extends WorkoutActiveState {}

class WorkoutActiveRunning extends WorkoutActiveState {
  final WorkoutEntity workout;
  final int elapsedSeconds;
  final int currentExerciseIndex;
  final bool isPaused;

  const WorkoutActiveRunning({
    required this.workout,
    required this.elapsedSeconds,
    required this.currentExerciseIndex,
    required this.isPaused,
  });

  WorkoutActiveRunning copyWith({
    int? elapsedSeconds,
    int? currentExerciseIndex,
    bool? isPaused,
  }) {
    return WorkoutActiveRunning(
      workout: workout,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentExerciseIndex:
          currentExerciseIndex ?? this.currentExerciseIndex,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  String get formattedTime {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  ExerciseEntity? get currentExercise {
    if (workout.exercises.isEmpty) return null;
    if (currentExerciseIndex >= workout.exercises.length) return null;
    return workout.exercises[currentExerciseIndex];
  }

  @override
  List<Object?> get props =>
      [workout, elapsedSeconds, currentExerciseIndex, isPaused];
}

class WorkoutActiveCompleted extends WorkoutActiveState {
  final WorkoutEntity workout;
  final int totalSeconds;
  final int caloriesBurned;

  const WorkoutActiveCompleted({
    required this.workout,
    required this.totalSeconds,
    required this.caloriesBurned,
  });

  String get formattedTime {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [workout, totalSeconds, caloriesBurned];
}
