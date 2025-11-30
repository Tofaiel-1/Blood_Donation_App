import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../../models/admin.dart';
import '../../../utils/app_colors.dart';

/// Admin Management Tab - Handles all admin CRUD operations
/// Search, Add, Edit, Delete, Activate/Deactivate admins
class AdminManagementTab extends StatefulWidget {
  const AdminManagementTab({super.key});

  @override
  State<AdminManagementTab> createState() => AdminManagementTabState();
}

class AdminManagementTabState extends State<AdminManagementTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search admins by name or email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        // Admin List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'orgAdmin')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final adminDocs = snapshot.data?.docs ?? [];
              final filteredAdmins = adminDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final email = (data['email'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery) ||
                    email.contains(_searchQuery);
              }).toList();

              if (filteredAdmins.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No admins yet'
                            : 'No admins found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add an admin to get started',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredAdmins.length,
                itemBuilder: (context, index) {
                  final doc = filteredAdmins[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final admin = AdminUser(
                    id: doc.id,
                    email: data['email'] ?? '',
                    name: data['name'] ?? '',
                    phone: data['phone'],
                    organization: data['organization'],
                    isActive: data['isActive'] ?? true,
                    createdAt:
                        (data['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                    createdBy: data['createdBy'],
                    permissions: List<String>.from(data['permissions'] ?? []),
                  );

                  return _buildAdminCard(admin);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Admin Card Widget
  Widget _buildAdminCard(AdminUser admin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: admin.isActive ? AppColors.bloodRed : Colors.grey,
          child: Text(
            admin.name.isNotEmpty ? admin.name[0].toUpperCase() : 'A',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          admin.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(admin.email, style: TextStyle(color: Colors.grey[600])),
            if (admin.organization != null)
              Text(
                'Org: ${admin.organization}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(
            admin.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: admin.isActive ? Colors.green[700] : Colors.red[700],
              fontSize: 12,
            ),
          ),
          backgroundColor: admin.isActive ? Colors.green[50] : Colors.red[50],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (admin.phone != null)
                  _buildInfoRow(Icons.phone, 'Phone', admin.phone!),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Created',
                  _formatDate(admin.createdAt),
                ),
                if (admin.permissions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Permissions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: admin.permissions
                        .map(
                          (p) => Chip(
                            label: Text(
                              p,
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Colors.blue[50],
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditAdminDialog(admin),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _toggleAdminStatus(admin),
                      icon: Icon(
                        admin.isActive ? Icons.block : Icons.check_circle,
                        size: 18,
                      ),
                      label: Text(admin.isActive ? 'Deactivate' : 'Activate'),
                      style: TextButton.styleFrom(
                        foregroundColor: admin.isActive
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteAdmin(admin),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ==================== CRUD OPERATIONS ====================

  /// Show Add Admin Dialog
  Future<void> showAddAdminDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final orgController = TextEditingController();
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Admin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: orgController,
                decoration: const InputDecoration(
                  labelText: 'Organization',
                  border: OutlineInputBorder(),
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
              if (nameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please fill required fields (Name, Email, Password)',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _createAdmin(
                nameController.text,
                emailController.text,
                passwordController.text,
                phoneController.text,
                orgController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
            ),
            child: const Text('Add Admin'),
          ),
        ],
      ),
    );
  }

  /// Create New Admin
  Future<void> _createAdmin(
    String name,
    String email,
    String password,
    String phone,
    String organization,
  ) async {
    try {
      final currentUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      // Important Note: Creating a new user with createUserWithEmailAndPassword
      // will automatically sign in as that new user, logging out the current admin.
      // In production, use Firebase Admin SDK on server-side to create users.

      final userCredential = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final newAdminUid = userCredential.user!.uid;

      // Add new admin to Firestore
      await FirebaseFirestore.instance.collection('users').doc(newAdminUid).set(
        {
          'name': name,
          'email': email,
          'phone': phone.isNotEmpty ? phone : null,
          'organization': organization.isNotEmpty ? organization : null,
          'role': 'orgAdmin',
          'isActive': true,
          'emailVerified': true,
          'phoneVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': currentUser.uid,
          'permissions': ['manage_requests', 'view_analytics'],
          'bloodType': 'N/A',
        },
      );

      // Sign out the newly created admin
      await fb_auth.FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ Admin created successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text('Email: $email'),
                Text('Password: $password'),
                const SizedBox(height: 8),
                const Text(
                  '⚠️ You have been logged out. Please login again.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ),
        );

        // Navigate to login screen after delay
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating admin: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Edit Admin
  Future<void> _showEditAdminDialog(AdminUser admin) async {
    final nameController = TextEditingController(text: admin.name);
    final phoneController = TextEditingController(text: admin.phone ?? '');
    final orgController = TextEditingController(text: admin.organization ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Admin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: orgController,
                decoration: const InputDecoration(
                  labelText: 'Organization',
                  border: OutlineInputBorder(),
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
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(admin.id)
                  .update({
                    'name': nameController.text,
                    'phone': phoneController.text.isNotEmpty
                        ? phoneController.text
                        : null,
                    'organization': orgController.text.isNotEmpty
                        ? orgController.text
                        : null,
                  });

              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Admin updated successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  /// Toggle Admin Status
  Future<void> _toggleAdminStatus(AdminUser admin) async {
    final newStatus = !admin.isActive;
    await FirebaseFirestore.instance.collection('users').doc(admin.id).update({
      'isActive': newStatus,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Admin ${newStatus ? "activated" : "deactivated"} successfully',
        ),
      ),
    );
  }

  /// Delete Admin
  Future<void> _deleteAdmin(AdminUser admin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete ${admin.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(admin.id)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin deleted successfully')),
      );
    }
  }
}
