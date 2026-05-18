import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../progress/data/repositories/progress_repository_impl.dart';
import '../../../progress/presentation/cubit/progress_cubit.dart';
import '../../../workouts/data/repositories/workout_repository_impl.dart';
import '../../../workouts/presentation/cubit/workout_active_cubit.dart';
import '../../../workouts/presentation/cubit/workouts_cubit.dart';
import '../../../workouts/presentation/screens/workouts_screen.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../cubit/dashboard_cubit.dart';
import 'dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../progress/presentation/screens/progress_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    WorkoutsScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService();
    final authRepo = AuthRepositoryImpl(storage);
    final progressRepo = ProgressRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DashboardCubit(StatsRepositoryImpl())..loadStats(),
        ),
        BlocProvider(
          create: (_) =>
              WorkoutsCubit(WorkoutRepositoryImpl())..loadWorkouts(),
        ),
        BlocProvider(
          create: (_) => ProgressCubit(progressRepo)..loadProgress(),
        ),
        BlocProvider(
          create: (_) => ProfileCubit(authRepo),
        ),
        BlocProvider(
          create: (_) => WorkoutActiveCubit(progressRepo),
        ),
        // Provide AuthCubit down the tree so profile/logout can access it
        BlocProvider.value(
          value: context.read<AuthCubit>(),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFF101415),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
