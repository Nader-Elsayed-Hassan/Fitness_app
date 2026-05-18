import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/workout_entity.dart';
import '../cubit/workout_active_cubit.dart';
import '../cubit/workouts_cubit.dart';
import 'active_workout_screen.dart';
import 'workout_detail_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWorkoutSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: BlocBuilder<WorkoutsCubit, WorkoutsState>(
        builder: (context, state) {
          final workouts = state is WorkoutsLoaded
              ? state.workouts
                  .where((w) => _searchQuery.isEmpty ||
                      w.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList()
              : <WorkoutEntity>[];

          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildCategoryFilter(context, state),
                    const SizedBox(height: 20),
                    if (state is WorkoutsLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      )
                    else if (state is WorkoutsLoaded)
                      _buildWorkoutList(context, workouts)
                    else if (state is WorkoutsError)
                      Center(
                        child: Text(state.message,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                      ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.tune_rounded,
                color: AppColors.textSecondary),
            onPressed: () => _showFilterSheet(context),
          ),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.bolt_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'ابحث عن تمرين...',
                hintStyle: TextStyle(
                    color: AppColors.textMuted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WorkoutsState state) {
    final selectedCategory =
        state is WorkoutsLoaded ? state.selectedCategory : null;

    final categories = [
      (null, 'الكل'),
      (WorkoutCategory.strength, 'قوة'),
      (WorkoutCategory.cardio, 'كارديو'),
      (WorkoutCategory.hiit, 'HIIT'),
      (WorkoutCategory.yoga, 'يوغا'),
      (WorkoutCategory.flexibility, 'مرونة'),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (category, label) = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () =>
                context.read<WorkoutsCubit>().filterByCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutList(
      BuildContext context, List<WorkoutEntity> workouts) {
    if (workouts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  color: AppColors.textMuted, size: 48),
              SizedBox(height: 12),
              Text('لا توجد تمارين',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final strengthWorkouts =
        workouts.where((w) => w.category == WorkoutCategory.strength).toList();
    final otherWorkouts =
        workouts.where((w) => w.category != WorkoutCategory.strength).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (strengthWorkouts.isNotEmpty) ...[
          _buildSectionHeader(context, 'تمارين الصدر', strengthWorkouts),
          const SizedBox(height: 12),
          ...strengthWorkouts.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _WorkoutImageCard(
                  workout: w,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                              value: context.read<WorkoutsCubit>()),
                          BlocProvider.value(
                              value: context.read<WorkoutActiveCubit>()),
                        ],
                        child: WorkoutDetailScreen(workout: w),
                      ),
                    ),
                  ),
                  onStart: () {
                    context.read<WorkoutActiveCubit>().startWorkout(w);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<WorkoutActiveCubit>(),
                          child: const ActiveWorkoutScreen(),
                        ),
                      ),
                    );
                  },
                ),
              )),
          const SizedBox(height: 8),
        ],
        if (otherWorkouts.isNotEmpty) ...[
          _buildSectionHeader(context, 'تمارين أخرى', otherWorkouts),
          const SizedBox(height: 12),
          ...otherWorkouts.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _WorkoutImageCard(
                  workout: w,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(
                              value: context.read<WorkoutsCubit>()),
                          BlocProvider.value(
                              value: context.read<WorkoutActiveCubit>()),
                        ],
                        child: WorkoutDetailScreen(workout: w),
                      ),
                    ),
                  ),
                  onStart: () {
                    context.read<WorkoutActiveCubit>().startWorkout(w);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<WorkoutActiveCubit>(),
                          child: const ActiveWorkoutScreen(),
                        ),
                      ),
                    );
                  },
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, List<WorkoutEntity> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('عرض كل $title'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: const Text(
            'عرض الكل',
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          title,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'تصفية التمارين',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _FilterRow(
              label: 'المفضلة فقط',
              icon: Icons.favorite_rounded,
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('عرض المفضلة')),
                );
              },
            ),
            const SizedBox(height: 10),
            _FilterRow(
              label: 'الأقصر وقتاً',
              icon: Icons.timer_rounded,
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ترتيب حسب الوقت')),
                );
              },
            ),
            const SizedBox(height: 10),
            _FilterRow(
              label: 'الأعلى حرقاً للسعرات',
              icon: Icons.local_fire_department_rounded,
              color: AppColors.accentOrange,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ترتيب حسب السعرات')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAddWorkoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'إضافة تمرين',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'هذه الميزة ستكون متاحة قريباً. يمكنك حالياً الاختيار من التمارين الموجودة.',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('حسناً'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FilterRow(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(label,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 10),
            Icon(icon, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Workout Image Card ──────────────────────────────────────────────────────

class _WorkoutImageCard extends StatelessWidget {
  final WorkoutEntity workout;
  final VoidCallback onTap;
  final VoidCallback onStart;

  const _WorkoutImageCard({
    required this.workout,
    required this.onTap,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(workout.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0D1318),
        ),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A1520),
                    const Color(0xFF0D1318),
                    categoryColor.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),

            // Category icon
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 40,
              child: Center(
                child: Icon(
                  _categoryIcon(workout.category),
                  size: 100,
                  color: const Color(0xFF1A2530),
                ),
              ),
            ),

            // Duration badge
            Positioned(
              bottom: 56,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${workout.durationMinutes} دقيقة',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            // Quick start button
            Positioned(
              bottom: 56,
              right: 12,
              child: GestureDetector(
                onTap: onStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 3),
                      Text('ابدأ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      workout.title,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _DifficultyBadge(difficulty: workout.difficulty),
                        const SizedBox(width: 6),
                        const Icon(Icons.trending_up_rounded,
                            color: AppColors.primary, size: 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

class _DifficultyBadge extends StatelessWidget {
  final DifficultyLevel difficulty;
  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      DifficultyLevel.beginner => ('مستوى مبتدئ', AppColors.accentGreen),
      DifficultyLevel.intermediate =>
        ('مستوى متوسط', AppColors.accentOrange),
      DifficultyLevel.advanced => ('مستوى متقدم', Colors.redAccent),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.trending_up_rounded, color: color, size: 12),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
