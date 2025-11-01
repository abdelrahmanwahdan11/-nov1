import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/compare_controller.dart';
import '../controllers/controllers_scope.dart';
import '../data/mock_data.dart';
import '../models/car_item.dart';
import '../models/jewelry_item.dart';

class JewelryComparePage extends StatelessWidget {
  const JewelryComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final compare = controllers.compareController;
    final catalog = controllers.catalogController;
    return AnimatedBuilder(
      animation: Listenable.merge([compare, catalog]),
      builder: (context, _) {
        final selected = catalog.items
            .where((item) => compare.selectedIds.contains(item.id))
            .toList();
        if (selected.isEmpty) {
          return const Center(child: Text('Select items to compare'));
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Field')),
              DataColumn(label: Text('Value')),
            ],
            rows: selected
                .expand((item) => [
                      DataRow(cells: [
                        DataCell(Text(item.name)),
                        DataCell(Text(item.brand)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Material')),
                        DataCell(Text(item.material.name)),
                      ]),
                      DataRow(cells: [
                        const DataCell(Text('Carat')),
                        DataCell(Text(item.carat.toString())),
                      ]),
                    ])
                .toList(),
          ),
        );
      },
    );
  }
}

class CarComparePage extends StatelessWidget {
  const CarComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cars = MockData.cars;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Brand')),
          DataColumn(label: Text('Year')),
          DataColumn(label: Text('Mileage')),
          DataColumn(label: Text('Price')),
        ],
        rows: cars
            .map((car) => DataRow(cells: [
                  DataCell(Text(car.name)),
                  DataCell(Text(car.brand)),
                  DataCell(Text(car.year.toString())),
                  DataCell(Text('${car.mileage} km')),
                  DataCell(Text('\$${car.price.toStringAsFixed(0)}')),
                ]))
            .toList(),
      ),
    );
  }
}
