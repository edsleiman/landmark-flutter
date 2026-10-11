import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/property_store.dart';

class ContactScreen extends StatefulWidget {
  final String? propertyId;
  const ContactScreen({super.key, this.propertyId});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final store = context.read<PropertyStore>();
    await store.service.sendInquiry(
      propertyID: widget.propertyId ?? '',
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
    );
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _sent
              ? const Center(child: Text("Thank you! We'll be in touch shortly."))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _sending ? null : _send,
                      child: _sending
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Send inquiry'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
