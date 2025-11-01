import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/jewelry_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const routeName = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
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
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final catalog = ControllersScope.of(context).catalogController;
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('search'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          t.translate('noSearchResults'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(item.images.first),
                            ),
                            title: Text(item.name),
                            subtitle: Text('${item.brand} • ${item.material.name}'),
                            onTap: () => Navigator.of(context)
                                .pushNamed('/details', arguments: item),
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
    final run = () {
      final hits = catalog.searchIndex(value.trim());
      setState(() {
        _results = hits;
        _loading = false;
      });
    };
    if (immediate) {
      run();
    } else {
      _debounce = Timer(const Duration(milliseconds: 250), run);
    }
  }
}
