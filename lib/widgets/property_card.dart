import 'dart:io';
import 'package:flutter/material.dart';
import '../models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const PropertyCard({
    super.key,
    required this.property,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: _Thumbnail(url: property.imageUrls.isNotEmpty ? property.imageUrls.first : null),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      _Badge(text: property.listingKind.label),
                      if (property.verified) ...[
                        const SizedBox(width: 6),
                        const _Badge(text: 'Verified', color: Colors.green),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.white),
                    onPressed: onToggleFavorite,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                  const SizedBox(height: 4),
                  Text('${property.neighborhood}, ${property.city}',
                      style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${_formatPrice(property.price)}${property.listingKind == ListingKind.rent ? "/month" : ""}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      if (property.bedrooms > 0) _MetaChip(icon: Icons.bed, label: '${property.bedrooms}'),
                      const SizedBox(width: 10),
                      if (property.bathrooms > 0) _MetaChip(icon: Icons.bathtub, label: '${property.bathrooms}'),
                      const SizedBox(width: 10),
                      _MetaChip(icon: Icons.square_foot, label: '${property.areaSqm.toStringAsFixed(0)} m²'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPrice(double price) {
    final s = price.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _Thumbnail extends StatelessWidget {
  final String? url;
  const _Thumbnail({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        color: Colors.black12,
        child: const Icon(Icons.home_outlined, size: 48, color: Colors.black38),
      );
    }
    if (url!.startsWith('file://') || url!.startsWith('/')) {
      final path = url!.startsWith('file://') ? url!.replaceFirst('file://', '') : url!;
      return Image.file(File(path), fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.black12));
    }
    return Image.network(url!, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.black12));
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, this.color = Colors.black87});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.85), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
      ],
    );
  }
}
