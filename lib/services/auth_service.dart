import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

/// Seeded demo directory + any accounts created at runtime via sign-up.
/// Mirrors the Swift MockUserDirectory: persisted in on-device storage with
/// NO real backend. Passwords are stored in plain text here only because
/// this is a mock/demo persistence layer — never do this in production.
class MockUserDirectory {
  static const _usersKey = 'landmark.mock.addedUsers';
  static const _passwordsKey = 'landmark.mock.addedPasswords';

  static final List<AppUser> _seeded = [
    AppUser(
        id: 'u-buyer-1',
        name: 'Nadine Khalil',
        email: 'buyer@demo.com',
        accountType: AccountType.customer,
        isBuyer: true),
    AppUser(
        id: 'u-seller-1',
        name: 'Rami Abboud',
        email: 'seller@demo.com',
        accountType: AccountType.customer,
        isSeller: true),
    AppUser(
        id: 'u-both-1',
        name: 'Layla Haddad',
        email: 'buyerseller@demo.com',
        accountType: AccountType.customer,
        isBuyer: true,
        isSeller: true),
    AppUser(
        id: 'u-realtor-1',
        name: 'Karim Fares',
        email: 'realtor@demo.com',
        accountType: AccountType.realtor),
    AppUser(
        id: 'u-admin-1',
        name: 'Admin User',
        email: 'admin@demo.com',
        accountType: AccountType.admin),
    AppUser(
        id: 'u-dev-1',
        name: 'Developer',
        email: 'developer@demo.com',
        accountType: AccountType.developer),
  ];

  static const Map<String, String> _seededPasswords = {
    'buyer@demo.com': 'password',
    'seller@demo.com': 'password',
    'buyerseller@demo.com': 'password',
    'realtor@demo.com': 'password',
    'admin@demo.com': 'password',
    'developer@demo.com': 'password',
  };

  static Future<List<AppUser>> _addedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(AppUser.fromJson).toList();
  }

  static Future<Map<String, String>> _addedPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_passwordsKey);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw));
  }

  static Future<List<AppUser>> allUsers() async =>
      [..._seeded, ...await _addedUsers()];

  static Future<void> register(AppUser user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _addedUsers();
    final passwords = await _addedPasswords();
    if ([..._seeded, ...users].any((u) => u.email == user.email)) {
      throw AuthException('An account with this email already exists.');
    }
    users.add(user);
    passwords[user.email] = password;
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
    await prefs.setString(_passwordsKey, jsonEncode(passwords));
  }

  static Future<AppUser> authenticate(String email, String password) async {
    final addedPasswords = await _addedPasswords();
    final allPasswords = {..._seededPasswords, ...addedPasswords};
    final users = await allUsers();
    final match = users.where((u) => u.email == email).toList();
    if (match.isEmpty) throw AuthException('No account found for this email.');
    if (allPasswords[email] != password) {
      throw AuthException('Incorrect password.');
    }
    return match.first;
  }

  static Future<AppUser?> byEmail(String email) async {
    final users = await allUsers();
    final match = users.where((u) => u.email == email).toList();
    return match.isEmpty ? null : match.first;
  }
}

class BiometricAuth {
  static final LocalAuthentication _instance = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final supported = await _instance.isDeviceSupported();
      final canCheck = await _instance.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Prompts Face ID / Touch ID / Android biometric unlock.
  /// Returns true on success, false if the user cancelled.
  /// Throws AuthException on a hard device error.
  static Future<bool> authenticate() async {
    try {
      return await _instance.authenticate(
        localizedReason: 'Log in to Landmark with biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      throw AuthException('Biometric login is not available: $e');
    }
  }
}
