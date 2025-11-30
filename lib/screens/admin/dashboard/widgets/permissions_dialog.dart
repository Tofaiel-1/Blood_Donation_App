import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_colors.dart';

class PermissionsDialog extends StatefulWidget {
  const PermissionsDialog({super.key});

  @override
  State<PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<PermissionsDialog> {
  String _selectedRole = 'orgAdmin';

  final Map<String, Map<String, bool>> _permissions = {
    'orgAdmin': {
      'createBloodRequest': true,
      'approveBloodRequest': true,
      'manageInventory': true,
      'viewDonors': true,
      'contactDonors': true,
      'viewReports': true,
      'exportData': false,
      'manageAdmins': false,
      'deleteUsers': false,
      'systemSettings': false,
    },
    'admin': {
      'createBloodRequest': true,
      'approveBloodRequest': false,
      'manageInventory': true,
      'viewDonors': true,
      'contactDonors': true,
      'viewReports': false,
      'exportData': false,
      'manageAdmins': false,
      'deleteUsers': false,
      'systemSettings': false,
    },
    'user': {
      'createBloodRequest': true,
      'approveBloodRequest': false,
      'manageInventory': false,
      'viewDonors': false,
      'contactDonors': false,
      'viewReports': false,
      'exportData': false,
      'manageAdmins': false,
      'deleteUsers': false,
      'systemSettings': false,
    },
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('permissions')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        for (var role in _permissions.keys) {
          if (data[role] != null) {
            final rolePerms = Map<String, dynamic>.from(data[role]);
            for (var perm in rolePerms.keys) {
              if (_permissions[role]!.containsKey(perm)) {
                _permissions[role]![perm] = rolePerms[perm] ?? false;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading permissions: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _savePermissions() async {
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('permissions')
          .set({..._permissions, 'updatedAt': FieldValue.serverTimestamp()});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving permissions: $e'),
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
                    Icon(Icons.security, color: AppColors.bloodRed, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Role Permissions',
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

            // Role selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRoleChip('orgAdmin', 'Org Admin', Icons.business),
                  const SizedBox(width: 8),
                  _buildRoleChip('admin', 'Admin', Icons.admin_panel_settings),
                  const SizedBox(width: 8),
                  _buildRoleChip('user', 'User', Icons.person),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Permissions list
            _isLoading
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Expanded(
                    child: ListView(
                      children: [
                        _buildPermissionCategory(
                          'Blood Requests',
                          Icons.bloodtype,
                          ['createBloodRequest', 'approveBloodRequest'],
                        ),
                        const SizedBox(height: 12),
                        _buildPermissionCategory(
                          'Inventory & Donors',
                          Icons.inventory,
                          ['manageInventory', 'viewDonors', 'contactDonors'],
                        ),
                        const SizedBox(height: 12),
                        _buildPermissionCategory(
                          'Reports & Data',
                          Icons.analytics,
                          ['viewReports', 'exportData'],
                        ),
                        const SizedBox(height: 12),
                        _buildPermissionCategory(
                          'Administration',
                          Icons.admin_panel_settings,
                          ['manageAdmins', 'deleteUsers', 'systemSettings'],
                        ),
                      ],
                    ),
                  ),

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.restore),
                  label: const Text('Reset to Defaults'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _savePermissions,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Permissions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bloodRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => setState(() => _selectedRole = role),
      selectedColor: AppColors.bloodRed,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildPermissionCategory(
    String title,
    IconData icon,
    List<String> permissionKeys,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.bloodRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...permissionKeys.map((key) => _buildPermissionSwitch(key)),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSwitch(String permissionKey) {
    final value = _permissions[_selectedRole]?[permissionKey] ?? false;
    final label = _formatPermissionName(permissionKey);
    final description = _getPermissionDescription(permissionKey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                _permissions[_selectedRole]![permissionKey] = newValue;
              });
            },
            activeColor: AppColors.bloodRed,
          ),
        ],
      ),
    );
  }

  String _formatPermissionName(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getPermissionDescription(String key) {
    switch (key) {
      case 'createBloodRequest':
        return 'Can create new blood requests';
      case 'approveBloodRequest':
        return 'Can approve or reject blood requests';
      case 'manageInventory':
        return 'Can manage blood inventory levels';
      case 'viewDonors':
        return 'Can view donor list and details';
      case 'contactDonors':
        return 'Can contact donors directly';
      case 'viewReports':
        return 'Can view analytics and reports';
      case 'exportData':
        return 'Can export data to CSV/Excel';
      case 'manageAdmins':
        return 'Can create and manage other admins';
      case 'deleteUsers':
        return 'Can delete user accounts';
      case 'systemSettings':
        return 'Can modify system settings';
      default:
        return '';
    }
  }

  void _resetToDefaults() {
    setState(() {
      _permissions['orgAdmin'] = {
        'createBloodRequest': true,
        'approveBloodRequest': true,
        'manageInventory': true,
        'viewDonors': true,
        'contactDonors': true,
        'viewReports': true,
        'exportData': false,
        'manageAdmins': false,
        'deleteUsers': false,
        'systemSettings': false,
      };
      _permissions['admin'] = {
        'createBloodRequest': true,
        'approveBloodRequest': false,
        'manageInventory': true,
        'viewDonors': true,
        'contactDonors': true,
        'viewReports': false,
        'exportData': false,
        'manageAdmins': false,
        'deleteUsers': false,
        'systemSettings': false,
      };
      _permissions['user'] = {
        'createBloodRequest': true,
        'approveBloodRequest': false,
        'manageInventory': false,
        'viewDonors': false,
        'contactDonors': false,
        'viewReports': false,
        'exportData': false,
        'manageAdmins': false,
        'deleteUsers': false,
        'systemSettings': false,
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permissions reset to defaults'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
