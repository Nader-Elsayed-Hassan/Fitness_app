import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/workout_entity.dart';
import '../cubit/workout_active_cubit.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutActiveCubit, WorkoutActiveState>(
      listener: (context, state) {
        if (state is WorkoutActiveCompleted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<WorkoutActiveCubit>(),
                child: const WorkoutCompletedScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is WorkoutActiveRunning) {
          return _RunningScreen(state: state);
        }
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      },
    );
  }
}

class _RunningScreen extends StatelessWidget {
  final WorkoutActiveRunning state;
  const _RunningScreen({required this.state});

  @override
  Widget build(BuildContext context) {
    final exercise = state.currentExercise;
    final total = state.workout.exercises.length;
    final progress = total > 0
        ? (state.currentExerciseIndex + 1) / total
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _confirmExit(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        state.formattedTime,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        state.isPaused ? 'متوقف مؤقتاً' : 'جاري التمرين',
                        style: TextStyle(
                          color: state.isPaused
                              ? AppColors.accentOrange
                              : AppColors.accentGreen,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${state.currentExerciseIndex + 1}/$total',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Workout name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                state.workout.title,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Exercise card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: exercise != null
                    ? _ExerciseCard(exercise: exercise)
                    : _NoExercisesCard(workout: state.workout),
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlBtn(
                        icon: Icons.skip_previous_rounded,
                        onTap: state.currentExerciseIndex > 0
                            ? () => context
                                .read<WorkoutActiveCubit>()
                                .previousExercise()
                            : null,
                        size: 52,
                      ),
                      _ControlBtn(
                        icon: state.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        onTap: () =>
                            context.read<WorkoutActiveCubit>().pauseResume(),
                        size: 72,
                        isPrimary: true,
                      ),
                      _ControlBtn(
                        icon: Icons.skip_next_rounded,
                        onTap: () =>
                            context.read<WorkoutActiveCubit>().nextExercise(),
                        size: 52,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context
                        .read<WorkoutActiveCubit>()
                        .finishEarly(),
                    child: const Text(
                      'إنهاء التمرين مبكراً',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'إنهاء التمرين؟',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'هل تريد إنهاء التمرين الحالي؟',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('متابعة',
                style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WorkoutActiveCubit>().reset();
              Navigator.pop(context);
            },
            child: const Text('إنهاء',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.primary,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            exercise.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exercise.muscleGroup,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(
                label: 'مجموعات',
                value: '${exercise.sets}',
                icon: Icons.repeat_rounded,
              ),
              if (exercise.durationSeconds != null)
                _StatPill(
                  label: 'ثانية',
                  value: '${exercise.durationSeconds}',
                  icon: Icons.timer_outlined,
                )
              else
                _StatPill(
                  label: 'تكرار',
                  value: '${exercise.reps}',
                  icon: Icons.loop_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoExercisesCard extends StatelessWidget {
  final WorkoutEntity workout;
  const _NoExercisesCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center_rounded,
              color: AppColors.primary, size: 60),
          const SizedBox(height: 16),
          Text(
            workout.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${workout.durationMinutes} دقيقة • ${workout.caloriesBurn} سعرة',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool isPrimary;

  const _ControlBtn({
    required this.icon,
    required this.onTap,
    required this.size,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : onTap != null
                  ? AppColors.surfaceVariant
                  : AppColors.border,
          shape: BoxShape.circle,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: onTap != null ? Colors.white : AppColors.textMuted,
          size: isPrimary ? 36 : 26,
        ),
      ),
    );
  }
}

// ─── Completed Screen ───────────────────────────────────────────────────────

class WorkoutCompletedScreen extends StatelessWidget {
  const WorkoutCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutActiveCubit, WorkoutActiveState>(
      builder: (context, state) {
        if (state is! WorkoutActiveCompleted) {
          return const SizedBox.shrink();
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  // Trophy
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: AppColors.primaryGradient),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '🎉 أحسنت!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أكملت تمرين ${state.workout.title}',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _ResultCard(
                          icon: Icons.timer_rounded,
                          label: 'الوقت',
                          value: state.formattedTime,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ResultCard(
                          icon: Icons.local_fire_department_rounded,
                          label: 'السعرات',
                          value: '${state.caloriesBurned}',
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<WorkoutActiveCubit>().reset();
                        Navigator.of(context)
                          ..pop()
                          ..pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'العودة للرئيسية',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
