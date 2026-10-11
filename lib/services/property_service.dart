import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import '../models/feature_catalog.dart';

class PropertyService {
  // v2: bumped because v1 seeded demo listings with no photos, which is
  // already persisted on anyone who ran the app before this fix — bumping
  // the key forces a fresh seed with real photos instead of leaving the
  // old imageless data stuck in local storage.
  static const _storeKey = 'landmark.properties.v2';

  Future<List<Property>> fetchProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    if (raw == null) {
      final seeded = _seed();
      await _save(prefs, seeded);
      return seeded;
    }
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Property.fromJson).toList();
  }

  Future<void> addProperty(Property property) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await fetchProperties();
    current.insert(0, property);
    await _save(prefs, current);
  }

  Future<void> updateProperty(Property property) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await fetchProperties();
    final idx = current.indexWhere((p) => p.id == property.id);
    if (idx != -1) current[idx] = property;
    await _save(prefs, current);
  }

  Future<void> sendInquiry(
      {required String propertyID, required String name, required String phone, required String message}) async {
    // Mock: in a real backend this would POST to the server.
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _save(SharedPreferences prefs, List<Property> list) async {
    await prefs.setString(_storeKey, jsonEncode(list.map((p) => p.toJson()).toList()));
  }

  List<Property> _seed() {
    final now = DateTime.now();
    return [
      Property(
        id: 'p1',
        title: 'Sea-View Apartment in Achrafieh',
        description:
            'Bright 3-bedroom apartment with a full sea view, renovated kitchen, and a large terrace. Steps from Sassine Square.',
        type: PropertyType.residential,
        listingKind: ListingKind.sale,
        subType: PropertySubType.apartment,
        condition: PropertyCondition.renovated,
        price: 420000,
        city: 'Beirut',
        neighborhood: 'Achrafieh',
        latitude: 33.8886,
        longitude: 35.5131,
        areaSqm: 210,
        bedrooms: 3,
        bathrooms: 3,
        floorNumber: 5,
        totalBuildingFloors: 8,
        amenities: const [
          'Full sea view', 'Central A/C', 'Generator', '24/7 electricity',
          'Elevator', 'Underground parking', "Maid's room", 'Terrace',
          'Fully equipped kitchen', 'Built-in wardrobes',
        ],
        imageUrls: const [
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1598228723793-52759bba239c?auto=format&fit=crop&w=1200&q=80',
        ],
        verified: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Property(
        id: 'p2',
        title: 'Modern Duplex Penthouse in Verdun',
        description:
            'Luxury duplex penthouse with panoramic Beirut skyline views, private rooftop, and a plunge pool.',
        type: PropertyType.luxury,
        listingKind: ListingKind.sale,
        subType: PropertySubType.penthouse,
        condition: PropertyCondition.brandNew,
        price: 1250000,
        city: 'Beirut',
        neighborhood: 'Verdun',
        latitude: 33.8869,
        longitude: 35.4875,
        areaSqm: 410,
        bedrooms: 4,
        bathrooms: 5,
        floorNumber: 12,
        totalBuildingFloors: 12,
        amenities: const [
          'Beirut skyline view', 'Private rooftop', 'Private swimming pool',
          'Smart-home automation', 'Private elevator', '24/7 concierge',
          '24/7 security', 'EV charging station', 'Wine cellar',
        ],
        imageUrls: const [
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
        ],
        verified: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Property(
        id: 'p3',
        title: 'Cozy Studio for Rent in Hamra',
        description: 'Fully furnished studio near AUB, perfect for students or young professionals.',
        type: PropertyType.residential,
        listingKind: ListingKind.rent,
        subType: PropertySubType.studio,
        condition: PropertyCondition.good,
        price: 650,
        city: 'Beirut',
        neighborhood: 'Hamra',
        latitude: 33.8959,
        longitude: 35.4800,
        areaSqm: 55,
        bedrooms: 0,
        bathrooms: 1,
        floorNumber: 3,
        totalBuildingFloors: 6,
        amenities: const [
          'Fully furnished', 'Wi-Fi', 'Central heating', 'Elevator',
          'Near universities', 'Near cafés',
        ],
        imageUrls: const [
          'https://images.unsplash.com/photo-1560184897-ae75f418493e?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=1200&q=80',
        ],
        verified: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Property(
        id: 'p4',
        title: 'Commercial Office Space in Downtown Beirut',
        description: 'Open-plan office floor in a prime Downtown location, move-in ready.',
        type: PropertyType.commercial,
        listingKind: ListingKind.rent,
        subType: PropertySubType.office,
        condition: PropertyCondition.readyToMoveIn,
        price: 4200,
        city: 'Beirut',
        neighborhood: 'Downtown',
        latitude: 33.8975,
        longitude: 35.5048,
        areaSqm: 320,
        bedrooms: 0,
        bathrooms: 2,
        floorNumber: 7,
        totalBuildingFloors: 15,
        amenities: const [
          'Open-plan layout', 'High-speed internet', 'Central A/C',
          '24/7 security', 'Reception/lobby', 'Multiple elevators',
          'Near Downtown Beirut',
        ],
        imageUrls: const [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80',
          'https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=1200&q=80',
        ],
        verified: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Property(
        id: 'p5',
        title: 'Residential Land Plot in Broummana',
        description: 'Elevated 950 sqm plot with mountain views, ready to build.',
        type: PropertyType.land,
        listingKind: ListingKind.sale,
        condition: PropertyCondition.vacant,
        price: 380000,
        city: 'Mount Lebanon',
        neighborhood: 'Broummana',
        latitude: 33.8828,
        longitude: 35.6453,
        areaSqm: 950,
        landAreaSqm: 950,
        bedrooms: 0,
        bathrooms: 0,
        amenities: const ['Mountain view', 'Easy road access', 'Open view'],
        imageUrls: const [
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
        ],
        verified: false,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }
}
