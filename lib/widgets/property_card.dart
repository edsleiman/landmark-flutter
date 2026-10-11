import 'dart:io';
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../theme.dart';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: LandmarkColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: LandmarkColors.navy.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 11,
                    child: _Thumbnail(url: property.imageUrls.isNotEmpty ? property.imageUrls.first : null),
                  ),
                  // Gradient scrim so the badges/price stay legible over any photo.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 70,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0), Colors.black.withOpacity(0.45)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      children: [
                        _Badge(
                          text: property.listingKind.label,
                          color: property.listingKind == ListingKind.sale
                              ? LandmarkColors.navy
                              : LandmarkColors.teal,
                        ),
                        if (property.verified) ...[
                          const SizedBox(width: 6),
                          const _Badge(text: 'Verified', color: LandmarkColors.success, icon: Icons.verified),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.black.withOpacity(0.28),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? LandmarkColors.goldLight : Colors.white, size: 20),
                        onPressed: onToggleFavorite,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 10,
                    child: Text(
                      '\$${_formatPrice(property.price)}${property.listingKind == ListingKind.rent ? "/mo" : ""}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 14, color: LandmarkColors.inkMuted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text('${property.neighborhood}, ${property.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (property.bedrooms > 0) ...[
                          _MetaChip(icon: Icons.bed_outlined, label: '${property.bedrooms}'),
                          const SizedBox(width: 14),
                        ],
                        if (property.bathrooms > 0) ...[
                          _MetaChip(icon: Icons.bathtub_outlined, label: '${property.bathrooms}'),
                          const SizedBox(width: 14),
                        ],
                        _MetaChip(icon: Icons.square_foot, label: '${property.areaSqm.toStringAsFixed(0)} m²'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [LandmarkColors.navy.withOpacity(0.12), LandmarkColors.teal.withOpacity(0.18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(child: Icon(Icons.home_outlined, size: 44, color: LandmarkColors.navy.withOpacity(0.35))),
      );
    }
    if (url!.startsWith('file://') || url!.startsWith('/')) {
      final path = url!.startsWith('file://') ? url!.replaceFirst('file://', '') : url!;
      return Image.file(File(path), fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: LandmarkColors.navy.withOpacity(0.08)));
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: LandmarkColors.navy.withOpacity(0.06),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: LandmarkColors.navy.withOpacity(0.08),
        child: Center(child: Icon(Icons.broken_image_outlined, color: LandmarkColors.navy.withOpacity(0.3))),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const _Badge({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: Colors.white), const SizedBox(width: 3)],
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
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
        Icon(icon, size: 15, color: LandmarkColors.inkMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12.5, color: LandmarkColors.inkMuted, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
