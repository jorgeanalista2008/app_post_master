import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String keyUserSession = 'user_session';
  static const String keyRegisteredUsers = 'registered_users';

  // Default credentials
  static const String defaultEmail = 'admin@dsdneo.cl';
  static const String defaultPassword = 'admin';
  static const String defaultName = 'Admin ERP';

  /// Performs simulated user login
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate delay

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    // 1. Check against registered users in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final usersJsonList = prefs.getStringList(keyRegisteredUsers) ?? [];

    for (final userJson in usersJsonList) {
      final userMap = json.decode(userJson);
      if (userMap['email'] == normalizedEmail && userMap['password'] == normalizedPassword) {
        final user = User(
          id: userMap['id'],
          name: userMap['name'],
          email: userMap['email'],
          role: userMap['role'] ?? 'Vendedor',
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await saveSession(user);
        return user;
      }
    }

    // 2. Check default credentials
    if (normalizedEmail == defaultEmail && normalizedPassword == defaultPassword) {
      final user = User(
        id: '1',
        name: defaultName,
        email: defaultEmail,
        role: 'Administrador',
        token: 'mock_token_admin_9999',
      );
      await saveSession(user);
      return user;
    }

    throw Exception('Credenciales inválidas. Intente con admin@dsdneo.cl / admin');
  }

  /// Performs simulated user registration
  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate delay

    final normalizedEmail = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    final usersJsonList = prefs.getStringList(keyRegisteredUsers) ?? [];

    // Check if email already exists
    for (final userJson in usersJsonList) {
      final userMap = json.decode(userJson);
      if (userMap['email'] == normalizedEmail) {
        throw Exception('El correo electrónico ya está registrado.');
      }
    }

    if (normalizedEmail == defaultEmail) {
      throw Exception('El correo electrónico ya está registrado.');
    }

    // Save user profile with password to allow subsequent logins
    final newUserMap = {
      'id': (usersJsonList.length + 2).toString(),
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password.trim(),
      'role': 'Vendedor',
    };

    usersJsonList.add(json.encode(newUserMap));
    await prefs.setStringList(keyRegisteredUsers, usersJsonList);
    return true;
  }

  /// Performs simulated password recovery
  Future<bool> recoverPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay
    // Just mock success, no actual email sent
    return true;
  }

  /// Saves the user session to SharedPreferences
  Future<void> saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserSession, json.encode(user.toJson()));
  }

  /// Clears the user session from SharedPreferences (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUserSession);
  }

  /// Retrieves the saved user session from SharedPreferences
  Future<User?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(keyUserSession);
    if (sessionJson == null) return null;
    try {
      final userMap = json.decode(sessionJson);
      return User.fromJson(userMap);
    } catch (_) {
      return null;
    }
  }
}
