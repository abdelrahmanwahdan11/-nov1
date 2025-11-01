import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/compare_controller.dart';
import '../controllers/controllers_scope.dart';
import '../data/mock_data.dart';
import '../l10n/app_localizations.dart';
import '../models/car_item.dart';
import '../models/jewelry_item.dart';
import '../theme/app_theme.dart';

class JewelryComparePage extends StatelessWidget {
  const JewelryComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final compare = controllers.compareController;
    final catalog = controllers.catalogController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    return Scaffold(
      appBar: AppBar(title: Text(localization.translate('compare'))),
      body: AnimatedBuilder(
        animation: Listenable.merge([compare, catalog]),
        builder: (context, _) {
          final allItems = catalog.searchIndex('');
          final selected = allItems
              .where((item) => compare.selectedIds.contains(item.id))
              .toList();
          if (selected.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  localization.translate('compareNow'),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final fields = _comparisonFields(localization);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 24),
                color: theme.colorScheme.surface.withOpacity(0.9),
                boxShadow: tokens?.softShadow,
              ),
              child: DataTable(
                columnSpacing: 28,
                headingRowHeight: 56,
                columns: [
                  DataColumn(label: Text(localization.translate('details'))),
                  for (final item in selected)
                    DataColumn(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.name, style: theme.textTheme.titleSmall),
                          IconButton(
                            tooltip: localization.translate('remove'),
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => compare.toggle(item.id),
                          ),
                        ],
                      ),
                    ),
                ],
                rows: [
                  for (final field in fields)
                    DataRow(
                      cells: [
                        DataCell(Text(field.label)),
                        for (final item in selected)
                          DataCell(Text(field.resolve(item))),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localization.translate('ok')),
          ),
        ),
      ),
    );
  }

  List<_CompareField> _comparisonFields(AppLocalizations localization) {
    return [
      _CompareField(localization.translate('brand'), (item) => item.brand),
      _CompareField(localization.translate('material'), (item) => localization.translate(item.material.name)),
      _CompareField(localization.translate('gem'), (item) => item.gem),
      _CompareField(localization.translate('carat'), (item) => item.carat.toStringAsFixed(2)),
      _CompareField(localization.translate('weight'), (item) => '${item.weightGrams} g'),
      _CompareField(localization.translate('ringSize'), (item) => item.ringSize.isEmpty ? '-' : item.ringSize),
      _CompareField(localization.translate('condition'), (item) => localization.translate(item.condition.name)),
      _CompareField(
        localization.translate('price'),
        (item) => item.price != null
            ? '${localization.translate('currencySymbol')}${item.price!.toStringAsFixed(0)}'
            : localization.translate('priceOnRequest'),
      ),
    ];
  }
}

class _CompareField {
  const _CompareField(this.label, this.resolve);

  final String label;
  final String Function(JewelryItem item) resolve;
}

class CarComparePage extends StatelessWidget {
  const CarComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cars = MockData.cars;
    final localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localization.translate('carCompare'))),
      body: SingleChildScrollView(
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
      ),
    );
  }
}
