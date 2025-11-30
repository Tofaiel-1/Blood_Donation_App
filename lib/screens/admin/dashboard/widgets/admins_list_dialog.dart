import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_colors.dart';

class AdminsListDialog extends StatelessWidget {
  const AdminsListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.blue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'All Admins',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Admins List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', whereIn: ['admin', 'orgAdmin', 'superAdmin'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final admins = snapshot.data?.docs ?? [];

                  if (admins.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.admin_panel_settings_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No admins found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group by role
                  final superAdmins = admins
                      .where(
                        (doc) => (doc.data() as Map)['role'] == 'superAdmin',
                      )
                      .toList();
                  final orgAdmins = admins
                      .where((doc) => (doc.data() as Map)['role'] == 'orgAdmin')
                      .toList();
                  final regularAdmins = admins
                      .where((doc) => (doc.data() as Map)['role'] == 'admin')
                      .toList();

                  return ListView(
                    children: [
                      if (superAdmins.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Super Admins',
                          Colors.purple,
                          superAdmins.length,
                        ),
                        ...superAdmins.map(
                          (doc) => _buildAdminTile(context, doc),
                        ),
                      ],
                      if (orgAdmins.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionHeader(
                          'Organization Admins',
                          Colors.blue,
                          orgAdmins.length,
                        ),
                        ...orgAdmins.map(
                          (doc) => _buildAdminTile(context, doc),
                        ),
                      ],
                      if (regularAdmins.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildSectionHeader(
                          'Regular Admins',
                          Colors.green,
                          regularAdmins.length,
                        ),
                        ...regularAdmins.map(
                          (doc) => _buildAdminTile(context, doc),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTile(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final role = data['role'] ?? 'admin';
    final isActive = data['isActive'] ?? true;

    Color roleColor;
    String roleLabel;
    switch (role) {
      case 'superAdmin':
        roleColor = Colors.purple;
        roleLabel = 'Super Admin';
        break;
      case 'orgAdmin':
        roleColor = Colors.blue;
        roleLabel = 'Org Admin';
        break;
      default:
        roleColor = Colors.green;
        roleLabel = 'Admin';
    }

    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor,
          child: Text(
            (data['name'] ?? 'A')[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                data['name'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['email'] ?? '', style: const TextStyle(fontSize: 12)),
            if (data['organization'] != null)
              Text(
                '🏢 ${data['organization']}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                roleLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: roleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _showAdminDetails(context, data, doc.id),
      ),
    );
  }

  void _showAdminDetails(
    BuildContext context,
    Map<String, dynamic> data,
    String adminId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.bloodRed,
              child: Text(
                (data['name'] ?? 'A')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(data['name'] ?? 'Unknown')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Email', data['email'] ?? 'N/A'),
              _detailRow('Phone', data['phone'] ?? 'N/A'),
              _detailRow('Role', data['role'] ?? 'N/A'),
              _detailRow('Organization', data['organization'] ?? 'N/A'),
              _detailRow(
                'Status',
                (data['isActive'] ?? true) ? 'Active' : 'Inactive',
              ),
              _detailRow(
                'Verified',
                (data['emailVerified'] ?? false) ? 'Yes ✓' : 'No',
              ),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
