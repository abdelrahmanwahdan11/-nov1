import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/controllers_scope.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/core/theme/app_theme.dart';
import 'saved_searches_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _alphaSlider = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appController = ControllersScope.of(context).appController;
    _alphaSlider = appController.primaryOpacity.clamp(0.5, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final appController = controllers.appController;
    final authController = controllers.authController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();

    final presetPalette = appController.presetPalette();
    final palette = {
      for (final color in [...presetPalette, ...appController.similarPalette()])
        color.value: color,
    }.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text(localization.translate('settings'))),
      body: AnimatedBuilder(
        animation: Listenable.merge([appController, authController]),
        builder: (context, _) {
          final user = authController.currentUser;
          final locales = AppLocalizations.supportedLocales;
          final currentLocale = appController.locale;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            children: [
              _SettingsSection(
                title: localization.translate('accountSettings'),
                tokens: tokens,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(user.displayName.characters.first.toUpperCase()),
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                      )
                    else
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person_outline),
                        title: Text(localization.translate('guest')),
                        subtitle: Text(localization.translate('signIn')), 
                      ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: user == null
                          ? () => Navigator.of(context).pushNamed('/auth/signin')
                          : () {
                              authController.signOut();
                              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => route.isFirst);
                            },
                      icon: Icon(user == null ? Icons.login : Icons.logout),
                      label: Text(localization.translate(user == null ? 'signIn' : 'signOut')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: localization.translate('appPreferences'),
                tokens: tokens,
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: appController.isDark,
                      onChanged: (value) => appController.setDark(value),
                      title: Text(localization.translate('darkMode')),
                      secondary: const Icon(Icons.nightlight_round),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.translate('primaryColor')),
                      subtitle: Text(localization.translate('tintPickerHelp')),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final color in palette)
                          _ColorOption(
                            color: color,
                            selected: color.value == appController.seedColor.value,
                            onTap: () {
                              setState(() {});
                              appController
                                ..setSeed(color)
                                ..setAlpha(_alphaSlider);
                            },
                            tokens: tokens,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(localization.translate('opacityControl')),
                      subtitle: Text(localization.translate('opacityPickerHelp')),
                    ),
                    Slider(
                      value: _alphaSlider,
                      min: 0.5,
                      max: 1.0,
                      divisions: 10,
                      label: _alphaSlider.toStringAsFixed(2),
                      onChanged: (value) {
                        setState(() => _alphaSlider = value);
                        appController.setAlpha(value);
                      },
                    ),
                    Wrap(
                      spacing: 12,
                      children: [
                        for (final locale in locales)
                          ChoiceChip(
                            label: Text(locale.languageCode.toUpperCase()),
                            selected: locale == currentLocale,
                            onSelected: (_) => appController.setLocale(locale),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: localization.translate('marketplaceTools'),
                tokens: tokens,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.inventory_2_outlined),
                      title: Text(localization.translate('myItems')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pushNamed('/my-items'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.bookmarks_outlined),
                      title: Text(localization.translate('savedSearches')),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pushNamed(SavedSearchesPage.routeName),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.tips_and_updates_outlined),
                      title: Text(localization.translate('showTutorialAgain')),
                      onTap: () => Navigator.of(context).pushNamed('/tutorial'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }



class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
    this.tokens,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final JewelThemeTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
          border: Border.all(color: borderColor, width: selected ? 3 : 1),
          boxShadow: tokens?.softShadow,
        ),
        child: selected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.tokens,
    required this.child,
  });

  final String title;
  final JewelThemeTokens? tokens;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.85),
            borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
            boxShadow: tokens?.softShadow,
          ),
          child: child,
        ),
      ],
    );
  }
}
