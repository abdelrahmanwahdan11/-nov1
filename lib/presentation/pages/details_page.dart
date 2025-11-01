import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/messages_controller.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';
import 'package:jewelx/core/theme/app_theme.dart';
import '../widgets/jewel_cached_image.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  static const routeName = '/details';

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  JewelryItem? _item;
  String? _selectedSize;
  String? _selectedMaterial;
  bool _viewLogged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is JewelryItem && _item == null) {
      _item = args;
    }
    final item = _item;
    if (item != null && !_viewLogged) {
      ControllersScope.of(context).browsingHistoryController.registerView(item.id);
      _viewLogged = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    if (item == null) {
      return const Scaffold(body: Center(child: Text('No item provided')));
    }
    final scope = ControllersScope.of(context);
    final catalog = scope.catalogController;
    final compare = scope.compareController;
    final cart = scope.cartController;
    final messages = scope.messagesController;
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    final localization = AppLocalizations.of(context);
    final listenable = Listenable.merge([catalog, compare]);

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final isFavorite = catalog.favorites.contains(item.id);
        final isCompared = compare.selectedIds.contains(item.id);
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const BackButton(),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _GalleryHeader(item: item, tokens: tokens, localization: localization),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.brand,
                        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 20),
                      _SpecsGrid(item: item, localization: localization),
                      const SizedBox(height: 24),
                      _RingSizesSection(
                        localization: localization,
                        selectedSize: _selectedSize,
                        onSelect: (value) => setState(() => _selectedSize = value),
                      ),
                      const SizedBox(height: 16),
                      _MetalSwatches(
                        localization: localization,
                        selectedColor: _selectedMaterial,
                        onSelect: (value) => setState(() => _selectedMaterial = value),
                      ),
                      const SizedBox(height: 24),
                      _ThreeDPreview(tokens: tokens, modelUrl: item.model3d),
                      const SizedBox(height: 24),
                      Text(
                        localization.translate('details'),
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(item.description, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens?.ctaBlack ?? Colors.black,
                  borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
                ),
                child: Row(
                  children: [
                    _BottomAction(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      label: localization.translate('favorites'),
                      onTap: () => catalog.toggleFavorite(item.id),
                      active: isFavorite,
                    ),
                    const SizedBox(width: 12),
                    _BottomAction(
                      icon: Icons.compare_arrows,
                      label: localization.translate('compare'),
                      onTap: () => compare.toggle(item.id),
                      active: isCompared,
                    ),
                    const SizedBox(width: 12),
                    _BottomAction(
                      icon: Icons.chat_bubble_outline,
                      label: localization.translate('contactSeller'),
                      onTap: () => _onContactSeller(
                        context,
                        item,
                        localization,
                        messages,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final size = _selectedSize;
                          final material = _selectedMaterial;
                          if (size == null || material == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localization.translate('selectSizeAndColor')),
                              ),
                            );
                            return;
                          }
                          cart.add(item, size: size, color: material);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(localization.translate('addedToCart'))),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
                          ),
                        ),
                        child: Text(localization.translate('addToCart')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({required this.item, required this.tokens, required this.localization});

  final JewelryItem item;
  final JewelThemeTokens? tokens;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              itemCount: item.images.length,
              itemBuilder: (context, index) {
                final image = item.images[index];
                return Hero(
                  tag: 'catalog-${item.id}',
                  child: JewelCachedImage(imageUrl: image, fit: BoxFit.cover),
                );
              },
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: _GalleryLabel(tokens: tokens, text: localization.translate('sizeGuide')),
          ),
        ],
      ),
    );
  }
}

class _GalleryLabel extends StatelessWidget {
  const _GalleryLabel({required this.tokens, required this.text});

  final JewelThemeTokens? tokens;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  const _SpecsGrid({required this.item, required this.localization});

