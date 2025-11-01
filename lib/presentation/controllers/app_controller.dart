import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  AppController({
    bool isDark = false,
    Color? primaryColor,
    Locale? locale,
  })  : _isDark = isDark,
        _primaryColor = primaryColor ?? const Color(0xFFFF6FA4),
        _locale = locale ?? const Locale('ar');

  static const _prefIsDark = 'app.isDark';
  static const _prefPrimary = 'app.primary';
  static const _prefLocale = 'app.locale';

  bool _isDark;
  Color _primaryColor;
  Locale _locale;

  bool get isDark => _isDark;
  Color get primaryColor => _primaryColor;
  double get primaryOpacity => _primaryColor.opacity;
  Locale get locale => _locale;

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


  List<Color> similarPalette([Color? seed]) {
    final base = HSVColor.fromColor((seed ?? _primaryColor).withOpacity(1));
    const offsets = <double>[-14, -7, 0, 7, 14];
    final alpha = _primaryColor.opacity;
    return offsets.map((offset) {
      var hue = base.hue + offset;
      if (hue < 0) hue += 360;
      if (hue > 360) hue -= 360;
      final color = HSVColor.fromAHSV(
        base.alpha,
        hue,
        (base.saturation * 0.92).clamp(0.0, 1.0),
        (base.value * 0.98).clamp(0.0, 1.0),
      ).toColor();
      return color.withOpacity(alpha);
    }).toList();
  }

  Future<void> setPrimaryOpacity(double opacity) async {
    final clamped = opacity.clamp(0.5, 1.0);
    await setPrimary(_primaryColor.withOpacity(clamped));
  }

}
