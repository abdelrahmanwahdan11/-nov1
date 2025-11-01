import 'package:flutter/foundation.dart';

@immutable
class Offer {
  const Offer({
    required this.id,
    required this.itemId,
    required this.amount,
    required this.message,
    required this.createdAt,
    required this.from,
  });

  final String id;
  final String itemId;
  final double amount;
  final String message;
  final int createdAt;
  final String from;

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      amount: (json['amount'] as num).toDouble(),
      message: json['message'] as String,
      createdAt: json['createdAt'] as int,
      from: json['from'] as String,
    );
  }
}
