import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is DashboardError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          if (state is DashboardLoaded) {
            return _DashboardContent(stats: state.stats);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final UserStatsEntity stats;

  const _DashboardContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              _buildGreeting(context),
              const SizedBox(height: 20),
              _buildTodayGoalCard(),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'إحصائيات اليوم',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCaloriesStatCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildActiveMinutesCard()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildWaterIntakeCard()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildWorkoutsCard()),
                ],
              ),
              const SizedBox(height: 20),
              _buildWeeklyActivity(),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      pinned: false,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'FITNESS PRO',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (ctx) {
            final count = NotificationService().unreadCount;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    final name = user?.name.split(' ').first ?? 'بطل';
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 18) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('👋', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              '$greeting، $name',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${stats.workoutsThisWeek} من 5 تمارين هذا الأسبوع',
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTodayGoalCard() {
    final stepsGoal = 10000;
    final currentSteps = stats.stepsToday;
    final percentage = ((currentSteps / stepsGoal) * 100).toInt();
    final stepsRemaining = (stepsGoal - currentSteps) > 0 
        ? (stepsGoal - currentSteps) 
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5F8D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'هدف اليوم',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Color(0xFFB0C4FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${currentSteps.toStringAsFixed(1)}k خطوة',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stepsRemaining.toStringAsFixed(1)}k خطوة متبقية',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Color(0xFF8FA9C9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFF2D4A6B),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF5B9FFF),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'تم',
                      style: TextStyle(
                        color: Color(0xFF8FA9C9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesStatCard() {
    final caloriesGoal = 1500;
    final currentCalories = stats.caloriesBurned;
    final percentage = ((currentCalories / caloriesGoal) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2C1A), Color(0xFF6B3E1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8C42).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Color(0xFFFFB380),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF8C42),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${currentCalories.toInt()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'سعرة محروقة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color(0xFFB89A7F),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveMinutesCard() {
    final minutesGoal = 60;
    final currentMinutes = stats.activeMinutes;
    final percentage = ((currentMinutes / minutesGoal) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A4D2E), Color(0xFF2D7A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ADE80).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Color(0xFF86EFAC),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.timer_outlined,
                color: Color(0xFF4ADE80),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$currentMinutes',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'دقيقة نشطة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color(0xFF8FB89F),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeCard() {
    final waterGoal = 2.5;
    final currentWater = stats.waterIntakeLiters;
    final percentage = ((currentWater / waterGoal) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C75), Color(0xFF1B6FA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B9DD9).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Color(0xFF7EC8E3),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.water_drop_outlined,
                color: Color(0xFF3B9DD9),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${currentWater.toStringAsFixed(1)}L',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'استهلاك الماء',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color(0xFF8FB8D4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsCard() {
    final workoutsGoal = 5;
    final currentWorkouts = stats.workoutsThisWeek;
    final percentage = ((currentWorkouts / workoutsGoal) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D2463), Color(0xFF5B3A8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA78BFA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Color(0xFFC4B5FD),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.fitness_center_rounded,
                color: Color(0xFFA78BFA),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$currentWorkouts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'تمارين',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color(0xFFB4A0C9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'النشاط الأسبوعي',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          // Simple bar chart placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildActivityBar('سبت', 0.4, false),
              _buildActivityBar('أحد', 0.6, false),
              _buildActivityBar('اثنين', 1.0, true),
              _buildActivityBar('ثلاثاء', 0.5, false),
              _buildActivityBar('أربعاء', 0.7, false),
              _buildActivityBar('خميس', 0.3, false),
              _buildActivityBar('جمعة', 0.8, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBar(String day, double value, bool isToday) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 100 * value,
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF5B9FFF) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isToday ? AppColors.primary : AppColors.textMuted,
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
