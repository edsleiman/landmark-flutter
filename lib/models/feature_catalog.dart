// Detailed property sub-type (separate from the broad PropertyType filter tabs)
enum PropertySubType {
  apartment,
  penthouse,
  duplex,
  triplex,
  loft,
  villa,
  townhouse,
  chalet,
  studio,
  servicedApartment,
  furnishedApartment,
  office,
  retail,
}

extension PropertySubTypeLabel on PropertySubType {
  String get label {
    switch (this) {
      case PropertySubType.apartment:
        return 'Apartment';
      case PropertySubType.penthouse:
        return 'Penthouse';
      case PropertySubType.duplex:
        return 'Duplex';
      case PropertySubType.triplex:
        return 'Triplex';
      case PropertySubType.loft:
        return 'Loft';
      case PropertySubType.villa:
        return 'Villa';
      case PropertySubType.townhouse:
        return 'Townhouse';
      case PropertySubType.chalet:
        return 'Chalet';
      case PropertySubType.studio:
        return 'Studio';
      case PropertySubType.servicedApartment:
        return 'Serviced apartment';
      case PropertySubType.furnishedApartment:
        return 'Furnished apartment';
      case PropertySubType.office:
        return 'Office';
      case PropertySubType.retail:
        return 'Retail / commercial property';
    }
  }
}

// Property condition (single-select status, not a tag)
enum PropertyCondition {
  brandNew,
  newConstruction,
  underConstruction,
  offPlan,
  recentlyRenovated,
  renovated,
  excellent,
  veryGood,
  good,
  needsRenovation,
  shellAndCore,
  readyToMoveIn,
  vacant,
  tenanted,
  investment,
}

extension PropertyConditionLabel on PropertyCondition {
  String get label {
    switch (this) {
      case PropertyCondition.brandNew:
        return 'Brand new';
      case PropertyCondition.newConstruction:
        return 'New construction';
      case PropertyCondition.underConstruction:
        return 'Under construction';
      case PropertyCondition.offPlan:
        return 'Off-plan';
      case PropertyCondition.recentlyRenovated:
        return 'Recently renovated';
      case PropertyCondition.renovated:
        return 'Renovated';
      case PropertyCondition.excellent:
        return 'Excellent condition';
      case PropertyCondition.veryGood:
        return 'Very good condition';
      case PropertyCondition.good:
        return 'Good condition';
      case PropertyCondition.needsRenovation:
        return 'Needs renovation';
      case PropertyCondition.shellAndCore:
        return 'Shell & core';
      case PropertyCondition.readyToMoveIn:
        return 'Ready to move in';
      case PropertyCondition.vacant:
        return 'Vacant';
      case PropertyCondition.tenanted:
        return 'Tenanted';
      case PropertyCondition.investment:
        return 'Investment property';
    }
  }
}

class FeatureCategory {
  final String id; // category name, also used as the section title
  final List<String> items;
  const FeatureCategory(this.id, this.items);
}

class FeatureCatalog {
  FeatureCatalog._();

