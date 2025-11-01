import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/theme_controller.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final themeController = controllers.themeController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          children: [
            _SettingCard(
              tokens: tokens,
              child: SwitchListTile(
                value: themeController.isDark,
                onChanged: (_) => themeController.toggleDarkMode(),
                title: Text(localization.translate('darkMode')),
                secondary: const Icon(Icons.nightlight_round),
              ),
            ),
            const SizedBox(height: 16),
            _SettingCard(
              tokens: tokens,
              child: ListTile(
                title: Text(localization.translate('primaryColor')),
                subtitle: Text('#${themeController.primaryColor.value.toRadixString(16).padLeft(8, '0')}'),
                leading: CircleAvatar(backgroundColor: themeController.primaryColor),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickPrimaryColor(context, themeController, localization),
              ),
            ),
            const SizedBox(height: 16),
            _SettingCard(
              tokens: tokens,
              child: ListTile(
                title: Text(localization.translate('language')),
                subtitle: Text(themeController.locale.languageCode),
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickLanguage(context, themeController, localization),
              ),
            ),
            const SizedBox(height: 16),
            _SettingCard(
              tokens: tokens,
              child: ListTile(
                title: Text(localization.translate('resetDemoData')),
                leading: const Icon(Icons.refresh),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localization.translate('demoDataReset'))),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _SettingCard(
              tokens: tokens,
              child: ListTile(
                title: Text(localization.translate('showTutorialAgain')),
                leading: const Icon(Icons.school),
                onTap: () async {
                  await themeController.resetTutorialFlag();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localization.translate('tutorialReset'))),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickPrimaryColor(
    BuildContext context,
    ThemeController controller,
    AppLocalizations localization,
  ) async {
    final palette = [
      const Color(0xFFFF6FA4),
      const Color(0xFF6F9BFF),
      const Color(0xFFFFB86F),
      const Color(0xFF9B6FFF),
    ];
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localization.translate('primaryColor')),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in palette)
                GestureDetector(
                  onTap: () {
                    controller.setPrimary(color);
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(backgroundColor: color, radius: 22),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickLanguage(
    BuildContext context,
    ThemeController controller,
    AppLocalizations localization,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  localization.translate('language'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final locale in AppLocalizations.supportedLocales)
                ListTile(
                  title: Text(locale.languageCode),
                  trailing: controller.locale == locale
                      ? const Icon(Icons.check_rounded)
                      : const SizedBox.shrink(),
                  onTap: () {
                    controller.setLocale(locale);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.tokens, required this.child});

  final JewelThemeTokens? tokens;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
        boxShadow: tokens?.softShadow,
      ),
      child: child,
    );
  }
}
