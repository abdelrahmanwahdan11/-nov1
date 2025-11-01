import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/app_notification.dart';
import '../models/jewelry_item.dart';
import '../models/offer.dart';
import 'notification_controller.dart';

class MyItemsController extends ChangeNotifier {
  MyItemsController()
      : _myItems = List<JewelryItem>.from(MockData.jewelry),
        _offers = MockData.mockOffers('j1');

  final List<JewelryItem> _myItems;
  final List<Offer> _offers;
  bool _isSubmitting = false;
  NotificationController? _notificationController;

  List<JewelryItem> get myItems => List.unmodifiable(_myItems);
  List<Offer> get offers => List.unmodifiable(_offers);
  bool get isSubmitting => _isSubmitting;

  void bindNotificationController(NotificationController controller) {
    _notificationController = controller;
  }

  Future<void> addItem(JewelryItem item) async {
    _isSubmitting = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _myItems.add(item);
    _notificationController?.addSystemNotification(
      type: NotificationType.newArrival,
      title: item.name,
      message: 'Added to your private collection',
    );
    _isSubmitting = false;
    notifyListeners();
  }

  Future<void> editItem(JewelryItem item) async {
    final index = _myItems.indexWhere((element) => element.id == item.id);
    if (index == -1) return;
    _myItems[index] = item;
    notifyListeners();
  }

  void toggleSaleState(String id, {required bool forSale, required bool awaitOffers}) {
    final index = _myItems.indexWhere((element) => element.id == id);
    if (index == -1) return;
    final item = _myItems[index];
    _myItems[index] = item.copyWith(
      forSale: forSale,
      awaitOffers: awaitOffers,
    );
    if (forSale) {
      _notificationController?.addSystemNotification(
        type: NotificationType.priceDrop,
        title: item.name,
        message: 'Now available with a listed price',
      );
    } else if (awaitOffers) {
      _notificationController?.addSystemNotification(
        type: NotificationType.wishlist,
        title: item.name,
        message: 'Accepting private offers',
      );
    }
    notifyListeners();
  }

  void simulateIncomingOffer(String itemId, double amount) {
    final offer = Offer(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      itemId: itemId,
      amount: amount,
      message: 'New offer received',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      from: 'collector@jewelx.app',
    );
    _offers.add(offer);
    _notificationController?.pushMockOffer(offer);
    notifyListeners();
  }
}
