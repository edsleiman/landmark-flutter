import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_store.dart';
import '../../widgets/property_card.dart';
import '../property_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PropertyStore>();
    final favorites = store.favorites;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: favorites.isEmpty
          ? const Center(child: Text('No saved properties yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, i) {
                final p = favorites[i];
                return PropertyCard(
                  property: p,
                  isFavorite: true,
                  onToggleFavorite: () => store.toggleFavorite(p.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => PropertyDetailScreen(propertyId: p.id)),
                  ),
                );
              },
            ),
    );
  }
}
