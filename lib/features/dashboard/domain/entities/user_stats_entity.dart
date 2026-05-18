import 'package:equatable/equatable.dart';

class UserStatsEntity extends Equatable {
  final int stepsToday;
  final int stepsGoal;
  final double caloriesBurned;
  final double caloriesGoal;
  final int activeMinutes;
  final int activeMinutesGoal;
  final double waterIntakeLiters;
  final double waterGoalLiters;
  final int workoutsThisWeek;
  final int weeklyGoal;
  final List<WeeklyActivityEntity> weeklyActivity;

  const UserStatsEntity({
    required this.stepsToday,
    required this.stepsGoal,
    required this.caloriesBurned,
    required this.caloriesGoal,
    required this.activeMinutes,
    required this.activeMinutesGoal,
    required this.waterIntakeLiters,
    required this.waterGoalLiters,
    required this.workoutsThisWeek,
    required this.weeklyGoal,
    required this.weeklyActivity,
  });

  double get stepsProgress => stepsToday / stepsGoal;
  double get caloriesProgress => caloriesBurned / caloriesGoal;
  double get activeMinutesProgress => activeMinutes / activeMinutesGoal;
  double get waterProgress => waterIntakeLiters / waterGoalLiters;

  @override
  List<Object?> get props => [
        stepsToday,
        caloriesBurned,
        activeMinutes,
        waterIntakeLiters,
        workoutsThisWeek,
      ];
}

class WeeklyActivityEntity extends Equatable {
  final String day;
  final double value;
  final bool isToday;

  const WeeklyActivityEntity({
    required this.day,
    required this.value,
    this.isToday = false,
  });

  @override
  List<Object?> get props => [day, value, isToday];
}
