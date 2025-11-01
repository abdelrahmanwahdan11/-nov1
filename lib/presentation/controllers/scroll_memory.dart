import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScrollMemory extends ChangeNotifier {
  static const _prefsKey = 'scroll_memory.offsets';

  final Map<String, double> _offsets = <String, double>{};
  bool _initialized = false;
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs?.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is num) {
          _offsets[entry.key] = value.toDouble();
        }
      }
    }
    _initialized = true;
  }

  double getOffset(String key) {
    return _offsets[key] ?? 0.0;
  }

  Future<void> save(String key, double value) async {
    if (!_initialized) {
      await initialize();
    }
    final rounded = value.clamp(0, double.infinity).toDouble();
    if ((_offsets[key] ?? -1) == rounded) {
      return;
    }
    _offsets[key] = rounded;
    notifyListeners();
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_prefsKey, jsonEncode(_offsets));
  }

  Future<void> clear(String key) async {
    if (!_initialized) {
      await initialize();
    }
    if (_offsets.remove(key) != null) {
      notifyListeners();
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(_prefsKey, jsonEncode(_offsets));
    }
  }
}
