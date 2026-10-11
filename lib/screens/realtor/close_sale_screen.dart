import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/viewing.dart';
import '../../providers/property_store.dart';
import '../../providers/sales_store.dart';
import '../../providers/auth_store.dart';
import '../../services/auth_service.dart';

/// Realtor closes a sale: commits buyer/seller to a final number and
/// records it in the permanent commission ledger (1% to the developer by
/// default, captured at the rate in effect when the sale closes).
class CloseSaleScreen extends StatefulWidget {
  final Offer offer;
  const CloseSaleScreen({super.key, required this.offer});

  @override
  State<CloseSaleScreen> createState() => _CloseSaleScreenState();
}

class _CloseSaleScreenState extends State<CloseSaleScreen> {
  late final TextEditingController _priceCtrl;
  bool _saving = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(text: widget.offer.amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    setState(() => _saving = true);
    final properties = context.read<PropertyStore>();
    final sales = context.read<SalesStore>();
    final auth = context.read<AuthStore>();
    final property = properties.byId(widget.offer.propertyID);

    final allUsers = await MockUserDirectory.allUsers();
    final buyerMatch = allUsers.where((u) => u.id == widget.offer.buyerID).toList();
    final buyerName = buyerMatch.isNotEmpty ? buyerMatch.first.name : 'Buyer';

    final sellerId = widget.offer.sellerID ?? property?.ownerUserId ?? 'unknown-seller';
    final sellerMatch = allUsers.where((u) => u.id == sellerId).toList();
    final sellerName = sellerMatch.isNotEmpty ? sellerMatch.first.name : 'Seller';

    await sales.recordSale(
      propertyID: widget.offer.propertyID,
      propertyTitle: property?.title ?? 'Listing',
      sellerID: sellerId,
      sellerName: sellerName,
      buyerID: widget.offer.buyerID,
      buyerName: buyerName,
      realtorID: auth.currentUser!.id,
      realtorName: auth.currentUser!.name,
      purchasePrice: double.tryParse(_priceCtrl.text.trim()) ?? widget.offer.amount,
    );

    setState(() {
      _saving = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SalesStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Close Sale')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _done
              ? const Center(
                  child: Text('Sale recorded in the ledger. Commission has been tracked.',
                      textAlign: TextAlign.center),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Final agreed price', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(prefixText: '\$ ', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Text('Developer commission rate: ${(sales.commissionRate * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _close,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _saving
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Commit & record sale'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
