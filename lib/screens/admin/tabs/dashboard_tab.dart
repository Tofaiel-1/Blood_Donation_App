import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/dashboard_widgets.dart';

/// Dashboard Tab - Main control panel for Super Admin
/// Shows statistics, quick actions, and recent activity
class DashboardTab extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onAddAdmin;

  const DashboardTab({
    super.key,
    required this.tabController,
    required this.onAddAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bloodRequests')
          .snapshots(),
      builder: (context, requestSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'orgAdmin')
              .snapshots(),
          builder: (context, adminSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (requestSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    adminSnapshot.connectionState == ConnectionState.waiting ||
                    userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Calculate statistics
                final totalRequests = requestSnapshot.data?.docs.length ?? 0;
                final pendingRequests =
                    requestSnapshot.data?.docs
                        .where((d) => (d.data() as Map)['status'] == 'pending')
                        .length ??
                    0;
                final fulfilledRequests =
                    requestSnapshot.data?.docs
                        .where(
                          (d) => (d.data() as Map)['status'] == 'fulfilled',
                        )
                        .length ??
                    0;
                final totalAdmins = adminSnapshot.data?.docs.length ?? 0;
                final activeAdmins =
                    adminSnapshot.data?.docs
                        .where((d) => (d.data() as Map)['isActive'] == true)
                        .length ??
                    0;
                final totalUsers = userSnapshot.data?.docs.length ?? 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Banner
                      DashboardWidgets.buildWelcomeBanner(),
                      const SizedBox(height: 24),

                      // Quick Actions Section
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2,
                        children: [
                          DashboardWidgets.buildQuickActionCard(
                            'Add Admin',
                            Icons.person_add,
                            Colors.blue,
                            onAddAdmin,
                          ),
                          DashboardWidgets.buildQuickActionCard(
                            'View Requests',
                            Icons.bloodtype,
                            Colors.red,
                            () => tabController.animateTo(2),
                          ),
                          DashboardWidgets.buildQuickActionCard(
                            'Manage Users',
                            Icons.people,
                            Colors.green,
                            () => tabController.animateTo(3),
                          ),
                          DashboardWidgets.buildQuickActionCard(
                            'Inventory',
                            Icons.inventory,
                            Colors.purple,
                            () => tabController.animateTo(5),
                          ),
                          DashboardWidgets.buildQuickActionCard(
                            'Settings',
                            Icons.settings,
                            Colors.orange,
                            () => tabController.animateTo(6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // System Statistics Section
                      Text(
                        'System Statistics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        children: [
                          DashboardWidgets.buildStatCard(
                            'Total Requests',
                            totalRequests.toString(),
                            Icons.bloodtype,
                            Colors.red,
                          ),
                          DashboardWidgets.buildStatCard(
                            'Pending',
                            pendingRequests.toString(),
                            Icons.pending,
                            Colors.orange,
                          ),
                          DashboardWidgets.buildStatCard(
                            'Fulfilled',
                            fulfilledRequests.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                          DashboardWidgets.buildStatCard(
                            'Total Admins',
                            totalAdmins.toString(),
                            Icons.admin_panel_settings,
                            Colors.blue,
                          ),
                          DashboardWidgets.buildStatCard(
                            'Active Admins',
                            activeAdmins.toString(),
                            Icons.verified_user,
                            Colors.teal,
                          ),
                          DashboardWidgets.buildStatCard(
                            'Total Users',
                            totalUsers.toString(),
                            Icons.people,
                            Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Activity Section
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DashboardWidgets.buildRecentActivity(
                        requestSnapshot.data?.docs ?? [],
                      ),
                      const SizedBox(height: 24),

                      // Blood Type Distribution Section
                      Text(
                        'Blood Type Distribution',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DashboardWidgets.buildBloodTypeChart(
                        requestSnapshot.data?.docs ?? [],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
