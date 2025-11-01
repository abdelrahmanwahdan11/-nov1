import 'package:flutter/foundation.dart';

import '../models/app_notification.dart';
import '../models/offer.dart';

class NotificationPreferences {
  NotificationPreferences(Map<NotificationType, bool> values)
      : _map = Map<NotificationType, bool>.from(values);

  final Map<NotificationType, bool> _map;

  bool isEnabled(NotificationType type) => _map[type] ?? true;

  Map<NotificationType, bool> toMap() => Map.unmodifiable(_map);

  NotificationPreferences copyWith({NotificationType? type, bool? enabled}) {
    final map = Map<NotificationType, bool>.from(_map);
    if (type != null && enabled != null) {
      map[type] = enabled;
    }
    return NotificationPreferences(map);
  }
}

class NotificationController extends ChangeNotifier {
  NotificationController()
      : _notifications = <AppNotification>[],
        _preferences = NotificationPreferences({
          for (final type in NotificationType.values) type: true,
        });

  final List<AppNotification> _notifications;
  NotificationPreferences _preferences;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  NotificationPreferences get preferences => _preferences;

  bool isSubscribed(NotificationType type) => _preferences.isEnabled(type);

  void toggleSubscription(NotificationType type, bool enabled) {
    _preferences = _preferences.copyWith(type: type, enabled: enabled);
    notifyListeners();
  }

  List<AppNotification> filtered(NotificationType? filter) {
    if (filter == null) {
      return notifications;
    }
    return notifications.where((element) => element.type == filter).toList();
  }

  void push(AppNotification notification) {
    if (!_preferences.isEnabled(notification.type)) {
      return;
    }
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void pushMockOffer(Offer offer) {
    push(
      AppNotification(
        id: offer.id,
        title: 'Offer from ${offer.from}',
        message: 'Amount: ${offer.amount.toStringAsFixed(0)}',
        type: NotificationType.offer,
        timestamp: DateTime.fromMillisecondsSinceEpoch(offer.createdAt),
      ),
    );
  }

  void addSystemNotification({
    required NotificationType type,
    required String title,
    required String message,
  }) {
    push(
      AppNotification(
        id: 'sys-${DateTime.now().millisecondsSinceEpoch}-$type',
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
      ),
    );
  }

  void markRead(String id) {
    final index = _notifications.indexWhere((element) => element.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(read: true);
    notifyListeners();
  }

  void clearType(NotificationType type) {
    _notifications.removeWhere((element) => element.type == type);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
