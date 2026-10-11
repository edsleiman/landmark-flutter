import 'package:flutter/material.dart';
import '../models/property.dart';
import '../models/feature_catalog.dart';
import 'amenities_browser_screen.dart';

class FilterScreen extends StatefulWidget {
  final PropertyFilter filter;
  const FilterScreen({super.key, required this.filter});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late PropertyFilter _f;

  @override
  void initState() {
    super.initState();
    _f = PropertyFilter()
      ..type = widget.filter.type
      ..listingKind = widget.filter.listingKind
      ..minPrice = widget.filter.minPrice
      ..maxPrice = widget.filter.maxPrice
      ..minBedrooms = widget.filter.minBedrooms
      ..amenities = {...widget.filter.amenities}
      ..verifiedOnly = widget.filter.verifiedOnly
      ..query = widget.filter.query
      ..sort = widget.filter.sort;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        actions: [
          TextButton(onPressed: () => setState(() => _f.reset()), child: const Text('Reset')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _f.type == null,
                onSelected: (_) => setState(() => _f.type = null),
              ),
              ...PropertyType.values.map((t) => ChoiceChip(
                    label: Text(t.label),
                    selected: _f.type == t,
                    onSelected: (_) => setState(() => _f.type = t),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Listing', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Any'),
                selected: _f.listingKind == null,
                onSelected: (_) => setState(() => _f.listingKind = null),
              ),
              ...ListingKind.values.map((k) => ChoiceChip(
                    label: Text(k.label),
                    selected: _f.listingKind == k,
                    onSelected: (_) => setState(() => _f.listingKind = k),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Minimum bedrooms', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [0, 1, 2, 3, 4].map((n) {
              return ChoiceChip(
                label: Text(n == 0 ? 'Any' : '$n+'),
                selected: (_f.minBedrooms ?? 0) == n,
                onSelected: (_) => setState(() => _f.minBedrooms = n == 0 ? null : n),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Verified listings only'),
            value: _f.verifiedOnly,
            onChanged: (v) => setState(() => _f.verifiedOnly = v),
          ),
          const SizedBox(height: 10),
          const Text('Quick amenities', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FeatureCatalog.quickFilters.map((item) {
              final selected = _f.amenities.contains(item);
              return FilterChip(
                label: Text(item),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _f.amenities.add(item);
                  } else {
                    _f.amenities.remove(item);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () async {
                final result = await Navigator.of(context).push<Set<String>>(
                  MaterialPageRoute(
                    builder: (_) => AmenitiesBrowserScreen(initialSelection: _f.amenities),
                  ),
                );
                if (result != null) setState(() => _f.amenities = result);
              },
              child: const Text('Browse all amenities →'),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Sort by', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SortOption.values.map((s) => ChoiceChip(
                  label: Text(s.label),
                  selected: _f.sort == s,
                  onSelected: (_) => setState(() => _f.sort = s),
                )).toList(),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_f),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Apply filters'),
          ),
        ],
      ),
    );
  }
}
