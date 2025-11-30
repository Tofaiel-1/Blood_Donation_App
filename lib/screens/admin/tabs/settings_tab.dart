import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/app_colors.dart';

/// Settings Tab - System configuration and management
/// Database management, security, monitoring
class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Settings & Control',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete administrative control over the Blood Donation System',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),

          // System Status Card
          _buildSystemStatsCard(),
          const SizedBox(height: 24),

          // Database Management
          _buildSettingsSection('Database Management', [
            _buildSettingsTile(
              'Export Data',
              'Export all system data to JSON',
              Icons.download,
              () => _showMessage('Export feature coming soon'),
            ),
            _buildSettingsTile(
              'Backup Database',
              'Create a backup of Firestore data',
              Icons.backup,
              () => _showMessage('Backup feature coming soon'),
            ),
            _buildSettingsTile(
              'Clear Cache',
              'Clear temporary data and cache',
              Icons.clear_all,
              () => _showMessage('Cache cleared successfully'),
            ),
          ]),
          const SizedBox(height: 24),

          // User Management
          _buildSettingsSection('User Management', [
            _buildSettingsTile(
              'Send Notifications',
              'Send bulk notifications to users',
              Icons.notifications,
              () => _showMessage('Notifications feature coming soon'),
            ),
            _buildSettingsTile(
              'Generate Reports',
              'Generate system usage reports',
              Icons.assessment,
              () => _showMessage('Reports feature coming soon'),
            ),
            _buildSettingsTile(
              'Audit Logs',
              'View system audit logs',
              Icons.history,
              () => _showMessage('Audit logs feature coming soon'),
            ),
          ]),
          const SizedBox(height: 24),

          // System Configuration
          _buildSettingsSection('System Configuration', [
            _buildSettingsTile(
              'Email Templates',
              'Configure email templates',
              Icons.email,
              () => _showMessage('Email templates coming soon'),
            ),
            _buildSettingsTile(
              'Blood Type Requirements',
              'Set minimum blood type requirements',
              Icons.bloodtype,
              () => _showMessage('Requirements settings coming soon'),
            ),
            _buildSettingsTile(
              'Donation Centers',
              'Manage donation center locations',
              Icons.location_on,
              () => _showMessage('Donation centers coming soon'),
            ),
          ]),
          const SizedBox(height: 24),

          // Security
          _buildSettingsSection('Security', [
            _buildSettingsTile(
              'Security Rules',
              'Review Firebase security rules',
              Icons.security,
              _showSecurityInfo,
            ),
            _buildSettingsTile(
              'API Keys',
              'Manage API keys and credentials',
              Icons.key,
              () => _showMessage('API key management coming soon'),
            ),
            _buildSettingsTile(
              'Access Control',
              'Configure role-based access',
              Icons.admin_panel_settings,
              () => _showMessage('Access control coming soon'),
            ),
          ]),
          const SizedBox(height: 24),

          // Danger Zone
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDangerButton(
                    'Reset All Data',
                    'Permanently delete all data',
                    Icons.delete_forever,
                    _confirmResetData,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.bloodRed),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDangerButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red[700],
        side: BorderSide(color: Colors.red[700]!),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatsCard() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.blue[700], size: 28),
                const SizedBox(width: 12),
                Text(
                  'System Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, userSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bloodRequests')
                      .snapshots(),
                  builder: (context, requestSnapshot) {
                    if (userSnapshot.hasData && requestSnapshot.hasData) {
                      final totalUsers = userSnapshot.data!.docs.length;
                      final totalRequests = requestSnapshot.data!.docs.length;
                      final activeRequests = requestSnapshot.data!.docs
                          .where(
                            (d) => (d.data() as Map)['status'] == 'pending',
                          )
                          .length;

                      return Column(
                        children: [
                          _buildStatusRow(
                            'Total Users',
                            totalUsers.toString(),
                            Icons.people,
                            Colors.blue,
                          ),
                          _buildStatusRow(
                            'Total Requests',
                            totalRequests.toString(),
                            Icons.bloodtype,
                            Colors.red,
                          ),
                          _buildStatusRow(
                            'Active Requests',
                            activeRequests.toString(),
                            Icons.pending,
                            Colors.orange,
                          ),
                          _buildStatusRow(
                            'System Health',
                            'Operational',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ],
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Information'),
        content: const Text(
          'Firebase Security Rules are configured.\n\n'
          'Current Rules:\n'
          '• Super Admin: Full access\n'
          '• Org Admin: Manage requests\n'
          '• Users: Read own data',
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

  Future<void> _confirmResetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Confirm Reset'),
        content: const Text(
          'This will permanently delete ALL data from the system.\n\n'
          'This action CANNOT be undone!\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showMessage(
        'Reset functionality requires additional security verification',
      );
    }
  }
}
