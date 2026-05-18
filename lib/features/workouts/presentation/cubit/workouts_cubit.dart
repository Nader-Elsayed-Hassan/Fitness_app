import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/workout_entity.dart';

part 'workouts_state.dart';

class WorkoutsCubit extends Cubit<WorkoutsState> {
  final WorkoutRepository _workoutRepository;
  WorkoutCategory? _selectedCategory;

  WorkoutsCubit(this._workoutRepository) : super(WorkoutsInitial());

  Future<void> loadWorkouts() async {
    emit(WorkoutsLoading());
    try {
      final workouts = _selectedCategory != null
          ? await _workoutRepository.getWorkoutsByCategory(_selectedCategory!)
          : await _workoutRepository.getWorkouts();
      emit(WorkoutsLoaded(
        workouts: workouts,
        selectedCategory: _selectedCategory,
      ));
    } catch (e) {
      emit(WorkoutsError(e.toString()));
    }
  }

  Future<void> filterByCategory(WorkoutCategory? category) async {
    _selectedCategory = category;
    await loadWorkouts();
  }

  Future<void> toggleFavorite(String workoutId) async {
    await _workoutRepository.toggleFavorite(workoutId);
    await loadWorkouts();
  }
}
