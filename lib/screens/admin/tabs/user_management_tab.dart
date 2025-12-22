import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/admin_service.dart';
import '../../../utils/app_colors.dart';

/// User Management Tab - Manage regular users and promote them to admin
class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final AdminService _adminService = AdminService();
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
              hintText: 'Search users by name, email, or blood type...',
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

        // User List
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _adminService.getAllRegularUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final users = snapshot.data ?? [];
              final filteredUsers = users.where((user) {
                final name = (user['name'] ?? '').toString().toLowerCase();
                final email = (user['email'] ?? '').toString().toLowerCase();
                final bloodType = (user['bloodType'] ?? '')
                    .toString()
                    .toLowerCase();
                return name.contains(_searchQuery) ||
                    email.contains(_searchQuery) ||
                    bloodType.contains(_searchQuery);
              }).toList();

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No users found'
                            : 'No matching users',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // User Card Widget
  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['id'] ?? '';
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? '';
    final phone = user['phone'] ?? 'N/A';
    final bloodType = user['bloodType'] ?? 'Unknown';
    final isActive = user['isActive'] ?? true;
    final age = user['age']?.toString() ?? 'N/A';
    final gender = user['gender'] ?? 'N/A';
    final address = user['address'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getBloodTypeColor(bloodType),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getBloodTypeColor(bloodType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getBloodTypeColor(bloodType),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    bloodType,
                    style: TextStyle(
                      color: _getBloodTypeColor(bloodType),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isActive
            ? const Icon(Icons.person, color: Colors.green)
            : const Icon(Icons.person_off, color: Colors.grey),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, 'Phone', phone),
                _buildInfoRow(Icons.cake, 'Age', age),
                _buildInfoRow(Icons.person_outline, 'Gender', gender),
                _buildInfoRow(Icons.location_on, 'Address', address),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showPromoteDialog(userId, name, email),
                      icon: const Icon(Icons.admin_panel_settings, size: 18),
                      label: const Text('Promote to Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bloodRed,
                        foregroundColor: Colors.white,
                      ),
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
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Color _getBloodTypeColor(String bloodType) {
    switch (bloodType.toUpperCase()) {
      case 'A+':
      case 'A-':
        return Colors.red;
      case 'B+':
      case 'B-':
        return Colors.blue;
      case 'AB+':
      case 'AB-':
        return Colors.purple;
      case 'O+':
      case 'O-':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Show Promote to Admin Dialog
  Future<void> _showPromoteDialog(
    String userId,
    String userName,
    String userEmail,
  ) async {
    final orgController = TextEditingController();
    final selectedPermissions = <String>['manage_requests', 'view_analytics'];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Promote to Admin'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promote "$userName" to admin?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orgController,
                  decoration: const InputDecoration(
                    labelText: 'Organization (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Permissions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Manage Requests'),
                  value: selectedPermissions.contains('manage_requests'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add('manage_requests');
                      } else {
                        selectedPermissions.remove('manage_requests');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('View Analytics'),
                  value: selectedPermissions.contains('view_analytics'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add('view_analytics');
                      } else {
                        selectedPermissions.remove('view_analytics');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Manage Users'),
                  value: selectedPermissions.contains('manage_users'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add('manage_users');
                      } else {
                        selectedPermissions.remove('manage_users');
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Manage Bookings'),
                  value: selectedPermissions.contains('manage_bookings'),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add('manage_bookings');
                      } else {
                        selectedPermissions.remove('manage_bookings');
                      }
                    });
                  },
                ),
              ],
            ),
          ),
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
              child: const Text('Promote'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _promoteUser(
        userId,
        userName,
        orgController.text.isNotEmpty ? orgController.text : null,
        selectedPermissions,
      );
    }
  }

  // Promote User to Admin
  Future<void> _promoteUser(
    String userId,
    String userName,
    String? organization,
    List<String> permissions,
  ) async {
    try {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('Promoting user to admin...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      await _adminService.promoteToAdmin(
        userId: userId,
        organization: organization,
        permissions: permissions,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $userName has been promoted to admin!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error promoting user: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
