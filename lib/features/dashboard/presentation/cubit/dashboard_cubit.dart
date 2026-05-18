import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../../domain/entities/user_stats_entity.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final StatsRepository _statsRepository;

  DashboardCubit(this._statsRepository) : super(DashboardInitial());

  Future<void> loadStats() async {
    emit(DashboardLoading());
    try {
      final stats = await _statsRepository.getUserStats();
      emit(DashboardLoaded(stats));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
