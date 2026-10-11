import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_store.dart';
import 'listings_screen.dart';
import 'shared/favorites_screen.dart';
import 'shared/contact_screen.dart';
import 'shared/profile_screen.dart';
import 'customer/my_listings_screen.dart';
import 'customer/my_viewings_screen.dart';
import 'realtor/realtor_appointments_screen.dart';
import 'realtor/negotiations_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'admin/sales_ledger_screen.dart';

/// Switches between the four persona tab-bar layouts, matching the Swift
/// app's RoleBasedRootView/CustomerTabView/RealtorTabView/AdminTabView/
/// DeveloperTabView split.
class RoleBasedRootScreen extends StatelessWidget {
  const RoleBasedRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthStore>().currentUser!;
    switch (user.accountType) {
      case AccountType.customer:
        return const _CustomerTabView();
      case AccountType.realtor:
        return const _RealtorTabView();
      case AccountType.admin:
        return const _AdminTabView();
      case AccountType.developer:
        return const _DeveloperTabView();
    }
  }
}

class _CustomerTabView extends StatefulWidget {
  const _CustomerTabView();
  @override
  State<_CustomerTabView> createState() => _CustomerTabViewState();
}

class _CustomerTabViewState extends State<_CustomerTabView> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthStore>().currentUser!;
    final pages = [
      const ListingsScreen(),
      const FavoritesScreen(),
      const MyViewingsScreen(),
      if (user.isSeller) const MyListingsScreen(),
      const ProfileScreen(),
    ];
    final items = [
      const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
      const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Saved'),
      const BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Viewings'),
      if (user.isSeller) const BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Listings'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}

class _RealtorTabView extends StatefulWidget {
  const _RealtorTabView();
  @override
  State<_RealtorTabView> createState() => _RealtorTabViewState();
}

class _RealtorTabViewState extends State<_RealtorTabView> {
  int _index = 0;
  static const _pages = [
    ListingsScreen(),
    RealtorAppointmentsScreen(),
    NegotiationsScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Listings'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake), label: 'Negotiations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _AdminTabView extends StatefulWidget {
  const _AdminTabView();
  @override
  State<_AdminTabView> createState() => _AdminTabViewState();
}

class _AdminTabViewState extends State<_AdminTabView> {
  int _index = 0;
  static const _pages = [
    AdminDashboardScreen(),
    ListingsScreen(),
    ContactScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Listings'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Inquiries'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/// The developer persona (you) gets the dashboard plus the commission-rate
/// editable ledger, since only the developer can change the standard rate.
class _DeveloperTabView extends StatefulWidget {
  const _DeveloperTabView();
  @override
  State<_DeveloperTabView> createState() => _DeveloperTabViewState();
}

class _DeveloperTabViewState extends State<_DeveloperTabView> {
  int _index = 0;
  static const _pages = [
    SalesLedgerScreen(canEditRate: true),
    AdminDashboardScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ledger'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
