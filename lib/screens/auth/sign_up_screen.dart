import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_store.dart';
import '../../theme.dart';

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
  bool _obscure = true;

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
      backgroundColor: LandmarkColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create your account', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 26)),
                    const SizedBox(height: 6),
                    const Text('Join Landmark to browse, save and list properties',
                        style: TextStyle(color: LandmarkColors.inkMuted, fontSize: 14)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline, size: 20)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline, size: 20)),
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
                    const SizedBox(height: 24),
                    Text('I am a', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _RoleTile(
                      title: 'Buyer',
                      subtitle: 'Browse listings and request viewings',
                      icon: Icons.search,
                      selected: _isBuyer,
                      onTap: () => setState(() => _isBuyer = !_isBuyer),
                    ),
                    const SizedBox(height: 10),
                    _RoleTile(
                      title: 'Seller',
                      subtitle: 'Add and manage your own listings',
                      icon: Icons.sell_outlined,
                      selected: _isSeller,
                      onTap: () => setState(() => _isSeller = !_isSeller),
                    ),
                    if (!_isBuyer && !_isSeller)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text('Select buyer, seller, or both to continue.',
                            style: TextStyle(color: LandmarkColors.inkMuted, fontSize: 12.5)),
                      ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: LandmarkColors.danger),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(auth.errorMessage!, style: const TextStyle(color: LandmarkColors.danger, fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
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
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create account'),
                    ),
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

class _RoleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? LandmarkColors.navy.withOpacity(0.06) : LandmarkColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? LandmarkColors.navy : LandmarkColors.navy.withOpacity(0.1), width: selected ? 1.4 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? LandmarkColors.navy : LandmarkColors.navy.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: selected ? Colors.white : LandmarkColors.navy),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(subtitle, style: const TextStyle(fontSize: 12.5, color: LandmarkColors.inkMuted)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? LandmarkColors.navy : LandmarkColors.inkMuted.withOpacity(0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
