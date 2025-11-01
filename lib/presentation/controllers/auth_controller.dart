import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jewelx/data/mock/mock_data.dart';
import 'package:jewelx/domain/models/user.dart';

class AuthController extends ChangeNotifier {
  AuthController();

  static const _prefsKey = 'auth.currentUser';

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKey);
    if (id != null) {
      _currentUser = MockData.users.firstWhere(
        (u) => u.id == id,
        orElse: () => MockData.users.first,
      );
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    try {
      _currentUser = MockData.users.firstWhere(
        (user) => user.email == email,
        orElse: () => throw Exception('User not found'),
      );
      await _persist();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signUp({
    required String displayName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _currentUser = UserModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      isGuest: false,
    );
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> signInGuest() async {
    _currentUser = MockData.users.first;
    await _persist();
    notifyListeners();
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _currentUser!.id);
  }
}
