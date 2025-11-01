import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/catalog_controller.dart';
import '../l10n/app_localizations.dart';
import 'cart_page.dart';
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
  CatalogController? _catalogController;

  final _pages = const [
    HomeDashboardPage(),
    CatalogPage(),
    SearchPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catalogController ??= ControllersScope.of(context).catalogController;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text([
          t.translate('home'),
          t.translate('catalog'),
          t.translate('search'),
          t.translate('favorites'),
          t.translate('profile'),
        ][_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: t.translate('home')),
          NavigationDestination(icon: const Icon(Icons.category), label: t.translate('catalog')),
          NavigationDestination(icon: const Icon(Icons.search), label: t.translate('search')),
          NavigationDestination(icon: const Icon(Icons.favorite), label: t.translate('favorites')),
          NavigationDestination(icon: const Icon(Icons.person), label: t.translate('profile')),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed('/catalog/jewelry'),
              icon: const Icon(Icons.compare),
              label: Text(t.translate('compare')),
            )
          : null,
    );
  }
}
