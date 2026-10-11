import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_store.dart';

/// Shown when the buyer taps the landmarkapp://verify?token=... link sent
/// by their realtor, confirming (with a record kept) that they viewed the unit.
class VerifyViewingScreen extends StatefulWidget {
  final String token;
  const VerifyViewingScreen({super.key, required this.token});

  @override
  State<VerifyViewingScreen> createState() => _VerifyViewingScreenState();
}

class _VerifyViewingScreenState extends State<VerifyViewingScreen> {
  bool _loading = true;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    final appointments = context.read<AppointmentStore>();
    final result = await appointments.verify(widget.token);
    setState(() {
      _loading = false;
      _success = result != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viewing Verification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_success ? Icons.check_circle : Icons.error,
                        size: 64, color: _success ? Colors.green : Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _success
                          ? 'Thank you! Your viewing has been verified and recorded.'
                          : 'This verification link is invalid or has expired.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
