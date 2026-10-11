import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_store.dart';
import '../../providers/property_store.dart';
import '../../models/viewing.dart';

/// Lets the admin track every viewing appointment across every realtor —
/// the full audit trail of requested → assigned → completed/verified.
class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppointmentStore>();
    final properties = context.watch<PropertyStore>();
    final all = appointments.allAppointmentsSorted;

    return Scaffold(
      appBar: AppBar(title: const Text('All Appointments')),
      body: all.isEmpty
          ? const Center(child: Text('No appointments yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: all.length,
              itemBuilder: (context, i) {
                final a = all[i];
                final title = properties.byId(a.propertyID)?.title ?? 'Listing';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                            _StatusBadge(status: a.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Buyer: ${a.buyerID}   •   Realtor: ${a.realtorID ?? "unassigned"}',
                            style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                        Text('Requested: ${a.requestedAt.toString().split(" ").first}'
                            '${a.scheduledAt != null ? " • Scheduled: ${a.scheduledAt.toString().split(" ").first}" : ""}',
                            style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                        if (a.verificationMethod != null)
                          Text(
                            'Verified via ${a.verificationMethod == VerificationMethod.signature ? "signature" : "link"}'
                            '${a.verifiedAt != null ? " on ${a.verifiedAt.toString().split(" ").first}" : ""}',
                            style: const TextStyle(fontSize: 12.5, color: Colors.green),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ViewingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ViewingStatus.verified:
        color = Colors.green;
        break;
      case ViewingStatus.completed:
        color = Colors.blue;
        break;
      case ViewingStatus.cancelled:
        color = Colors.red;
        break;
      case ViewingStatus.assigned:
        color = Colors.orange;
        break;
      case ViewingStatus.requested:
        color = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(status.label, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }
}
