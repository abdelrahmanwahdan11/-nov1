import 'package:flutter/widgets.dart';

import 'app_controller.dart';
import 'auth_controller.dart';
import 'catalog_controller.dart';
import 'cart_controller.dart';
import 'checkout_controller.dart';
import 'saved_searches_controller.dart';
import 'compare_controller.dart';
import 'messages_controller.dart';
import 'my_items_controller.dart';
import 'notification_controller.dart';

class ControllersScope extends InheritedWidget {
  const ControllersScope({
    super.key,
    required this.appController,
    required this.authController,
    required this.catalogController,
    required this.compareController,
    required this.myItemsController,
    required this.cartController,
    required this.checkoutController,
    required this.messagesController,
    required this.notificationController,
    required this.savedSearchesController,
    required super.child,
  });

  final AppController appController;
  final AuthController authController;
  final CatalogController catalogController;
  final CompareController compareController;
  final MyItemsController myItemsController;
  final CartController cartController;
  final CheckoutController checkoutController;
  final MessagesController messagesController;
  final NotificationController notificationController;
  final SavedSearchesController savedSearchesController;

  static ControllersScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ControllersScope>();
    assert(scope != null, 'ControllersScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(ControllersScope oldWidget) {
    return appController != oldWidget.appController ||
        authController != oldWidget.authController ||
        catalogController != oldWidget.catalogController ||
        compareController != oldWidget.compareController ||
        myItemsController != oldWidget.myItemsController ||
        cartController != oldWidget.cartController ||
        checkoutController != oldWidget.checkoutController ||
        messagesController != oldWidget.messagesController ||
        notificationController != oldWidget.notificationController ||
        savedSearchesController != oldWidget.savedSearchesController;
  }
}
