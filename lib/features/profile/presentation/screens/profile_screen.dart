import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../progress/data/repositories/progress_repository_impl.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../cubit/profile_cubit.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return _ProfileContent(user: user);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserEntity user;
  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),
                _buildStatsRow(context),
                const SizedBox(height: 24),
                _buildAchievementsSection(context),
                const SizedBox(height: 24),
                _buildMenuSection(context),
                const SizedBox(height: 16),
                _buildSignOutButton(context),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
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
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary),
            onPressed: () => _showSettingsSheet(context),
          ),
          const Text(
            'الملف الشخصي',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserEntity user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: ClipOval(
                child: Container(
                  color: const Color(0xFF1A2530),
                  child: const Icon(Icons.person_rounded,
                      color: Color(0xFF2A3540), size: 60),
                ),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.level,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (user.bio.isNotEmpty) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              user.bio,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, state) {
        final totalWorkouts =
            state is ProgressLoaded ? state.stats.totalWorkouts : 0;
        final totalHours = state is ProgressLoaded
            ? (state.stats.totalMinutes / 60).round()
            : 0;
        final streak =
            state is ProgressLoaded ? state.stats.currentStreak : 0;

        return Row(
          children: [
            Expanded(child: _StatBox(value: '$streak', label: 'أطول سلسلة')),
            const SizedBox(width: 10),
            Expanded(
                child: _StatBox(value: '$totalHours', label: 'الساعات التدريبية')),
            const SizedBox(width: 10),
            Expanded(
                child: _StatBox(
                    value: '$totalWorkouts', label: 'إجمالي التمارين')),
          ],
        );
      },
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _showAllAchievements(context),
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const Text(
              'الإنجازات',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _AchievementBadge(
                icon: Icons.fitness_center_rounded,
                label: 'وحش الصالة',
                unlocked: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AchievementBadge(
                icon: Icons.calendar_today_rounded,
                label: 'مواظب',
                unlocked: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AchievementBadge(
                icon: Icons.bolt_rounded,
                label: 'طاقة قصوى',
                unlocked: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline_rounded,
            label: 'تعديل البيانات الشخصية',
            onTap: () => _openEditProfile(context),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.flag_outlined,
            label: 'أهدافي الرياضية',
            onTap: () => _showGoalsSheet(context),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.history_rounded,
            label: 'تاريخ التمارين',
            onTap: () => _showWorkoutHistory(context),
          ),
          const _Divider(),
          _MenuItem(
            icon: Icons.settings_outlined,
            label: 'الإعدادات',
            onTap: () => _showSettingsSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
            SizedBox(width: 8),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ProfileCubit>()),
            BlocProvider.value(value: context.read<AuthCubit>()),
          ],
          child: EditProfileScreen(user: user),
        ),
      ),
    );
  }

  void _showGoalsSheet(BuildContext context) {
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
              'أهدافي الرياضية',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _GoalRow(
                icon: Icons.fitness_center_rounded,
                label: 'التمارين الأسبوعية',
                value: '${user.weeklyGoal} جلسات',
                color: AppColors.primary),
            const SizedBox(height: 10),
            _GoalRow(
                icon: Icons.flag_outlined,
                label: 'الهدف الرياضي',
                value: user.fitnessGoal,
                color: AppColors.accentGreen),
            const SizedBox(height: 10),
            _GoalRow(
                icon: Icons.monitor_weight_outlined,
                label: 'الوزن الحالي',
                value: '${user.weight} كجم',
                color: AppColors.accentOrange),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showWorkoutHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => BlocBuilder<ProgressCubit, ProgressState>(
          bloc: context.read<ProgressCubit>(),
          builder: (ctx, state) {
            final history =
                state is ProgressLoaded ? state.stats.history : [];
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'تاريخ التمارين',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: history.isEmpty
                      ? const Center(
                          child: Text('لا يوجد تاريخ بعد',
                              style: TextStyle(
                                  color: AppColors.textSecondary)))
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: history.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final h = history[i] as WorkoutHistoryEntry;
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${h.durationMinutes} دقيقة',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12),
                                      ),
                                      Text(
                                        '${h.caloriesBurned} سعرة',
                                        style: const TextStyle(
                                            color: AppColors.accentOrange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        h.title,
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        _formatDate(h.date),
                                        style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAllAchievements(BuildContext context) {
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
              'جميع الإنجازات',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AchievementBadge(
                    icon: Icons.fitness_center_rounded,
                    label: 'وحش الصالة',
                    unlocked: true),
                _AchievementBadge(
                    icon: Icons.calendar_today_rounded,
                    label: 'مواظب',
                    unlocked: true),
                _AchievementBadge(
                    icon: Icons.bolt_rounded,
                    label: 'طاقة قصوى',
                    unlocked: false),
                _AchievementBadge(
                    icon: Icons.local_fire_department_rounded,
                    label: 'محترق',
                    unlocked: false),
                _AchievementBadge(
                    icon: Icons.emoji_events_rounded,
                    label: 'بطل',
                    unlocked: false),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
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
              'الإعدادات',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _SettingToggle(label: 'الإشعارات', icon: Icons.notifications_outlined),
            const SizedBox(height: 10),
            _SettingToggle(label: 'الوضع الليلي', icon: Icons.dark_mode_outlined, initialValue: true),
            const SizedBox(height: 10),
            _SettingToggle(label: 'تذكير يومي', icon: Icons.alarm_rounded),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'هل تريد تسجيل الخروج من حسابك؟',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            child: const Text('خروج',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    return 'منذ ${diff.inDays} أيام';
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool unlocked;
  const _AchievementBadge(
      {required this.icon, required this.label, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: unlocked
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.cardBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Icon(icon,
              color: unlocked ? AppColors.primary : AppColors.textMuted,
              size: 28),
        ),
        const SizedBox(height: 8),
        Text(label,
            textDirection: TextDirection.rtl,
            style: TextStyle(
                color: unlocked
                    ? AppColors.textSecondary
                    : AppColors.textMuted,
                fontSize: 11)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: const Icon(Icons.chevron_left_rounded,
          color: AppColors.textMuted, size: 20),
      title: Text(label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      trailing: Icon(icon, color: AppColors.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(
        height: 1, color: AppColors.border, indent: 16, endIndent: 16);
  }
}

class _GoalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _GoalRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text(label,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool initialValue;
  const _SettingToggle(
      {required this.label, required this.icon, this.initialValue = false});

  @override
  State<_SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<_SettingToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: _value,
            onChanged: (v) => setState(() => _value = v),
            activeThumbColor: AppColors.primary,
          ),
          Row(
            children: [
              Text(widget.label,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Icon(widget.icon, color: AppColors.textSecondary, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
