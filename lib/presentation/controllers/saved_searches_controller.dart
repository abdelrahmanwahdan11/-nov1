import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jewelx/data/mock/mock_data.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';
import 'package:jewelx/domain/models/saved_search.dart';

import 'catalog_controller.dart';
import 'notification_controller.dart';

class SavedSearchesController extends ChangeNotifier {
  SavedSearchesController({
    CatalogController? catalogController,
    NotificationController? notificationController,
  }) {
    if (catalogController != null) {
      bindCatalog(catalogController);
    }
    if (notificationController != null) {
      bindNotifications(notificationController);
    }
  }

  static const _boxName = 'saved_searches';

  final List<SavedSearch> _list = [];
  CatalogController? _catalogController;
  NotificationController? _notificationController;
  Box<dynamic>? _box;

  List<SavedSearch> get list => List.unmodifiable(_list);

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }

  Future<void> initialize() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    _list
      ..clear()
      ..addAll(
        _box!.values
            .whereType<Map>()
            .map((value) => SavedSearch.fromJson(Map<String, dynamic>.from(value)))
            .toList(),
      );
    notifyListeners();
  }

  void bindCatalog(CatalogController controller) {
    _catalogController = controller;
  }

  void bindNotifications(NotificationController controller) {
    _notificationController = controller;
  }

  Future<void> saveCurrent({
    required String name,
    required String query,
    required Map<String, dynamic> filters,
    double? priceAlertBelow,
  }) async {
    final normalizedFilters = _sanitizeFilters(filters);
    final id = 'ss-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';
    final search = SavedSearch(
      id: id,
      name: name.isEmpty ? query.takeIfNotEmpty() ?? 'Search $id' : name,
      query: query,
      filters: normalizedFilters,
      priceAlertBelow: priceAlertBelow,
      createdAt: DateTime.now(),
    );
    _list.insert(0, search);
    await _persist(search);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    final index = _list.indexWhere((element) => element.id == id);
    if (index == -1) return;
    final removed = _list.removeAt(index);
    await _box?.delete(removed.id);
    notifyListeners();
  }

  Future<void> updatePriceAlert(String id, double? threshold) async {
    final index = _list.indexWhere((element) => element.id == id);
    if (index == -1) return;
    final updated = _list[index].copyWith(priceAlertBelow: threshold, resetPriceAlert: threshold == null);
    _list[index] = updated;
    await _persist(updated);
    notifyListeners();
  }

  Future<void> triggerMockAlerts() async {
    if (_notificationController == null) return;
    final catalog = _catalogController;
    final itemsSource = catalog?.composeSource() ?? MockData.jewelry;
    for (final search in _list) {
      if (search.priceAlertBelow == null) continue;
      final eligible = _applySearch(search, itemsSource)
          .where((item) => item.price != null && item.price! <= search.priceAlertBelow!);
      if (eligible.isEmpty) continue;
      final first = eligible.first;
      _notificationController!.pushPriceAlert(
        search: search,
        item: first,
      );
    }
  }

  Future<void> _persist(SavedSearch search) async {
    await _box?.put(search.id, search.toJson());
  }

  List<JewelryItem> _applySearch(SavedSearch search, List<JewelryItem> source) {
    final queryLower = search.query.toLowerCase().trim();
    return source.where((item) {
      final matchesQuery = queryLower.isEmpty
          ? true
          : [
                item.name,
                item.brand,
                item.gem,
                item.description,
                item.color,
                item.ringSize,
              ].any((field) => field.toLowerCase().contains(queryLower));
      final matchesFilters = _matchesFilters(search.filters, item);
      return matchesQuery && matchesFilters;
    }).toList();
  }

  Map<String, dynamic> _sanitizeFilters(Map<String, dynamic> filters) {
    return jsonDecode(jsonEncode(filters)) as Map<String, dynamic>;
  }

  bool _matchesFilters(Map<String, dynamic> filters, JewelryItem item) {
    if (filters.isEmpty) return true;
    bool match = true;
    filters.forEach((key, value) {
      if (!match) return;
      switch (key) {
        case 'category':
          final categories = (value as List?)?.cast<String>() ?? [];
          match = categories.isEmpty || categories.contains(item.category.name);
          break;
        case 'material':
          final materials = (value as List?)?.cast<String>() ?? [];
          match = materials.isEmpty || materials.contains(item.material.name);
          break;
        case 'condition':
          final conditions = (value as List?)?.cast<String>() ?? [];
          match = conditions.isEmpty || conditions.contains(item.condition.name);
          break;
        case 'price':
          final min = (value['min'] as num?)?.toDouble();
          final max = (value['max'] as num?)?.toDouble();
          final price = item.price;
          if (price == null) {
            match = min == null && max == null;
          } else {
            if (min != null && price < min) match = false;
            if (max != null && price > max) match = false;
          }
          break;
        case 'carat':
          final min = (value['min'] as num?)?.toDouble();
          final max = (value['max'] as num?)?.toDouble();
          if (min != null && item.carat < min) match = false;
          if (max != null && item.carat > max) match = false;
          break;
        case 'gem':
          final gem = (value as String?)?.toLowerCase() ?? '';
          match = gem.isEmpty || item.gem.toLowerCase().contains(gem);
          break;
        default:
          break;
      }
    });
    return match;
  }
}

extension on String {
  String? takeIfNotEmpty() => trim().isEmpty ? null : this;
}
