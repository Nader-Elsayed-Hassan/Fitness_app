import '../../../workouts/domain/entities/workout_entity.dart';

class WorkoutHistoryEntry {
  final String id;
  final String title;
  final DateTime date;
  final int durationMinutes;
  final int caloriesBurned;
  final WorkoutCategory category;

  const WorkoutHistoryEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.category,
  });
}

class ProgressStats {
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCalories;
  final int currentStreak;
  final List<WorkoutHistoryEntry> history;
  final List<double> weeklyCalories; // 7 days
  final List<double> weeklySteps;    // 7 days
  final double weight;
  final double bmi;
  final double bodyFat;
  final double muscleMass;

  const ProgressStats({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCalories,
    required this.currentStreak,
    required this.history,
    required this.weeklyCalories,
    required this.weeklySteps,
    required this.weight,
    required this.bmi,
    required this.bodyFat,
    required this.muscleMass,
  });
}

abstract class ProgressRepository {
  Future<ProgressStats> getProgressStats();
  Future<void> logWorkout(WorkoutHistoryEntry entry);
}

class ProgressRepositoryImpl implements ProgressRepository {
  final List<WorkoutHistoryEntry> _history = [
    WorkoutHistoryEntry(
      id: 'h1',
      title: 'تمرين الجسم الكامل',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      durationMinutes: 45,
      caloriesBurned: 380,
      category: WorkoutCategory.strength,
    ),
    WorkoutHistoryEntry(
      id: 'h2',
      title: 'يوغا الصباح',
      date: DateTime.now().subtract(const Duration(days: 1)),
      durationMinutes: 25,
      caloriesBurned: 120,
      category: WorkoutCategory.yoga,
    ),
    WorkoutHistoryEntry(
      id: 'h3',
      title: 'HIIT كارديو',
      date: DateTime.now().subtract(const Duration(days: 2)),
      durationMinutes: 30,
      caloriesBurned: 450,
      category: WorkoutCategory.hiit,
    ),
    WorkoutHistoryEntry(
      id: 'h4',
      title: 'تمرين الجزء العلوي',
      date: DateTime.now().subtract(const Duration(days: 4)),
      durationMinutes: 40,
      caloriesBurned: 280,
      category: WorkoutCategory.strength,
    ),
    WorkoutHistoryEntry(
      id: 'h5',
      title: 'ركض 5 كيلو',
      date: DateTime.now().subtract(const Duration(days: 5)),
      durationMinutes: 35,
      caloriesBurned: 320,
      category: WorkoutCategory.cardio,
    ),
  ];

  @override
  Future<ProgressStats> getProgressStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ProgressStats(
      totalWorkouts: 12,
      totalMinutes: 86 * 60,
      totalCalories: 14820,
      currentStreak: 5,
      history: List.from(_history),
      weeklyCalories: [1200, 1800, 1400, 2100, 1600, 1900, 1240],
      weeklySteps: [6200, 8400, 7100, 9800, 7500, 8900, 7842],
      weight: 74.5,
      bmi: 22.8,
      bodyFat: 18.2,
      muscleMass: 61.0,
    );
  }

  @override
  Future<void> logWorkout(WorkoutHistoryEntry entry) async {
    _history.insert(0, entry);
  }
}