  /// Full categorized list, matching Beirut real-estate listing terminology.
  static const List<FeatureCategory> categories = [
    FeatureCategory('Rooms & Layout', [
      'Master bedroom', "Guest bathroom / powder room", 'Living room', 'Dining room',
      'Family room', 'TV room', 'Reception area', 'Home office', 'Kitchen', 'Pantry',
      'Laundry room', "Maid's room", "Maid's bathroom", "Driver's room", "Driver's bathroom",
      'Storage room', 'Basement/cave', 'Walk-in closet', 'Dressing room', 'Entrance hall',
      'Service entrance', 'Service elevator',
    ]),
    FeatureCategory('Outdoor', [
      'Balcony', 'Multiple balconies', 'Large terrace', 'Rooftop', 'Terrace',
      'Private garden', 'Shared garden', 'Landscaped garden', 'Private courtyard',
      'Outdoor seating area', 'BBQ area', 'Outdoor kitchen', 'Private swimming pool',
      'Shared swimming pool', "Children's pool", 'Jacuzzi', 'Outdoor shower', 'Playground',
      "Children's play area", 'Green areas', 'Fruit trees', 'Private rooftop',
      'Sea-view terrace', 'Panoramic terrace',
    ]),
    FeatureCategory('Views', [
      'Sea view', 'Partial sea view', 'Full sea view', 'City view', 'Downtown view',
      'Mountain view', 'Beirut skyline view', 'Garden view', 'Pool view', 'Street view',
      'Panoramic view', 'Open view', 'Unobstructed view', 'Sunset view',
    ]),
    FeatureCategory('Parking & Transportation', [
      'Private parking', 'Underground parking', 'Covered parking', 'Uncovered parking',
      'Assigned parking spaces', 'Multiple parking spaces', 'Visitor parking',
      'Valet parking', 'Remote-controlled parking', 'Automated parking',
      'EV charging station', 'Motorcycle parking', 'Bicycle storage', "Driver's room",
      'Easy road access',
    ]),
    FeatureCategory('Building Facilities & Services', [
      'Elevator', 'Multiple elevators', 'High-speed elevator', 'Service elevator',
      '24/7 concierge', 'Reception/lobby', 'Doorman', 'Security guards', '24/7 security',
      'CCTV/security cameras', 'Gated entrance', 'Controlled building access',
      'Video intercom', 'Key-card access', 'Smart access', 'Property management',
      'Maintenance service', 'On-site maintenance', 'Cleaning service', 'Common areas',
      "Residents' lounge", 'Visitor parking', 'Parcel/package room',
    ]),
    FeatureCategory('Electricity & Utilities', [
      'Municipal electricity', 'Generator', 'Private generator', 'Building generator',
      '24/7 electricity', 'Generator backup', 'UPS', 'Inverter system', 'Solar panels',
      'Solar energy system', 'Solar water heating', 'Battery storage', 'Emergency power',
      'Water tank', 'Private water supply', 'Municipal water', 'Well water', 'Water pump',
      'Hot-water tank', 'Central hot water', 'Independent electricity meter',
      'Independent water meter', 'Independent generator meter', 'Sewage connection',
      'Municipal sewer', 'Wastewater system',
    ]),
    FeatureCategory('Heating & Cooling', [
      'Central A/C', 'Split A/C', 'Ducted A/C', 'Multi-split A/C', 'VRV/VRF system',
      'Heating system', 'Central heating', 'Electric heating', 'Gas heating', 'Radiators',
      'Underfloor heating', 'Fireplace', 'Electric fireplace', 'Wood-burning fireplace',
      'Climate-control system', 'Individual temperature controls',
    ]),
    FeatureCategory('Kitchen', [
      'Fully equipped kitchen', 'Open-plan kitchen', 'Closed kitchen', 'Modern kitchen',
      'Built-in kitchen', 'Kitchen island', 'Breakfast bar', 'Pantry', 'Built-in oven',
      'Gas oven', 'Electric oven', 'Microwave', 'Refrigerator', 'Freezer', 'Dishwasher',
      'Washing machine', 'Dryer', 'Wine cooler', 'Built-in coffee machine',
      'Extractor hood', 'Gas stove', 'Electric stove', 'Induction cooktop',
      'Built-in appliances', 'Granite countertops', 'Marble countertops',
      'Quartz countertops', 'Solid-surface countertops', 'Custom cabinetry',
    ]),
    FeatureCategory('Interior', [
      'Furnished', 'Fully furnished', 'Semi-furnished', 'Unfurnished', 'High ceilings',
      'Floor-to-ceiling windows', 'Double-glazed windows', 'Large windows',
      'Panoramic windows', 'Built-in wardrobes', 'Walk-in closets', 'Dressing rooms',
      'Hardwood flooring', 'Parquet flooring', 'Marble flooring', 'Ceramic flooring',
      'Porcelain flooring', 'Stone flooring', 'Tiled floors', 'Modern finishes',
      'Luxury finishes', 'Renovated interiors', 'Open-plan layout', 'Soundproofing',
      'Thermal insulation', 'Double glazing', 'Safety/security door',
    ]),
    FeatureCategory('Technology & Connectivity', [
      'High-speed internet', 'Fiber-optic internet', 'Fiber-to-the-home', 'Wi-Fi',
      'Satellite TV', 'Cable TV', 'Smart TV', 'Smart-home system', 'Smart lighting',
      'Smart thermostat', 'Smart locks', 'Video intercom', 'Home automation',
      'Security alarm', 'CCTV', 'Network cabling', 'Telephone lines',
      'Internet-ready building',
    ]),
    FeatureCategory('Security', [
      '24/7 security', 'Security guards', 'CCTV cameras', 'Security system',
      'Alarm system', 'Gated building', 'Gated community', 'Controlled access',
      'Key-card entry', 'Electronic access', 'Video intercom', 'Security door',
      'Visitor registration', 'Doorman', 'Concierge', 'Secure underground parking',
      'Emergency exits',
    ]),
    FeatureCategory('Fire & Emergency Safety', [
      'Smoke detectors', 'Fire alarms', 'Fire sprinklers', 'Fire extinguishers',
      'Fire-fighting system', 'Fire hose reels', 'Emergency exits', 'Emergency lighting',
      'Fire-rated doors', 'Fire escape', 'Backup emergency power', 'Evacuation system',
      'Building safety system',
    ]),
    FeatureCategory('Fitness & Wellness', [
      'Gym', 'Fitness center', 'Fully equipped gym', 'Indoor gym', 'Outdoor gym',
      'Yoga room', 'Spa', 'Sauna', 'Steam room', 'Jacuzzi', 'Massage room',
      'Indoor swimming pool', 'Outdoor swimming pool', "Children's pool",
    ]),
    FeatureCategory('Family & Children', [
      "Children's playground", "Children's playroom", "Children's pool", "Kids' club",
      'Nursery/daycare', 'Family lounge', 'Garden', 'Safe outdoor play area',
      'Indoor play area', 'Baby-changing facilities',
    ]),
    FeatureCategory('Accessibility', [
      'Wheelchair accessible', 'Accessible entrance', 'Accessible elevator',
      'Accessible parking', 'Step-free entrance', 'Wide doorways',
      'Accessible bathrooms', 'Ramps', 'Accessible common areas',
    ]),
    FeatureCategory('Furnishing & Appliances', [
      'Fully furnished', 'Partially furnished', 'Unfurnished', 'Beds', 'Sofas',
      'Dining table', 'Dining chairs', 'TV', 'Curtains', 'Blinds', 'Lighting fixtures',
      'Kitchen appliances', 'Washing machine', 'Dryer', 'Refrigerator', 'Dishwasher',
      'Microwave', 'Oven', 'Cooktop', 'Air conditioners', 'Water heater',
    ]),
    FeatureCategory('Staff & Services', [
      'Concierge', '24/7 concierge', 'Reception service', 'Security', 'Doorman',
      'Housekeeping', 'Cleaning service', 'Laundry service', 'Maintenance',
      'Property management', 'Gardening', 'Pool maintenance', 'Waste collection',
      'Pest control', 'Valet parking', 'Delivery/package handling',
    ]),
    FeatureCategory('Luxury Amenities', [
      'Private elevator', 'Private lobby', 'Private swimming pool', 'Rooftop pool',
      'Indoor pool', 'Private gym', 'Private spa', 'Sauna', 'Steam room', 'Jacuzzi',
      'Cinema room', 'Home theater', 'Wine cellar', 'Wine room', 'Library', 'Games room',
      'Entertainment room', 'Private office', 'Business center', "Residents' lounge",
      'Sky lounge', 'Rooftop lounge', 'Private garden', 'Outdoor kitchen', 'BBQ area',
      'Smart-home automation', 'Home security system', "Driver's quarters",
      'Staff quarters', 'Multiple parking spaces', 'EV charging', 'Panoramic sea view',
    ]),
    FeatureCategory('Environmental / Energy', [
      'Solar panels', 'Solar water heating', 'Energy-efficient appliances', 'LED lighting',
      'Double-glazed windows', 'Thermal insulation', 'Green building',
      'Eco-friendly construction', 'Energy-efficient A/C', 'Water-saving fixtures',
      'Water recycling', 'Rainwater collection', 'Green roof', 'Landscaped gardens',
      'Waste recycling',
    ]),
    FeatureCategory('Nearby', [
      'Near restaurants', 'Near cafés', 'Near supermarkets', 'Near shopping malls',
      'Near schools', 'Near universities', 'Near hospitals', 'Near pharmacies',
      'Near banks', 'Near gyms', 'Near spas', 'Near nightlife', 'Near beaches',
      'Near public transportation', 'Near major highways', 'Near business districts',
      'Near Downtown Beirut', 'Near Beirut Central District',
    ]),
  ];

  /// A curated shortlist of the most commonly searched Beirut features, for quick-filter chips.
  static const List<String> quickFilters = [
    'Generator', '24/7 electricity', 'Solar system', 'Central A/C', 'Central heating',
    'Underground parking', 'Visitor parking', 'Elevator', 'Concierge', '24/7 security',
    'CCTV', 'Pool', 'Gym', 'Garden', 'Balcony', 'Terrace', 'Sea view', 'City view',
    "Maid's room", 'Storage room', 'Built-in wardrobes', 'Fully equipped kitchen',
    'Furnished', 'Fiber-optic internet', 'Fire alarms', 'Double glazing',
    'Wheelchair accessible', 'Property management',
  ];

  /// All items, flattened, for lookups.
  static List<String> get allItems =>
      categories.expand((c) => c.items).toList();

  /// The category title a given feature belongs to (first match), for grouped display.
  static String? categoryFor(String item) {
    for (final c in categories) {
      if (c.items.contains(item)) return c.id;
    }
    return null;
  }
}
