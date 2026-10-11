import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_store.dart';
import '../../providers/auth_store.dart';
import '../../widgets/property_card.dart';
import '../property_detail_screen.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PropertyStore>();
    final auth = context.watch<AuthStore>();
    final user = auth.currentUser!;
    final mine = store.listedBy(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New listing'),
      ),
      body: mine.isEmpty
          ? const Center(child: Text('You have no listings yet. Tap "New listing" to add one.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: mine.length,
              itemBuilder: (context, i) {
                final p = mine[i];
                return GestureDetector(
                  onLongPress: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AddEditListingScreen(existing: p)),
                  ),
                  child: PropertyCard(
                    property: p,
                    isFavorite: store.favoriteIds.contains(p.id),
                    onToggleFavorite: () => store.toggleFavorite(p.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PropertyDetailScreen(propertyId: p.id)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
