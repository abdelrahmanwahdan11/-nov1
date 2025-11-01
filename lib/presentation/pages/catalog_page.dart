
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/compare_controller.dart';
import '../controllers/controllers_scope.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';
import 'package:jewelx/core/theme/app_theme.dart';
import '../widgets/jewel_cached_image.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  static const double _compareBarHeight = 72;

  CatalogController? _catalog;
  CompareController? _compare;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = ControllersScope.of(context);
    _catalog ??= scope.catalogController;
    _compare ??= scope.compareController;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog!;
    final compare = _compare!;
    final listenable = Listenable.merge([catalog, compare]);
    final localization = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final items = catalog.items;
        final isLoading = catalog.isLoading;
        final hasMore = catalog.hasMore;
        final compareIds = compare.selectedIds;
        final showCompareBar = compareIds.length >= 2;

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: catalog.refresh,
              edgeOffset: 0,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200 &&
                      !catalog.isLoading &&
                      catalog.hasMore) {
                    catalog.loadMore();
                  }
                  return false;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _PinnedHeaderDelegate(
                        minHeight: 72,
                        maxHeight: 72,
                        child: _FilterToolbar(
                          catalog: catalog,
                          localization: localization,
                          onOpenFilters: () => _openFiltersSheet(context, catalog),
                          onSortSelected: (value) => catalog.setSort(value),
                        ),
                      ),
                    ),
                    if (isLoading && items.isEmpty)
                      _buildSkeletonGrid(showCompareBar)
                    else if (items.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(localization.translate('emptyCatalog')),
                        ),
                      )
                    else
                      _buildCatalogGrid(
                        context,
                        items,
                        localization,
                        catalog,
                        compare,
                        showCompareBar,
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          showCompareBar ? _compareBarHeight + 24 : 32,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: hasMore
                              ? isLoading && items.isNotEmpty
                                  ? const Center(
                                      key: ValueKey('loading'),
                                      child: CircularProgressIndicator(),
                                    )
                                  : const SizedBox.shrink()
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showCompareBar)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.of(context).padding.bottom,
                child: _CompareBar(
                  count: compareIds.length,
                  localization: localization,
                  onClear: compare.clear,
                  onCompare: () =>
                      Navigator.of(context).pushNamed('/compare/jewelry'),
                ),
              ),
          ],
        );
      },
    );
  }

  SliverPadding _buildCatalogGrid(
    BuildContext context,
    List<JewelryItem> items,
    AppLocalizations localization,
    CatalogController catalog,
    CompareController compare,
    bool showCompareBar,
  ) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, showCompareBar ? _compareBarHeight + 24 : 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _CatalogCard(
              item: item,
              localization: localization,
              catalog: catalog,
              compare: compare,
              theme: theme,
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  SliverPadding _buildSkeletonGrid(bool showCompareBar) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, showCompareBar ? _compareBarHeight + 24 : 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const _SkeletonCard(),
          childCount: 6,
        ),
      ),
    );
  }

  Future<void> _openFiltersSheet(
    BuildContext context,
    CatalogController catalog,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CatalogFiltersSheet(
        initialFilters: catalog.filters,
      ),
    );
    if (result != null) {
      await catalog.applyFilters(result);
    }
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  final Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final elevation = overlapsContent ? 4.0 : 0.0;
    return Material(
      elevation: elevation,
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent;
  }
}

class _FilterToolbar extends StatelessWidget {
  const _FilterToolbar({
    required this.catalog,
    required this.localization,
    required this.onOpenFilters,
    required this.onSortSelected,
  });

  final CatalogController catalog;
  final AppLocalizations localization;
  final VoidCallback onOpenFilters;
  final ValueChanged<String?> onSortSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeFilters = _countActiveFilters(catalog.filters);
    final sortLabel = _sortLabel(localization, catalog.sort);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: onOpenFilters,
                icon: const Icon(Icons.tune),
                label: Text(
                  activeFilters > 0
                      ? '${localization.translate('filters')} ($activeFilters)'
                      : localization.translate('filters'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              initialValue: catalog.sort,
              onSelected: onSortSelected,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'priceAsc',
                  child: Text(localization.translate('sortPriceLowHigh')),
                ),
                PopupMenuItem(
                  value: 'priceDesc',
                  child: Text(localization.translate('sortPriceHighLow')),
                ),
                PopupMenuItem(
                  value: 'newest',
                  child: Text(localization.translate('sortNewest')),
                ),
                if (catalog.sort != null)
                  const PopupMenuDivider(),
                if (catalog.sort != null)
                  PopupMenuItem(
                    value: null,
                    child: Text(localization.translate('reset')),
                  ),
              ],
              child: Ink(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(sortLabel),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countActiveFilters(Map<String, dynamic> filters) {
    return filters.values.where((value) {
      if (value == null) return false;
      if (value is Iterable && value.isEmpty) return false;
      if (value is String && value.trim().isEmpty) return false;
      if (value is Map) {
        final min = value['min'];
        final max = value['max'];
        return (min is num && min.isFinite) || (max is num && max.isFinite);
      }
      return true;
    }).length;
  }

  String _sortLabel(AppLocalizations localization, String? sort) {
    switch (sort) {
      case 'priceAsc':
        return localization.translate('sortPriceLowHigh');
      case 'priceDesc':
        return localization.translate('sortPriceHighLow');
      case 'newest':
        return localization.translate('sortNewest');
      default:
        return localization.translate('sortBy');
    }
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.item,
    required this.localization,
    required this.catalog,
    required this.compare,
    required this.theme,
  });

