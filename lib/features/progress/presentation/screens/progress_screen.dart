import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../cubit/progress_cubit.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          if (state is ProgressLoading || state is ProgressInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is ProgressError) {
            return Center(
              child: Text(state.message,
                  style: const TextStyle(color: AppColors.textSecondary)),
            );
          }
          final stats =
              state is ProgressLoaded ? state.stats : null;

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                backgroundColor: AppColors.background,
                floating: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text(
                  'التقدم',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'نظرة عامة'),
                    Tab(text: 'التمارين'),
                    Tab(text: 'الجسم'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(stats: stats),
                _WorkoutsTab(history: stats?.history ?? []),
                _BodyTab(stats: stats),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final ProgressStats? stats;
  const _OverviewTab({this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SummaryBanner(stats: stats),
          const SizedBox(height: 24),
          _CaloriesChart(
              data: stats?.weeklyCalories ??
                  [1200, 1800, 1400, 2100, 1600, 1900, 1240]),
          const SizedBox(height: 24),
          _StepsChart(
              data: stats?.weeklySteps ??
                  [6200, 8400, 7100, 9800, 7500, 8900, 7842]),
        ],
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final ProgressStats? stats;
  const _SummaryBanner({this.stats});

  @override
  Widget build(BuildContext context) {
    final workouts = stats?.totalWorkouts ?? 0;
    final calories = stats?.totalCalories ?? 0;
    final hours = ((stats?.totalMinutes ?? 0) / 60).toStringAsFixed(1);
    final streak = stats?.currentStreak ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('هذا الشهر',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            '$workouts تمرين',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _MiniStat(label: 'سلسلة', value: '$streak أيام'),
              const SizedBox(width: 24),
              _MiniStat(label: 'ساعات', value: hours),
              const SizedBox(width: 24),
              _MiniStat(
                  label: 'سعرات',
                  value: '${(calories / 1000).toStringAsFixed(1)}k'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _CaloriesChart extends StatelessWidget {
  final List<double> data;
  const _CaloriesChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return _ChartCard(
      title: 'السعرات المحروقة',
      subtitle: 'آخر 7 أيام',
      child: SizedBox(
        height: 140,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.border, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
                    return Text(days[value.toInt() % 7],
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11));
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.accentOrange,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.accentOrange.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepsChart extends StatelessWidget {
  final List<double> data;
  const _StepsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return _ChartCard(
      title: 'الخطوات اليومية',
      subtitle: 'آخر 7 أيام',
      child: SizedBox(
        height: 140,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: AppColors.border, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const days = ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج'];
                    return Text(days[value.toInt() % 7],
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11));
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.primary,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _ChartCard(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
              Text(title,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Workouts Tab ─────────────────────────────────────────────────────────────

class _WorkoutsTab extends StatelessWidget {
  final List<WorkoutHistoryEntry> history;
  const _WorkoutsTab({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center_rounded,
                color: AppColors.textMuted, size: 48),
            SizedBox(height: 12),
            Text('لا يوجد تاريخ تمارين بعد',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = history[index];
        final color = _categoryColor(item.category);
        final icon = _categoryIcon(item.category);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.durationMinutes} دقيقة',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Text('${item.caloriesBurned} سعرة',
                      style: const TextStyle(
                          color: AppColors.accentOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item.title,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(_formatDate(item.date),
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    return 'منذ ${diff.inDays} أيام';
  }

  Color _categoryColor(dynamic cat) {
    switch (cat.toString()) {
      case 'WorkoutCategory.strength':
        return AppColors.accentOrange;
      case 'WorkoutCategory.cardio':
        return AppColors.accentGreen;
      case 'WorkoutCategory.hiit':
        return Colors.redAccent;
      case 'WorkoutCategory.yoga':
        return AppColors.accentPurple;
      default:
        return AppColors.primary;
    }
  }

  IconData _categoryIcon(dynamic cat) {
    switch (cat.toString()) {
      case 'WorkoutCategory.strength':
        return Icons.fitness_center_rounded;
      case 'WorkoutCategory.cardio':
        return Icons.directions_run_rounded;
      case 'WorkoutCategory.hiit':
        return Icons.local_fire_department_rounded;
      case 'WorkoutCategory.yoga':
        return Icons.self_improvement_rounded;
      default:
        return Icons.sports_rounded;
    }
  }
}

// ─── Body Tab ─────────────────────────────────────────────────────────────────

class _BodyTab extends StatelessWidget {
  final ProgressStats? stats;
  const _BodyTab({this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _BodyMetricCard(
            label: 'الوزن',
            value: '${stats?.weight ?? 74.5}',
            unit: 'كجم',
            change: '-1.5 كجم هذا الشهر',
            isPositive: true,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _BodyMetricCard(
            label: 'مؤشر كتلة الجسم',
            value: '${stats?.bmi ?? 22.8}',
            unit: '',
            change: 'نطاق طبيعي',
            isPositive: true,
            color: AppColors.accentGreen,
          ),
          const SizedBox(height: 12),
          _BodyMetricCard(
            label: 'نسبة الدهون',
            value: '${stats?.bodyFat ?? 18.2}',
            unit: '%',
            change: '-0.8% هذا الشهر',
            isPositive: true,
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: 12),
          _BodyMetricCard(
            label: 'الكتلة العضلية',
            value: '${stats?.muscleMass ?? 61.0}',
            unit: 'كجم',
            change: '+0.5 كجم هذا الشهر',
            isPositive: true,
            color: AppColors.accentPurple,
          ),
        ],
      ),
    );
  }
}

class _BodyMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String change;
  final bool isPositive;
  final Color color;

  const _BodyMetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.change,
    required this.isPositive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.w700),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(label,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 2),
                Text(change,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        color: isPositive
                            ? AppColors.accentGreen
                            : Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.monitor_weight_outlined, color: color, size: 24),
          ),
        ],
      ),
    );
  }
}
