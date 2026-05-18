import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;

  ProfileCubit(this._authRepository) : super(ProfileInitial());

  void loadProfile(UserEntity user) {
    emit(ProfileLoaded(user: user, isEditing: false));
  }

  Future<void> saveProfile({
    required UserEntity current,
    required String name,
    required int age,
    required double weight,
    required double height,
    required String fitnessGoal,
    required String bio,
  }) async {
    emit(ProfileSaving());
    try {
      final updated = current.copyWith(
        name: name,
        age: age,
        weight: weight,
        height: height,
        fitnessGoal: fitnessGoal,
        bio: bio,
      );
      final saved = await _authRepository.updateProfile(updated);
      emit(ProfileLoaded(user: saved, isEditing: false));
      emit(ProfileSaved(saved));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
