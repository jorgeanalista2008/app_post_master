import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isChecking = true;
  bool get isChecking => _isChecking;

  /// Checks if a valid session exists in persistent storage
  Future<void> checkAuth() async {
    _isChecking = true;
    notifyListeners();

    try {
      final savedUser = await _authService.getSavedSession();
      if (savedUser != null) {
        _currentUser = savedUser;
        _isAuthenticated = true;
      }
    } catch (_) {
      // Ignore reading error
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Processes user login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Processes user registration
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(name, email, password);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initiates password recovery flow
  Future<bool> recoverPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.recoverPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs the current user out and clears stored session
  Future<void> logout() async {
    await _authService.clearSession();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
