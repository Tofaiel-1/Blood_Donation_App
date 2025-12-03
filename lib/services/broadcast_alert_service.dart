import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/broadcast_alert.dart';

/// Service for managing broadcast alerts (Admin/SuperAdmin only)
class BroadcastAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Create a new broadcast alert (Admin/SuperAdmin only)
  /// Super Admin can broadcast to ALL users (including other admins)
  Future<String> createAlert({
    required String title,
    required String message,
    required AlertType type,
    required AlertTarget target,
    String? targetValue,
    DateTime? expiresAt,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    // Get admin info
    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final userData = userDoc.data();
    final role = userData?['role'] as String?;

    // Check if user is admin or superAdmin
    if (role != 'admin' && role != 'orgAdmin' && role != 'superAdmin') {
      throw Exception('Unauthorized: Only admins can create broadcast alerts');
    }

    // Count total recipients for this alert
    int totalRecipients = await _countTargetRecipients(target, targetValue);

    final alert = BroadcastAlert(
      id: '', // Will be set by Firestore
      title: title,
      message: message,
      type: type,
      target: target,
      targetValue: targetValue,
      createdBy: currentUser.uid,
      createdByName: userData?['name'] ?? 'Admin',
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      isActive: true,
      viewCount: 0,
      viewedBy: [],
    );

    final docRef = await _firestore.collection('broadcastAlerts').add({
      ...alert.toMap(),
      'totalRecipients': totalRecipients,
      'sentToCount': totalRecipients, // For backward compatibility
    });

    return docRef.id;
  }

  /// Count how many users will receive this alert
  Future<int> _countTargetRecipients(
    AlertTarget target,
    String? targetValue,
  ) async {
    Query query = _firestore.collection('users');

    switch (target) {
      case AlertTarget.all:
        // All users
        break;
      case AlertTarget.bloodType:
        if (targetValue != null && targetValue.isNotEmpty) {
          query = query.where('bloodType', isEqualTo: targetValue);
        } else {
          return 0;
        }
        break;
      case AlertTarget.location:
        if (targetValue != null && targetValue.isNotEmpty) {
          // Approximate location matching on address field
          query = query.orderBy('address').startAt([targetValue]).endAt([
            targetValue + '\uf8ff',
          ]);
        } else {
          return 0;
        }
        break;
      case AlertTarget.activeDopers:
        query = query
            .where('availableForDonation', isEqualTo: true)
            .where('isEligibleToDonate', isEqualTo: true);
        break;
    }

    final snapshot = await query.get();
    return snapshot.docs.length;
  }

  /// Get all active alerts for a specific user
  Stream<List<BroadcastAlert>> getAlertsForUser(String userId) {
    return _firestore
        .collection('broadcastAlerts')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final userDoc = await _firestore
              .collection('users')
              .doc(userId)
              .get();
          final userData = userDoc.data();

          if (userData == null) return <BroadcastAlert>[];

          final alerts = snapshot.docs
              .map((doc) => BroadcastAlert.fromFirestore(doc))
              .where(
                (alert) => alert.shouldShowToUser({...userData, 'id': userId}),
              )
              .toList();

          return alerts;
        });
  }

  /// Mark alert as viewed by user
  Future<void> markAsViewed(String alertId, String userId) async {
    await _firestore.collection('broadcastAlerts').doc(alertId).update({
      'viewedBy': FieldValue.arrayUnion([userId]),
      'viewCount': FieldValue.increment(1),
    });
  }

  /// Get all alerts (Admin only - for management)
  Stream<List<BroadcastAlert>> getAllAlerts() {
    return _firestore
        .collection('broadcastAlerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BroadcastAlert.fromFirestore(doc))
              .toList(),
        );
  }

  /// Update alert status
  Future<void> updateAlertStatus(String alertId, bool isActive) async {
    await _firestore.collection('broadcastAlerts').doc(alertId).update({
      'isActive': isActive,
    });
  }

  /// Delete alert
  Future<void> deleteAlert(String alertId) async {
    await _firestore.collection('broadcastAlerts').doc(alertId).delete();
  }

  /// Get unread alert count for user
  Future<int> getUnreadAlertCount(String userId) async {
    final snapshot = await _firestore
        .collection('broadcastAlerts')
        .where('isActive', isEqualTo: true)
        .get();

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    if (userData == null) return 0;

    return snapshot.docs
        .map((doc) => BroadcastAlert.fromFirestore(doc))
        .where((alert) => alert.shouldShowToUser({...userData, 'id': userId}))
        .length;
  }

  /// Get detailed statistics for a specific alert (Super Admin only)
  Future<Map<String, dynamic>> getAlertStatistics(String alertId) async {
    final alertDoc = await _firestore
        .collection('broadcastAlerts')
        .doc(alertId)
        .get();

    if (!alertDoc.exists) {
      throw Exception('Alert not found');
    }

    final alertData = alertDoc.data()!;
    final viewedBy = List<String>.from(alertData['viewedBy'] ?? []);
    final totalRecipients = alertData['totalRecipients'] ?? 0;
    final viewCount = alertData['viewCount'] ?? 0;

    // Get viewer details
    List<Map<String, dynamic>> viewers = [];
    for (String userId in viewedBy) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        viewers.add({
          'userId': userId,
          'name': userData['name'] ?? 'Unknown',
          'email': userData['email'] ?? '',
          'role': userData['role'] ?? 'user',
          'bloodType': userData['bloodType'] ?? '',
        });
      }
    }

    return {
      'alertId': alertId,
      'title': alertData['title'],
      'message': alertData['message'],
      'type': alertData['type'],
      'target': alertData['target'],
      'totalRecipients': totalRecipients,
      'viewCount': viewCount,
      'seenCount': viewedBy.length,
      'unseenCount': totalRecipients - viewedBy.length,
      'viewPercentage': totalRecipients > 0
          ? (viewedBy.length / totalRecipients * 100).toStringAsFixed(1)
          : '0.0',
      'createdBy': alertData['createdByName'] ?? 'Admin',
      'createdAt': (alertData['createdAt'] as Timestamp).toDate(),
      'isActive': alertData['isActive'] ?? true,
      'viewers': viewers,
    };
  }

  /// Get all alerts with basic statistics (Super Admin dashboard)
  Stream<List<Map<String, dynamic>>> getAllAlertsWithStats() {
    return _firestore
        .collection('broadcastAlerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final viewedBy = List<String>.from(data['viewedBy'] ?? []);
            final totalRecipients = data['totalRecipients'] ?? 0;

            return {
              'id': doc.id,
              'title': data['title'],
              'message': data['message'],
              'type': data['type'],
              'target': data['target'],
              'totalRecipients': totalRecipients,
              'seenCount': viewedBy.length,
              'unseenCount': totalRecipients - viewedBy.length,
              'viewPercentage': totalRecipients > 0
                  ? (viewedBy.length / totalRecipients * 100).toStringAsFixed(1)
                  : '0.0',
              'createdBy': data['createdByName'] ?? 'Admin',
              'createdAt': (data['createdAt'] as Timestamp).toDate(),
              'isActive': data['isActive'] ?? true,
            };
          }).toList();
        });
  }

  /// Get list of users who haven't seen a specific alert
  Future<List<Map<String, dynamic>>> getUnseenUsers(String alertId) async {
    final alertDoc = await _firestore
        .collection('broadcastAlerts')
        .doc(alertId)
        .get();

    if (!alertDoc.exists) {
      throw Exception('Alert not found');
    }

    final alertData = alertDoc.data()!;
    final viewedBy = List<String>.from(alertData['viewedBy'] ?? []);
    final targetStr = alertData['target'] as String; // e.g., 'all'
    final targetValue = alertData['targetValue'] as String?;

    // Get all target users
    Query query = _firestore.collection('users');

    final targetEnum = AlertTarget.values.firstWhere(
      (e) => e.toString().split('.').last == targetStr,
      orElse: () => AlertTarget.all,
    );

    switch (targetEnum) {
      case AlertTarget.all:
        // All users
        break;
      case AlertTarget.bloodType:
        if (targetValue != null && targetValue.isNotEmpty) {
          query = query.where('bloodType', isEqualTo: targetValue);
        } else {
          return [];
        }
        break;
      case AlertTarget.location:
        if (targetValue != null && targetValue.isNotEmpty) {
          query = query.orderBy('address').startAt([targetValue]).endAt([
            targetValue + '\uf8ff',
          ]);
        } else {
          return [];
        }
        break;
      case AlertTarget.activeDopers:
        query = query
            .where('availableForDonation', isEqualTo: true)
            .where('isEligibleToDonate', isEqualTo: true);
        break;
    }

    final snapshot = await query.get();

    // Filter out users who have already seen
    final unseenUsers = snapshot.docs
        .where((doc) => !viewedBy.contains(doc.id))
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'userId': doc.id,
            'name': data['name'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'role': data['role'] ?? 'user',
            'bloodType': data['bloodType'] ?? '',
            'phone': data['phone'] ?? '',
          };
        })
        .toList();

    return unseenUsers;
  }
}
