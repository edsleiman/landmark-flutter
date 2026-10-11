import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_store.dart';
import '../../theme.dart';
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
      backgroundColor: LandmarkColors.navyDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branded header — matches the splash screen's gradient so the
              // transition into the login screen feels like one piece, not
              // a hand-off from a styled screen to a plain form.
              Container(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [LandmarkColors.navyDeep, LandmarkColors.navy, LandmarkColors.teal],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: LandmarkColors.goldLight, width: 1.6),
                      ),
                      child: const Icon(Icons.location_city, color: LandmarkColors.goldLight, size: 26),
                    ),
                    const SizedBox(height: 20),
                    Text('Welcome back',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: Colors.white, fontSize: 28)),
                    const SizedBox(height: 6),
                    Text('Log in to pick up where you left off',
                        style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 14.5)),
                  ],
                ),
              ),

              // Form card overlaps the header slightly for a layered, less
              // flat composition.
              Transform.translate(
                offset: const Offset(0, -22),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: LandmarkColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail_outline, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.error_outline, size: 16, color: LandmarkColors.danger),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(auth.errorMessage!,
                                  style: const TextStyle(color: LandmarkColors.danger, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: auth.isLoading
                            ? null
                            : () => auth.login(_emailCtrl.text.trim(), _passwordCtrl.text),
                        child: auth.isLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Log In'),
                      ),
                      if (auth.biometricAvailable && _savedEmail != null) ...[
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: auth.isLoading ? null : () => auth.loginWithBiometrics(),
                          icon: const Icon(Icons.fingerprint, size: 20),
                          label: const Text('Log in with Face ID / biometrics'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                      child: const Text("Don't have an account? Sign up"),
                    ),
                    const SizedBox(height: 12),
                    const _DemoAccountsHint(),
                  ],
                ),
              ),
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
    const rows = [
      ('buyer@demo.com', 'Buyer'),
      ('seller@demo.com', 'Seller'),
      ('buyerseller@demo.com', 'Buyer & Seller'),
      ('realtor@demo.com', 'Realtor'),
      ('admin@demo.com', 'Admin'),
      ('developer@demo.com', 'Developer'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LandmarkColors.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LandmarkColors.gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 15, color: LandmarkColors.gold),
              const SizedBox(width: 6),
              Text('Demo accounts', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13.5)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Password: "password" for all', style: TextStyle(fontSize: 12, color: LandmarkColors.inkMuted)),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(r.$1,
                            style: const TextStyle(fontSize: 12.5, color: LandmarkColors.ink, fontWeight: FontWeight.w500))),
                    Text(r.$2, style: const TextStyle(fontSize: 12.5, color: LandmarkColors.inkMuted)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
