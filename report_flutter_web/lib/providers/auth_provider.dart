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
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('rememberMe') ?? false;
    if (!saved) return;
    final userId = prefs.getInt('userId');
    final username = prefs.getString('username');
    final role = prefs.getString('role');
    final token = prefs.getString('token');
    if (userId != null && username != null && role != null && token != null) {
      _user = User(userId: userId, username: username, role: role, token: token);
      _rememberMe = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password, {bool rememberMe = false}) async {
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
      return false;
    } catch (e) {
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
    notifyListeners();
  }
}
