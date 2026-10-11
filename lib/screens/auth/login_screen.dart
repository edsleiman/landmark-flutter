import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_store.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _savedEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthStore>();
      final saved = await auth.savedEmail();
      if (saved != null) {
        setState(() {
          _savedEmail = saved;
          _emailCtrl.text = saved;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text('Welcome back',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Log in to Landmark', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 32),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(auth.errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: auth.isLoading
                    ? null
                    : () => auth.login(_emailCtrl.text.trim(), _passwordCtrl.text),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Log In'),
              ),
              if (auth.biometricAvailable && _savedEmail != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: auth.isLoading ? null : () => auth.loginWithBiometrics(),
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Log in with Face ID / biometrics'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ],
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  ),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ),
              const SizedBox(height: 24),
              const _DemoAccountsHint(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoAccountsHint extends StatelessWidget {
  const _DemoAccountsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Demo accounts (password: "password"):\n'
        '• buyer@demo.com — Buyer\n'
        '• seller@demo.com — Seller\n'
        '• buyerseller@demo.com — Buyer & Seller\n'
        '• realtor@demo.com — Realtor\n'
        '• admin@demo.com — Admin\n'
        '• developer@demo.com — Developer',
        style: TextStyle(fontSize: 12.5, color: Colors.black54),
      ),
    );
  }
}
