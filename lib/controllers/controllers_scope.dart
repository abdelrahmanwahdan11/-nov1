import 'package:flutter/widgets.dart';

import 'auth_controller.dart';
import 'catalog_controller.dart';
import 'compare_controller.dart';
import 'my_items_controller.dart';
import 'notification_controller.dart';
import 'theme_controller.dart';

class ControllersScope extends InheritedWidget {
  const ControllersScope({
    super.key,
    required this.themeController,
    required this.authController,
    required this.catalogController,
    required this.compareController,
    required this.myItemsController,
    required this.notificationController,
    required super.child,
  });

  final ThemeController themeController;
  final AuthController authController;
  final CatalogController catalogController;
  final CompareController compareController;
  final MyItemsController myItemsController;
  final NotificationController notificationController;

  static ControllersScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ControllersScope>();
    assert(scope != null, 'ControllersScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(ControllersScope oldWidget) {
    return themeController != oldWidget.themeController ||
        authController != oldWidget.authController ||
        catalogController != oldWidget.catalogController ||
        compareController != oldWidget.compareController ||
        myItemsController != oldWidget.myItemsController ||
        notificationController != oldWidget.notificationController;
  }
}
