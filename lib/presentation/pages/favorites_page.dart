import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/scroll_memory.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/core/theme/app_theme.dart';
import '../widgets/jewel_cached_image.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  ScrollController? _controller;
  ScrollMemory? _scrollMemory;
  bool _initialised = false;
  bool _showBackToTop = false;
  double _lastSavedOffset = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    final scope = ControllersScope.of(context);
    _scrollMemory = scope.scrollMemory;
    final saved = _scrollMemory?.getOffset('favorites') ?? 0;
    _controller = ScrollController(initialScrollOffset: saved)
      ..addListener(_handleScroll);
    _lastSavedOffset = saved;
    _initialised = true;
    if (saved > 220) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _showBackToTop = true);
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleScroll);
    _controller?.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final controller = _controller;
    if (controller == null || !controller.hasClients) return;
    final offset = controller.offset;
    if ((offset - _lastSavedOffset).abs() > 12) {
      _lastSavedOffset = offset;
      _scrollMemory?.save('favorites', offset);
    }
    final shouldShow = offset > 220;
    if (shouldShow != _showBackToTop) {
      setState(() => _showBackToTop = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllers = ControllersScope.of(context);
    final catalog = controllers.catalogController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();

    return AnimatedBuilder(
      animation: catalog,
      builder: (context, _) {
        final favorites = catalog.items
            .where((item) => catalog.favorites.contains(item.id))
            .toList();
        if (favorites.isEmpty) {
          return Center(
            child: _EmptyFavoritesCard(message: localization.translate('emptyFavorites')),
          );
        }
        return Stack(
          children: [
            ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 22),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      child: ClipOval(
                        child: JewelCachedImage(
                          imageUrl: item.images.first,
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(item.brand),
                    trailing: const Icon(IconlyBold.arrow_right_circle),
                    onTap: () => Navigator.of(context).pushNamed('/details', arguments: item),
                  ),
                );
              },
            ),
            Positioned(
              right: 24,
              bottom: 24 + MediaQuery.of(context).padding.bottom,
              child: AnimatedSlide(
                offset: _showBackToTop ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _showBackToTop ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_showBackToTop,
                    child: FilledButton.tonalIcon(
                      onPressed: () => _controller?.animateTo(
                        0,
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: Text(localization.translate('backToTop')),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyFavoritesCard extends StatelessWidget {
  const _EmptyFavoritesCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(IconlyBold.heart, size: 44, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).translate('emptyStateMessage'),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
