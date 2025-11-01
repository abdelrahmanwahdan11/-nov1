import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/my_items_controller.dart';
import '../models/jewelry_item.dart';

class MyItemsPage extends StatelessWidget {
  const MyItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllersScope.of(context).myItemsController;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.myItems;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            return _ItemCard(item: item, controller: controller);
          },
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.controller});

  final JewelryItem item;
  final MyItemsController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleMedium),
            Text(item.brand),
            const SizedBox(height: 8),
            Row(
              children: [
                FilterChip(
                  label: Text(item.forSale ? 'For sale' : 'Await offers'),
                  selected: item.forSale,
                  onSelected: (value) {
                    controller.toggleSaleState(
                      item.id,
                      forSale: value,
                      awaitOffers: !value,
                    );
                  },
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Await offers'),
                  selected: item.awaitOffers,
                  onSelected: (value) {
                    controller.toggleSaleState(
                      item.id,
                      forSale: !value,
                      awaitOffers: value,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.tips),
          ],
        ),
      ),
    );
  }
}
