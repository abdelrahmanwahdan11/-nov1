import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/cart_entry.dart';
import '../models/jewelry_item.dart';

class CartController extends ChangeNotifier {
  CartController({double shipping = 25, double discount = 0})
      : _shipping = shipping,
        _discount = discount;

  final List<CartEntry> _items = [];
  double _shipping;
  double _discount;
  String? _coupon;

  UnmodifiableListView<CartEntry> get items => UnmodifiableListView(_items);
  double get shipping => _shipping;
  double get discount => _discount;
  String? get coupon => _coupon;

  double get subtotal => _items.fold(0, (sum, entry) => sum + entry.lineTotal);
  double get total => (subtotal - _discount).clamp(0, double.infinity) + _shipping;

  void add(JewelryItem item) {
    final existingIndex = _items.indexWhere((entry) => entry.item.id == item.id);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      _items.add(CartEntry(item: item, quantity: 1));
    }
    _recalculateDiscount();
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((entry) => entry.item.id == id);
    _recalculateDiscount();
    notifyListeners();
  }

  void clear() {
    _items
      ..clear();
    _discount = 0;
    _coupon = null;
    notifyListeners();
  }

  void setQty(String id, int quantity) {
    final index = _items.indexWhere((entry) => entry.item.id == id);
    if (index == -1) return;
    if (quantity <= 0) {
      remove(id);
      return;
    }
    _items[index] = _items[index].copyWith(quantity: quantity);
    _recalculateDiscount();
    notifyListeners();
  }

  void applyCoupon(String? code) {
    if (code == null || code.isEmpty) {
      _coupon = null;
      _discount = 0;
      notifyListeners();
      return;
    }
    _coupon = code;
    _recalculateDiscount();
    notifyListeners();
  }

  void updateShipping(double value) {
    _shipping = value;
    notifyListeners();
  }

  void _recalculateDiscount() {
    if (_coupon == null || _coupon!.isEmpty) {
      _discount = 0;
      return;
    }
    if (_coupon!.toUpperCase() == 'JEWEL10') {
      _discount = subtotal * 0.1;
    } else {
      _discount = 0;
    }
  }
}
