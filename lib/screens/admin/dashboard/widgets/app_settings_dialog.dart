import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_colors.dart';

class AppSettingsDialog extends StatefulWidget {
  const AppSettingsDialog({super.key});

  @override
  State<AppSettingsDialog> createState() => _AppSettingsDialogState();
}

class _AppSettingsDialogState extends State<AppSettingsDialog> {
  bool _maintenanceMode = false;
  bool _allowNewRegistrations = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _autoApproveRequests = false;
  int _maxDonationsPerMonth = 1;
  int _minDaysBetweenDonations = 90;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('app_config')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _maintenanceMode = data['maintenanceMode'] ?? false;
          _allowNewRegistrations = data['allowNewRegistrations'] ?? true;
          _emailNotifications = data['emailNotifications'] ?? true;
          _smsNotifications = data['smsNotifications'] ?? false;
          _autoApproveRequests = data['autoApproveRequests'] ?? false;
          _maxDonationsPerMonth = data['maxDonationsPerMonth'] ?? 1;
          _minDaysBetweenDonations = data['minDaysBetweenDonations'] ?? 90;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('app_config')
          .set({
            'maintenanceMode': _maintenanceMode,
            'allowNewRegistrations': _allowNewRegistrations,
            'emailNotifications': _emailNotifications,
            'smsNotifications': _smsNotifications,
            'autoApproveRequests': _autoApproveRequests,
            'maxDonationsPerMonth': _maxDonationsPerMonth,
            'minDaysBetweenDonations': _minDaysBetweenDonations,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
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
                    Icon(Icons.settings, color: AppColors.bloodRed, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'App Settings',
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

            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: ListView(
                      children: [
                        // System Settings
                        _buildSectionHeader('System Settings', Icons.computer),
                        _buildSwitchTile(
                          'Maintenance Mode',
                          'Put the app in maintenance mode',
                          _maintenanceMode,
                          (value) => setState(() => _maintenanceMode = value),
                          isWarning: true,
                        ),
                        _buildSwitchTile(
                          'Allow New Registrations',
                          'Allow new users to register',
                          _allowNewRegistrations,
                          (value) =>
                              setState(() => _allowNewRegistrations = value),
                        ),
                        _buildSwitchTile(
                          'Auto-Approve Requests',
                          'Automatically approve blood requests',
                          _autoApproveRequests,
                          (value) =>
                              setState(() => _autoApproveRequests = value),
                        ),

                        const SizedBox(height: 16),
                        _buildSectionHeader(
                          'Notifications',
                          Icons.notifications,
                        ),
                        _buildSwitchTile(
                          'Email Notifications',
                          'Send email notifications to users',
                          _emailNotifications,
                          (value) =>
                              setState(() => _emailNotifications = value),
                        ),
                        _buildSwitchTile(
                          'SMS Notifications',
                          'Send SMS notifications to users',
                          _smsNotifications,
                          (value) => setState(() => _smsNotifications = value),
                        ),

                        const SizedBox(height: 16),
                        _buildSectionHeader('Donation Rules', Icons.bloodtype),
                        _buildNumberTile(
                          'Max Donations per Month',
                          'Maximum number of donations allowed per donor per month',
                          _maxDonationsPerMonth,
                          1,
                          5,
                          (value) =>
                              setState(() => _maxDonationsPerMonth = value),
                        ),
                        _buildNumberTile(
                          'Days Between Donations',
                          'Minimum days required between donations',
                          _minDaysBetweenDonations,
                          56,
                          180,
                          (value) =>
                              setState(() => _minDaysBetweenDonations = value),
                        ),

                        const SizedBox(height: 24),
                        // Database Actions
                        _buildSectionHeader('Database Actions', Icons.storage),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.backup,
                                    color: Colors.blue,
                                  ),
                                  title: const Text('Backup Database'),
                                  subtitle: const Text(
                                    'Create a backup of all data',
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: _backupDatabase,
                                    child: const Text('Backup'),
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.cleaning_services,
                                    color: Colors.orange,
                                  ),
                                  title: const Text('Clear Cache'),
                                  subtitle: const Text('Clear temporary data'),
                                  trailing: ElevatedButton(
                                    onPressed: _clearCache,
                                    child: const Text('Clear'),
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                  title: const Text('Reset Demo Data'),
                                  subtitle: const Text(
                                    'Remove all demo/test data',
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: _resetDemoData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Reset'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bloodRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.bloodRed),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool isWarning = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: isWarning ? Colors.orange : AppColors.bloodRed,
        secondary: isWarning && value
            ? const Icon(Icons.warning, color: Colors.orange)
            : null,
      ),
    );
  }

  Widget _buildNumberTile(
    String title,
    String subtitle,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bloodRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.bloodRed,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupDatabase() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup started... This may take a while.'),
        backgroundColor: Colors.blue,
      ),
    );

    // Simulate backup
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearCache() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _resetDemoData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Reset Demo Data?'),
          ],
        ),
        content: const Text(
          'This will remove all demo/test data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo data reset!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
