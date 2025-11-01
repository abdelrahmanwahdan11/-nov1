import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/jewelry_item.dart';

class CatalogController extends ChangeNotifier {
  CatalogController()
      : _items = MockData.jewelry,
        _favorites = <String>{},
        _pageSize = 12;

  List<JewelryItem> _items;
  final Set<String> _favorites;
  final int _pageSize;

  bool _isLoading = false;
  bool _hasMore = false;
  String _query = '';
  Map<String, dynamic> _filters = {};
  int _page = 1;

  List<JewelryItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get page => _page;
  String get query => _query;
  Set<String> get favorites => _favorites;

  Future<void> loadInitial() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _items = _applyQuery(MockData.jewelry);
    _page = 1;
    _hasMore = _items.length > _pageSize;
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
    final filtered = _applyQuery(MockData.jewelry);
    _hasMore = filtered.length > _page * _pageSize;
    _items = filtered.take(_page * _pageSize).toList();
    _isLoading = false;
    notifyListeners();
  }

  void applyFilters(Map<String, dynamic> filters) {
    _filters = filters;
    loadInitial();
  }

  void search(String query) {
    _query = query;
    loadInitial();
  }

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
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
    if (_filters.containsKey('category') && _filters['category'] != null) {
      final category = _filters['category'] as JewelryCategory;
      list = list.where((item) => item.category == category);
    }
    if (_filters.containsKey('material') && _filters['material'] != null) {
      final material = _filters['material'] as JewelryMaterial;
      list = list.where((item) => item.material == material);
    }
    return list.take(_page * _pageSize).toList();
  }
}
