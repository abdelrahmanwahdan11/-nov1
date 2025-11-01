import 'jewelry_item.dart';

class CartEntry {
  const CartEntry({
    required this.item,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
  });

  final JewelryItem item;
  final int quantity;
  final String selectedSize;
  final String selectedColor;

  String get key => '${item.id}::$selectedSize::$selectedColor';

  double get lineTotal => (item.price ?? 0) * quantity;

  CartEntry copyWith({
    JewelryItem? item,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartEntry(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}
