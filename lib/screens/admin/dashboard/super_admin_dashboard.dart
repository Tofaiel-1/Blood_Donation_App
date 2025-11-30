import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/admin_service.dart';
import '../../../../services/auth_service.dart';
import 'widgets/stat_card.dart';
import 'widgets/control_panel_card.dart';
import 'widgets/activity_log_list.dart';
import 'widgets/analytics_chart.dart';
import 'widgets/create_admin_dialog.dart';
import 'widgets/create_user_dialog.dart';
import 'widgets/donors_list_dialog.dart';
import 'widgets/donations_list_dialog.dart';
import 'widgets/pending_requests_dialog.dart';
import 'widgets/activity_logs_dialog.dart';
import 'widgets/admins_list_dialog.dart';
import 'widgets/manage_orgs_dialog.dart';
import 'widgets/app_settings_dialog.dart';
import 'widgets/permissions_dialog.dart';
import 'widgets/broadcast_alert_dialog.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _stats = {
    'totalAdmins': 0,
    'activeAdmins': 0,
    'totalUsers': 0,
    'totalRequests': 0,
    'pendingRequests': 0,
    'fulfilledRequests': 0,
  };
  Map<String, int> _bloodTypeDistribution = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final stats = await _adminService.getSystemStats();
      final bloodDist = await _adminService.getBloodTypeDistribution();

      // Get donation count separately as it's not in getSystemStats
      final donationsSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .count()
          .get();
      final donationCount = donationsSnapshot.count ?? 0;

      // Get organization count (distinct organizations)
      // This is an approximation by counting admins with organizations
      // For a more accurate count, we would need a separate organizations collection
      // or a more complex query. For now, let's use the number of admins as a proxy or
      // just count unique organization names from users if possible, but that's heavy.
      // Let's assume 1 admin = 1 org for now or just use a placeholder if not critical.
      // Actually, let's try to get unique organizations from the users collection where role is orgAdmin
      final adminsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'orgAdmin')
          .get();

      final organizations = adminsSnapshot.docs
          .map((doc) => doc.data()['organization'] as String?)
          .where((org) => org != null && org.isNotEmpty)
          .toSet()
          .length;

      if (mounted) {
        setState(() {
          _stats = stats;
          _stats['totalDonations'] = donationCount;
          _stats['totalOrgs'] = organizations;
          _bloodTypeDistribution = bloodDist;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bloodtype, color: Colors.red, size: 20),
            const SizedBox(width: 6),
            const Flexible(
              child: Text(
                'Super Admin Dashboard',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.campaign),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BroadcastAlertDialog(),
              );
            },
            tooltip: 'Broadcast Alert',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'Profile':
                  _showProfileDialog(context);
                  break;
                case 'Settings':
                  showDialog(
                    context: context,
                    builder: (context) => const AppSettingsDialog(),
                  );
                  break;
                case 'Logout':
                  _showLogoutConfirmation(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, size: 20),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text('SA', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return _buildDesktopLayout(context);
                } else {
                  return _buildMobileLayout(context);
                }
              },
            ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text(
                'Super Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Already on dashboard, just refresh
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admins'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showDialog(
                  context: context,
                  builder: (context) => const AdminsListDialog(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Organizations'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showDialog(
                  context: context,
                  builder: (context) => const ManageOrgsDialog(),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                showDialog(
                  context: context,
                  builder: (context) => const AppSettingsDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsGrid(context, crossAxisCount: 2),
          const SizedBox(height: 24),
          Text(
            'Control Panel',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildControlPanelGrid(context, crossAxisCount: 2),
          const SizedBox(height: 24),
          const DonationTrendsChart(),
          const SizedBox(height: 16),
          BloodGroupDemandChart(data: _bloodTypeDistribution),
          const SizedBox(height: 24),
          _buildActivityLogs(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NavigationRail(
          selectedIndex: 0,
          onDestinationSelected: (int index) {
            switch (index) {
              case 0:
                // Dashboard - refresh data
                _loadData();
                break;
              case 1:
                // Admins
                showDialog(
                  context: context,
                  builder: (context) => const AdminsListDialog(),
                );
                break;
              case 2:
                // Organizations
                showDialog(
                  context: context,
                  builder: (context) => const ManageOrgsDialog(),
                );
                break;
              case 3:
                // Settings
                showDialog(
                  context: context,
                  builder: (context) => const AppSettingsDialog(),
                );
                break;
            }
          },
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.admin_panel_settings),
              label: Text('Admins'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.business),
              label: Text('Orgs'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(context, crossAxisCount: 4),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Control Panel',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          _buildControlPanelGrid(context, crossAxisCount: 3),
                          const SizedBox(height: 24),
                          const DonationTrendsChart(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 280),
                        child: Column(
                          children: [
                            BloodGroupDemandChart(data: _bloodTypeDistribution),
                            const SizedBox(height: 24),
                            _buildActivityLogs(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, {required int crossAxisCount}) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Total Admins',
          value: _stats['totalAdmins'].toString(),
          icon: Icons.admin_panel_settings,
          color: Colors.blue,
          onTap: () => _showAdminsList(context),
        ),
        StatCard(
          title: 'Organizations',
          value: (_stats['totalOrgs'] ?? 0).toString(),
          icon: Icons.business,
          color: Colors.orange,
          onTap: () => _showOrganizations(context),
        ),
        StatCard(
          title: 'Total Donors',
          value: _stats['totalUsers'].toString(),
          icon: Icons.people,
          color: Colors.green,
          onTap: () => _showDonorsList(context),
        ),
        StatCard(
          title: 'Donations',
          value: (_stats['totalDonations'] ?? 0).toString(),
          icon: Icons.bloodtype,
          color: Colors.red,
          onTap: () => _showDonationsList(context),
        ),
        StatCard(
          title: 'Pending',
          value: _stats['pendingRequests'].toString(),
          icon: Icons.pending_actions,
          color: Colors.amber,
          onTap: () => _showPendingRequests(context),
        ),
        StatCard(
          title: 'Logs',
          value: '45', // Placeholder for now, or fetch logs count
          icon: Icons.history,
          color: Colors.grey,
          onTap: () => _showActivityLogs(context),
        ),
      ],
    );
  }

  void _showAdminsList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AdminsListDialog(),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.red),
            SizedBox(width: 8),
            Text('Super Admin Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red,
                child: Text(
                  'SA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileRow(
              Icons.person,
              'Name',
              user?.displayName ?? 'Super Admin',
            ),
            const SizedBox(height: 12),
            _buildProfileRow(Icons.email, 'Email', user?.email ?? 'N/A'),
            const SizedBox(height: 12),
            _buildProfileRow(Icons.security, 'Role', 'Super Administrator'),
            const SizedBox(height: 12),
            _buildProfileRow(Icons.verified_user, 'Status', 'Active'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => _performLogout(dialogContext),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext dialogContext) async {
    // Close dialog first
    Navigator.of(dialogContext).pop();

    // Show loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      await AuthService().signOut();

      if (mounted) {
        // Close loading dialog and navigate
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  void _showDonorsList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DonorsListDialog(),
    );
  }

  void _showOrganizations(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ManageOrgsDialog(),
    );
  }

  void _showDonationsList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DonationsListDialog(),
    );
  }

  void _showPendingRequests(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PendingRequestsDialog(),
    );
  }

  void _showActivityLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ActivityLogsDialog(),
    );
  }

  Widget _buildControlPanelGrid(
    BuildContext context, {
    required int crossAxisCount,
  }) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        ControlPanelCard(
          title: 'Broadcast Alert',
          icon: Icons.campaign,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const BroadcastAlertDialog(),
            );
          },
        ),
        ControlPanelCard(
          title: 'Create Admin',
          icon: Icons.person_add,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const CreateAdminDialog(),
            );
          },
        ),
        ControlPanelCard(
          title: 'Create User',
          icon: Icons.group_add,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const CreateUserDialog(),
            );
          },
        ),
        ControlPanelCard(
          title: 'Manage Orgs',
          icon: Icons.business_center,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ManageOrgsDialog(),
            );
          },
        ),
        ControlPanelCard(
          title: 'App Settings',
          icon: Icons.settings_applications,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AppSettingsDialog(),
            );
          },
        ),
        ControlPanelCard(
          title: 'Permissions',
          icon: Icons.security,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const PermissionsDialog(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityLogs() {
    return ActivityLogList(
      logs: const [
        {
          'action': 'New Admin Created',
          'description': 'User "Rahim Ahmed" added as Organization Admin',
          'time': '2 mins ago',
          'user': 'SuperAdmin',
          'status': 'Success',
        },
        {
          'action': 'Org Approved',
          'description': 'Red Crescent Society approved for blood collection',
          'time': '1 hour ago',
          'user': 'SuperAdmin',
          'status': 'Completed',
        },
        {
          'action': 'Blood Donation Recorded',
          'description': 'A+ blood (2 units) donated at Dhaka Medical',
          'time': '2 hours ago',
          'user': 'System',
          'status': 'Success',
        },
        {
          'action': 'Settings Updated',
          'description': 'Notification preferences changed',
          'time': '3 hours ago',
          'user': 'System',
        },
        {
          'action': 'Backup Completed',
          'description': 'Daily database backup successful',
          'time': '5 hours ago',
          'user': 'System',
          'status': 'Success',
        },
      ],
    );
  }
}
