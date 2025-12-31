import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const _isLoggedIn = "is_logged_in";
  static const _userId = "user_id";
  static const _mobile = "mobile";
  static const _userName = "user_name";

  static Future<void> saveLogin({
    required String userId,
    required String mobile,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedIn, true);
    await prefs.setString(_userId, userId);
    await prefs.setString(_mobile, mobile);
    await prefs.setString(_userName, name);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedIn) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userId);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName);
  }
}
