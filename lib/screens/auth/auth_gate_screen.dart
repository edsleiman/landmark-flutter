import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_store.dart';
import '../role_based_root_screen.dart';
import 'login_screen.dart';

/// Decides what the person sees: logged-in root nav, or the login screen.
class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    if (auth.currentUser != null) {
      return const RoleBasedRootScreen();
    }
    return const LoginScreen();
  }
}
