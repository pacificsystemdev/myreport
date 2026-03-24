import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  final ApiService _apiService = ApiService();
  bool _rememberMe = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get rememberMe => _rememberMe;
  Future<void> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token'); // ✅ FIXED

      if (token != null && token.isNotEmpty) {
        _user = User(
          userId: prefs.getInt('userId') ?? 0,
          username: prefs.getString('username') ?? 'auto',
          role: prefs.getString('role') ?? 'user',
          token: token,
        );

        _rememberMe = true;
        notifyListeners();
        return;
      }

      // Optional: try refresh if token exists but expired
      if (token != null) {
        final response = await _apiService.refreshToken(token); // ✅ FIXED

        if (response['success']) {
          final userId = response['userId'];
          final newToken = response['accessToken']; // ✅ FIXED

          await prefs.setString('token', newToken);
          await prefs.setInt('userId', userId);

          _user = User(
            userId: userId,
            username: 'auto',
            role: 'user',
            token: newToken,
          );

          _rememberMe = true;
          notifyListeners();
        }
      }
    } catch (e) {
      print("Auto login error: $e");
    }
  }

  Future<bool> login(
    String username,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiService.login(username, password);
      if (response['success']) {
        _user = User.fromJson(response);
        _rememberMe = rememberMe;
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('rememberMe', true);
          await prefs.setInt('userId', _user!.userId);
          await prefs.setString('username', _user!.username);
          await prefs.setString('role', _user!.role);
          await prefs.setString('token', _user!.token);
        } else {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('rememberMe');
          await prefs.remove('userId');
          await prefs.remove('username');
          await prefs.remove('role');
          await prefs.remove('token');
        }
        notifyListeners();
        return true;
      }
      print('Login failed: success field is false');
      return false;
    } catch (e, stack) {
      print('Login exception: ' + e.toString());
      print(stack);
      return false;
    }
  }

  void logout() async {
    _user = null;
    _rememberMe = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('role');
    await prefs.remove('token');
    await prefs.clear();
    notifyListeners();
  }
}
