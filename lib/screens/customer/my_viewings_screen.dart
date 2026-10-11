import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_store.dart';
import '../../providers/property_store.dart';
import '../../providers/auth_store.dart';
import '../../models/viewing.dart';

class MyViewingsScreen extends StatelessWidget {
  const MyViewingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppointmentStore>();
    final properties = context.watch<PropertyStore>();
    final auth = context.watch<AuthStore>();
    final mine = appointments.viewingsForBuyer(auth.currentUser!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('My Viewings')),
      body: mine.isEmpty
          ? const Center(child: Text('You have no viewing requests yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mine.length,
              itemBuilder: (context, i) {
                final a = mine[i];
                final property = properties.byId(a.propertyID);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(property?.title ?? 'Listing'),
                    subtitle: Text(
                      'Requested ${_fmt(a.requestedAt)}'
                      '${a.scheduledAt != null ? "\nScheduled ${_fmt(a.scheduledAt!)}" : ""}',
                    ),
                    trailing: _StatusChip(status: a.status),
                    isThreeLine: a.scheduledAt != null,
                  ),
                );
              },
            ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _StatusChip extends StatelessWidget {
  final ViewingStatus status;
  const _StatusChip({required this.status});

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
    return Chip(
      label: Text(status.label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
