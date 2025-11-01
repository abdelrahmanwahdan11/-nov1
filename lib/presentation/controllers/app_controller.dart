import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends ChangeNotifier {
  AppController({
    bool isDark = false,
    Color? seedColor,
    Locale? locale,
    double alpha = 1.0,
    bool seenTutorial = false,
  })  : _isDark = isDark,
        _seedColor = (seedColor ?? const Color(0xFFFF6FA4)).withOpacity(1),
        _alpha = alpha.clamp(0.5, 1.0),
        _locale = locale ?? const Locale('ar'),
        _seenTutorial = seenTutorial;

  static const _prefIsDark = 'app.isDark';
  static const _prefSeed = 'app.seed';
  static const _prefLocale = 'app.locale';
  static const _prefAlpha = 'app.alpha';
  static const _prefSeenTutorial = 'app.seenTutorial';

  bool _isDark;
  Color _seedColor;
  double _alpha;
  Locale _locale;
  bool _seenTutorial;

  bool get isDark => _isDark;
  Color get seedColor => _seedColor;
  double get alpha => _alpha;
  Color get primaryColor => _seedColor.withOpacity(_alpha);
  double get primaryOpacity => _alpha;
  Locale get locale => _locale;
  bool get seenTutorial => _seenTutorial;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_prefIsDark) ?? _isDark;
    final seedValue = prefs.getInt(_prefSeed);
    if (seedValue != null) {
      _seedColor = Color(seedValue).withOpacity(1);
    }
    _alpha = (prefs.getDouble(_prefAlpha) ?? _alpha).clamp(0.5, 1.0);
    final localeCode = prefs.getString(_prefLocale);
    if (localeCode != null && localeCode.isNotEmpty) {
      _locale = Locale(localeCode);
    }
    _seenTutorial = prefs.getBool(_prefSeenTutorial) ?? _seenTutorial;
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefIsDark, _isDark);
  }

  Future<void> setSeed(Color color) async {
    final normalized = color.withOpacity(1);
    if (_seedColor.value == normalized.value) return;
    _seedColor = normalized;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefSeed, _seedColor.value);
  }

  Future<void> setAlpha(double value) async {
    final clamped = value.clamp(0.5, 1.0);
    if ((_alpha - clamped).abs() < 0.0001) return;
    _alpha = clamped;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefAlpha, _alpha);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLocale, locale.languageCode);
  }

  Future<void> setSeenTutorial(bool value) async {
    if (_seenTutorial == value) return;
    _seenTutorial = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefSeenTutorial, _seenTutorial);
  }

  List<Color> similarPalette([Color? seed]) {
    final base = HSVColor.fromColor((seed ?? _seedColor).withOpacity(1));
    const offsets = <double>[-14, -7, 0, 7, 14];
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
      return color;
    }).toList();
  }

  List<Color> presetPalette() => const [
        Color(0xFFFF6FA4),
        Color(0xFFFF6A00),
        Color(0xFF006C9A),
        Color(0xFF17A589),
        Color(0xFF6F42C1),
        Color(0xFFFFB300),
      ];
}
