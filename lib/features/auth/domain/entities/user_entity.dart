import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int age;
  final double weight; // kg
  final double height; // cm
  final String fitnessGoal;
  final int weeklyGoal; // workouts per week
  final String level;
  final String bio;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoal,
    required this.weeklyGoal,
    this.level = 'مستوى مبتدئ',
    this.bio = '',
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  UserEntity copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? age,
    double? weight,
    double? height,
    String? fitnessGoal,
    int? weeklyGoal,
    String? level,
    String? bio,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
      level: level ?? this.level,
      bio: bio ?? this.bio,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        age,
        weight,
        height,
        fitnessGoal,
        weeklyGoal,
        level,
        bio,
      ];
}
