import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'catalog_page.dart';
import 'favorites_page.dart';
import 'home_dashboard_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    HomeDashboardPage(),
    CatalogPage(),
    SearchPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final cart = controllers.cartController;
    final notifications = controllers.notificationController;
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    final titles = [
      t.translate('home'),
      t.translate('catalog'),
      t.translate('search'),
      t.translate('favorites'),
      t.translate('profile'),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          titles[_index],
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          AnimatedBuilder(
            animation: cart,
            builder: (context, _) {
              return _RoundedAction(
                icon: Icons.shopping_bag_outlined,
                count: cart.totalItems,
                onTap: () => Navigator.of(context).pushNamed('/cart'),
              );
            },
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: notifications,
            builder: (context, _) {
              final unread = notifications.notifications.where((n) => !n.read).length;
              return _RoundedAction(
                icon: IconlyBold.notification,
                showDot: unread > 0,
                onTap: () => Navigator.of(context).pushNamed('/notifications'),
              );
            },
          ),
          const SizedBox(width: 12),
          _RoundedAction(
            icon: IconlyBold.setting,
            onTap: () => Navigator.of(context).pushNamed('/settings'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.of(context).padding.bottom / 2,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.78),
            borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 24),
            boxShadow: tokens?.softShadow,
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: [
              NavigationDestination(icon: const Icon(IconlyBold.home), label: t.translate('home')),
              NavigationDestination(
                icon: const Icon(IconlyBold.category),
                label: t.translate('catalog'),
              ),
              NavigationDestination(icon: const Icon(IconlyBold.search), label: t.translate('search')),
              NavigationDestination(icon: const Icon(IconlyBold.heart), label: t.translate('favorites')),
              NavigationDestination(icon: const Icon(IconlyBold.profile), label: t.translate('profile')),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedAction extends StatelessWidget {
  const _RoundedAction({
    required this.icon,
    required this.onTap,
    this.count,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? count;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: theme.colorScheme.surface.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: 22, color: theme.colorScheme.onSurface),
            ),
          ),
        ),
        if ((count ?? 0) > 0)
          Positioned(
            right: -2,
            top: -4,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                count! > 9 ? '9+' : '$count',
                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else if (showDot)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
