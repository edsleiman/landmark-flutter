import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final user = auth.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(user.name.isNotEmpty ? user.name[0] : '?',
                style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 16),
          Center(
              child:
                  Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Center(child: Text(user.email, style: const TextStyle(color: Colors.black54))),
          const SizedBox(height: 6),
          Center(
            child: Chip(label: Text(user.roleLabel)),
          ),
          const SizedBox(height: 32),
          FilledButton.tonal(
            onPressed: () => auth.logout(),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}
