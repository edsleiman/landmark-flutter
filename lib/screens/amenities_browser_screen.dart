import 'package:flutter/material.dart';
import '../models/feature_catalog.dart';

/// Searchable, grouped, multi-select amenities browser — the full categorized
/// catalog, not just the quick-filter shortlist.
class AmenitiesBrowserScreen extends StatefulWidget {
  final Set<String> initialSelection;
  const AmenitiesBrowserScreen({super.key, this.initialSelection = const {}});

  @override
  State<AmenitiesBrowserScreen> createState() => _AmenitiesBrowserScreenState();
}

class _AmenitiesBrowserScreenState extends State<AmenitiesBrowserScreen> {
  late Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final categories = FeatureCatalog.categories
        .map((c) => FeatureCategory(
            c.id, q.isEmpty ? c.items : c.items.where((i) => i.toLowerCase().contains(q)).toList()))
        .where((c) => c.items.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Amenities (${_selected.length})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search amenities',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final cat = categories[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 6),
                      child: Text(cat.id,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cat.items.map((item) {
                        final selected = _selected.contains(item);
                        return FilterChip(
                          label: Text(item),
                          selected: selected,
                          onSelected: (v) => setState(() {
                            if (v) {
                              _selected.add(item);
                            } else {
                              _selected.remove(item);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only grouped display of a property's own amenities (detail screen).
class AmenitiesByCategory extends StatelessWidget {
  final List<String> amenities;
  const AmenitiesByCategory({super.key, required this.amenities});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> grouped = {};
    for (final a in amenities) {
      final cat = FeatureCatalog.categoryFor(a) ?? 'Other';
      grouped.putIfAbsent(cat, () => []).add(a);
    }
    final keys = grouped.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keys.map((k) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: grouped[k]!
                    .map((item) => Chip(label: Text(item, style: const TextStyle(fontSize: 12.5))))
                    .toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
