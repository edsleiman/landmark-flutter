import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/property_store.dart';
import '../providers/auth_store.dart';
import '../models/user.dart';
import '../models/feature_catalog.dart';
import 'amenities_browser_screen.dart';
import 'shared/contact_screen.dart';
import 'customer/request_viewing_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PropertyStore>();
    final auth = context.watch<AuthStore>();
    final property = store.byId(widget.propertyId);

    if (property == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Listing not found.')));
    }

    final user = auth.currentUser;
    final canRequestViewing = user != null &&
        user.accountType == AccountType.customer &&
        user.isBuyer &&
        property.ownerUserId != user.id;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  store.favoriteIds.contains(property.id) ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () => store.toggleFavorite(property.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: property.imageUrls.isEmpty
                  ? Container(color: Colors.black12, child: const Icon(Icons.home, size: 64))
                  : PageView.builder(
                      itemCount: property.imageUrls.length,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                      itemBuilder: (context, i) {
                        final url = property.imageUrls[i];
                        final isLocal = url.startsWith('file://') || url.startsWith('/');
                        return isLocal
                            ? Image.file(File(url.replaceFirst('file://', '')), fit: BoxFit.cover)
                            : Image.network(url, fit: BoxFit.cover);
                      },
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (property.imageUrls.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('${_imageIndex + 1} / ${property.imageUrls.length}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ),
                  Text(property.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${property.neighborhood}, ${property.city}',
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 10),
                  Text(
                    '\$${property.price.toStringAsFixed(0)}${property.listingKind.name == 'rent' ? '/month' : ''}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      _StatItem(icon: Icons.bed, label: '${property.bedrooms} bed'),
                      _StatItem(icon: Icons.bathtub, label: '${property.bathrooms} bath'),
                      _StatItem(icon: Icons.square_foot, label: '${property.areaSqm.toStringAsFixed(0)} m²'),
                      if (property.subType != null) _StatItem(icon: Icons.apartment, label: property.subType!.label),
                      if (property.condition != null) _StatItem(icon: Icons.verified_outlined, label: property.condition!.label),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(property.description),
                  const Divider(height: 32),
                  const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  AmenitiesByCategory(amenities: property.amenities),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ContactScreen(propertyId: property.id)),
                          ),
                          child: const Text('Send inquiry'),
                        ),
                      ),
                      if (canRequestViewing) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => RequestViewingScreen(propertyId: property.id)),
                            ),
                            child: const Text('Request a Viewing'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
