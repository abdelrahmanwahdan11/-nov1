import 'package:flutter/material.dart';

import '../data/mock_data.dart';

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
            leading: Image.network(car.images.first, width: 80, fit: BoxFit.cover),
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
