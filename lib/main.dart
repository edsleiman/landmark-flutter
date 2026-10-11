import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import 'providers/auth_store.dart';
import 'providers/property_store.dart';
import 'providers/appointment_store.dart';
import 'providers/sales_store.dart';
import 'services/property_service.dart';
import 'services/appointment_service.dart';
import 'services/sales_service.dart';
import 'screens/splash_screen.dart';
import 'screens/customer/verify_viewing_screen.dart';

void main() {
  runApp(const LandmarkApp());
}

class LandmarkApp extends StatefulWidget {
  const LandmarkApp({super.key});

  @override
  State<LandmarkApp> createState() => _LandmarkAppState();
}

class _LandmarkAppState extends State<LandmarkApp> {
  late final AuthStore authStore;
  late final PropertyStore propertyStore;
  late final AppointmentStore appointmentStore;
  late final SalesStore salesStore;

  final _navigatorKey = GlobalKey<NavigatorState>();
  AppLinks? _appLinks;

  @override
  void initState() {
    super.initState();
    authStore = AuthStore();
    propertyStore = PropertyStore(PropertyService());
    appointmentStore = AppointmentStore(AppointmentService());
    salesStore = SalesStore(SalesService());

    authStore.bootstrap();
    propertyStore.load();
    appointmentStore.load();
    salesStore.load();

    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    // landmarkapp://verify?token=... — handles both a cold-start link and
    // one received while the app is already running.
    _appLinks!.uriLinkStream.listen(_handleIncomingLink, onError: (_) {});
    try {
      final initial = await _appLinks!.getInitialLink();
      if (initial != null) _handleIncomingLink(initial);
    } catch (_) {}
  }

  void _handleIncomingLink(Uri uri) {
    if (uri.host != 'verify') return;
    final token = uri.queryParameters['token'];
    if (token == null) return;
    _navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => VerifyViewingScreen(token: token)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authStore),
        ChangeNotifierProvider.value(value: propertyStore),
        ChangeNotifierProvider.value(value: appointmentStore),
        ChangeNotifierProvider.value(value: salesStore),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Landmark',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF0E4C6B),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
