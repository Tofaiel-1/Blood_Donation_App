import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ActivityType { admin, donation, request, booking, system, user }

enum ActivityStatus { success, failed, pending, completed, cancelled }

class ActivityLog {
  final String id;
  final String action;
  final String description;
  final ActivityType type;
  final ActivityStatus status;
  final String performedBy;
  final String performedByName;
  final String? targetUserId;
  final String? targetUserName;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    required this.action,
    required this.description,
    required this.type,
    required this.status,
    required this.performedBy,
    required this.performedByName,
    this.targetUserId,
    this.targetUserName,
    this.details,
    required this.timestamp,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> data, String id) {
    return ActivityLog(
      id: id,
      action: data['action'] ?? 'Unknown Action',
      description: data['description'] ?? '',
      type: _parseType(data['type']),
      status: _parseStatus(data['status']),
      performedBy: data['performedBy'] ?? '',
      performedByName: data['performedByName'] ?? 'Unknown',
      targetUserId: data['targetUserId'],
      targetUserName: data['targetUserName'],
      details: data['details'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'description': description,
      'type': type.name,
      'status': status.name,
      'performedBy': performedBy,
      'performedByName': performedByName,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'details': details,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  static ActivityType _parseType(dynamic value) {
    if (value == null) return ActivityType.system;
    try {
      return ActivityType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
        orElse: () => ActivityType.system,
      );
    } catch (_) {
      return ActivityType.system;
    }
  }

  static ActivityStatus _parseStatus(dynamic value) {
    if (value == null) return ActivityStatus.success;
    try {
      return ActivityStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
        orElse: () => ActivityStatus.success,
      );
    } catch (_) {
      return ActivityStatus.success;
    }
  }
}

class ActivityLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _logsCollection =>
      _firestore.collection('activityLogs');

  // Log an activity
  Future<void> logActivity({
    required String action,
    required String description,
    required ActivityType type,
    ActivityStatus status = ActivityStatus.success,
    String? targetUserId,
    String? targetUserName,
    Map<String, dynamic>? details,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get user details
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      final log = ActivityLog(
        id: '',
        action: action,
        description: description,
        type: type,
        status: status,
        performedBy: user.uid,
        performedByName: userData?['name'] ?? user.email ?? 'Unknown',
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        details: details,
        timestamp: DateTime.now(),
      );

      await _logsCollection.add(log.toMap());
    } catch (e) {
      print('Failed to log activity: $e');
    }
  }

  // Get activity logs with filters
  Stream<List<ActivityLog>> getActivityLogs({
    ActivityType? type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) {
    Query query = _logsCollection.orderBy('timestamp', descending: true);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (startDate != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    return query
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ActivityLog.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Get activity logs for a specific user
  Stream<List<ActivityLog>> getUserActivityLogs(
    String userId, {
    int limit = 50,
  }) {
    return _logsCollection
        .where('performedBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ActivityLog.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Get activity count by type
  Future<Map<String, int>> getActivityCountByType({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _logsCollection;

    if (startDate != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();

    Map<String, int> counts = {};
    for (var type in ActivityType.values) {
      counts[type.name] = 0;
    }

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final type = data['type']?.toString() ?? 'system';
      counts[type] = (counts[type] ?? 0) + 1;
    }

    return counts;
  }

  // Get activity statistics for dashboard
  Future<Map<String, dynamic>> getActivityStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _logsCollection;

    if (startDate != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();

    int totalActivities = snapshot.docs.length;
    int successCount = 0;
    int failedCount = 0;
    Map<String, int> activitiesByType = {};
    Map<String, int> activitiesByUser = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Count by status
      final status = data['status']?.toString().toLowerCase() ?? 'success';
      if (status == 'success' || status == 'completed') {
        successCount++;
      } else if (status == 'failed' || status == 'cancelled') {
        failedCount++;
      }

      // Count by type
      final type = data['type']?.toString() ?? 'system';
      activitiesByType[type] = (activitiesByType[type] ?? 0) + 1;

      // Count by user
      final userName = data['performedByName']?.toString() ?? 'Unknown';
      activitiesByUser[userName] = (activitiesByUser[userName] ?? 0) + 1;
    }

    return {
      'totalActivities': totalActivities,
      'successCount': successCount,
      'failedCount': failedCount,
      'successRate': totalActivities > 0
          ? (successCount / totalActivities * 100).toStringAsFixed(1)
          : '0',
      'activitiesByType': activitiesByType,
      'activitiesByUser': activitiesByUser,
    };
  }

  // Delete old logs (cleanup)
  Future<void> deleteOldLogs(Duration retention) async {
    final cutoffDate = DateTime.now().subtract(retention);
    final snapshot = await _logsCollection
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Convenience methods for common activities
  Future<void> logAdminAction({
    required String action,
    required String description,
    String? targetUserId,
    String? targetUserName,
    Map<String, dynamic>? details,
  }) {
    return logActivity(
      action: action,
      description: description,
      type: ActivityType.admin,
      targetUserId: targetUserId,
      targetUserName: targetUserName,
      details: details,
    );
  }

  Future<void> logDonation({
    required String donorName,
    required String bloodType,
    required int units,
    required String location,
  }) {
    return logActivity(
      action: 'Blood Donation',
      description: '$donorName donated $bloodType ($units units) at $location',
      type: ActivityType.donation,
      status: ActivityStatus.success,
    );
  }

  Future<void> logRequest({
    required String action,
    required String description,
    ActivityStatus status = ActivityStatus.pending,
  }) {
    return logActivity(
      action: action,
      description: description,
      type: ActivityType.request,
      status: status,
    );
  }

  Future<void> logBooking({
    required String action,
    required String description,
    ActivityStatus status = ActivityStatus.pending,
  }) {
    return logActivity(
      action: action,
      description: description,
      type: ActivityType.booking,
      status: status,
    );
  }

  Future<void> logSystemEvent({
    required String action,
    required String description,
  }) {
    return logActivity(
      action: action,
      description: description,
      type: ActivityType.system,
    );
  }

  Future<void> logUserAction({
    required String action,
    required String description,
    String? targetUserId,
  }) {
    return logActivity(
      action: action,
      description: description,
      type: ActivityType.user,
      targetUserId: targetUserId,
    );
  }
}
