import 'package:flutter/material.dart';

import '../data/services/auth_service.dart';
import '../data/services/auth_storage.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.checking;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, dynamic>? _currentUser;
  String? _token;

  AuthStatus get status => _status;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> initialize() async {
    _status = AuthStatus.checking;
    _errorMessage = null;
    notifyListeners();

    final storedToken = await AuthStorage.getToken();

    if (storedToken == null || storedToken.isEmpty) {
      _token = null;
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final user = await AuthService.getCurrentUser(storedToken);
      _token = storedToken;
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } on AuthException catch (e) {
      if (e.message == 'Unauthorized') {
        await AuthStorage.clearToken();
        _token = null;
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      } else {
        _errorMessage = e.message;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat memvalidasi sesi.';
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newToken = await AuthService.login(
        username: username,
        password: password,
      );
      await AuthStorage.saveToken(newToken);
      _token = newToken;
      _currentUser = await AuthService.getCurrentUser(newToken);
      _status = AuthStatus.authenticated;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message == 'Unauthorized'
          ? 'Sesi tidak valid.'
          : e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan saat login.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthStorage.clearToken();
    _token = null;
    _currentUser = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
