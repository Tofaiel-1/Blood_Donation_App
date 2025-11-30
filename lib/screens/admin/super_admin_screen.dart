import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../utils/app_colors.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/admin_management_tab.dart';
import 'tabs/blood_requests_tab.dart';
import 'tabs/users_management_tab.dart';
import 'tabs/donations_tab.dart';
import 'tabs/settings_tab.dart';
import 'inventory_screen.dart';

/// Super Admin Screen - Main Control Panel
/// Organized into separate tabs for each functionality
/// All code is modular and easy to present/modify
class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_AdminManagementTabWrapperState> _adminTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 28),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Super Admin Control Panel',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Complete System Access',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.bloodRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // Current user info
          StreamBuilder<fb_auth.User?>(
            stream: fb_auth.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Center(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          user?.email?.substring(0, 1).toUpperCase() ?? 'S',
                          style: TextStyle(
                            color: AppColors.bloodRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.email?.split('@').first ?? 'Admin',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Super Admin',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admins'),
            Tab(icon: Icon(Icons.bloodtype), text: 'Requests'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.favorite), text: 'Donations'),
            Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Dashboard Tab - Shows statistics, quick actions, recent activity
          DashboardTab(
            tabController: _tabController,
            onAddAdmin: () => _adminTabKey.currentState?.showAddAdminDialog(),
          ),

          // Admin Management Tab - Add, edit, delete, activate/deactivate admins
          _AdminManagementTabWrapper(key: _adminTabKey),

          // Blood Requests Tab - Approve, reject, fulfill requests
          const BloodRequestsTab(),

          // Users Management Tab - View, search, filter, manage users
          const UsersManagementTab(),

          // Donations Tab - Track blood donations
          const DonationsTab(),

          // Inventory Tab - Manage blood stock
          const InventoryScreen(),

          // Settings Tab - System configuration
          const SettingsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _adminTabKey.currentState?.showAddAdminDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Admin'),
              backgroundColor: AppColors.bloodRed,
            )
          : null,
    );
  }

  /// Handle Logout with Bengali confirmation
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('লগ আউট নিশ্চিত করুন'),
        content: const Text('আপনি কি নিশ্চিতভাবে লগ আউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('না'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
            ),
            child: const Text('হ্যাঁ, লগ আউট করুন'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await fb_auth.FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }
}

/// Wrapper for AdminManagementTab to expose showAddAdminDialog
class _AdminManagementTabWrapper extends StatefulWidget {
  const _AdminManagementTabWrapper({super.key});

  @override
  State<_AdminManagementTabWrapper> createState() =>
      _AdminManagementTabWrapperState();
}

class _AdminManagementTabWrapperState
    extends State<_AdminManagementTabWrapper> {
  final GlobalKey<AdminManagementTabState> _adminTabKey = GlobalKey();

  void showAddAdminDialog() {
    _adminTabKey.currentState?.showAddAdminDialog();
  }

  @override
  Widget build(BuildContext context) {
    return AdminManagementTab(key: _adminTabKey);
  }
}
