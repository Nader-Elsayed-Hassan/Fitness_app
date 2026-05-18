import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/progress_repository_impl.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final ProgressRepository _repo;

  ProgressCubit(this._repo) : super(ProgressInitial());

  Future<void> loadProgress() async {
    emit(ProgressLoading());
    try {
      final stats = await _repo.getProgressStats();
      emit(ProgressLoaded(stats));
    } catch (e) {
      emit(ProgressError(e.toString()));
    }
  }
}
