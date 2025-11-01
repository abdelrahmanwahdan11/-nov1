import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jewelx/data/mock/mock_data.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';
import 'my_items_controller.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({MyItemsController? myItemsController})
      : _favorites = <String>{},
        _pageSize = 12 {
    if (myItemsController != null) {
      bindMyItems(myItemsController);
    }
  }

  static const double caratMinDefault = 0.0;
  static const double caratMaxDefault = 10.0;
  static const double priceMinDefault = 0.0;
  static const double priceMaxDefault = 100000.0;

  static const _prefFilters = 'catalog.filters';
  static const _prefSort = 'catalog.sort';
  static const _prefFavorites = 'catalog.favorites';

  final Set<String> _favorites;
  final int _pageSize;
  SharedPreferences? _prefs;
  bool _initialized = false;
  MyItemsController? _myItemsController;

  List<JewelryItem> _items = const [];
  bool _isLoading = false;
  bool _hasMore = false;
  String _query = '';
  Map<String, dynamic> _filters = {};
  String? _sort;
  int _page = 1;

  List<JewelryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get page => _page;
  String get query => _query;
  String? get sort => _sort;
  Map<String, dynamic> get filters => Map.unmodifiable(_filters);
  Set<String> get favorites => Set.unmodifiable(_favorites);

  Map<String, dynamic> exportFilters() => _encodeFilters(_filters);

  List<JewelryItem> composeSource() => List.unmodifiable(_composeSource());

  Future<void> initialize() async {
    if (_initialized) {
      await loadInitial();
      return;
    }
    _prefs = await SharedPreferences.getInstance();
    final storedFilters = _prefs!.getString(_prefFilters);
    if (storedFilters != null && storedFilters.isNotEmpty) {
      _filters = _decodeFilters(storedFilters);
    }
    _sort = _prefs!.getString(_prefSort);
    final storedFavorites = _prefs!.getStringList(_prefFavorites);
    if (storedFavorites != null) {
      _favorites
        ..clear()
        ..addAll(storedFavorites);
    }
    _initialized = true;
    await loadInitial();
  }

  void bindMyItems(MyItemsController controller) {
    if (identical(_myItemsController, controller)) {
      return;
    }
    _myItemsController?.removeListener(_handleMyItemsChanged);
    _myItemsController = controller;
    _myItemsController?.addListener(_handleMyItemsChanged);
  }

  @override
  void dispose() {
    _myItemsController?.removeListener(_handleMyItemsChanged);
    super.dispose();
  }

  Future<void> loadInitial() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final filtered = _applyQuery(_composeSource());
    _page = 1;
    _items = filtered.take(_pageSize).toList();
    _hasMore = filtered.length > _items.length;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _page += 1;
    final filtered = _applyQuery(_composeSource());
    final takeCount = _page * _pageSize;
    _items = filtered.take(takeCount).toList();
    _hasMore = filtered.length > _items.length;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _filters = _normalizeFilters(filters);
    await _persistFilters();
    await loadInitial();
  }

  Future<void> setSort(String? sortKey) async {
    _sort = sortKey;
    await _persistSort();
    await loadInitial();
  }

  Future<void> search(String query) async {
    _query = query;
    await loadInitial();
  }

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    _persistFavorites();
    notifyListeners();
  }

  List<JewelryItem> _composeSource() {
    final List<JewelryItem> combined = [];
    final seen = <String>{};
    for (final item in MockData.jewelry.where((item) => item.forSale)) {
      if (seen.add(item.id)) {
        combined.add(item);
      }
    }
    final myItems = _myItemsController?.myItems ?? const [];
    for (final item in myItems) {
      final eligible = item.awaitOffers && item.price == null;
      if (eligible && seen.add(item.id)) {
        combined.add(item);
      }
    }
    return combined;
  }

  List<JewelryItem> _applyQuery(List<JewelryItem> source) {
    return _applyQueryCustom(
      source,
      query: _query,
      filters: _filters,
      sortKey: _sort,
    );
  }

  List<JewelryItem> searchIndex(String query) {
    return _applyQueryCustom(
      _composeSource(),
      query: query,
      filters: _filters,
      sortKey: _sort,
    );
  }

  List<JewelryItem> _applyQueryCustom(
    List<JewelryItem> source, {
    String? query,
    Map<String, dynamic>? filters,
    String? sortKey,
  }) {
    final activeFilters = filters ?? const <String, dynamic>{};
    Iterable<JewelryItem> list = source;
    final q = query?.toLowerCase();
    if (q != null && q.isNotEmpty) {
      list = list.where((item) {
        final material = describeEnum(item.material);
        final condition = describeEnum(item.condition);
        final text = [
          item.name,
          item.brand,
          item.gem,
          item.description,
          item.color,
          item.ringSize,
          material,
          condition,
          item.carat.toStringAsFixed(1),
        ].join(' ').toLowerCase();
        return text.contains(q);
      });
    }

    final categoryFilter = activeFilters['category'];
    if (categoryFilter is Iterable<JewelryCategory> && categoryFilter.isNotEmpty) {
      final set = categoryFilter.toSet();
      list = list.where((item) => set.contains(item.category));
    }

    final materialFilter = activeFilters['material'];
    if (materialFilter is Iterable<JewelryMaterial> && materialFilter.isNotEmpty) {
      final set = materialFilter.toSet();
      list = list.where((item) => set.contains(item.material));
    }

    final conditionFilter = activeFilters['condition'];
    if (conditionFilter is Iterable<JewelryCondition> && conditionFilter.isNotEmpty) {
      final set = conditionFilter.toSet();
      list = list.where((item) => set.contains(item.condition));
    }

    final caratRange = activeFilters['carat'];
    if (caratRange is Map<String, dynamic>) {
      final min = (caratRange['min'] as num?)?.toDouble();
      final max = (caratRange['max'] as num?)?.toDouble();
      if (min != null) {
        list = list.where((item) => item.carat >= min);
      }
      if (max != null) {
        list = list.where((item) => item.carat <= max);
      }
    }

    final priceRange = activeFilters['price'];
    if (priceRange is Map<String, dynamic>) {
      final min = (priceRange['min'] as num?)?.toDouble();
      final max = (priceRange['max'] as num?)?.toDouble();
      list = list.where((item) {
        final price = item.price;
        if (price == null) {
          return true;
        }
        if (min != null && price < min) {
          return false;
        }
        if (max != null && price > max) {
          return false;
        }
        return true;
      });
    }

    final brandFilter = activeFilters['brand'];
    if (brandFilter is String && brandFilter.isNotEmpty) {
      final bq = brandFilter.toLowerCase();
      list = list.where((item) => item.brand.toLowerCase().contains(bq));
    }

    final sorted = list.toList();
    switch (sortKey) {
      case 'priceAsc':
        sorted.sort((a, b) {
          final aPrice = a.price ?? double.infinity;
          final bPrice = b.price ?? double.infinity;
          return aPrice.compareTo(bPrice);
        });
        break;
      case 'priceDesc':
        sorted.sort((a, b) {
          final aPrice = a.price ?? -1;
          final bPrice = b.price ?? -1;
          return bPrice.compareTo(aPrice);
        });
        break;
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      default:
        break;
    }

    return sorted;
  }

  Map<String, dynamic> _normalizeFilters(Map<String, dynamic> raw) {
    final result = <String, dynamic>{};
    for (final entry in raw.entries) {
      final value = entry.value;
      if (_isMeaningfulFilterValue(entry.key, value)) {
        result[entry.key] = value;
      }
    }
    return result;
  }

  bool _isMeaningfulFilterValue(String key, dynamic value) {
    if (value == null) return false;
    if (value is Iterable && value.isEmpty) return false;
    if (value is String && value.trim().isEmpty) return false;
    if (value is Map) {
      final min = (value['min'] as num?)?.toDouble();
      final max = (value['max'] as num?)?.toDouble();
      if (min == null && max == null) {
        return false;
      }
      if (key == 'carat' &&
          (min == null || min <= caratMinDefault) &&
          (max == null || max >= caratMaxDefault)) {
        return false;
      }
      if (key == 'price' &&
          (min == null || min <= priceMinDefault) &&
          (max == null || max >= priceMaxDefault)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _persistFilters() async {
    final filters = _filters;
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    if (filters.isEmpty) {
      await _prefs!.remove(_prefFilters);
    } else {
      await _prefs!.setString(_prefFilters, jsonEncode(_encodeFilters(filters)));
    }
  }

  Future<void> _persistSort() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    if (_sort == null || _sort!.isEmpty) {
      await _prefs!.remove(_prefSort);
    } else {
      await _prefs!.setString(_prefSort, _sort!);
    }
  }

  Future<void> _persistFavorites() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await _prefs!.setStringList(_prefFavorites, _favorites.toList());
  }

  Map<String, dynamic> _encodeFilters(Map<String, dynamic> filters) {
    final result = <String, dynamic>{};
    for (final entry in filters.entries) {
      final value = entry.value;
      if (value is Iterable<JewelryCategory>) {
        result[entry.key] = value.map(describeEnum).toList();
      } else if (value is Iterable<JewelryMaterial>) {
        result[entry.key] = value.map(describeEnum).toList();
      } else if (value is Iterable<JewelryCondition>) {
        result[entry.key] = value.map(describeEnum).toList();
      } else if (value is Map<String, dynamic>) {
        result[entry.key] = {
          'min': (value['min'] as num?)?.toDouble(),
          'max': (value['max'] as num?)?.toDouble(),
        };
      } else if (value is String) {
        result[entry.key] = value;
      }
    }
    return result;
  }

  Map<String, dynamic> _decodeFilters(String jsonStr) {
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    final result = <String, dynamic>{};

    Iterable<JewelryCategory> _parseCategories(dynamic value) {
      if (value is! List) return const [];
      return value
          .map((raw) => JewelryCategory.values.firstWhere(
                (e) => describeEnum(e) == raw,
                orElse: () => JewelryCategory.ring,
              ))
          .toSet();
    }

    Iterable<JewelryMaterial> _parseMaterials(dynamic value) {
      if (value is! List) return const [];
      return value
          .map((raw) => JewelryMaterial.values.firstWhere(
                (e) => describeEnum(e) == raw,
                orElse: () => JewelryMaterial.gold,
              ))
          .toSet();
    }

    Iterable<JewelryCondition> _parseConditions(dynamic value) {
      if (value is! List) return const [];
      return value
          .map((raw) => JewelryCondition.values.firstWhere(
                (e) => describeEnum(e) == raw,
                orElse: () => JewelryCondition.veryGood,
              ))
          .toSet();
    }

    if (decoded['category'] != null) {
      final parsed = _parseCategories(decoded['category']);
      if (parsed.isNotEmpty) {
        result['category'] = parsed;
      }
    }
    if (decoded['material'] != null) {
      final parsed = _parseMaterials(decoded['material']);
      if (parsed.isNotEmpty) {
        result['material'] = parsed;
      }
    }
    if (decoded['condition'] != null) {
      final parsed = _parseConditions(decoded['condition']);
      if (parsed.isNotEmpty) {
        result['condition'] = parsed;
      }
    }
    if (decoded['carat'] is Map) {
      final map = decoded['carat'] as Map;
      final min = (map['min'] as num?)?.toDouble();
      final max = (map['max'] as num?)?.toDouble();
      if (min != null || max != null) {
        result['carat'] = {'min': min, 'max': max};
      }
    }
    if (decoded['price'] is Map) {
      final map = decoded['price'] as Map;
      final min = (map['min'] as num?)?.toDouble();
      final max = (map['max'] as num?)?.toDouble();
      if (min != null || max != null) {
        result['price'] = {'min': min, 'max': max};
      }
    }
    final brand = decoded['brand'];
    if (brand is String && brand.isNotEmpty) {
      result['brand'] = brand;
    }

    return result;
  }

  void _handleMyItemsChanged() {
    loadInitial();
  }
}
