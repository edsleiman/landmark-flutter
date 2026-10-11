import 'feature_catalog.dart';

enum PropertyType { residential, commercial, land, luxury }

extension PropertyTypeLabel on PropertyType {
  String get label {
    switch (this) {
      case PropertyType.residential:
        return 'Residential';
      case PropertyType.commercial:
        return 'Commercial';
      case PropertyType.land:
        return 'Land';
      case PropertyType.luxury:
        return 'Luxury';
    }
  }
}

enum ListingKind { sale, rent }

extension ListingKindLabel on ListingKind {
  String get label => this == ListingKind.sale ? 'For Sale' : 'For Rent';
}

enum SortOption { newest, priceLow, priceHigh, sizeLarge }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Newest';
      case SortOption.priceLow:
        return 'Price: Low to High';
      case SortOption.priceHigh:
        return 'Price: High to Low';
      case SortOption.sizeLarge:
        return 'Largest';
    }
  }
}

class Property {
  final String id;
  final String title;
  final String description;
  final PropertyType type;
  final ListingKind listingKind;
  final PropertySubType? subType;
  final PropertyCondition? condition;
  final double price;
  final String currency;
  final String city;
  final String neighborhood;
  final double? latitude;
  final double? longitude;
  final double areaSqm;
  final double? landAreaSqm;
  final int bedrooms;
  final int bathrooms;
  final int? floorNumber;
  final int? totalBuildingFloors;
  final List<String> amenities;
  final List<String> imageUrls; // remote URLs or local file:// paths
  final bool verified;
  final DateTime createdAt;
  final String? ownerUserId; // seller/owner who listed it (customer-added)

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.listingKind,
    this.subType,
    this.condition,
    required this.price,
    this.currency = 'USD',
    required this.city,
    required this.neighborhood,
    this.latitude,
    this.longitude,
    required this.areaSqm,
    this.landAreaSqm,
    required this.bedrooms,
    required this.bathrooms,
    this.floorNumber,
    this.totalBuildingFloors,
    this.amenities = const [],
    this.imageUrls = const [],
    this.verified = false,
    required this.createdAt,
    this.ownerUserId,
  });

  Property copyWith({
    String? title,
    String? description,
    double? price,
    List<String>? amenities,
    List<String>? imageUrls,
    bool? verified,
  }) {
    return Property(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type,
      listingKind: listingKind,
      subType: subType,
      condition: condition,
      price: price ?? this.price,
      currency: currency,
      city: city,
      neighborhood: neighborhood,
      latitude: latitude,
      longitude: longitude,
      areaSqm: areaSqm,
      landAreaSqm: landAreaSqm,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      floorNumber: floorNumber,
      totalBuildingFloors: totalBuildingFloors,
      amenities: amenities ?? this.amenities,
      imageUrls: imageUrls ?? this.imageUrls,
      verified: verified ?? this.verified,
      createdAt: createdAt,
      ownerUserId: ownerUserId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'listingKind': listingKind.name,
        'subType': subType?.name,
        'condition': condition?.name,
        'price': price,
        'currency': currency,
        'city': city,
        'neighborhood': neighborhood,
        'latitude': latitude,
        'longitude': longitude,
        'areaSqm': areaSqm,
        'landAreaSqm': landAreaSqm,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'floorNumber': floorNumber,
        'totalBuildingFloors': totalBuildingFloors,
        'amenities': amenities,
        'imageUrls': imageUrls,
        'verified': verified,
        'createdAt': createdAt.toIso8601String(),
        'ownerUserId': ownerUserId,
      };

  factory Property.fromJson(Map<String, dynamic> j) => Property(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        type: PropertyType.values.byName(j['type']),
        listingKind: ListingKind.values.byName(j['listingKind']),
        subType: j['subType'] != null
            ? PropertySubType.values.byName(j['subType'])
            : null,
        condition: j['condition'] != null
            ? PropertyCondition.values.byName(j['condition'])
            : null,
        price: (j['price'] as num).toDouble(),
        currency: j['currency'] ?? 'USD',
        city: j['city'],
        neighborhood: j['neighborhood'],
        latitude: j['latitude'],
        longitude: j['longitude'],
        areaSqm: (j['areaSqm'] as num).toDouble(),
        landAreaSqm: (j['landAreaSqm'] as num?)?.toDouble(),
        bedrooms: j['bedrooms'],
        bathrooms: j['bathrooms'],
        floorNumber: j['floorNumber'],
        totalBuildingFloors: j['totalBuildingFloors'],
        amenities: List<String>.from(j['amenities'] ?? []),
        imageUrls: List<String>.from(j['imageUrls'] ?? []),
        verified: j['verified'] ?? false,
        createdAt: DateTime.parse(j['createdAt']),
        ownerUserId: j['ownerUserId'],
      );
}

class PropertyFilter {
  PropertyType? type;
  ListingKind? listingKind;
  double? minPrice;
  double? maxPrice;
  int? minBedrooms;
  Set<String> amenities = {};
  bool verifiedOnly = false;
  String query = '';
  SortOption sort = SortOption.newest;

  int get activeCount {
    var n = 0;
    if (type != null) n++;
    if (listingKind != null) n++;
    if (minPrice != null) n++;
    if (maxPrice != null) n++;
    if (minBedrooms != null) n++;
    if (amenities.isNotEmpty) n++;
    if (verifiedOnly) n++;
    return n;
  }

  void reset() {
    type = null;
    listingKind = null;
    minPrice = null;
    maxPrice = null;
    minBedrooms = null;
    amenities = {};
    verifiedOnly = false;
  }

  bool matches(Property p) {
    if (type != null && p.type != type) return false;
    if (listingKind != null && p.listingKind != listingKind) return false;
    if (minPrice != null && p.price < minPrice!) return false;
    if (maxPrice != null && p.price > maxPrice!) return false;
    if (minBedrooms != null && p.bedrooms < minBedrooms!) return false;
    if (verifiedOnly && !p.verified) return false;
    if (amenities.isNotEmpty &&
        !amenities.every((a) => p.amenities.contains(a))) {
      return false;
    }
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      final hay =
          '${p.title} ${p.city} ${p.neighborhood} ${p.description}'
              .toLowerCase();
      if (!hay.contains(q)) return false;
    }
    return true;
  }
}
