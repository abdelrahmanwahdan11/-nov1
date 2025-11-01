import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'catalog_controller.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';

class BrowsingHistoryController extends ChangeNotifier {
  static const _boxName = 'browsing_history';
  static const _storageKey = 'ids';
  static const int _maxEntries = 20;

  final List<String> _recentIds = <String>[];
  CatalogController? _catalogController;
  Box<dynamic>? _box;

  List<String> get recentIds => List.unmodifiable(_recentIds);

  List<JewelryItem> recentItems({int limit = 8}) {
    final source = _catalogController?.composeSource() ?? const <JewelryItem>[];
    if (source.isEmpty || _recentIds.isEmpty) {
      return const <JewelryItem>[];
    }
    final lookup = <String, JewelryItem>{
      for (final item in source) item.id: item,
    };
    final results = <JewelryItem>[];
    for (final id in _recentIds) {
      final item = lookup[id];
      if (item != null) {
        results.add(item);
      }
      if (results.length >= limit) {
        break;
      }
    }
    return results;
  }

  Future<void> initialize() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    final stored = _box!.get(_storageKey);
    if (stored is List) {
      _recentIds
        ..clear()
        ..addAll(stored.whereType<String>());
    }
  }

  void bindCatalog(CatalogController controller) {
    if (identical(_catalogController, controller)) {
      return;
    }
    _catalogController?.removeListener(_handleCatalogChanged);
    _catalogController = controller;
    _catalogController?.addListener(_handleCatalogChanged);
  }

  void registerView(String id) {
    if (id.isEmpty) return;
    _recentIds.remove(id);
    _recentIds.insert(0, id);
    if (_recentIds.length > _maxEntries) {
      _recentIds.removeRange(_maxEntries, _recentIds.length);
    }
    _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    if (_recentIds.isEmpty) return;
    _recentIds.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _box?.put(_storageKey, _recentIds);
  }

  void _handleCatalogChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _catalogController?.removeListener(_handleCatalogChanged);
    _box?.close();
    super.dispose();
  }
}
