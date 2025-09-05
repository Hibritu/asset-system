import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asset/models/user.dart';
import 'package:asset/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  UserModel? _user;
  ThemeMode _themeMode = ThemeMode.light;

  String? get token => _token;
  UserModel? get user => _user;
  ThemeMode get themeMode => _themeMode;

  // Toggle dark/light mode
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveThemeToPrefs(isDark);
    notifyListeners();
  }

  // Save theme to shared preferences
  Future<void> _saveThemeToPrefs(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // Load theme from shared preferences
  Future<void> loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Load token and user
  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = UserModel.fromJsonString(userJson);
    }

    await loadThemeFromPrefs(); // Optional: restore theme

    notifyListeners();
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      _token = response['token'];
      _user = UserModel.fromJson(response['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', _user!.toJsonString());

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<void> register(String username, String email, String password) async {
  try {
    await _authService.register(username, email, password);
    // Don't expect token or user, just notify UI
  } catch (e) {
    rethrow;
  }
}

  // Logout
  Future<void> logout() async {
    _token = null;
    _user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    notifyListeners();
  }


}
