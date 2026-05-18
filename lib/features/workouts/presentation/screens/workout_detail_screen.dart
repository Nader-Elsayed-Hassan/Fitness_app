import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/workout_entity.dart';
import '../cubit/workout_active_cubit.dart';
import '../cubit/workouts_cubit.dart';
import 'active_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutEntity workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(workout.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary),
              ),
            ),
            actions: [
              // Favourite toggle
              BlocBuilder<WorkoutsCubit, WorkoutsState>(
                builder: (context, state) {
                  final isFav = workout.isFavorite;
                  return GestureDetector(
                    onTap: () =>
                        context.read<WorkoutsCubit>().toggleFavorite(workout.id),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.redAccent : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      categoryColor.withValues(alpha: 0.25),
                      AppColors.background,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _categoryIcon(workout.category),
                    size: 90,
                    color: categoryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title
                Text(
                  workout.title,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  workout.description,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    _StatPill(
                      icon: Icons.timer_rounded,
                      label: '${workout.durationMinutes} دقيقة',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.local_fire_department_rounded,
                      label: '${workout.caloriesBurn} سعرة',
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 10),
                    _StatPill(
                      icon: Icons.list_rounded,
                      label: '${workout.exerciseCount} تمرين',
                      color: AppColors.accentGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Exercises list
                if (workout.exercises.isNotEmpty) ...[
                  const Text(
                    'التمارين',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...workout.exercises.asMap().entries.map(
                        (e) => _ExerciseItem(
                          index: e.key + 1,
                          exercise: e.value,
                        ),
                      ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 20),

                // Start Workout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<WorkoutActiveCubit>()
                          .startWorkout(workout);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<WorkoutActiveCubit>(),
                            child: const ActiveWorkoutScreen(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'ابدأ التمرين',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Add to schedule (shows snackbar for now)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'تمت إضافة "${workout.title}" للجدول ✓'),
                          backgroundColor: AppColors.accentGreen,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: const Text(
                      'إضافة للجدول',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(WorkoutCategory cat) {
    switch (cat) {
      case WorkoutCategory.strength:
        return AppColors.accentOrange;
      case WorkoutCategory.cardio:
        return AppColors.accentGreen;
      case WorkoutCategory.hiit:
        return Colors.redAccent;
      case WorkoutCategory.yoga:
        return AppColors.accentPurple;
      case WorkoutCategory.flexibility:
        return AppColors.accent;
      case WorkoutCategory.sports:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(WorkoutCategory cat) {
    switch (cat) {
      case WorkoutCategory.strength:
        return Icons.fitness_center_rounded;
      case WorkoutCategory.cardio:
        return Icons.directions_run_rounded;
      case WorkoutCategory.hiit:
        return Icons.local_fire_department_rounded;
      case WorkoutCategory.yoga:
        return Icons.self_improvement_rounded;
      case WorkoutCategory.flexibility:
        return Icons.accessibility_new_rounded;
      case WorkoutCategory.sports:
        return Icons.sports_rounded;
    }
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final int index;
  final ExerciseEntity exercise;
  const _ExerciseItem({required this.index, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Sets / reps (right side in RTL)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${exercise.sets} مجموعات',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                exercise.durationSeconds != null
                    ? '${exercise.durationSeconds} ثانية'
                    : '${exercise.reps} تكرار',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  exercise.name,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  exercise.muscleGroup,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
