import '../../domain/entities/workout_entity.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutEntity>> getWorkouts();
  Future<List<WorkoutEntity>> getWorkoutsByCategory(WorkoutCategory category);
  Future<WorkoutEntity?> getWorkoutById(String id);
  Future<List<WorkoutEntity>> getFavoriteWorkouts();
  Future<void> toggleFavorite(String workoutId);
}

class WorkoutRepositoryImpl implements WorkoutRepository {
  // Mock data — replace with API/local DB calls
  final List<WorkoutEntity> _mockWorkouts = [
    const WorkoutEntity(
      id: '1',
      title: 'Full Body Blast',
      description: 'A complete full-body workout targeting all major muscle groups.',
      category: WorkoutCategory.strength,
      difficulty: DifficultyLevel.intermediate,
      durationMinutes: 45,
      caloriesBurn: 380,
      exerciseCount: 8,
      isFavorite: true,
      exercises: [
        ExerciseEntity(
          id: 'e1',
          name: 'Push-ups',
          sets: 3,
          reps: 15,
          muscleGroup: 'Chest',
        ),
        ExerciseEntity(
          id: 'e2',
          name: 'Squats',
          sets: 4,
          reps: 12,
          muscleGroup: 'Legs',
        ),
        ExerciseEntity(
          id: 'e3',
          name: 'Pull-ups',
          sets: 3,
          reps: 10,
          muscleGroup: 'Back',
        ),
        ExerciseEntity(
          id: 'e4',
          name: 'Plank',
          sets: 3,
          reps: 1,
          durationSeconds: 60,
          muscleGroup: 'Core',
        ),
      ],
    ),
    const WorkoutEntity(
      id: '2',
      title: 'HIIT Cardio Rush',
      description: 'High-intensity interval training to torch calories fast.',
      category: WorkoutCategory.hiit,
      difficulty: DifficultyLevel.advanced,
      durationMinutes: 30,
      caloriesBurn: 450,
      exerciseCount: 6,
      exercises: [
        ExerciseEntity(
          id: 'e5',
          name: 'Burpees',
          sets: 4,
          reps: 10,
          muscleGroup: 'Full Body',
        ),
        ExerciseEntity(
          id: 'e6',
          name: 'Jump Squats',
          sets: 4,
          reps: 15,
          muscleGroup: 'Legs',
        ),
        ExerciseEntity(
          id: 'e7',
          name: 'Mountain Climbers',
          sets: 3,
          reps: 20,
          muscleGroup: 'Core',
        ),
      ],
    ),
    const WorkoutEntity(
      id: '3',
      title: 'Morning Yoga Flow',
      description: 'Gentle yoga sequence to start your day with energy.',
      category: WorkoutCategory.yoga,
      difficulty: DifficultyLevel.beginner,
      durationMinutes: 25,
      caloriesBurn: 120,
      exerciseCount: 10,
      isFavorite: true,
    ),
    const WorkoutEntity(
      id: '4',
      title: 'Upper Body Power',
      description: 'Focused upper body strength training for chest, back and arms.',
      category: WorkoutCategory.strength,
      difficulty: DifficultyLevel.intermediate,
      durationMinutes: 40,
      caloriesBurn: 280,
      exerciseCount: 7,
    ),
    const WorkoutEntity(
      id: '5',
      title: '5K Run Prep',
      description: 'Structured cardio program to prepare for your first 5K.',
      category: WorkoutCategory.cardio,
      difficulty: DifficultyLevel.beginner,
      durationMinutes: 35,
      caloriesBurn: 320,
      exerciseCount: 4,
    ),
    const WorkoutEntity(
      id: '6',
      title: 'Core & Flexibility',
      description: 'Strengthen your core and improve overall flexibility.',
      category: WorkoutCategory.flexibility,
      difficulty: DifficultyLevel.beginner,
      durationMinutes: 20,
      caloriesBurn: 100,
      exerciseCount: 8,
    ),
  ];

  final Set<String> _favorites = {'1', '3'};

  @override
  Future<List<WorkoutEntity>> getWorkouts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockWorkouts
        .map((w) => _applyFavorite(w))
        .toList();
  }

  @override
  Future<List<WorkoutEntity>> getWorkoutsByCategory(
      WorkoutCategory category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockWorkouts
        .where((w) => w.category == category)
        .map((w) => _applyFavorite(w))
        .toList();
  }

  @override
  Future<WorkoutEntity?> getWorkoutById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final workout = _mockWorkouts.firstWhere((w) => w.id == id);
      return _applyFavorite(workout);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<WorkoutEntity>> getFavoriteWorkouts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockWorkouts
        .where((w) => _favorites.contains(w.id))
        .map((w) => _applyFavorite(w))
        .toList();
  }

  @override
  Future<void> toggleFavorite(String workoutId) async {
    if (_favorites.contains(workoutId)) {
      _favorites.remove(workoutId);
    } else {
      _favorites.add(workoutId);
    }
  }

  WorkoutEntity _applyFavorite(WorkoutEntity w) {
    return WorkoutEntity(
      id: w.id,
      title: w.title,
      description: w.description,
      category: w.category,
      difficulty: w.difficulty,
      durationMinutes: w.durationMinutes,
      caloriesBurn: w.caloriesBurn,
      exerciseCount: w.exerciseCount,
      imageUrl: w.imageUrl,
      isFavorite: _favorites.contains(w.id),
      exercises: w.exercises,
    );
  }
}
