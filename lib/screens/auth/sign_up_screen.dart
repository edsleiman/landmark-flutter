import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_store.dart';

/// Sign-up is customer-only: buyer, seller, or both. Realtor/admin/developer
/// accounts are provisioned separately (seeded demo accounts here), matching
/// the original requirement that only customers self-register.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isBuyer = true;
  bool _isSeller = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              const Text('I am a:', style: TextStyle(fontWeight: FontWeight.w600)),
              CheckboxListTile(
                value: _isBuyer,
                onChanged: (v) => setState(() => _isBuyer = v ?? false),
                title: const Text('Buyer'),
                subtitle: const Text('Browse listings and request viewings'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                value: _isSeller,
                onChanged: (v) => setState(() => _isSeller = v ?? false),
                title: const Text('Seller'),
                subtitle: const Text('Add and manage your own listings'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: auth.isLoading || (!_isBuyer && !_isSeller)
                    ? null
                    : () => auth.register(
                          name: _nameCtrl.text.trim(),
                          email: _emailCtrl.text.trim(),
                          password: _passwordCtrl.text,
                          isBuyer: _isBuyer,
                          isSeller: _isSeller,
                        ),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create account'),
              ),
              if (!_isBuyer && !_isSeller)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Select buyer, seller, or both to continue.',
                      style: TextStyle(color: Colors.black54, fontSize: 12.5)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
