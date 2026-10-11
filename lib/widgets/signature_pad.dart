import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

/// A signature pad used when a buyer signs on the realtor's screen to
/// confirm they viewed a unit. Returns the signature as a base64 PNG string,
/// matching the Swift app's `signaturePNGBase64` field.
class SignaturePad extends StatefulWidget {
  final void Function(String base64Png) onSigned;
  const SignaturePad({super.key, required this.onSigned});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.isEmpty) return;
    final bytes = await _controller.toPngBytes();
    if (bytes == null) return;
    widget.onSigned(base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Please sign below to confirm you viewed this unit',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          height: 220,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Signature(controller: _controller, backgroundColor: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _controller.clear(),
                child: const Text('Clear'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _save,
                child: const Text('Confirm signature'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
