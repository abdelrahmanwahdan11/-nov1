import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/jewelry_item.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = ControllersScope.of(context).catalogController;
    final t = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: catalog,
      builder: (context, _) {
        final items = catalog.items;
        return RefreshIndicator(
          onRefresh: catalog.refresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _CatalogCard(item: item, t: t);
            },
          ),
        );
      },
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.item, required this.t});

  final JewelryItem item;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final catalog = ControllersScope.of(context).catalogController;
    final isFavorite = catalog.favorites.contains(item.id);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/details', arguments: item),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(item.images.first, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => catalog.toggleFavorite(item.id),
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(item.brand, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    item.price != null
                        ? '\$${item.price!.toStringAsFixed(0)}'
                        : t.translate('noPriceShown'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
