import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/core/theme/app_theme.dart';

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});

  static const routeName = '/order/success';

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    final checkoutController = ControllersScope.of(context).checkoutController;
    final orderId = (ModalRoute.of(context)?.settings.arguments as String?) ??
        checkoutController.orderId;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(localization.translate('checkout')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
              boxShadow: tokens?.softShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    localization.translate('orderDone'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localization.translate('orderSuccess'),
                    textAlign: TextAlign.center,
                  ),
                  if (orderId != null && orderId.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(tokens?.pillRadius ?? 18),
                      ),
                      child: Text(
                        '${localization.translate('orderId')}: $orderId',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () {
                      checkoutController.clearOrder();
                      Navigator.of(context).popUntil(
                        (route) =>
                            route.settings.name == '/home' || route.isFirst,
                      );
                    },
                    child: Text(localization.translate('backToHome')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
