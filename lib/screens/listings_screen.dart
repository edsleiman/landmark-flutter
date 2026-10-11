import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_store.dart';
import '../widgets/property_card.dart';
import 'filter_screen.dart';
import 'property_detail_screen.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PropertyStore>();
    final listings = store.filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () async {
                  final result = await Navigator.of(context).push<dynamic>(
                    MaterialPageRoute(builder: (_) => FilterScreen(filter: store.filter)),
                  );
                  if (result != null) {
                    store.setFilter((_) => result);
                  }
                },
              ),
              if (store.filter.activeCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.redAccent,
                    child: Text('${store.filter.activeCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => store.load(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Area, city or keyword',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => store.setFilter((f) {
                  f.query = v;
                  return f;
                }),
              ),
            ),
            Expanded(
              child: store.isLoading && listings.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : listings.isEmpty
                      ? const Center(child: Text('No properties match your search.'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                          itemCount: listings.length,
                          itemBuilder: (context, i) {
                            final p = listings[i];
                            return PropertyCard(
                              property: p,
                              isFavorite: store.favoriteIds.contains(p.id),
                              onToggleFavorite: () => store.toggleFavorite(p.id),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => PropertyDetailScreen(propertyId: p.id)),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
