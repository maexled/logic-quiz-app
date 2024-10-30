import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const _themeKey = 'theme';
  static const _defaultTheme = 'system';

  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  /// Returns the theme stored in the shared preferences
  /// or the default theme if no theme is stored or the stored theme is invalid.
  /// The valid themes are 'light', 'dark' and 'system'.
  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_themeKey)) {
      return _defaultTheme;
    }
    String theme = prefs.getString(_themeKey)!;
    if (theme != 'light' && theme != 'dark' && theme != 'system') {
      return _defaultTheme;
    }
    return theme;
  }
}
