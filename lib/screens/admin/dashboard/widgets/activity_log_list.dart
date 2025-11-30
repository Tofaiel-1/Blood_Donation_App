import 'package:flutter/material.dart';

class ActivityLogList extends StatelessWidget {
  final List<Map<String, dynamic>> logs;

  const ActivityLogList({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.history, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 12),
            logs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No recent activity',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: logs.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return _buildLogItem(context, log);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, Map<String, dynamic> log) {
    // Determine icon and color based on action type
    IconData icon;
    Color iconColor;
    final action = (log['action'] ?? '').toString().toLowerCase();

    if (action.contains('admin')) {
      icon = Icons.admin_panel_settings;
      iconColor = Colors.blue;
    } else if (action.contains('donation') || action.contains('blood')) {
      icon = Icons.bloodtype;
      iconColor = Colors.red;
    } else if (action.contains('org') || action.contains('approved')) {
      icon = Icons.business;
      iconColor = Colors.orange;
    } else if (action.contains('setting') || action.contains('backup')) {
      icon = Icons.settings;
      iconColor = Colors.purple;
    } else {
      icon = Icons.history;
      iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),

          // Content - wrapped in Expanded to prevent overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action title with status badge in same row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log['action'] ?? 'Unknown Action',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (log['status'] != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            log['status'],
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          log['status'],
                          style: TextStyle(
                            fontSize: 9,
                            color: _getStatusColor(log['status']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),

                // Description (if available)
                if (log['description'] != null &&
                    log['description'].toString().isNotEmpty)
                  Text(
                    log['description'],
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 4),

                // User and Time row - made flexible
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          log['user'] ?? 'System',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          log['time'] ?? 'Just now',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'error':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
