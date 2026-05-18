import 'dart:convert';
import '../../domain/entities/user_entity.dart';
import '../../../../core/services/local_storage_service.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weight,
    required double height,
    required String fitnessGoal,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> updateProfile(UserEntity user);
}

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageService _storage;
  static const _userKey = 'current_user';
  static const _usersDbKey = 'users_database';

  AuthRepositoryImpl(this._storage);

  // Load users from storage or initialize with default user
  List<Map<String, dynamic>> _loadUsers() {
    final stored = _storage.read<String>(_usersDbKey);
    if (stored != null) {
      try {
        final List<dynamic> decoded = jsonDecode(stored);
        return decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        // If parsing fails, return default user
      }
    }
    // Default user
    return [
      {
        'id': 'u1',
        'name': 'أحمد محمد',
        'email': 'ahmed@example.com',
        'password': '123456',
        'age': 28,
        'weight': 80.0,
        'height': 178.0,
        'fitnessGoal': 'بناء العضلات',
        'weeklyGoal': 5,
        'level': 'مستوى متقدم',
        'bio':
            'أسعى دائماً لكسر حدودي البدنية. مدرب معتمد وشغوف برياضة رفع الأثقال وتطوير الأداء الرياضي العالمي.',
      },
    ];
  }

  // Save users to storage
  void _saveUsers(List<Map<String, dynamic>> users) {
    _storage.write(_usersDbKey, jsonEncode(users));
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final users = _loadUsers();
    final user = users.firstWhere(
      (u) =>
          u['email'] == email.trim() && u['password'] == password,
      orElse: () => throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
    );
    final entity = _mapToEntity(user);
    _storage.writeJson(_userKey, user);
    return entity;
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weight,
    required double height,
    required String fitnessGoal,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final users = _loadUsers();
    if (users.any((u) => u['email'] == email.trim())) {
      throw Exception('البريد الإلكتروني مستخدم بالفعل');
    }
    final newUser = {
      'id': 'u${users.length + 1}',
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
      'age': age,
      'weight': weight,
      'height': height,
      'fitnessGoal': fitnessGoal,
      'weeklyGoal': 4,
      'level': 'مستوى مبتدئ',
      'bio': '',
    };
    users.add(newUser);
    _saveUsers(users); // Save to storage
    final entity = _mapToEntity(newUser);
    _storage.writeJson(_userKey, newUser);
    return entity;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _storage.remove(_userKey);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final json = _storage.readJson(_userKey);
    if (json == null) return null;
    return _mapToEntity(json);
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final users = _loadUsers();
    final idx = users.indexWhere((u) => u['id'] == user.id);
    if (idx == -1) throw Exception('المستخدم غير موجود');
    users[idx] = {
      ...users[idx],
      'name': user.name,
      'age': user.age,
      'weight': user.weight,
      'height': user.height,
      'fitnessGoal': user.fitnessGoal,
      'weeklyGoal': user.weeklyGoal,
      'bio': user.bio,
    };
    _saveUsers(users); // Save to storage
    _storage.writeJson(_userKey, users[idx]);
    return _mapToEntity(users[idx]);
  }

  UserEntity _mapToEntity(Map<String, dynamic> m) => UserEntity(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        age: m['age'] as int,
        weight: (m['weight'] as num).toDouble(),
        height: (m['height'] as num).toDouble(),
        fitnessGoal: m['fitnessGoal'] as String,
        weeklyGoal: m['weeklyGoal'] as int,
        level: m['level'] as String? ?? 'مستوى مبتدئ',
        bio: m['bio'] as String? ?? '',
      );
}
