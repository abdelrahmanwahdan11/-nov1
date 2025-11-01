import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/jewelry_item.dart';
import 'my_items_controller.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({MyItemsController? myItemsController})
      : _favorites = <String>{},
        _pageSize = 12 {
    if (myItemsController != null) {
      bindMyItems(myItemsController);
    }
  }

  final Set<String> _favorites;
  final int _pageSize;
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
    await Future<void>.delayed(const Duration(milliseconds: 400));
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
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _page += 1;
    final filtered = _applyQuery(_composeSource());
    final takeCount = _page * _pageSize;
    _items = filtered.take(takeCount).toList();
    _hasMore = filtered.length > _items.length;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> applyFilters(Map<String, dynamic> filters) async {
    _filters = filters;
    await loadInitial();
  }

  Future<void> setSort(String? sortKey) async {
    _sort = sortKey;
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
    Iterable<JewelryItem> list = source;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((item) {
        final text = [
          item.name,
          item.brand,
          item.gem,
          item.description,
          item.color,
          item.ringSize,
        ].join(' ').toLowerCase();
        return text.contains(q);
      });
    }

    final categoryFilter = _filters['category'];
    if (categoryFilter != null) {
      if (categoryFilter is Iterable<JewelryCategory>) {
        final set = categoryFilter.toSet();
        list = list.where((item) => set.contains(item.category));
      } else if (categoryFilter is JewelryCategory) {
        list = list.where((item) => item.category == categoryFilter);
      }
    }

    final materialFilter = _filters['material'];
    if (materialFilter != null) {
      if (materialFilter is Iterable<JewelryMaterial>) {
        final set = materialFilter.toSet();
        list = list.where((item) => set.contains(item.material));
      } else if (materialFilter is JewelryMaterial) {
        list = list.where((item) => item.material == materialFilter);
      }
    }

    final conditionFilter = _filters['condition'];
    if (conditionFilter != null) {
      if (conditionFilter is Iterable<JewelryCondition>) {
        final set = conditionFilter.toSet();
        list = list.where((item) => set.contains(item.condition));
      } else if (conditionFilter is JewelryCondition) {
        list = list.where((item) => item.condition == conditionFilter);
      }
    }

    final caratRange = _filters['carat'];
    if (caratRange != null) {
      double? min;
      double? max;
      if (caratRange is List && caratRange.length >= 2) {
        min = (caratRange.first as num?)?.toDouble();
        max = (caratRange[1] as num?)?.toDouble();
      } else if (caratRange is Map) {
        min = (caratRange['min'] as num?)?.toDouble();
        max = (caratRange['max'] as num?)?.toDouble();
      }
      if (min != null) {
        list = list.where((item) => item.carat >= min!);
      }
      if (max != null) {
        list = list.where((item) => item.carat <= max!);
      }
    }

    final priceRange = _filters['price'];
    if (priceRange != null) {
      double? min;
      double? max;
      if (priceRange is List && priceRange.length >= 2) {
        min = (priceRange.first as num?)?.toDouble();
        max = (priceRange[1] as num?)?.toDouble();
      } else if (priceRange is Map) {
        min = (priceRange['min'] as num?)?.toDouble();
        max = (priceRange['max'] as num?)?.toDouble();
      }
      final minValue = min;
      final maxValue = max;
      list = list.where((item) {
        final price = item.price;
        if (price == null) {
          return true;
        }
        if (minValue != null && price < minValue) {
          return false;
        }
        if (maxValue != null && price > maxValue) {
          return false;
        }
        return true;
      });
    }

    final brandFilter = _filters['brand'];
    if (brandFilter is String && brandFilter.isNotEmpty) {
      final q = brandFilter.toLowerCase();
      list = list.where((item) => item.brand.toLowerCase().contains(q));
    }

    final sorted = list.toList();
    switch (_sort) {
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

  void _handleMyItemsChanged() {
    loadInitial();
  }
}
