import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_store.dart';
import '../../providers/auth_store.dart';

class RequestViewingScreen extends StatefulWidget {
  final String propertyId;
  const RequestViewingScreen({super.key, required this.propertyId});

  @override
  State<RequestViewingScreen> createState() => _RequestViewingScreenState();
}

class _RequestViewingScreenState extends State<RequestViewingScreen> {
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 2));
  final _notesCtrl = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_preferredDate));
    setState(() {
      _preferredDate = DateTime(date.year, date.month, date.day, time?.hour ?? 10, time?.minute ?? 0);
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final appointments = context.read<AppointmentStore>();
    final auth = context.read<AuthStore>();
    await appointments.requestViewing(
      propertyID: widget.propertyId,
      buyerID: auth.currentUser!.id,
      preferredDate: _preferredDate,
      notes: _notesCtrl.text.trim(),
    );
    setState(() {
      _submitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request a Viewing')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _submitted
              ? const Center(
                  child: Text(
                    'Your viewing request has been recorded. A realtor will reach out to confirm.',
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Preferred date & time', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(
                        '${_preferredDate.year}-${_preferredDate.month.toString().padLeft(2, '0')}-${_preferredDate.day.toString().padLeft(2, '0')} '
                        '${_preferredDate.hour.toString().padLeft(2, '0')}:${_preferredDate.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Notes for the realtor (optional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _submitting
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Request viewing'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'This creates a tracked record. After the viewing, you will either sign on the '
                      "realtor's screen or receive a link to verify that you viewed the unit — the admin "
                      'can track the full history of every appointment.',
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
