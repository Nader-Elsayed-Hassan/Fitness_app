import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weight,
    required double height,
    required String fitnessGoal,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        age: age,
        weight: weight,
        height: height,
        fitnessGoal: fitnessGoal,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> updateProfile(UserEntity user) async {
    try {
      final updated = await _authRepository.updateProfile(user);
      emit(AuthAuthenticated(updated));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  UserEntity? get currentUser {
    final s = state;
    if (s is AuthAuthenticated) return s.user;
    return null;
  }
}
