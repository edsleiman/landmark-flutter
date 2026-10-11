import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_store.dart';
import '../../providers/appointment_store.dart';
import '../../providers/sales_store.dart';
import '../customer/add_edit_listing_screen.dart';
import 'admin_appointments_screen.dart';
import 'sales_ledger_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = context.watch<PropertyStore>();
    final appointments = context.watch<AppointmentStore>();
    final sales = context.watch<SalesStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
        ),
        icon: const Icon(Icons.add_business),
        label: const Text('Add listing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(label: 'Total listings', value: '${properties.properties.length}'),
              _StatCard(label: 'Verified listings', value: '${properties.properties.where((p) => p.verified).length}'),
              _StatCard(label: 'Appointments', value: '${appointments.appointments.length}'),
              _StatCard(label: 'Sales closed', value: '${sales.sales.length}'),
              _StatCard(label: 'Commission owed', value: '\$${sales.totalCommissionOwed.toStringAsFixed(0)}'),
              _StatCard(label: 'Sales volume', value: '\$${sales.totalSalesVolume.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: const Icon(Icons.event_note),
            title: const Text('Track all appointments'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminAppointmentsScreen()),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: const Icon(Icons.receipt_long),
            title: const Text('Sales & commission ledger'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SalesLedgerScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
        ],
      ),
    );
  }
}
