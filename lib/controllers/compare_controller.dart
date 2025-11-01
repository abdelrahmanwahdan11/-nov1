import 'package:flutter/foundation.dart';

class CompareController extends ChangeNotifier {
  final Set<String> _selectedIds = {};

  Set<String> get selectedIds => _selectedIds;

  void toggle(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void clear() {
    _selectedIds.clear();
    notifyListeners();
  }
}
