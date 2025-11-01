import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({
    bool isDark = false,
    Color? primaryColor,
    Locale? locale,
    bool seenTutorial = false,
  })  : _isDark = isDark,
        _primaryColor = primaryColor ?? const Color(0xFFFF6FA4),
        _locale = locale ?? const Locale('ar'),
        _seenTutorial = seenTutorial;

  static const _prefIsDark = 'theme.isDark';
  static const _prefPrimary = 'theme.primary';
  static const _prefLocale = 'theme.locale';
  static const _prefSeenTutorial = 'theme.seenTutorial';

  bool _isDark;
  Color _primaryColor;
  Locale _locale;
  bool _seenTutorial;

  bool get isDark => _isDark;
  Color get primaryColor => _primaryColor;
  Locale get locale => _locale;
  bool get seenTutorial => _seenTutorial;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefIsDark) ?? _isDark;
    final primaryValue = prefs.getInt(_prefPrimary);
    if (primaryValue != null) {
      _primaryColor = Color(primaryValue);
    }
    final localeCode = prefs.getString(_prefLocale);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
    _seenTutorial = prefs.getBool(_prefSeenTutorial) ?? _seenTutorial;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIsDark, _isDark);
  }

  Future<void> setPrimary(Color color) async {
    _primaryColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefPrimary, color.value);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLocale, locale.languageCode);
  }

  Future<void> markTutorialSeen() async {
    if (_seenTutorial) return;
    _seenTutorial = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefSeenTutorial, true);
  }

  Future<void> resetTutorialFlag() async {
    _seenTutorial = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefSeenTutorial);
  }
}
