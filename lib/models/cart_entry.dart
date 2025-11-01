import 'jewelry_item.dart';

class CartEntry {
  const CartEntry({required this.item, required this.quantity});

  final JewelryItem item;
  final int quantity;

  double get lineTotal => (item.price ?? 0) * quantity;

  CartEntry copyWith({JewelryItem? item, int? quantity}) {
    return CartEntry(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}
