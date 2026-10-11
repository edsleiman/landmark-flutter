import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_store.dart';
import '../../models/sale.dart';

class SalesLedgerScreen extends StatelessWidget {
  /// Only the developer role can edit the standard commission rate.
  final bool canEditRate;
  const SalesLedgerScreen({super.key, this.canEditRate = false});

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SalesStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Ledger')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatBlock(
                            label: 'Total sales volume', value: '\$${sales.totalSalesVolume.toStringAsFixed(0)}'),
                      ),
                      Expanded(
                        child: _StatBlock(
                            label: 'Commission earned',
                            value: '\$${sales.totalCommissionOwed.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (canEditRate) CommissionRateEditor(rate: sales.commissionRate),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Sale history', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          if (sales.sales.isEmpty) const Text('No sales recorded yet.'),
          ...sales.sales.map((s) => _SaleRow(sale: s)),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SaleRow extends StatelessWidget {
  final Sale sale;
  const _SaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sale.propertyTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Seller: ${sale.sellerName}   •   Buyer: ${sale.buyerName}'),
            Text('Realtor: ${sale.realtorName}'),
            Text(
                'Price: \$${sale.purchasePrice.toStringAsFixed(0)}   •   Commission (${(sale.developerCommissionRate * 100).toStringAsFixed(2)}%): '
                '\$${sale.developerCommissionAmount.toStringAsFixed(2)}'),
            Text('Date: ${sale.dateOfSale.toString().split(" ").first}',
                style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}

/// Developer-only control for changing the standard commission rate.
/// Past sales keep whatever rate was in effect when they closed.
class CommissionRateEditor extends StatefulWidget {
  final double rate;
  const CommissionRateEditor({super.key, required this.rate});

  @override
  State<CommissionRateEditor> createState() => _CommissionRateEditorState();
}

class _CommissionRateEditorState extends State<CommissionRateEditor> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: (widget.rate * 100).toStringAsFixed(2));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Commission rate (%)', border: OutlineInputBorder()),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: () {
            final pct = double.tryParse(_ctrl.text.trim());
            if (pct == null) return;
            context.read<SalesStore>().setCommissionRate(pct / 100);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Commission rate updated for future sales.')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
