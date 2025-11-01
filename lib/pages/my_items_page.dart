import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/my_items_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/jewelry_item.dart';
import '../theme/app_theme.dart';

class MyItemsPage extends StatefulWidget {
  const MyItemsPage({super.key});

  @override
  State<MyItemsPage> createState() => _MyItemsPageState();
}

class _MyItemsPageState extends State<MyItemsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final myItemsController = controllers.myItemsController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('myItems')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localization.translate('tabAllItems')),
            Tab(text: localization.translate('sellNow')),
            Tab(text: localization.translate('awaitOffers')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSheet(context, myItemsController, localization),
        icon: const Icon(Icons.add),
        label: Text(localization.translate('addItem')),
      ),
      body: AnimatedBuilder(
        animation: myItemsController,
        builder: (context, _) {
          final items = myItemsController.myItems;
          final filtered = _filteredItems(items, _tabController.index);
          if (filtered.isEmpty) {
            return Center(
              child: Text(localization.translate('noSearchResults')),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _MyItemCard(
                  item: item,
                  tokens: tokens,
                  localization: localization,
                  onToggleSale: (value) => myItemsController.toggleSaleState(
                    item.id,
                    forSale: value,
                    awaitOffers: !value,
                  ),
                  onToggleAwait: (value) => myItemsController.toggleSaleState(
                    item.id,
                    forSale: !value,
                    awaitOffers: value,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<JewelryItem> _filteredItems(List<JewelryItem> items, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return items.where((item) => item.forSale).toList();
      case 2:
        return items.where((item) => item.awaitOffers).toList();
      default:
        return items;
    }
  }

  Future<void> _openCreateSheet(
    BuildContext context,
    MyItemsController controller,
    AppLocalizations localization,
  ) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localization.translate('addItem'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: localization.translate('itemName')),
                    validator: (value) => value == null || value.isEmpty
                        ? localization.translate('fieldRequired')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: localization.translate('price')),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final item = JewelryItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          brand: 'Private',
                          category: JewelryCategory.ring,
                          images: const ['https://picsum.photos/seed/myitem/400/400'],
                          model3d: 'https://example.com/models/ring.glb',
                          material: JewelryMaterial.gold,
                          gem: 'Diamond',
                          carat: 1.0,
                          weightGrams: 3.2,
                          ringSize: '42',
                          color: 'G',
                          condition: JewelryCondition.veryGood,
                          certificate: '',
                          price: priceController.text.isEmpty
                              ? null
                              : double.tryParse(priceController.text),
                          negotiable: true,
                          forSale: priceController.text.isNotEmpty,
                          awaitOffers: priceController.text.isEmpty,
                          tips: localization.translate('tips'),
                          description: localization.translate('details'),
                          createdAt: DateTime.now().millisecondsSinceEpoch,
                        );
                        await controller.addItem(item);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(localization.translate('addItem')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MyItemCard extends StatelessWidget {
  const _MyItemCard({
    required this.item,
    required this.tokens,
    required this.localization,
    required this.onToggleSale,
    required this.onToggleAwait,
  });

  final JewelryItem item;
  final JewelThemeTokens? tokens;
  final AppLocalizations localization;
  final ValueChanged<bool> onToggleSale;
  final ValueChanged<bool> onToggleAwait;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
        boxShadow: tokens?.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular((tokens?.cardRadius ?? 26) / 2),
                  child: Image.network(
                    item.images.first,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(item.brand, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilterChip(
                  label: Text(localization.translate('sellNow')),
                  selected: item.forSale,
                  onSelected: onToggleSale,
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: Text(localization.translate('awaitOffers')),
                  selected: item.awaitOffers,
                  onSelected: onToggleAwait,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
