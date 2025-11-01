import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';

class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final controllers = ControllersScope.of(context);
    final catalog = controllers.catalogController;
    return RefreshIndicator(
      onRefresh: catalog.refresh,
      child: AnimatedBuilder(
        animation: catalog,
        builder: (context, _) {
          final items = catalog.items;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeroSection(title: 'Royal Gems', subtitle: 'Pink gradient • Exclusive'),
              const SizedBox(height: 24),
              _BrandRow(),
              const SizedBox(height: 24),
              Text(
                t.translate('newArrivals'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/details', arguments: item),
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          image: DecorationImage(
                            image: NetworkImage(item.images.first),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: [Colors.black54, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.brand,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(t.translate('aiInfo')),
                      content: const Text(
                        'سيتم لاحقًا استخدام الذكاء الاصطناعي لشرح مواصفات الحجر والمعدن.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('حسنًا'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                label: Text(t.translate('aiInfo')),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.8), theme.colorScheme.secondaryContainer],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.donut_large,
                size: 120,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pushNamed('/details', arguments: null),
                  style: FilledButton.styleFrom(backgroundColor: Colors.white),
                  child: Text(
                    'Explore',
                    style: TextStyle(color: theme.colorScheme.primary),
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

class _BrandRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final brands = List.generate(
      5,
      (index) => 'https://picsum.photos/seed/brand${index + 1}/200/200',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('brands'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final url = brands[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
              );
            },
          ),
        ),
      ],
    );
  }
}
