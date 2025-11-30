import 'package:flutter/material.dart';
import '../models/broadcast_alert.dart';
import '../services/broadcast_alert_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

/// Notice Bar Widget - Shows broadcast alerts on home screen
/// Only visible when user logs in and has unread alerts
class NoticeBar extends StatefulWidget {
  const NoticeBar({super.key});

  @override
  State<NoticeBar> createState() => _NoticeBarState();
}

class _NoticeBarState extends State<NoticeBar>
    with SingleTickerProviderStateMixin {
  final BroadcastAlertService _alertService = BroadcastAlertService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissNotice() {
    _animationController.reverse().then((_) {
      setState(() {
        _isDismissed = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<BroadcastAlert>>(
      stream: _alertService.getAlertsForUser(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get the most recent alert
        final alert = snapshot.data!.first;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(
                BroadcastAlert.getAlertColor(alert.type),
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(BroadcastAlert.getAlertColor(alert.type)),
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAlertDetails(context, alert),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(
                            BroadcastAlert.getAlertColor(alert.type),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          BroadcastAlert.getAlertIcon(alert.type),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(
                                  BroadcastAlert.getAlertColor(alert.type),
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alert.message,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Badge for multiple alerts
                      if (snapshot.data!.length > 1)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(
                              BroadcastAlert.getAlertColor(alert.type),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${snapshot.data!.length - 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Close button
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Color(
                            BroadcastAlert.getAlertColor(alert.type),
                          ),
                          size: 18,
                        ),
                        onPressed: () {
                          _alertService.markAsViewed(alert.id, user.uid);
                          _dismissNotice();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAlertDetails(BuildContext context, BroadcastAlert alert) {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      _alertService.markAsViewed(alert.id, user.uid);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              BroadcastAlert.getAlertIcon(alert.type),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alert.title,
                style: TextStyle(
                  color: Color(BroadcastAlert.getAlertColor(alert.type)),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(alert.message, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'From: ${alert.createdByName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(alert.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (alert.expiresAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Expires: ${_formatDateTime(alert.expiresAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Compact Notice Badge - Shows unread count
class NoticeBarBadge extends StatelessWidget {
  const NoticeBarBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final alertService = BroadcastAlertService();

    return FutureBuilder<int>(
      future: alertService.getUnreadAlertCount(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${snapshot.data}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
