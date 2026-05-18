part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final bool isEditing;
  const ProfileLoaded({required this.user, this.isEditing = false});
  @override
  List<Object?> get props => [user, isEditing];
}

class ProfileSaving extends ProfileState {}

class ProfileSaved extends ProfileState {
  final UserEntity user;
  const ProfileSaved(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
