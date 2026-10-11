import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_store.dart';
import '../../providers/property_store.dart';
import '../../providers/auth_store.dart';
import '../../models/viewing.dart';
import 'close_sale_screen.dart';

class NegotiationsScreen extends StatelessWidget {
  const NegotiationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppointmentStore>();
    final properties = context.watch<PropertyStore>();
    final auth = context.watch<AuthStore>();
    final offers = appointments.offersForRealtor(auth.currentUser!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Negotiations')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewOfferSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New offer'),
      ),
      body: offers.isEmpty
          ? const Center(child: Text('No offers yet.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: offers.length,
              itemBuilder: (context, i) {
                final o = offers[i];
                final title = properties.byId(o.propertyID)?.title ?? 'Listing';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Offer: \$${o.amount.toStringAsFixed(0)}'),
                        Text('Status: ${o.status.label}', style: const TextStyle(color: Colors.black54)),
                        if (o.notes.isNotEmpty) Text(o.notes, style: const TextStyle(fontSize: 12.5)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (o.status == OfferStatus.pending || o.status == OfferStatus.countered) ...[
                              OutlinedButton(
                                onPressed: () => appointments.updateOfferStatus(
                                    offerID: o.id, status: OfferStatus.countered),
                                child: const Text('Counter'),
                              ),
                              OutlinedButton(
                                onPressed: () => appointments.updateOfferStatus(
                                    offerID: o.id, status: OfferStatus.declined),
                                child: const Text('Decline'),
                              ),
                              FilledButton(
                                onPressed: () => appointments.updateOfferStatus(
                                    offerID: o.id, status: OfferStatus.accepted),
                                child: const Text('Accept'),
                              ),
                            ],
                            if (o.status == OfferStatus.accepted)
                              FilledButton.tonal(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => CloseSaleScreen(offer: o)),
                                ),
                                child: const Text('Close sale'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showNewOfferSheet(BuildContext context) {
    final properties = context.read<PropertyStore>().properties;
    final auth = context.read<AuthStore>();
    final appointments = context.read<AppointmentStore>();
    String? propertyId = properties.isNotEmpty ? properties.first.id : null;
    final amountCtrl = TextEditingController();
    final buyerIdCtrl = TextEditingController(text: 'u-buyer-1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(builder: (ctx, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Record a new offer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: propertyId,
                decoration: const InputDecoration(labelText: 'Property', border: OutlineInputBorder()),
                items: properties
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.title, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => propertyId = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: buyerIdCtrl,
                decoration: const InputDecoration(labelText: 'Buyer user id', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Offer amount (\$)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (propertyId == null || amountCtrl.text.trim().isEmpty) return;
                  appointments.submitOffer(Offer(
                    id: 'o-${DateTime.now().millisecondsSinceEpoch}',
                    propertyID: propertyId!,
                    realtorID: auth.currentUser!.id,
                    buyerID: buyerIdCtrl.text.trim(),
                    amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ));
                  Navigator.of(ctx).pop();
                },
                child: const Text('Submit offer'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
