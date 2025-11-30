import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_colors.dart';

class ActivityLogsDialog extends StatefulWidget {
  const ActivityLogsDialog({super.key});

  @override
  State<ActivityLogsDialog> createState() => _ActivityLogsDialogState();
}

class _ActivityLogsDialogState extends State<ActivityLogsDialog> {
  String _selectedType = 'All';
  final List<String> _logTypes = [
    'All',
    'Admin',
    'Donation',
    'Request',
    'System',
  ];

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
                    const Icon(Icons.history, color: Colors.grey, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Activity Logs',
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

            // Log type filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _logTypes.map((type) {
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) =>
                          setState(() => _selectedType = type),
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppColors.bloodRed.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.bloodRed,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Logs List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('audit_logs')
                    .orderBy('timestamp', descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    // If collection doesn't exist, show sample data
                    return _buildSampleLogs();
                  }

                  var logs = snapshot.data?.docs ?? [];

                  if (logs.isEmpty) {
                    return _buildSampleLogs();
                  }

                  // Filter by type
                  if (_selectedType != 'All') {
                    logs = logs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['type'] ?? '').toString().toLowerCase() ==
                          _selectedType.toLowerCase();
                    }).toList();
                  }

                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final data = logs[index].data() as Map<String, dynamic>;
                      return _buildLogTile(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleLogs() {
    // Show sample/recent activity from various collections
    return FutureBuilder(
      future: _fetchRecentActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = snapshot.data ?? [];

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No activity logs yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Filter by type
        var filteredLogs = logs;
        if (_selectedType != 'All') {
          filteredLogs = logs
              .where(
                (log) =>
                    log['type']?.toString().toLowerCase() ==
                    _selectedType.toLowerCase(),
              )
              .toList();
        }

        return ListView.builder(
          itemCount: filteredLogs.length,
          itemBuilder: (context, index) {
            return _buildLogTile(filteredLogs[index]);
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRecentActivity() async {
    List<Map<String, dynamic>> logs = [];

    try {
      // Fetch recent donations
      try {
        final donations = await FirebaseFirestore.instance
            .collection('donations')
            .orderBy('donationDate', descending: true)
            .limit(15)
            .get();

        for (var doc in donations.docs) {
          final data = doc.data();
          logs.add({
            'action': 'New Donation',
            'description':
                '${data['donorName'] ?? 'Unknown'} donated ${data['bloodType'] ?? 'blood'} (${data['units'] ?? 1} units)',
            'type': 'Donation',
            'timestamp': data['donationDate'] ?? data['createdAt'],
            'user': data['donorName'] ?? 'Anonymous',
          });
        }
      } catch (e) {
        debugPrint('Error fetching donations: $e');
      }

      // Fetch recent blood requests
      try {
        final requests = await FirebaseFirestore.instance
            .collection('bloodRequests')
            .orderBy('requestDate', descending: true)
            .limit(15)
            .get();

        for (var doc in requests.docs) {
          final data = doc.data();
          final status = data['status']?.toString() ?? 'pending';
          logs.add({
            'action': 'Blood Request - ${status.toUpperCase()}',
            'description':
                '${data['bloodType'] ?? '?'} needed at ${data['hospitalName'] ?? 'Unknown Hospital'} for ${data['patientName'] ?? 'patient'}',
            'type': 'Request',
            'timestamp': data['requestDate'] ?? data['createdAt'],
            'user': data['requestedByName'] ?? 'User',
          });
        }
      } catch (e) {
        debugPrint('Error fetching requests: $e');
      }

      // Fetch recent users/admins (without complex query)
      try {
        final users = await FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .get();

        for (var doc in users.docs) {
          final data = doc.data();
          final role = data['role'] ?? 'user';

          if (data['createdAt'] != null) {
            if (role == 'superAdmin' || role == 'orgAdmin' || role == 'admin') {
              logs.add({
                'action': 'Admin Account Created',
                'description':
                    '${data['name'] ?? 'Unknown'} registered as ${_formatRole(role)}',
                'type': 'Admin',
                'timestamp': data['createdAt'],
                'user': 'System',
              });
            } else {
              logs.add({
                'action': 'New Donor Registered',
                'description':
                    '${data['name'] ?? 'Unknown'} (${data['bloodType'] ?? 'Unknown'}) from ${data['district'] ?? 'Unknown'}',
                'type': 'System',
                'timestamp': data['createdAt'],
                'user': 'System',
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching users: $e');
      }

      // Sort all logs by timestamp
      logs.sort((a, b) {
        final aTime = a['timestamp'];
        final bTime = b['timestamp'];
        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }
        if (aTime is Timestamp) return -1;
        if (bTime is Timestamp) return 1;
        return 0;
      });
    } catch (e) {
      debugPrint('Error fetching activity: $e');
    }

    // If no logs found, add some placeholder logs
    if (logs.isEmpty) {
      logs = [
        {
          'action': 'System Started',
          'description': 'Blood Donation App initialized successfully',
          'type': 'System',
          'timestamp': Timestamp.now(),
          'user': 'System',
        },
      ];
    }

    return logs;
  }

  String _formatRole(String role) {
    switch (role) {
      case 'superAdmin':
        return 'Super Admin';
      case 'orgAdmin':
        return 'Organization Admin';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }

  Widget _buildLogTile(Map<String, dynamic> data) {
    final type = (data['type'] ?? 'System').toString();
    final timestamp = data['timestamp'];
    String timeStr = 'Unknown time';

    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) {
        timeStr = 'Just now';
      } else if (diff.inMinutes < 60) {
        timeStr = '${diff.inMinutes} mins ago';
      } else if (diff.inHours < 24) {
        timeStr = '${diff.inHours} hours ago';
      } else if (diff.inDays < 7) {
        timeStr = '${diff.inDays} days ago';
      } else {
        timeStr = '${date.day}/${date.month}/${date.year}';
      }
    }

    IconData icon;
    Color iconColor;
    switch (type.toLowerCase()) {
      case 'admin':
        icon = Icons.admin_panel_settings;
        iconColor = Colors.blue;
        break;
      case 'donation':
        icon = Icons.bloodtype;
        iconColor = AppColors.bloodRed;
        break;
      case 'request':
        icon = Icons.pending_actions;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.settings;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          data['action'] ?? 'Unknown Action',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['description'] != null)
              Text(data['description'], style: const TextStyle(fontSize: 12)),
            Row(
              children: [
                Icon(Icons.person, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  data['user'] ?? 'System',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          timeStr,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        isThreeLine: true,
      ),
    );
  }
}
