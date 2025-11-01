import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/controllers_scope.dart';
import '../controllers/saved_searches_controller.dart';
import '../widgets/jewel_cached_image.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/domain/models/jewelry_item.dart';

import 'saved_searches_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const routeName = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceAlertController = TextEditingController();
  Timer? _debounce;
  List<JewelryItem> _results = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalog = ControllersScope.of(context).catalogController;
      setState(() => _results = catalog.items);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _priceAlertController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ControllersScope.of(context);
    final catalog = scope.catalogController;
    final savedSearches = scope.savedSearchesController;
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('search')),
        actions: [
          IconButton(
            tooltip: t.translate('savedSearches'),
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => Navigator.of(context).pushNamed(SavedSearchesPage.routeName),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: t.translate('searchHint'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => _triggerSearch(catalog, value),
              onSubmitted: (value) => _triggerSearch(catalog, value, immediate: true),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save_alt),
                    label: Text(t.translate('saveSearch')),
                    onPressed: () => _saveCurrentSearch(t, catalog, savedSearches),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamed(SavedSearchesPage.routeName),
                  child: Text(t.translate('savedSearches')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            t.translate('noSearchResults'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return ListTile(
                            leading: JewelCachedImage(
                              imageUrl: item.images.first,
                              width: 52,
                              height: 52,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text(item.name),
                            subtitle: Text('${item.brand} • ${item.material.name}'),
                            onTap: () => Navigator.of(context).pushNamed(
                              '/details',
                              arguments: item,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _triggerSearch(CatalogController catalog, String value, {bool immediate = false}) {
    _debounce?.cancel();
    setState(() => _loading = true);
    void run() {
      final hits = catalog.searchIndex(value.trim());
      setState(() {
        _results = hits;
        _loading = false;
      });
    }

    if (immediate) {
      run();
    } else {
      _debounce = Timer(const Duration(milliseconds: 250), run);
    }
  }

  Future<void> _saveCurrentSearch(
    AppLocalizations t,
    CatalogController catalog,
    SavedSearchesController savedSearches,
  ) async {
    final query = _controller.text.trim();
    _nameController
      ..text = query
      ..selection = TextSelection.collapsed(offset: _nameController.text.length);
    _priceAlertController.clear();

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
                t.translate('saveSearch'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: t.translate('searchNameLabel')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceAlertController,
                decoration: InputDecoration(labelText: t.translate('priceAlertLabel')),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'name': _nameController.text.trim(),
                        'price': double.tryParse(_priceAlertController.text.trim()),
                      });
                    },
                    child: Text(t.translate('apply')),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(t.translate('cancel')),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      await savedSearches.saveCurrent(
        name: result['name'] as String? ?? query,
        query: query,
        filters: catalog.exportFilters(),
        priceAlertBelow: result['price'] as double?,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('searchSaved'))),
      );
    }
  }
}
