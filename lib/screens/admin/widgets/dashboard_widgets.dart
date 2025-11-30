import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/app_colors.dart';

/// Dashboard Widgets - Contains all reusable dashboard components
/// Used by Super Admin Control Panel
class DashboardWidgets {
  /// Welcome Banner Card
  static Widget buildWelcomeBanner() {
    return Card(
      color: AppColors.bloodRed.withValues(alpha: 0.1),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 60,
              color: AppColors.bloodRed,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Super Admin!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bloodRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have complete control over the Blood Donation System',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick Action Card with tap functionality
  static Widget buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  /// Statistics Card for displaying counts
  static Widget buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Activity List showing latest blood requests
  static Widget buildRecentActivity(List<QueryDocumentSnapshot> requests) {
    // Sort by timestamp and get last 5
    final recentRequests = requests.toList()
      ..sort((a, b) {
        final aTime = (a.data() as Map)['createdAt'] as Timestamp?;
        final bTime = (b.data() as Map)['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

    final displayRequests = recentRequests.take(5).toList();

    if (displayRequests.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No recent activity',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayRequests.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final doc = displayRequests[index];
          final data = doc.data() as Map<String, dynamic>;
          final patientName = data['patientName'] ?? 'Unknown';
          final bloodType = data['bloodType'] ?? '';
          final status = data['status'] ?? 'pending';
          final timestamp = data['createdAt'] as Timestamp?;

          String timeAgo = 'Recently';
          if (timestamp != null) {
            final diff = DateTime.now().difference(timestamp.toDate());
            if (diff.inDays > 0) {
              timeAgo = '${diff.inDays}d ago';
            } else if (diff.inHours > 0) {
              timeAgo = '${diff.inHours}h ago';
            } else if (diff.inMinutes > 0) {
              timeAgo = '${diff.inMinutes}m ago';
            } else {
              timeAgo = 'Just now';
            }
          }

          Color statusColor = status == 'pending'
              ? Colors.orange
              : status == 'fulfilled'
              ? Colors.green
              : Colors.red;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.2),
              child: Icon(Icons.bloodtype, color: statusColor),
            ),
            title: Text(
              '$patientName - $bloodType',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Status: ${status.toUpperCase()}'),
            trailing: Text(
              timeAgo,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  /// Blood Type Distribution Chart
  static Widget buildBloodTypeChart(List<QueryDocumentSnapshot> requests) {
    // Count blood types
    final bloodTypeCounts = <String, int>{};
    for (final doc in requests) {
      final data = doc.data() as Map<String, dynamic>;
      final bloodType = data['bloodType'] as String?;
      if (bloodType != null) {
        bloodTypeCounts[bloodType] = (bloodTypeCounts[bloodType] ?? 0) + 1;
      }
    }

    if (bloodTypeCounts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No blood type data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.blue,
      Colors.lightBlue,
      Colors.green,
      Colors.lightGreen,
      Colors.orange,
      Colors.deepOrange,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...bloodTypes.asMap().entries.map((entry) {
              final index = entry.key;
              final type = entry.value;
              final count = bloodTypeCounts[type] ?? 0;
              final total = requests.length;
              final percentage = total > 0 ? (count / total * 100) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$count (${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(colors[index]),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
