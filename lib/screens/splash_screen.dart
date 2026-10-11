import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/auth_gate_screen.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGateScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [LandmarkColors.navyDeep, LandmarkColors.navy, LandmarkColors.teal],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Falls back to a simple mark if assets/images/landmark_logo.png
                // hasn't been added yet — see README for where to drop the logo.
                Image.asset(
                  'assets/images/landmark_logo.png',
                  width: 140,
                  height: 140,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: LandmarkColors.goldLight, width: 2),
                    ),
                    child: const Icon(Icons.location_city, size: 52, color: LandmarkColors.goldLight),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'LANDMARK',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your new beginning starts here',
                  style: GoogleFonts.plusJakartaSans(color: LandmarkColors.goldLight, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
