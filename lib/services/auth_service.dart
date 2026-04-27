import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Identifiants en dur — modifier ici si besoin
  static const String _validUser = 'admin';
  static const String _validPass = 'smart123';

  static Future<bool> login(String username, String password) async {
    if (username.trim() == _validUser && password == _validPass) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged_in', true);
      await prefs.setString('username', username);
      return true;
    }
    return false;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logged_in') ?? false;
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
  }
}
