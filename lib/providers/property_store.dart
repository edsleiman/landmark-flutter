import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../services/property_service.dart';

class PropertyStore extends ChangeNotifier {
  final PropertyService service;
  PropertyStore(this.service);

  List<Property> properties = [];
  Set<String> favoriteIds = {};
  bool isLoading = false;
  String? errorMessage;
  PropertyFilter filter = PropertyFilter();

  List<Property> get filtered {
    final list = properties.where(filter.matches).toList();
    switch (filter.sort) {
      case SortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.sizeLarge:
        list.sort((a, b) => b.areaSqm.compareTo(a.areaSqm));
        break;
    }
    return list;
  }

  List<Property> get favorites => properties.where((p) => favoriteIds.contains(p.id)).toList();

  List<Property> listedBy(String userId) => properties.where((p) => p.ownerUserId == userId).toList();

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      properties = await service.fetchProperties();
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addProperty(Property property) async {
    await service.addProperty(property);
    await load();
  }

  Future<void> updateProperty(Property property) async {
    await service.updateProperty(property);
    await load();
  }

  void toggleFavorite(String propertyId) {
    if (favoriteIds.contains(propertyId)) {
      favoriteIds.remove(propertyId);
    } else {
      favoriteIds.add(propertyId);
    }
    notifyListeners();
  }

  void setFilter(PropertyFilter Function(PropertyFilter) update) {
    filter = update(filter);
    notifyListeners();
  }

  Property? byId(String id) {
    final matches = properties.where((p) => p.id == id).toList();
    return matches.isEmpty ? null : matches.first;
  }
}
