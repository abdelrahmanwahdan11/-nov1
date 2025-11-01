import 'package:flutter/foundation.dart';

enum JewelryCategory { ring, necklace, bracelet, earring }
enum JewelryMaterial { gold, silver, roseGold, platinum }
enum JewelryCondition { newItem, likeNew, veryGood, good, needsRepair }

@immutable
class JewelryItem {
  const JewelryItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.images,
    required this.model3d,
    required this.material,
    required this.gem,
    required this.carat,
    required this.weightGrams,
    required this.ringSize,
    required this.color,
    required this.condition,
    this.certificate,
    this.price,
    required this.negotiable,
    required this.forSale,
    required this.awaitOffers,
    required this.tips,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String brand;
  final JewelryCategory category;
  final List<String> images;
  final String model3d;
  final JewelryMaterial material;
  final String gem;
  final double carat;
  final double weightGrams;
  final String ringSize;
  final String color;
  final JewelryCondition condition;
  final String? certificate;
  final double? price;
  final bool negotiable;
  final bool forSale;
  final bool awaitOffers;
  final String tips;
  final String description;
  final int createdAt;

  JewelryItem copyWith({
    String? id,
    String? name,
    String? brand,
    JewelryCategory? category,
    List<String>? images,
    String? model3d,
    JewelryMaterial? material,
    String? gem,
    double? carat,
    double? weightGrams,
    String? ringSize,
    String? color,
    JewelryCondition? condition,
    String? certificate,
    double? price,
    bool? negotiable,
    bool? forSale,
    bool? awaitOffers,
    String? tips,
    String? description,
    int? createdAt,
  }) {
    return JewelryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      images: images ?? this.images,
      model3d: model3d ?? this.model3d,
      material: material ?? this.material,
      gem: gem ?? this.gem,
      carat: carat ?? this.carat,
      weightGrams: weightGrams ?? this.weightGrams,
      ringSize: ringSize ?? this.ringSize,
      color: color ?? this.color,
      condition: condition ?? this.condition,
      certificate: certificate ?? this.certificate,
      price: price ?? this.price,
      negotiable: negotiable ?? this.negotiable,
      forSale: forSale ?? this.forSale,
      awaitOffers: awaitOffers ?? this.awaitOffers,
      tips: tips ?? this.tips,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory JewelryItem.fromJson(Map<String, dynamic> json) {
    return JewelryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      category: JewelryCategory.values.firstWhere(
        (e) => describeEnum(e) == json['category'],
      ),
      images: List<String>.from(json['images'] as List<dynamic>),
      model3d: json['model3d'] as String,
      material: JewelryMaterial.values.firstWhere(
        (e) => describeEnum(e) == json['material'],
      ),
      gem: json['gem'] as String,
      carat: (json['carat'] as num).toDouble(),
      weightGrams: (json['weightGrams'] as num).toDouble(),
      ringSize: json['ringSize'] as String,
      color: json['color'] as String,
      condition: () {
        final value = json['condition'] as String;
        if (value == 'new') {
          return JewelryCondition.newItem;
        }
        return JewelryCondition.values.firstWhere(
          (e) => describeEnum(e) == value,
          orElse: () => JewelryCondition.veryGood,
        );
      }(),
      certificate: json['certificate'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      negotiable: json['negotiable'] as bool? ?? false,
      forSale: json['forSale'] as bool? ?? false,
      awaitOffers: json['awaitOffers'] as bool? ?? false,
      tips: json['tips'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] as int? ?? 0,
    );
  }
}
