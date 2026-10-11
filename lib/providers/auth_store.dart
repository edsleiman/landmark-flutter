import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthStore extends ChangeNotifier {
  static const _savedEmailKey = 'landmark.savedLoginEmail';

  AppUser? currentUser;
  String? errorMessage;
  bool isLoading = false;
  bool biometricAvailable = false;

  Future<void> bootstrap() async {
    biometricAvailable = await BiometricAuth.isAvailable();
    notifyListeners();
  }

  Future<String?> savedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_savedEmailKey);
  }

  Future<void> login(String email, String password, {bool remember = true}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final user = await MockUserDirectory.authenticate(email, password);
      currentUser = user;
      if (remember) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_savedEmailKey, email);
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  /// Face ID / Touch ID / Android biometric login for a previously-saved email.
  Future<void> loginWithBiometrics() async {
    final email = await savedEmail();
    if (email == null) {
      errorMessage = 'Log in with your password once first, then biometric login will be available.';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final ok = await BiometricAuth.authenticate();
      if (!ok) {
        errorMessage = null; // user cancelled; not an error worth showing
        isLoading = false;
        notifyListeners();
        return;
      }
      final user = await MockUserDirectory.byEmail(email);
      if (user == null) {
        errorMessage = 'Saved account no longer exists. Please log in with your password.';
      } else {
        currentUser = user;
      }
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required bool isBuyer,
    required bool isSeller,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final user = AppUser(
        id: 'u-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        accountType: AccountType.customer,
        isBuyer: isBuyer,
        isSeller: isSeller,
      );
      await MockUserDirectory.register(user, password);
      currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedEmailKey, email);
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}
