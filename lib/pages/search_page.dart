import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';
import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const routeName = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
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
              onSubmitted: catalog.search,
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: catalog,
              builder: (context, _) {
                final items = catalog.items;
                if (items.isEmpty) {
                  return Center(child: Text(t.translate('noPriceShown')));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(item.images.first),
                      ),
                      title: Text(item.name),
                      subtitle: Text(item.brand),
                      onTap: () => Navigator.of(context)
                          .pushNamed('/details', arguments: item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
