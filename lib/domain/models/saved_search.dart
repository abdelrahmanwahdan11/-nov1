import 'package:flutter/foundation.dart';

@immutable
class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.name,
    required this.query,
    required this.filters,
    this.priceAlertBelow,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String query;
  final Map<String, dynamic> filters;
  final double? priceAlertBelow;
  final DateTime createdAt;

  SavedSearch copyWith({
    String? id,
    String? name,
    String? query,
    Map<String, dynamic>? filters,
    double? priceAlertBelow,
    bool resetPriceAlert = false,
    DateTime? createdAt,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      name: name ?? this.name,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      priceAlertBelow: resetPriceAlert ? null : priceAlertBelow ?? this.priceAlertBelow,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'query': query,
      'filters': filters,
      'priceAlertBelow': priceAlertBelow,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['id'] as String,
      name: json['name'] as String,
      query: json['query'] as String? ?? '',
      filters: Map<String, dynamic>.from(json['filters'] as Map? ?? const {}),
      priceAlertBelow: (json['priceAlertBelow'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
