import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<String?> getString(String key);
  Future<bool?> getBool(String key);
}

class PreferencesSettingsRepository implements SettingsRepository {
  @override
  Future<String?> getString(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  @override
  Future<bool?> getBool(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  }
}
