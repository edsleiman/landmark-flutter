import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/property.dart';
import '../../models/feature_catalog.dart';
import '../../providers/property_store.dart';
import '../../providers/auth_store.dart';
import '../amenities_browser_screen.dart';

/// Seller/admin listing-creation + edit form. Photos use image_picker:
/// ImageSource.camera opens the device camera with the OS's own native
/// accept/retake UI (no custom camera UI needed — same as the Swift
/// UIImagePickerController approach), and ImageSource.gallery opens the
/// photo library picker. Photos append (not replace) and can be removed.
class AddEditListingScreen extends StatefulWidget {
  final Property? existing;
  const AddEditListingScreen({super.key, this.existing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController(text: '0');
  final _bathroomsCtrl = TextEditingController(text: '0');

  PropertyType _type = PropertyType.residential;
  ListingKind _listingKind = ListingKind.sale;
  PropertySubType? _subType;
  PropertyCondition? _condition;
  Set<String> _amenities = {};
  final List<String> _photoPaths = [];
  bool _saving = false;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _titleCtrl.text = p.title;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toStringAsFixed(0);
      _cityCtrl.text = p.city;
      _neighborhoodCtrl.text = p.neighborhood;
      _areaCtrl.text = p.areaSqm.toStringAsFixed(0);
      _bedroomsCtrl.text = '${p.bedrooms}';
      _bathroomsCtrl.text = '${p.bathrooms}';
      _type = p.type;
      _listingKind = p.listingKind;
      _subType = p.subType;
      _condition = p.condition;
      _amenities = {...p.amenities};
      _photoPaths.addAll(p.imageUrls);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _cityCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _areaCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    // Opens the native camera UI, which already provides Retake/Use Photo.
    final shot = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (shot == null) return;
    await _storeAndAppend(shot);
  }

  Future<void> _pickFromLibrary() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    for (final p in picked) {
      await _storeAndAppend(p);
    }
  }

  Future<void> _storeAndAppend(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = '${const Uuid().v4()}.jpg';
    final dest = '${dir.path}/listing_photos/$name';
    await Directory('${dir.path}/listing_photos').create(recursive: true);
    final saved = await File(file.path).copy(dest);
    setState(() => _photoPaths.add(saved.path));
  }

  void _removePhoto(int index) {
    setState(() => _photoPaths.removeAt(index));
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final store = context.read<PropertyStore>();
    final auth = context.read<AuthStore>();
    final user = auth.currentUser!;

    final property = Property(
      id: widget.existing?.id ?? const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: _type,
      listingKind: _listingKind,
      subType: _subType,
      condition: _condition,
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      city: _cityCtrl.text.trim(),
      neighborhood: _neighborhoodCtrl.text.trim(),
      areaSqm: double.tryParse(_areaCtrl.text.trim()) ?? 0,
      bedrooms: int.tryParse(_bedroomsCtrl.text.trim()) ?? 0,
      bathrooms: int.tryParse(_bathroomsCtrl.text.trim()) ?? 0,
      amenities: _amenities.toList(),
      imageUrls: _photoPaths,
      verified: widget.existing?.verified ?? (user.accountType.name == 'admin'),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      ownerUserId: widget.existing?.ownerUserId ?? user.id,
    );

    if (widget.existing == null) {
      await store.addProperty(property);
    } else {
      await store.updateProperty(property);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add listing' : 'Edit listing')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int i = 0; i < _photoPaths.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(_photoPaths[i]), width: 96, height: 96, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removePhoto(i),
                              child: const CircleAvatar(
                                radius: 11,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _AddPhotoButton(icon: Icons.camera_alt, label: 'Camera', onTap: _takePhoto),
                  const SizedBox(width: 8),
                  _AddPhotoButton(icon: Icons.photo_library, label: 'Library', onTap: _pickFromLibrary),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (\$)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _areaCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Area (m²)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder())),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                      controller: _neighborhoodCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Neighborhood', border: OutlineInputBorder())),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bedroomsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bedrooms', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _bathroomsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bathrooms', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: PropertyType.values
                  .map((t) => ChoiceChip(
                        label: Text(t.label),
                        selected: _type == t,
                        onSelected: (_) => setState(() => _type = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('Listing', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ListingKind.values
                  .map((k) => ChoiceChip(
                        label: Text(k.label),
                        selected: _listingKind == k,
                        onSelected: (_) => setState(() => _listingKind = k),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('Sub-type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PropertySubType.values
                  .map((s) => ChoiceChip(
                        label: Text(s.label),
                        selected: _subType == s,
                        onSelected: (_) => setState(() => _subType = _subType == s ? null : s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('Condition', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PropertyCondition.values
                  .map((c) => ChoiceChip(
                        label: Text(c.label),
                        selected: _condition == c,
                        onSelected: (_) => setState(() => _condition = _condition == c ? null : c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Amenities (${_amenities.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Set<String>>(
                      MaterialPageRoute(
                          builder: (_) => AmenitiesBrowserScreen(initialSelection: _amenities)),
                    );
                    if (result != null) setState(() => _amenities = result);
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.existing == null ? 'Publish listing' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AddPhotoButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
