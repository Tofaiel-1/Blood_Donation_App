import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../utils/app_colors.dart';
import '../dashboard/widgets/create_user_dialog.dart';

/// Dashboard Tab - Admin Control Panel
/// NO DEMO/FAKE DATA - All statistics from Firebase
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
          .collection('users')
          .where('role', isEqualTo: 'user')
          .snapshots(),
      builder: (context, usersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('donations')
              .snapshots(),
          builder: (context, donationsSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .snapshots(),
              builder: (context, eventsSnapshot) {
                // Loading state
                if (usersSnapshot.connectionState == ConnectionState.waiting ||
                    donationsSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    eventsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // CALCULATE REAL STATISTICS FROM FIREBASE
                final totalUsers = usersSnapshot.data?.docs.length ?? 0;

                final approvedDonors =
                    usersSnapshot.data?.docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return (data['totalDonations'] ?? 0) > 0;
                    }).length ??
                    0;

                final totalEvents = eventsSnapshot.data?.docs.length ?? 0;

                final completedDonations =
                    donationsSnapshot.data?.docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return data['status'] == 'completed';
                    }).length ??
                    0;

                final pendingDonations =
                    donationsSnapshot.data?.docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      return data['status'] == 'pending';
                    }).length ??
                    0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Logout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: AppColors.bloodRed,
                            ),
                            onPressed: () => _handleLogout(context),
                            tooltip: 'Logout',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Statistics Cards (Real Data Only)
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _buildStatCard(
                            title: 'Total Users',
                            value: totalUsers.toString(),
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            title: 'Approved Donors',
                            value: approvedDonors.toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            title: 'Events',
                            value: totalEvents.toString(),
                            icon: Icons.event,
                            color: Colors.orange,
                          ),
                          _buildStatCard(
                            title: 'Completed',
                            value: completedDonations.toString(),
                            icon: Icons.done_all,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pending Card (Full Width)
                      _buildStatCard(
                        title: 'Pending Donations',
                        value: pendingDonations.toString(),
                        icon: Icons.pending,
                        color: Colors.amber,
                        fullWidth: true,
                      ),
                      const SizedBox(height: 32),

                      // Operations Section
                      Text(
                        'Operations',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Operation Cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: [
                          _buildOperationCard(
                            context: context,
                            title: 'Add User',
                            icon: Icons.person_add,
                            color: AppColors.bloodRed,
                            onTap: () {
                              debugPrint('✅ Add User clicked');
                              _showAddUserDialog(context);
                            },
                          ),
                          _buildOperationCard(
                            context: context,
                            title: 'Manage Users',
                            icon: Icons.manage_accounts,
                            color: Colors.blue,
                            onTap: () {
                              debugPrint('✅ Manage Users clicked');
                              tabController.animateTo(3);
                            },
                          ),
                          _buildOperationCard(
                            context: context,
                            title: 'Org Info',
                            icon: Icons.info,
                            color: Colors.teal,
                            onTap: () {
                              debugPrint('✅ Org Info clicked');
                              _showOrgInfoDialog(context);
                            },
                          ),
                          _buildOperationCard(
                            context: context,
                            title: 'Create Event',
                            icon: Icons.add_box,
                            color: Colors.orange,
                            onTap: () {
                              debugPrint('✅ Create Event clicked');
                              _showCreateEventDialog(context);
                            },
                          ),
                          _buildOperationCard(
                            context: context,
                            title: 'Donations',
                            icon: Icons.bloodtype,
                            color: Colors.red,
                            onTap: () {
                              debugPrint('✅ Donations clicked');
                              tabController.animateTo(4);
                            },
                          ),
                          _buildOperationCard(
                            context: context,
                            title: 'View Reports',
                            icon: Icons.assessment,
                            color: Colors.purple,
                            onTap: () {
                              debugPrint('✅ View Reports clicked');
                              _showReportsInfo(context);
                            },
                          ),
                          _buildOperationCard(
                            context: context,
                            title: 'Clear Data',
                            icon: Icons.delete_forever,
                            color: Colors.red[900]!,
                            onTap: () {
                              debugPrint('⚠️ Clear Data clicked');
                              _showClearDataDialog(context);
                            },
                          ),
                        ],
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

  /// Build Statistics Card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: fullWidth ? 36 : 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build Operation Card
  Widget _buildOperationCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle Logout
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await fb_auth.FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Show Add User Dialog
  void _showAddUserDialog(BuildContext context) {
    try {
      showDialog(
        context: context,
        builder: (context) => const CreateUserDialog(),
      );
      // Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Opening Add User form...'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('❌ ERROR Add User: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Show Organization Info Dialog
  void _showOrgInfoDialog(BuildContext context) {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: AppColors.bloodRed),
              SizedBox(width: 8),
              Text('Organization Info'),
            ],
          ),
          content: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(fb_auth.FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data?.data() as Map<String, dynamic>?;
              if (data == null) {
                return const Text('No data available');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Admin Name', data['name'] ?? 'Unknown'),
                  const Divider(),
                  _buildInfoRow('Email', data['email'] ?? 'No Email'),
                  const Divider(),
                  _buildInfoRow(
                    'Organization',
                    data['organization'] ?? 'Not Set',
                  ),
                  const Divider(),
                  _buildInfoRow('Role', data['role'] ?? 'Admin'),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ ERROR Org Info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  /// Show Create Event Dialog
  void _showCreateEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();

    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.event, color: AppColors.bloodRed),
              SizedBox(width: 8),
              Text('Create New Event'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ Please enter event title'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  debugPrint('📝 Creating event: ${titleController.text}');

                  await FirebaseFirestore.instance.collection('events').add({
                    'title': titleController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'location': locationController.text.trim(),
                    'createdBy': fb_auth.FirebaseAuth.instance.currentUser?.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                    'status': 'upcoming',
                  });

                  debugPrint('✅ Event created successfully');

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Event created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint('❌ ERROR Create Event: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bloodRed,
              ),
              child: const Text('Create Event'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ ERROR Event Dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Show Reports Info
  void _showReportsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assessment, color: Colors.purple),
            SizedBox(width: 8),
            Text('Reports'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Reports:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text('• User Statistics Report'),
            SizedBox(height: 8),
            Text('• Donation History Report'),
            SizedBox(height: 8),
            Text('• Event Summary Report'),
            SizedBox(height: 8),
            Text('• Blood Type Analytics'),
            SizedBox(height: 16),
            Text(
              'Reports can be accessed from respective tabs.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
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

  /// Show Clear Data Dialog - Delete previous admin data
  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ WARNING: This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 16),
            Text('• All Users (role: user)'),
            Text('• All Donations'),
            Text('• All Events'),
            SizedBox(height: 16),
            Text(
              '⚠️ Admin accounts will NOT be deleted.',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmClearData(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Confirm Clear Data with password
  void _confirmClearData(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Type "DELETE" to confirm:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'Type DELETE',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text == 'DELETE') {
                Navigator.pop(context);
                await _executeDeleteAllData(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please type DELETE to confirm'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All Data'),
          ),
        ],
      ),
    );
  }

  /// Execute delete all data
  Future<void> _executeDeleteAllData(BuildContext context) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting data...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      debugPrint('🗑️ Starting data deletion...');

      // Delete all users (except admins)
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      for (var doc in usersSnapshot.docs) {
        await doc.reference.delete();
        debugPrint('🗑️ Deleted user: ${doc.id}');
      }

      // Delete all donations
      final donationsSnapshot = await FirebaseFirestore.instance
          .collection('donations')
          .get();

      for (var doc in donationsSnapshot.docs) {
        await doc.reference.delete();
        debugPrint('🗑️ Deleted donation: ${doc.id}');
      }

      // Delete all events
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      for (var doc in eventsSnapshot.docs) {
        await doc.reference.delete();
        debugPrint('🗑️ Deleted event: ${doc.id}');
      }

      // Delete all blood requests if exists
      try {
        final requestsSnapshot = await FirebaseFirestore.instance
            .collection('bloodRequests')
            .get();

        for (var doc in requestsSnapshot.docs) {
          await doc.reference.delete();
          debugPrint('🗑️ Deleted blood request: ${doc.id}');
        }
      } catch (e) {
        debugPrint('ℹ️ No bloodRequests collection or error: $e');
      }

      // Delete all notifications if exists
      try {
        final notificationsSnapshot = await FirebaseFirestore.instance
            .collection('notifications')
            .get();

        for (var doc in notificationsSnapshot.docs) {
          await doc.reference.delete();
          debugPrint('🗑️ Deleted notification: ${doc.id}');
        }
      } catch (e) {
        debugPrint('ℹ️ No notifications collection or error: $e');
      }

      debugPrint('✅ All data deleted successfully');

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Deleted: ${usersSnapshot.docs.length} users, '
              '${donationsSnapshot.docs.length} donations, '
              '${eventsSnapshot.docs.length} events',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ERROR deleting data: $e');
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