  final JewelryItem item;
  final AppLocalizations localization;
  final CatalogController catalog;
  final CompareController compare;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isFavorite = catalog.favorites.contains(item.id);
    final isCompared = compare.selectedIds.contains(item.id);
    final tokens = theme.extension<JewelThemeTokens>();

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/details', arguments: item),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Hero(
                      tag: 'catalog-${item.id}',
                      child: JewelCachedImage(
                        imageUrl: item.images.first,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: Colors.black45,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => catalog.toggleFavorite(item.id),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _CatalogPriceTag(
                      tokens: tokens,
                      text: item.price != null
                          ? '\$${item.price!.toStringAsFixed(0)}'
                          : localization.translate('noPriceShown'),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.brand,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => compare.toggle(item.id),
                      icon: Icon(
                        Icons.compare_arrows,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        isCompared
                            ? localization.translate('compareNow')
                            : localization.translate('compare'),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isCompared
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : null,
                        side: BorderSide(
                          color: isCompared
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
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

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26)),
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                final base = theme.colorScheme.surfaceVariant;
                final highlight = theme.colorScheme.onSurfaceVariant
                    .withOpacity(0.08 + t * 0.12);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    gradient: LinearGradient(
                      colors: [base, highlight, base],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLine(theme, widthFactor: 0.9),
                const SizedBox(height: 8),
                _buildLine(theme, widthFactor: 0.6),
                const SizedBox(height: 16),
                _buildLine(theme, height: 40, widthFactor: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(ThemeData theme, {double widthFactor = 1, double height = 14}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _CatalogPriceTag extends StatelessWidget {
  const _CatalogPriceTag({required this.tokens, required this.text});

  final JewelThemeTokens? tokens;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tokens?.pricePillBackground ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: tokens?.pricePillForeground ?? theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _CompareBar extends StatelessWidget {
  const _CompareBar({
    required this.count,
    required this.localization,
    required this.onClear,
    required this.onCompare,
  });

  final int count;
  final AppLocalizations localization;
  final VoidCallback onClear;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${localization.translate('compare')} ($count)',
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: Text(localization.translate('reset')),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onCompare,
              icon: const Icon(Icons.table_rows),
              label: Text(localization.translate('compareNow')),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogFiltersSheet extends StatefulWidget {
  const _CatalogFiltersSheet({required this.initialFilters});

  final Map<String, dynamic> initialFilters;

  @override
  State<_CatalogFiltersSheet> createState() => _CatalogFiltersSheetState();
}

class _CatalogFiltersSheetState extends State<_CatalogFiltersSheet> {
  late Set<JewelryCategory> _selectedCategories;
  late Set<JewelryMaterial> _selectedMaterials;
  late Set<JewelryCondition> _selectedConditions;
  late RangeValues _caratRange;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _selectedCategories = (filters['category'] as Iterable<JewelryCategory>?)?.toSet() ?? {};
    _selectedMaterials = (filters['material'] as Iterable<JewelryMaterial>?)?.toSet() ?? {};
    _selectedConditions = (filters['condition'] as Iterable<JewelryCondition>?)?.toSet() ?? {};

    final caratMap = filters['carat'] as Map<String, dynamic>?;
    final caratMin = caratMap != null
        ? (caratMap['min'] as num?)?.toDouble() ?? CatalogController.caratMinDefault
        : CatalogController.caratMinDefault;
    final caratMax = caratMap != null
        ? (caratMap['max'] as num?)?.toDouble() ?? CatalogController.caratMaxDefault
        : CatalogController.caratMaxDefault;
    _caratRange = RangeValues(caratMin, caratMax);

    final priceMap = filters['price'] as Map<String, dynamic>?;
    final priceMin = priceMap != null
        ? (priceMap['min'] as num?)?.toDouble() ?? CatalogController.priceMinDefault
        : CatalogController.priceMinDefault;
    final priceMax = priceMap != null
        ? (priceMap['max'] as num?)?.toDouble() ?? CatalogController.priceMaxDefault
        : CatalogController.priceMaxDefault;
    _priceRange = RangeValues(priceMin, priceMax);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            localization.translate('filters'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: _reset,
                          child: Text(localization.translate('reset')),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _Section(
                          title: localization.translate('catalog'),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: JewelryCategory.values
                                .map((category) => FilterChip(
                                      label: Text(_describe(category.name)),
                                      selected: _selectedCategories.contains(category),
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            _selectedCategories.add(category);
                                          } else {
                                            _selectedCategories.remove(category);
                                          }
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Section(
                          title: localization.translate('material'),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: JewelryMaterial.values
                                .map((material) => FilterChip(
                                      label: Text(_describe(material.name)),
                                      selected: _selectedMaterials.contains(material),
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            _selectedMaterials.add(material);
                                          } else {
                                            _selectedMaterials.remove(material);
                                          }
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Section(
                          title: localization.translate('condition'),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: JewelryCondition.values
                                .map((condition) => FilterChip(
                                      label: Text(_describe(condition.name)),
                                      selected: _selectedConditions.contains(condition),
                                      onSelected: (value) {
                                        setState(() {
                                          if (value) {
                                            _selectedConditions.add(condition);
                                          } else {
                                            _selectedConditions.remove(condition);
                                          }
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Section(
                          title: localization.translate('carat'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RangeSlider(
                                values: _caratRange,
                                min: CatalogController.caratMinDefault,
                                max: CatalogController.caratMaxDefault,
                                divisions: ((CatalogController.caratMaxDefault -
                                            CatalogController.caratMinDefault) *
                                        10)
                                    .round(),
                                labels: RangeLabels(
                                  _caratRange.start.toStringAsFixed(1),
                                  _caratRange.end.toStringAsFixed(1),
                                ),
                                onChanged: (value) {
                                  setState(() => _caratRange = value);
                                },
                              ),
                              Text(
                                '${_caratRange.start.toStringAsFixed(1)} - '
                                '${_caratRange.end.toStringAsFixed(1)}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Section(
                          title: localization.translate('price'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RangeSlider(
                                values: _priceRange,
                                min: CatalogController.priceMinDefault,
                                max: CatalogController.priceMaxDefault,
                                divisions: 20,
                                labels: RangeLabels(
                                  _formatCurrency(_priceRange.start),
                                  _formatCurrency(_priceRange.end),
                                ),
                                onChanged: (value) {
                                  setState(() => _priceRange = value);
                                },
                              ),
                              Text(
                                '${_formatCurrency(_priceRange.start)} - '
                                '${_formatCurrency(_priceRange.end)}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _apply,
                        child: Text(localization.translate('apply')),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _selectedCategories.clear();
      _selectedMaterials.clear();
      _selectedConditions.clear();
      _caratRange = const RangeValues(
        CatalogController.caratMinDefault,
        CatalogController.caratMaxDefault,
      );
      _priceRange = const RangeValues(
        CatalogController.priceMinDefault,
        CatalogController.priceMaxDefault,
      );
    });
  }

  void _apply() {
    final filters = <String, dynamic>{};
    if (_selectedCategories.isNotEmpty) {
      filters['category'] = _selectedCategories;
    }
    if (_selectedMaterials.isNotEmpty) {
      filters['material'] = _selectedMaterials;
    }
    if (_selectedConditions.isNotEmpty) {
      filters['condition'] = _selectedConditions;
    }
    if (_caratRange.start > CatalogController.caratMinDefault ||
        _caratRange.end < CatalogController.caratMaxDefault) {
      filters['carat'] = {
        'min': _caratRange.start,
        'max': _caratRange.end,
      };
    }
    if (_priceRange.start > CatalogController.priceMinDefault ||
        _priceRange.end < CatalogController.priceMaxDefault) {
      filters['price'] = {
        'min': _priceRange.start,
        'max': _priceRange.end,
      };
    }
    Navigator.of(context).pop(filters);
  }

  String _describe(String value) {
    if (value.isEmpty) {
      return value;
    }
    final spaced = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    final capitalized = spaced[0].toUpperCase() + spaced.substring(1);
    return capitalized;
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(1)}k';
    }
    return '\$${value.toStringAsFixed(0)}';
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
