import '../../domain/entities/user_stats_entity.dart';

abstract class StatsRepository {
  Future<UserStatsEntity> getUserStats();
}

class StatsRepositoryImpl implements StatsRepository {
  @override
  Future<UserStatsEntity> getUserStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserStatsEntity(
      stepsToday: 7842,
      stepsGoal: 10000,
      caloriesBurned: 1240,
      caloriesGoal: 2000,
      activeMinutes: 48,
      activeMinutesGoal: 60,
      waterIntakeLiters: 1.8,
      waterGoalLiters: 2.5,
      workoutsThisWeek: 3,
      weeklyGoal: 5,
      weeklyActivity: [
        WeeklyActivityEntity(day: 'Mon', value: 0.8),
        WeeklyActivityEntity(day: 'Tue', value: 0.6),
        WeeklyActivityEntity(day: 'Wed', value: 1.0),
        WeeklyActivityEntity(day: 'Thu', value: 0.4),
        WeeklyActivityEntity(day: 'Fri', value: 0.75, isToday: true),
        WeeklyActivityEntity(day: 'Sat', value: 0.0),
        WeeklyActivityEntity(day: 'Sun', value: 0.0),
      ],
    );
  }
}
