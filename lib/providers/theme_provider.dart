import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advanced_login_app/theme.dart';

enum AppThemeType { light, dark, cyber }

class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'app_theme';

  AppThemeType _currentTheme = AppThemeType.dark; 

  ThemeProvider() {
    _loadSavedTheme();
  }

  AppThemeType get currentTheme => _currentTheme;

  ThemeData get themeData {
    switch (_currentTheme) {
      case AppThemeType.light:
        return AppTheme.lightTheme;
      case AppThemeType.cyber:
        return AppTheme.cyberTheme;
      case AppThemeType.dark:
      default:
        return AppTheme.darkTheme;
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    if (theme == _currentTheme) return;
    _currentTheme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, theme.name);
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      try {
        _currentTheme = AppThemeType.values
            .firstWhere((t) => t.name == saved, orElse: () => _currentTheme);
        notifyListeners();
      } catch (_) {
        // to do later
      }
    }
  }
}

