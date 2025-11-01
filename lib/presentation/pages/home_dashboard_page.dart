import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/controllers_scope.dart';
import 'package:jewelx/data/mock/mock_data.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';
import 'package:jewelx/core/theme/app_theme.dart';
import '../widgets/jewel_cached_image.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  late final PageController _pageController;
  Timer? _autoPlay;
  int _carouselIndex = 0;

  List<String> get _carouselImages =>
      MockData.jewelry.map((item) => item.images.first).toSet().take(6).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlay?.cancel();
    if (_carouselImages.length < 2) return;
    _autoPlay = Timer.periodic(4.seconds, (_) {
      if (!mounted) return;
      _carouselIndex = (_carouselIndex + 1) % _carouselImages.length;
      _pageController.animateToPage(
        _carouselIndex,
        duration: 550.ms,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final catalog = controllers.catalogController;
    final history = controllers.browsingHistoryController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    final listenable = Listenable.merge([catalog, history]);

    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: listenable,
        builder: (context, _) {
          final items = catalog.items;
          final isLoading = catalog.isLoading && items.isEmpty;
          final recent = history.recentItems(limit: 8);
          final recommended = catalog.recommendedItems(
            limit: 8,
            recentIds: history.recentIds,
            excludeIds: recent.map((item) => item.id),
          );
          return RefreshIndicator(
            color: theme.colorScheme.primary,
            onRefresh: catalog.refresh,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.extentAfter < 320 &&
                    !catalog.isLoading &&
                    catalog.hasMore) {
                  catalog.loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: _HeroCarousel(
                        controller: _pageController,
                        images: _carouselImages,
                        localization: localization,
                        tokens: tokens,
                        onPageChanged: (value) => setState(() => _carouselIndex = value),
                      ),
                    ),
                  ),
                  if (recent.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 0, 12),
                        child: _RecentRail(
                          items: recent,
                          localization: localization,
                          tokens: tokens,
                          onClear: () => history.clear(),
                          onOpen: _openDetails,
                          onQuickLook: _openQuickLook,
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: _BrandRail(
                        tokens: tokens,
                        onBrandSelected: (brand) => catalog.search(brand),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _AiInsightButton(localization: localization),
                    ),
                  ),
                  if (recommended.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: _RecommendationRail(
                          items: recommended,
                          localization: localization,
                          tokens: tokens,
                          onTap: _openDetails,
                        ),
                      ),
                    ),
                  if (isLoading)
                    _SkeletonGrid(tokens: tokens)
                  else if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(localization.translate('emptyCatalog')),
                      ),
                    )
                  else
                    _HomeGrid(
                      items: items,
                      localization: localization,
                      tokens: tokens,
                      onQuickLook: _openQuickLook,
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openQuickLook(JewelryItem item) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'quick-look',
      transitionDuration: 350.ms,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Hero(
            tag: 'home-${item.id}',
            child: _QuickLookCard(
              item: item,
              onClose: () => Navigator.of(context).pop(),
              onViewDetails: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/details', arguments: item);
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondary, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  void _openDetails(JewelryItem item) {
    Navigator.of(context).pushNamed('/details', arguments: item);
  }
}

class _RecentRail extends StatelessWidget {
  const _RecentRail({
    required this.items,
    required this.localization,
    required this.tokens,
    required this.onClear,
    required this.onOpen,
    required this.onQuickLook,
  });

  final List<JewelryItem> items;
  final AppLocalizations localization;
  final JewelThemeTokens? tokens;
  final VoidCallback onClear;
  final ValueChanged<JewelryItem> onOpen;
  final ValueChanged<JewelryItem> onQuickLook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = tokens?.cardRadius ?? 26;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              localization.translate('recentlyViewed'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton(
              onPressed: onClear,
              child: Text(localization.translate('clearHistory')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: () => onOpen(item),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: tokens?.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(radius),
                          topRight: Radius.circular(radius),
                        ),
                        child: JewelCachedImage(
                          imageUrl: item.images.isNotEmpty
                              ? item.images.first
                              : 'https://picsum.photos/seed/${item.id}/300/300',
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 32),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () => onQuickLook(item),
                                  child: Text(localization.translate('quickLook')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendationRail extends StatelessWidget {
  const _RecommendationRail({
    required this.items,
    required this.localization,
    required this.tokens,
    required this.onTap,
  });

  final List<JewelryItem> items;
  final AppLocalizations localization;
  final JewelThemeTokens? tokens;
  final ValueChanged<JewelryItem> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = tokens?.cardRadius ?? 26;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              localization.translate('recommendedForYou'),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 4),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              final price = item.price;
              final priceText = price != null
                  ? '${localization.translate('currencySymbol')}${price.toStringAsFixed(0)}'
                  : localization.translate('priceOnRequest');
              return InkWell(
                onTap: () => onTap(item),
                borderRadius: BorderRadius.circular(radius),
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: tokens?.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(radius),
                          topRight: Radius.circular(radius),
                        ),
                        child: JewelCachedImage(
                          imageUrl: item.images.isNotEmpty
                              ? item.images.first
                              : 'https://picsum.photos/seed/reco-${item.id}/300/300',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                        child: Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.brand} • ${localization.translate(item.material.name)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Text(
                          priceText,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  const _HeroCarousel({
    required this.controller,
    required this.images,
    required this.localization,
    required this.tokens,
    required this.onPageChanged,
  });

  final PageController controller;
  final List<String> images;
  final AppLocalizations localization;
  final JewelThemeTokens? tokens;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: controller,
        onPageChanged: onPageChanged,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final image = images[index % images.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  JewelCachedImage(imageUrl: image, fit: BoxFit.cover),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.translate('newArrivals'),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              localization.translate('compareNow'),
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                        FilledButton.tonal(
                          onPressed: () => Navigator.of(context).pushNamed('/catalog/jewelry'),
                          child: Text(localization.translate('seeAll')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BrandRail extends StatelessWidget {
  const _BrandRail({required this.tokens, required this.onBrandSelected});

  final JewelThemeTokens? tokens;
  final ValueChanged<String> onBrandSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);
    final brands = List.generate(
      5,
      (index) => 'https://picsum.photos/seed/brand${index + 1}/200/200',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.translate('brands'),
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ).animate().fadeIn(duration: 300.ms).moveY(begin: 12, end: 0),
        const SizedBox(height: 14),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final url = brands[index];
              final label = 'Brand ${index + 1}';
              return GestureDetector(
                onTap: () => onBrandSelected(label),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: tokens?.brandAvatarBg.withOpacity(0.88) ?? Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: tokens?.softShadow,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: JewelCachedImage(imageUrl: url, width: 58, height: 58, borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(label, style: theme.textTheme.labelMedium),
                  ],
                ).animate().fadeIn(delay: (index * 70).ms).moveY(begin: 10, end: 0),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AiInsightButton extends StatelessWidget {
  const _AiInsightButton({required this.localization});

  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localization.translate('aiInfo')),
            content: Text(localization.translate('aiInsightDescription')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(localization.translate('ok')),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.auto_awesome),
      label: Text(localization.translate('aiInfo')),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4)),
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid({required this.tokens});

  final JewelThemeTokens? tokens;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
              ),
            ).animate().shimmer(duration: 1200.ms, delay: (index * 80).ms);
          },
          childCount: 6,
        ),
      ),
    );
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid({
    required this.items,
    required this.localization,
    required this.tokens,
    required this.onQuickLook,
  });

  final List<JewelryItem> items;
  final AppLocalizations localization;
  final JewelThemeTokens? tokens;
  final ValueChanged<JewelryItem> onQuickLook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _HomeItemCard(
              item: item,
              localization: localization,
              tokens: tokens,
              onQuickLook: onQuickLook,
            ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).moveY(begin: 12, end: 0);
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

class _HomeItemCard extends StatelessWidget {
  const _HomeItemCard({
    required this.item,
    required this.localization,
    required this.tokens,
    required this.onQuickLook,
  });

  final JewelryItem item;
  final AppLocalizations localization;
  final JewelThemeTokens? tokens;
  final ValueChanged<JewelryItem> onQuickLook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = item.price != null
        ? '${localization.translate('currencySymbol')}${item.price!.toStringAsFixed(0)}'
        : localization.translate('priceOnRequest');
    return GestureDetector(
      onTap: () => onQuickLook(item),
      child: Hero(
        tag: 'home-${item.id}',
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.88),
            borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
            boxShadow: tokens?.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: JewelCachedImage(
                  imageUrl: item.images.first,
                  borderRadius: BorderRadius.circular((tokens?.cardRadius ?? 26) - 6),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('${item.brand} • ${item.material.name}', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
                      ),
                      child: Text(price, style: theme.textTheme.labelLarge),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLookCard extends StatefulWidget {
  const _QuickLookCard({
    required this.item,
    required this.onClose,
    required this.onViewDetails,
  });

  final JewelryItem item;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  @override
  State<_QuickLookCard> createState() => _QuickLookCardState();
}

class _QuickLookCardState extends State<_QuickLookCard> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => setState(() => _showBack = !_showBack),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.82,
          height: 440,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
            boxShadow: tokens?.softShadow,
          ),
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: 450.ms,
                transitionBuilder: (child, animation) {
                  final rotate = Tween<double>(begin: math.pi, end: 0).animate(animation);
                  return AnimatedBuilder(
                    animation: rotate,
                    child: child,
                    builder: (context, child) {
                      final value = rotate.value;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(value),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                  );
                },
                child: _showBack
                    ? _QuickLookBack(item: widget.item)
                    : _QuickLookFront(item: widget.item),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: FilledButton(
                  onPressed: widget.onViewDetails,
                  child: Text(AppLocalizations.of(context).translate('details')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLookFront extends StatelessWidget {
  const _QuickLookFront({required this.item});

  final JewelryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('front'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: JewelCachedImage(
            imageUrl: item.images.first,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(item.brand, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 8),
              Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickLookBack extends StatelessWidget {
  const _QuickLookBack({required this.item});

  final JewelryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context);
    final specs = {
      localization.translate('material'): item.material.name,
      localization.translate('carat'): item.carat.toStringAsFixed(2),
      localization.translate('weight'): '${item.weightGrams} g',
      localization.translate('condition'): item.condition.name,
    };
    return Padding(
      key: const ValueKey('back'),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(localization.translate('details'), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          for (final entry in specs.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text(entry.value, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          const Spacer(),
          Text(localization.translate('tips'), style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(item.tips, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