  final JewelryItem item;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final specs = <String, String>{
      localization.translate('material'): item.material.name,
      localization.translate('gem'): item.gem,
      localization.translate('carat'): item.carat.toStringAsFixed(2),
      localization.translate('weight'): '${item.weightGrams} g',
      localization.translate('condition'): item.condition.name,
    };

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: specs.entries
          .map(
            (entry) => _ChipBadge(
              label: entry.key,
              value: entry.value,
            ),
          )
          .toList(),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RingSizesSection extends StatelessWidget {
  const _RingSizesSection({
    required this.localization,
    required this.selectedSize,
    required this.onSelect,
  });

  final AppLocalizations localization;
  final String? selectedSize;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();
    final sizes = ['41', '42', '43', '44', '45'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(localization.translate('sizes'), style: theme.textTheme.titleMedium),
            TextButton(
              onPressed: () {},
              child: Text(localization.translate('viewSizeGuide')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: sizes
              .map(
                (size) {
                  final isSelected = selectedSize == size;
                  return GestureDetector(
                    onTap: () => onSelect(size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.18)
                            : theme.colorScheme.surface.withOpacity(0.7),
                        border: Border.all(
                          color:
                              isSelected ? theme.colorScheme.primary : Colors.transparent,
                          width: 1.6,
                        ),
                      ),
                      child: Text(
                        size,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MetalSwatches extends StatelessWidget {
  const _MetalSwatches({
    required this.localization,
    required this.selectedColor,
    required this.onSelect,
  });

  final AppLocalizations localization;
  final String? selectedColor;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      _MetalOption('gold', const [Color(0xFFF9D976), Color(0xFFF39F86)]),
      _MetalOption('silver', const [Color(0xFFE6E9F0), Color(0xFFCFD9DF)]),
      _MetalOption('roseGold', const [Color(0xFFFAD0C4), Color(0xFFFFD1FF)]),
      _MetalOption('platinum', const [Color(0xFFD7E1EC), Color(0xFFF2F6FF)]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localization.translate('metalColor'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 18,
          runSpacing: 16,
          children: options
              .map(
                (option) {
                  final isSelected = selectedColor == option.key;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => onSelect(option.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: option.gradient),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2.4,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: theme.colorScheme.onPrimary)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localization.translate(option.key),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MetalOption {
  const _MetalOption(this.key, this.gradient);

  final String key;
  final List<Color> gradient;
}

class _ThreeDPreview extends StatefulWidget {
  const _ThreeDPreview({required this.tokens, required this.modelUrl});

  final JewelThemeTokens? tokens;
  final String modelUrl;

  @override
  State<_ThreeDPreview> createState() => _ThreeDPreviewState();
}

class _ThreeDPreviewState extends State<_ThreeDPreview> {
  late final Flutter3dController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3dController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.setAutoRotate(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.tokens?.cardRadius ?? 26),
        color: theme.colorScheme.surface.withOpacity(0.65),
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasError
          ? Center(
              child: Text(
                AppLocalizations.of(context).translate('threeDUnavailable'),
                textAlign: TextAlign.center,
              ),
            )
          : Flutter3dViewer.network(
              src: widget.modelUrl,
              controller: _controller,
              onLoading: (progress) {
                if (!mounted) return;
                if (progress == null) return;
              },
              onError: (error) {
                if (!mounted) return;
                setState(() => _hasError = true);
              },
            ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(active ? 0.9 : 0.2),
            child: Icon(icon, color: active ? Colors.redAccent : Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

void _onContactSeller(
  BuildContext pageContext,
  JewelryItem item,
  AppLocalizations localization,
  MessagesController messages,
) {
  final phone = item.sellerPhone?.trim();
  final email = item.sellerEmail?.trim();
  final whatsapp = item.sellerWhatsApp?.trim();

  final options = <_ContactOption>[];

  if (phone != null && phone.isNotEmpty) {
    options.add(
      _ContactOption(
        icon: Icons.call,
        label: localization.translate('callSeller'),
        subtitle: phone,
        onTap: (sheetContext) async {
          Navigator.of(sheetContext).pop();
          await _launchUri(
            pageContext,
            Uri(scheme: 'tel', path: phone),
            localization,
          );
        },
      ),
    );
  }

  if (email != null && email.isNotEmpty) {
    options.add(
      _ContactOption(
        icon: Icons.email_outlined,
        label: localization.translate('emailSeller'),
        subtitle: email,
        onTap: (sheetContext) async {
          Navigator.of(sheetContext).pop();
          await _launchUri(
            pageContext,
            Uri(scheme: 'mailto', path: email),
            localization,
          );
        },
      ),
    );
  }

  if (whatsapp != null && whatsapp.isNotEmpty) {
    final digits = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    options.add(
      _ContactOption(
        icon: Icons.whatsapp,
        label: localization.translate('whatsappSeller'),
        subtitle: whatsapp,
        onTap: (sheetContext) async {
          Navigator.of(sheetContext).pop();
          await _launchUri(
            pageContext,
            Uri.parse('https://wa.me/$digits'),
            localization,
          );
        },
      ),
    );
  }

  options.add(
    _ContactOption(
      icon: Icons.chat_bubble_outline,
      label: localization.translate('messages'),
      subtitle: localization.translate('contactSeller'),
      onTap: (sheetContext) async {
        Navigator.of(sheetContext).pop();
        messages.openThread(item.id, item.name);
        Navigator.of(pageContext).pushNamed('/messages', arguments: item.id);
      },
    ),
  );

  if (options.length == 1) {
    messages.openThread(item.id, item.name);
    Navigator.of(pageContext).pushNamed('/messages', arguments: item.id);
    return;
  }

  showModalBottomSheet<void>(
    context: pageContext,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final tokens = theme.extension<JewelThemeTokens>();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.translate('contactOptions'),
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (tileContext, index) {
                    final option = options[index];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
                      ),
                      tileColor: theme.colorScheme.surfaceVariant.withOpacity(0.25),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                        child: Icon(option.icon, color: theme.colorScheme.primary),
                      ),
                      title: Text(option.label),
                      subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
                      onTap: () => option.onTap(tileContext),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> _launchUri(
  BuildContext context,
  Uri uri,
  AppLocalizations localization,
) async {
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.translate('launchFailed'))),
    );
  }
}

class _ContactOption {
  const _ContactOption({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Future<void> Function(BuildContext context) onTap;
}
