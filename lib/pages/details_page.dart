import 'package:flutter/material.dart';

import '../models/jewelry_item.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  static const routeName = '/details';

  @override
  Widget build(BuildContext context) {
    final item = ModalRoute.of(context)?.settings.arguments as JewelryItem?;
    if (item == null) {
      return const Scaffold(
        body: Center(child: Text('No item provided')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        children: [
          SizedBox(
            height: 300,
            child: PageView(
              children: item.images
                  .map((url) => Image.network(url, fit: BoxFit.cover))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.brand, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(item.description),
                const SizedBox(height: 12),
                Text('Material: ${item.material.name}'),
                Text('Gem: ${item.gem}'),
                Text('Carat: ${item.carat}'),
                Text('Weight: ${item.weightGrams} g'),
                Text('Condition: ${item.condition.name}'),
                if (item.price != null)
                  Text('Price: ${item.price!.toStringAsFixed(0)}'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () {},
            child: const Text('Add to cart'),
          ),
        ),
      ),
    );
  }
}
