import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/jewelry_item.dart';
import '../theme/app_theme.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final catalog = controllers.catalogController;
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    final localization = AppLocalizations.of(context);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: catalog.refresh,
        child: AnimatedBuilder(
          animation: catalog,
          builder: (context, _) {
            final items = catalog.items;
            return ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                _HeroShowcase(tokens: tokens)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slide(begin: const Offset(0, 0.15)),
                const SizedBox(height: 28),
                _BrandRail(
                  tokens: tokens,
                  onBrandSelected: (brand) => catalog.search(brand),
                ).animate().fadeIn(duration: 350.ms).moveY(begin: 12, end: 0),
                const SizedBox(height: 32),
                _NewArrivalsCarousel(
                  items: items,
                  localization: localization,
                  tokens: tokens,
                ).animate().fadeIn(duration: 350.ms).moveY(begin: 20, end: 0),
                const SizedBox(height: 28),
                _AiInsightButton(localization: localization)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .moveY(begin: 20, end: 0),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroShowcase extends StatelessWidget {
  const _HeroShowcase({required this.tokens});

  final JewelThemeTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
      child: Stack(
        children: [
          Container(
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.85),
                  theme.colorScheme.primaryContainer.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Icon(
                  Icons.diamond_outlined,
                  size: 120,
                  color: Colors.white.withOpacity(0.25),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: tokens?.glassBlurSigma ?? 12, sigmaY: tokens?.glassBlurSigma ?? 12),
              child: const SizedBox(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Royal Gems',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pink gradient • Exclusive release',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/catalog/jewelry'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.92)),
                  icon: Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.primary),
                  label: Text(
                    AppLocalizations.of(context).translate('seeAll'),
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final url = brands[index];
              return GestureDetector(
                onTap: () => onBrandSelected('Brand ${index + 1}'),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: tokens?.brandAvatarBg.withOpacity(0.85) ?? Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: tokens?.softShadow,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.network(
                          url,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Brand ${index + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: tokens?.brandAvatarFg ?? theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NewArrivalsCarousel extends StatelessWidget {
  const _NewArrivalsCarousel({
    required this.items,
    required this.localization,
    required this.tokens,
  });

  final List<JewelryItem> items;
  final AppLocalizations localization;
  final JewelThemeTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localization.translate('newArrivals'),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/catalog/jewelry'),
              child: Text(localization.translate('seeAll')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: items.isEmpty
              ? _EmptyCarouselPlaceholder(tokens: tokens)
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: math.min(items.length, 8),
                  separatorBuilder: (_, __) => const SizedBox(width: 18),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _NewArrivalCard(item: item, tokens: tokens, localization: localization);
                  },
                ),
        ),
      ],
    );
  }
}

class _NewArrivalCard extends StatelessWidget {
  const _NewArrivalCard({
    required this.item,
    required this.tokens,
    required this.localization,
  });

  final JewelryItem item;
  final JewelThemeTokens? tokens;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/details', arguments: item),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
          boxShadow: tokens?.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(item.images.first, fit: BoxFit.cover),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.favorite_border, color: Colors.white, size: 18),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: _PricePill(
                  tokens: tokens,
                  text: item.price != null
                      ? '\$${item.price!.toStringAsFixed(0)}'
                      : localization.translate('noPriceShown'),
                ),
              ),
              Positioned(
                bottom: 84,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.brand,
                      style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70),
                    ),
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

class _EmptyCarouselPlaceholder extends StatelessWidget {
  const _EmptyCarouselPlaceholder({required this.tokens});

  final JewelThemeTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
        color: theme.colorScheme.surface.withOpacity(0.4),
      ),
      child: Center(
        child: Text(
          AppLocalizations.of(context).translate('emptyCatalog'),
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.tokens, required this.text});

  final JewelThemeTokens? tokens;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tokens?.pricePillBackground ?? Colors.white,
        borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: tokens?.pricePillForeground ?? theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AiInsightButton extends StatelessWidget {
  const _AiInsightButton({required this.localization});

  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.icon(
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(localization.translate('aiInfo')),
              content: Text(localization.translate('aiInsightDescription')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localization.translate('ok')),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.auto_awesome),
      label: Text(localization.translate('aiInfo')),
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.onSurface,
        foregroundColor: theme.colorScheme.surface,
      ),
    );
  }
}
