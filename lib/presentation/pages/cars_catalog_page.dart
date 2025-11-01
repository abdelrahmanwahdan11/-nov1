import 'package:flutter/material.dart';

import 'package:jewelx/data/mock/mock_data.dart';

class CarsCatalogPage extends StatelessWidget {
  const CarsCatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cars = MockData.cars;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cars.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final car = cars[index];
        return Card(
          child: ListTile(
            leading: JewelCachedImage(imageUrl: car.images.first, width: 80, height: 56, borderRadius: BorderRadius.circular(16)),
            title: Text(car.name),
            subtitle: Text('${car.brand} • ${car.year}'),
            trailing: Text('\$${car.price.toStringAsFixed(0)}'),
            onTap: () => Navigator.of(context).pushNamed('/compare/cars'),
          ),
        );
      },
    );
  }
}
