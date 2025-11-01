import 'package:flutter/foundation.dart';

@immutable
class CarItem {
  const CarItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.images,
    required this.year,
    required this.mileage,
    required this.price,
    required this.specs,
  });

  final String id;
  final String name;
  final String brand;
  final List<String> images;
  final int year;
  final int mileage;
  final double price;
  final Map<String, String> specs;

  factory CarItem.fromJson(Map<String, dynamic> json) {
    return CarItem(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      images: List<String>.from(json['images'] as List<dynamic>),
      year: json['year'] as int,
      mileage: json['mileage'] as int,
      price: (json['price'] as num).toDouble(),
      specs: (json['specs'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
