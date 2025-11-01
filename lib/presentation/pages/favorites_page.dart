import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/controllers_scope.dart';
import '../widgets/jewel_cached_image.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final catalog = controllers.catalogController;
    return AnimatedBuilder(
      animation: catalog,
      builder: (context, _) {
        final favorites = catalog.items
            .where((item) => catalog.favorites.contains(item.id))
            .toList();
        if (favorites.isEmpty) {
          return const Center(child: Text('No favorites yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = favorites[index];
            return _FavoriteCard(item: item);
          },
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item});

  final JewelryItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          child: ClipOval(
            child: JewelCachedImage(imageUrl: item.images.first, width: 44, height: 44),
          ),
        ),
        title: Text(item.name),
        subtitle: Text(item.brand),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed('/details', arguments: item),
      ),
    );
  }
}
