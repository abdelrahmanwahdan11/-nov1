import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/core/theme/app_theme.dart';
import 'package:jewelx/domain/models/saved_search.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/saved_searches_controller.dart';

class SavedSearchesPage extends StatefulWidget {
  const SavedSearchesPage({super.key});

  static const routeName = '/saved-searches';

  @override
  State<SavedSearchesPage> createState() => _SavedSearchesPageState();
}

class _SavedSearchesPageState extends State<SavedSearchesPage> {
  @override
  Widget build(BuildContext context) {
    final scope = ControllersScope.of(context);
    final controller = scope.savedSearchesController;
    final localization = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<JewelThemeTokens>();
    final formatter = NumberFormat.compactCurrency(symbol: localization.translate('currencySymbol'));

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('savedSearches')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: localization.translate('triggerPriceAlerts'),
            onPressed: () async {
              await controller.triggerMockAlerts();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localization.translate('priceAlertsTriggered'))),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final saved = controller.list;
          if (saved.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  localization.translate('noSavedSearches'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: saved.length,
            itemBuilder: (context, index) {
              final search = saved[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
                  boxShadow: tokens?.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            search.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.remove(search.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (search.query.isNotEmpty)
                      Text(
                        '“${search.query}”',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in search.filters.entries)
                          Chip(
                            label: Text('${entry.key}: ${_describeFilterValue(entry.value)}'),
                          ),
                        if (search.filters.isEmpty)
                          Chip(label: Text(localization.translate('noFiltersApplied'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            search.priceAlertBelow != null
                                ? localization.translate('priceAlertBelow').replaceFirst(
                                      '{value}',
                                      formatter.format(search.priceAlertBelow),
                                    )
                                : localization.translate('noPriceAlert'),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _showPriceAlertSheet(context, controller, search),
                          icon: const Icon(Icons.price_change_outlined),
                          label: Text(localization.translate('setPriceAlert')),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showPriceAlertSheet(
    BuildContext context,
    SavedSearchesController controller,
    SavedSearch search,
  ) async {
    final localization = AppLocalizations.of(context);
    final thresholdController = TextEditingController(
      text: search.priceAlertBelow?.toStringAsFixed(0) ?? '',
    );
    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.translate('setPriceAlert'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: thresholdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: localization.translate('priceAlertLabel'),
                  suffixText: localization.translate('currencySymbol'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {
                      final value = double.tryParse(thresholdController.text);
                      Navigator.of(context).pop({'price': value});
                    },
                    child: Text(localization.translate('apply')),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop({'reset': true}),
                    child: Text(localization.translate('reset')),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (result == null) {
      return;
    }
    if (result['reset'] == true) {
      await controller.updatePriceAlert(search.id, null);
      return;
    }
    final value = result['price'] as double?;
    await controller.updatePriceAlert(search.id, value);
  }

  String _describeFilterValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    if (value is Map) {
      final min = value['min'];
      final max = value['max'];
      if (min != null && max != null) {
        return '$min - $max';
      }
      if (min != null) {
        return '≥ $min';
      }
      if (max != null) {
        return '≤ $max';
      }
    }
    return value?.toString() ?? '';
  }
}
