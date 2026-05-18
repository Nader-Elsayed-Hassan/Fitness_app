import 'package:equatable/equatable.dart';

enum WorkoutCategory { strength, cardio, yoga, hiit, flexibility, sports }

enum DifficultyLevel { beginner, intermediate, advanced }

class WorkoutEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final WorkoutCategory category;
  final DifficultyLevel difficulty;
  final int durationMinutes;
  final int caloriesBurn;
  final int exerciseCount;
  final String? imageUrl;
  final bool isFavorite;
  final List<ExerciseEntity> exercises;

  const WorkoutEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationMinutes,
    required this.caloriesBurn,
    required this.exerciseCount,
    this.imageUrl,
    this.isFavorite = false,
    this.exercises = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        difficulty,
        durationMinutes,
        caloriesBurn,
        isFavorite,
      ];
}

class ExerciseEntity extends Equatable {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int? durationSeconds;
  final String? imageUrl;
  final String? videoUrl;
  final String muscleGroup;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.durationSeconds,
    this.imageUrl,
    this.videoUrl,
    required this.muscleGroup,
  });

  @override
  List<Object?> get props => [id, name, sets, reps, muscleGroup];
}
