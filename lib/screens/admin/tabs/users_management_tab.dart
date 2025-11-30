import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/app_colors.dart';

/// Users Tab - Manage all system users (donors)
/// View, search, filter users by role
class UsersManagementTab extends StatefulWidget {
  const UsersManagementTab({super.key});

  @override
  State<UsersManagementTab> createState() => _UsersManagementTabState();
}

class _UsersManagementTabState extends State<UsersManagementTab> {
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
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
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _roleFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                  DropdownMenuItem(value: 'user', child: Text('Donors')),
                  DropdownMenuItem(value: 'orgAdmin', child: Text('Admins')),
                  DropdownMenuItem(
                    value: 'superAdmin',
                    child: Text('Super Admins'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _roleFilter = value ?? 'all';
                  });
                },
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final users = snapshot.data?.docs ?? [];

              // Apply filters
              final filteredUsers = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final email = (data['email'] ?? '').toString().toLowerCase();
                final role = data['role'] ?? 'user';

                final matchesSearch =
                    name.contains(_searchQuery) || email.contains(_searchQuery);
                final matchesRole = _roleFilter == 'all' || role == _roleFilter;

                return matchesSearch && matchesRole;
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
                        'No users found',
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
                  final doc = filteredUsers[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _UserCard(userId: doc.id, userData: data);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual User Card Widget
class _UserCard extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const _UserCard({required this.userId, required this.userData});

  @override
  Widget build(BuildContext context) {
    final name = userData['name'] ?? 'Unknown';
    final email = userData['email'] ?? '';
    final role = userData['role'] ?? 'user';
    final bloodType = userData['bloodType'] ?? 'N/A';
    final phone = userData['phone'];
    final isActive = userData['isActive'] ?? true;
    final createdAt = (userData['createdAt'] as Timestamp?)?.toDate();

    Color roleColor = _getRoleColor(role);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
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
            Text(
              'Blood Type: $bloodType',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Chip(
              label: Text(
                _getRoleLabel(role),
                style: TextStyle(
                  color: roleColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: roleColor.withValues(alpha: 0.1),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (phone != null) _buildInfoRow(Icons.phone, 'Phone', phone),
                _buildInfoRow(Icons.email, 'Email', email),
                _buildInfoRow(Icons.bloodtype, 'Blood Type', bloodType),
                if (userData['age'] != null)
                  _buildInfoRow(Icons.cake, 'Age', userData['age'].toString()),
                if (userData['gender'] != null)
                  _buildInfoRow(Icons.person, 'Gender', userData['gender']),
                if (userData['address'] != null)
                  _buildInfoRow(
                    Icons.location_on,
                    'Address',
                    userData['address'],
                  ),
                _buildInfoRow(
                  Icons.admin_panel_settings,
                  'Role',
                  _getRoleLabel(role),
                ),
                if (createdAt != null)
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Joined',
                    _formatDate(createdAt),
                  ),
                _buildInfoRow(
                  Icons.verified,
                  'Status',
                  isActive ? 'Active' : 'Inactive',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          _viewUserDetails(context, userId, userData),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Details'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    if (role != 'superAdmin')
                      TextButton.icon(
                        onPressed: () =>
                            _toggleUserStatus(context, userId, isActive),
                        icon: Icon(
                          isActive ? Icons.block : Icons.check_circle,
                          size: 18,
                        ),
                        label: Text(isActive ? 'Deactivate' : 'Activate'),
                        style: TextButton.styleFrom(
                          foregroundColor: isActive
                              ? Colors.orange
                              : Colors.green,
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'superAdmin':
        return AppColors.bloodRed;
      case 'orgAdmin':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'superAdmin':
        return 'Super Admin';
      case 'orgAdmin':
        return 'Org Admin';
      default:
        return 'Donor';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewUserDetails(
    BuildContext context,
    String userId,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['name'] ?? 'User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', data['name'] ?? 'N/A'),
              _buildDetailRow('Email', data['email'] ?? 'N/A'),
              _buildDetailRow('Phone', data['phone'] ?? 'N/A'),
              _buildDetailRow('Blood Type', data['bloodType'] ?? 'N/A'),
              if (data['age'] != null)
                _buildDetailRow('Age', data['age'].toString()),
              if (data['gender'] != null)
                _buildDetailRow('Gender', data['gender']),
              if (data['address'] != null)
                _buildDetailRow('Address', data['address']),
              _buildDetailRow('Role', _getRoleLabel(data['role'] ?? 'user')),
              _buildDetailRow(
                'Status',
                (data['isActive'] ?? true) ? 'Active' : 'Inactive',
              ),
              _buildDetailRow(
                'Email Verified',
                (data['emailVerified'] ?? false) ? 'Yes' : 'No',
              ),
              _buildDetailRow(
                'Phone Verified',
                (data['phoneVerified'] ?? false) ? 'Yes' : 'No',
              ),
              if (data['location'] != null)
                _buildDetailRow('Location', data['location']),
              if (data['organization'] != null)
                _buildDetailRow('Organization', data['organization']),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  static Future<void> _toggleUserStatus(
    BuildContext context,
    String userId,
    bool currentStatus,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isActive': !currentStatus,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${!currentStatus ? "activated" : "deactivated"} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
