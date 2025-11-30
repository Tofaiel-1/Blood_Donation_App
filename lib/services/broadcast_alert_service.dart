import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/broadcast_alert.dart';

/// Service for managing broadcast alerts (Admin/SuperAdmin only)
class BroadcastAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Create a new broadcast alert (Admin/SuperAdmin only)
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

    final docRef = await _firestore
        .collection('broadcastAlerts')
        .add(alert.toMap());
    return docRef.id;
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
}
