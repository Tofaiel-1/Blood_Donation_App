import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';

/// Priority levels for alerts
enum AlertPriority { low, normal, high, urgent }

/// Target audience for broadcast alerts
enum AlertTargetAudience { all, donors, admins, byBloodType }

/// Broadcast Alert model
class BroadcastAlert {
  final String id;
  final String title;
  final String message;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final AlertPriority priority;
  final AlertTargetAudience targetAudience;
  final String? specificBloodType;
  final bool isActive;
  final List<String> readBy;

  BroadcastAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.priority,
    required this.targetAudience,
    this.specificBloodType,
    this.isActive = true,
    this.readBy = const [],
  });

  factory BroadcastAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BroadcastAlert(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Admin',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: AlertPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => AlertPriority.normal,
      ),
      targetAudience: AlertTargetAudience.values.firstWhere(
        (e) => e.name == data['targetAudience'],
        orElse: () => AlertTargetAudience.all,
      ),
      specificBloodType: data['specificBloodType'],
      isActive: data['isActive'] ?? true,
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
      'priority': priority.name,
      'targetAudience': targetAudience.name,
      'specificBloodType': specificBloodType,
      'isActive': isActive,
      'readBy': readBy,
    };
  }
}

/// Service for managing notifications and broadcast alerts
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== BROADCAST ALERTS ====================

  /// Send broadcast alert to all users or specific audience
  Future<String> sendBroadcastAlert({
    required String title,
    required String message,
    required AlertPriority priority,
    required AlertTargetAudience targetAudience,
    String? specificBloodType,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      // Get sender info
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final senderName = userDoc.data()?['name'] ?? 'Admin';

      // Create broadcast alert
      final docRef = await _firestore.collection('broadcastAlerts').add({
        'title': title,
        'message': message,
        'senderId': currentUser.uid,
        'senderName': senderName,
        'timestamp': FieldValue.serverTimestamp(),
        'priority': priority.name,
        'targetAudience': targetAudience.name,
        'specificBloodType': specificBloodType,
        'isActive': true,
        'readBy': [], // Track who has read it
      });

      // Get target users based on audience
      List<String> targetUserIds = await _getTargetUsers(
        targetAudience,
        specificBloodType,
      );

      // Create notification for each user
      final batch = _firestore.batch();
      for (String userId in targetUserIds) {
        if (userId == currentUser.uid) continue; // Skip sender

        final notifRef = _firestore.collection('notifications').doc();
        batch.set(notifRef, {
          'userId': userId,
          'alertId': docRef.id,
          'title': title,
          'message': message,
          'priority': priority.name,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'broadcast',
        });
      }
      await batch.commit();

      return docRef.id;
    } catch (e) {
      debugPrint('Error sending broadcast alert: $e');
      rethrow;
    }
  }

  /// Get target users based on audience type
  Future<List<String>> _getTargetUsers(
    AlertTargetAudience audience,
    String? bloodType,
  ) async {
    Query query = _firestore.collection('users');

    switch (audience) {
      case AlertTargetAudience.donors:
        query = query.where('role', isEqualTo: 'user');
        break;
      case AlertTargetAudience.admins:
        query = query.where('role', whereIn: ['orgAdmin', 'superAdmin']);
        break;
      case AlertTargetAudience.byBloodType:
        if (bloodType != null) {
          query = query.where('bloodType', isEqualTo: bloodType);
        }
        break;
      case AlertTargetAudience.all:
        // No filter needed
        break;
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Get all broadcast alerts (for admin view)
  Stream<List<BroadcastAlert>> getBroadcastAlerts() {
    return _firestore
        .collection('broadcastAlerts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BroadcastAlert.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get active alerts for current user
  Stream<List<Map<String, dynamic>>> getUserNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Get unread notification count
  Stream<int> getUnreadNotificationCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Delete old notifications (cleanup)
  Future<void> deleteOldNotifications({int daysOld = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

    final snapshot = await _firestore
        .collection('notifications')
        .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
        .limit(100)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Deactivate a broadcast alert
  Future<void> deactivateAlert(String alertId) async {
    await _firestore.collection('broadcastAlerts').doc(alertId).update({
      'isActive': false,
    });
  }

  // ==================== PERSONAL MESSAGES ====================

  /// Send personal message to a user
  Future<void> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.personal,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not authenticated');

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final senderName = userDoc.data()?['name'] ?? 'User';

      await _firestore.collection('messages').add({
        'senderId': currentUser.uid,
        'senderName': senderName,
        'receiverId': receiverId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': type.name,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  /// Get messages for current user
  Stream<List<Message>> getMessages() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList(),
        );
  }

  /// Get sent messages
  Stream<List<Message>> getSentMessages() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('messages')
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList(),
        );
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'isRead': true,
    });
  }

  // ==================== EMERGENCY ALERTS ====================

  /// Send emergency blood request alert
  Future<void> sendEmergencyAlert({
    required String bloodType,
    required String hospitalName,
    required String location,
    required String contactPhone,
    required String patientName,
  }) async {
    await sendBroadcastAlert(
      title: '🚨 জরুরি রক্তের প্রয়োজন - $bloodType',
      message:
          '''
রোগীর নাম: $patientName
হাসপাতাল: $hospitalName
ঠিকানা: $location
যোগাযোগ: $contactPhone

অনুগ্রহ করে যত দ্রুত সম্ভব যোগাযোগ করুন!
''',
      priority: AlertPriority.urgent,
      targetAudience: AlertTargetAudience.byBloodType,
      specificBloodType: bloodType,
    );
  }
}
