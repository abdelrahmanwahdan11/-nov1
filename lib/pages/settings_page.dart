import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final themeController = controllers.themeController;
    final t = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: Text(t.translate('darkMode')),
              value: themeController.isDark,
              onChanged: (_) => themeController.toggleDarkMode(),
            ),
            ListTile(
              title: Text(t.translate('primaryColor')),
              subtitle: Text('#${themeController.primaryColor.value.toRadixString(16)}'),
              trailing: const Icon(Icons.palette),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(t.translate('primaryColor')),
                      content: Wrap(
                        spacing: 12,
                        children: [
                          for (final color in const [
                            Color(0xFFFF6FA4),
                            Color(0xFF6F9BFF),
                            Color(0xFFFFB86F),
                            Color(0xFF9B6FFF),
                          ])
                            GestureDetector(
                              onTap: () {
                                themeController.setPrimary(color);
                                Navigator.of(context).pop();
                              },
                              child: CircleAvatar(backgroundColor: color, radius: 20),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              title: Text(t.translate('language')),
              subtitle: Text(themeController.locale.languageCode),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text(t.translate('language')),
                      children: AppLocalizations.supportedLocales
                          .map(
                            (locale) => SimpleDialogOption(
                              onPressed: () {
                                themeController.setLocale(locale);
                                Navigator.of(context).pop();
                              },
                              child: Text(locale.languageCode),
                            ),
                          )
                          .toList(),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
