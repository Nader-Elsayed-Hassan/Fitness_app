import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/workout_entity.dart';
import '../../../progress/data/repositories/progress_repository_impl.dart';

part 'workout_active_state.dart';

class WorkoutActiveCubit extends Cubit<WorkoutActiveState> {
  final ProgressRepository _progressRepo;
  Timer? _timer;

  WorkoutActiveCubit(this._progressRepo) : super(WorkoutActiveIdle());

  void startWorkout(WorkoutEntity workout) {
    _timer?.cancel();
    emit(WorkoutActiveRunning(
      workout: workout,
      elapsedSeconds: 0,
      currentExerciseIndex: 0,
      isPaused: false,
    ));
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state;
      if (s is WorkoutActiveRunning && !s.isPaused) {
        emit(s.copyWith(elapsedSeconds: s.elapsedSeconds + 1));
      }
    });
  }

  void pauseResume() {
    final s = state;
    if (s is WorkoutActiveRunning) {
      emit(s.copyWith(isPaused: !s.isPaused));
    }
  }

  void nextExercise() {
    final s = state;
    if (s is WorkoutActiveRunning) {
      final next = s.currentExerciseIndex + 1;
      if (next >= s.workout.exercises.length) {
        _finishWorkout(s);
      } else {
        emit(s.copyWith(currentExerciseIndex: next));
      }
    }
  }

  void previousExercise() {
    final s = state;
    if (s is WorkoutActiveRunning && s.currentExerciseIndex > 0) {
      emit(s.copyWith(
          currentExerciseIndex: s.currentExerciseIndex - 1));
    }
  }

  Future<void> _finishWorkout(WorkoutActiveRunning s) async {
    _timer?.cancel();
    final entry = WorkoutHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: s.workout.title,
      date: DateTime.now(),
      durationMinutes: s.elapsedSeconds ~/ 60,
      caloriesBurned: s.workout.caloriesBurn,
      category: s.workout.category,
    );
    await _progressRepo.logWorkout(entry);
    emit(WorkoutActiveCompleted(
      workout: s.workout,
      totalSeconds: s.elapsedSeconds,
      caloriesBurned: s.workout.caloriesBurn,
    ));
  }

  void finishEarly() {
    final s = state;
    if (s is WorkoutActiveRunning) {
      _finishWorkout(s);
    }
  }

  void reset() {
    _timer?.cancel();
    emit(WorkoutActiveIdle());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
