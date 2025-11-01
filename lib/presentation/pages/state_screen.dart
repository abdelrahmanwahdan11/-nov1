import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/jewel_loader.dart';

enum JewelStateVariant { empty, error, offline }

class JewelStateScreen extends StatelessWidget {
  const JewelStateScreen({super.key, required this.variant});

  final JewelStateVariant variant;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    final data = _StateData.fromVariant(variant, t, theme.colorScheme.primary);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
          ),
          elevation: 0,
          color: theme.colorScheme.surface.withOpacity(0.86),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon, size: 48, color: data.color),
                const SizedBox(height: 20),
                Text(
                  data.title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  data.message,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                  textAlign: TextAlign.center,
                ),
                if (variant == JewelStateVariant.offline) ...[
                  const SizedBox(height: 24),
                  const JewelLoader(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StateData {
  const _StateData({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;

  static _StateData fromVariant(JewelStateVariant variant, AppLocalizations t, Color accent) {
    switch (variant) {
      case JewelStateVariant.empty:
        return _StateData(
          title: t.translate('emptyStateTitle'),
          message: t.translate('emptyStateMessage'),
          icon: IconlyBold.folder,
          color: accent,
        );
      case JewelStateVariant.error:
        return _StateData(
          title: t.translate('errorStateTitle'),
          message: t.translate('errorStateMessage'),
          icon: IconlyBold.info_circle,
          color: Colors.redAccent,
        );
      case JewelStateVariant.offline:
        return _StateData(
          title: t.translate('offlineStateTitle'),
          message: t.translate('offlineStateMessage'),
          icon: IconlyBold.danger,
          color: accent,
        );
    }
  }
}
