import 'package:flutter/foundation.dart';

enum NotificationType {
  offer,
  wishlist,
  priceAlert,
  newArrival,
}

extension NotificationTypeLabel on NotificationType {
  String key() {
    switch (this) {
      case NotificationType.offer:
        return 'notifications.offer';
      case NotificationType.wishlist:
        return 'notifications.wishlist';
      case NotificationType.priceAlert:
        return 'notifications.priceAlert';
      case NotificationType.newArrival:
        return 'notifications.newArrival';
    }
  }
}

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.read = false,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool read;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      read: read ?? this.read,
    );
  }
}
