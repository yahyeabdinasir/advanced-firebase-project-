import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefsService {
  static const String _lastEmailKey = 'lastEmail';

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastEmailKey, email);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastEmailKey);
  }
}
