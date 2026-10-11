import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/appointment_store.dart';
import '../../providers/property_store.dart';
import '../../providers/auth_store.dart';
import '../../models/viewing.dart';
import '../../widgets/signature_pad.dart';

class RealtorAppointmentsScreen extends StatelessWidget {
  const RealtorAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppointmentStore>();
    final properties = context.watch<PropertyStore>();
    final auth = context.watch<AuthStore>();
    final realtorId = auth.currentUser!.id;

    final unassigned = appointments.unassignedRequests;
    final mine = appointments.viewingsForRealtor(realtorId);

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (unassigned.isNotEmpty) ...[
            const Text('Unassigned requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            ...unassigned.map((a) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(properties.byId(a.propertyID)?.title ?? 'Listing'),
                    subtitle: Text('Requested for ${_fmt(a.scheduledAt ?? a.requestedAt)}'),
                    trailing: FilledButton(
                      onPressed: () => appointments.assign(
                        appointmentID: a.id,
                        realtorID: realtorId,
                        scheduledAt: a.scheduledAt ?? DateTime.now().add(const Duration(days: 1)),
                      ),
                      child: const Text('Take'),
                    ),
                  ),
                )),
            const Divider(height: 28),
          ],
          const Text('My appointments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          if (mine.isEmpty) const Text('No appointments assigned to you yet.'),
          ...mine.map((a) => _AppointmentTile(appointment: a, propertyTitle: properties.byId(a.propertyID)?.title ?? 'Listing')),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _AppointmentTile extends StatelessWidget {
  final ViewingAppointment appointment;
  final String propertyTitle;
  const _AppointmentTile({required this.appointment, required this.propertyTitle});

  Future<void> _showSignatureSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SignaturePad(
          onSigned: (base64) async {
            await ctx.read<AppointmentStore>().verifyWithSignature(
                  appointmentID: appointment.id,
                  signaturePNGBase64: base64,
                );
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }

  Future<void> _sendLink(BuildContext context) async {
    final uri = await context.read<AppointmentStore>().sendVerificationLink(appointment.id);
    if (uri != null) {
      await Share.share('Please confirm you viewed the unit: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canVerify = appointment.status == ViewingStatus.assigned;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(propertyTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Status: ${appointment.status.label}', style: const TextStyle(color: Colors.black54)),
            if (canVerify) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showSignatureSheet(context),
                      child: const Text('Sign on this screen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _sendLink(context),
                      child: const Text('Send verify link'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
