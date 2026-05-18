import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Simple in-memory storage that simulates persistence.
/// Replace with SharedPreferences / Hive in production.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Map<String, dynamic> _store = {};

  void write(String key, dynamic value) => _store[key] = value;

  T? read<T>(String key) {
    final v = _store[key];
    if (v is T) return v;
    return null;
  }

  bool containsKey(String key) => _store.containsKey(key);

  void remove(String key) => _store.remove(key);

  void clear() => _store.clear();

  // JSON helpers
  void writeJson(String key, Map<String, dynamic> json) =>
      write(key, jsonEncode(json));

  Map<String, dynamic>? readJson(String key) {
    final raw = read<String>(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('LocalStorageService.readJson error: $e');
      return null;
    }
  }
}
