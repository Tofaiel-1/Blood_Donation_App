import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Emergency Contact Network Service
/// Build family/workplace/alumni networks for instant blood help
class EmergencyContactNetworkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final EmergencyContactNetworkService _instance =
      EmergencyContactNetworkService._internal();
  factory EmergencyContactNetworkService() => _instance;
  EmergencyContactNetworkService._internal();

  /// Create a network group
  Future<String> createNetwork({
    required String creatorId,
    required String networkName,
    required String
    networkType, // family, workplace, alumni, community, friends
    required String bloodType,
    String? description,
    List<String>? tags,
  }) async {
    final docRef = await _firestore.collection('emergencyNetworks').add({
      'creatorId': creatorId,
      'networkName': networkName,
      'networkType': networkType,
      'bloodType': bloodType,
      'description': description ?? '',
      'tags': tags ?? [],
      'members': [creatorId],
      'memberCount': 1,
      'isActive': true,
      'totalAlerts': 0,
      'successfulHelps': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Join a network
  Future<void> joinNetwork(String networkId, String userId) async {
    await _firestore.collection('emergencyNetworks').doc(networkId).update({
      'members': FieldValue.arrayUnion([userId]),
      'memberCount': FieldValue.increment(1),
    });

    // Notify creator
    final networkDoc = await _firestore
        .collection('emergencyNetworks')
        .doc(networkId)
        .get();
    final creatorId = networkDoc.data()?['creatorId'];

    if (creatorId != null) {
      await _firestore.collection('notifications').add({
        'userId': creatorId,
        'type': 'network_join',
        'title': 'New Network Member!',
        'message': 'Someone joined your emergency network.',
        'networkId': networkId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  /// Leave a network
  Future<void> leaveNetwork(String networkId, String userId) async {
    await _firestore.collection('emergencyNetworks').doc(networkId).update({
      'members': FieldValue.arrayRemove([userId]),
      'memberCount': FieldValue.increment(-1),
    });
  }

  /// Send emergency alert to network
  Future<void> sendEmergencyAlert({
    required String networkId,
    required String senderId,
    required String bloodType,
    required String hospitalName,
    required String hospitalAddress,
    required double latitude,
    required double longitude,
    required String urgency, // critical, urgent
    String? patientName,
    String? contactNumber,
    String? additionalNotes,
  }) async {
    // Create alert
    final alertRef = await _firestore.collection('emergencyAlerts').add({
      'networkId': networkId,
      'senderId': senderId,
      'bloodType': bloodType,
      'hospitalName': hospitalName,
      'hospitalAddress': hospitalAddress,
      'latitude': latitude,
      'longitude': longitude,
      'urgency': urgency,
      'patientName': patientName,
      'contactNumber': contactNumber,
      'additionalNotes': additionalNotes,
      'status': 'active', // active, fulfilled, cancelled
      'respondents': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Get network members
    final networkDoc = await _firestore
        .collection('emergencyNetworks')
        .doc(networkId)
        .get();
    final members = List<String>.from(networkDoc.data()?['members'] ?? []);

    // Send cascade notifications
    await _sendCascadeNotifications(
      members: members,
      alertId: alertRef.id,
      bloodType: bloodType,
      hospitalName: hospitalName,
      urgency: urgency,
      senderId: senderId,
    );

    // Update network stats
    await _firestore.collection('emergencyNetworks').doc(networkId).update({
      'totalAlerts': FieldValue.increment(1),
      'lastAlertAt': FieldValue.serverTimestamp(),
    });
  }

  /// Send cascade notifications (priority to nearby members)
  Future<void> _sendCascadeNotifications({
    required List<String> members,
    required String alertId,
    required String bloodType,
    required String hospitalName,
    required String urgency,
    required String senderId,
  }) async {
    for (var memberId in members) {
      if (memberId == senderId) continue; // Don't notify sender

      await _firestore.collection('notifications').add({
        'userId': memberId,
        'type': 'emergency_alert',
        'title': urgency == 'critical'
            ? '🚨 CRITICAL EMERGENCY!'
            : '⚠️ Emergency Blood Needed',
        'message':
            '$bloodType needed at $hospitalName\nYour network needs you!',
        'alertId': alertId,
        'priority': 'urgent',
        'sound': 'emergency',
        'vibrate': true,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  /// Respond to emergency alert
  Future<void> respondToAlert({
    required String alertId,
    required String responderId,
    required String response, // 'can_help', 'cannot_help', 'on_my_way'
    String? message,
  }) async {
    await _firestore.collection('emergencyAlerts').doc(alertId).update({
      'respondents': FieldValue.arrayUnion([
        {
          'userId': responderId,
          'response': response,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        },
      ]),
    });

    // Notify alert creator
    final alertDoc = await _firestore
        .collection('emergencyAlerts')
        .doc(alertId)
        .get();
    final senderId = alertDoc.data()?['senderId'];

    if (senderId != null && response == 'on_my_way') {
      await _firestore.collection('notifications').add({
        'userId': senderId,
        'type': 'alert_response',
        'title': '🚀 Help is On the Way!',
        'message': 'A network member is coming to help.',
        'alertId': alertId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  /// Mark alert as fulfilled
  Future<void> fulfillAlert(String alertId, String helperId) async {
    await _firestore.collection('emergencyAlerts').doc(alertId).update({
      'status': 'fulfilled',
      'helperId': helperId,
      'fulfilledAt': FieldValue.serverTimestamp(),
    });

    // Update network success stats
    final alertDoc = await _firestore
        .collection('emergencyAlerts')
        .doc(alertId)
        .get();
    final networkId = alertDoc.data()?['networkId'];

    if (networkId != null) {
      await _firestore.collection('emergencyNetworks').doc(networkId).update({
        'successfulHelps': FieldValue.increment(1),
      });
    }

    // Award helper (৳100 bonus)
    await _firestore.collection('users').doc(helperId).update({
      'wallet': FieldValue.increment(100),
    });

    await _firestore.collection('transactions').add({
      'userId': helperId,
      'type': 'emergency_help_bonus',
      'amount': 100,
      'description': 'Emergency network help bonus',
      'relatedId': alertId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Search networks
  Future<List<Map<String, dynamic>>> searchNetworks({
    String? bloodType,
    String? networkType,
    String? location,
  }) async {
    Query query = _firestore
        .collection('emergencyNetworks')
        .where('isActive', isEqualTo: true);

    if (bloodType != null) {
      query = query.where('bloodType', isEqualTo: bloodType);
    }

    if (networkType != null) {
      query = query.where('networkType', isEqualTo: networkType);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Get my networks
  Future<List<Map<String, dynamic>>> getMyNetworks(String userId) async {
    final snapshot = await _firestore
        .collection('emergencyNetworks')
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Get network stats
  Future<Map<String, int>> getNetworkStats() async {
    final networksSnapshot = await _firestore
        .collection('emergencyNetworks')
        .get();
    final alertsSnapshot = await _firestore.collection('emergencyAlerts').get();

    int totalNetworks = networksSnapshot.docs.length;
    int activeNetworks = networksSnapshot.docs
        .where((doc) => doc.data()['isActive'] == true)
        .length;
    int totalMembers = networksSnapshot.docs.fold(
      0,
      (sum, doc) => sum + ((doc.data()['memberCount'] ?? 0) as int),
    );
    int totalAlerts = alertsSnapshot.docs.length;
    int fulfilledAlerts = alertsSnapshot.docs
        .where((doc) => doc.data()['status'] == 'fulfilled')
        .length;

    return {
      'totalNetworks': totalNetworks,
      'activeNetworks': activeNetworks,
      'totalMembers': totalMembers,
      'avgMembersPerNetwork': totalNetworks > 0
          ? (totalMembers / totalNetworks).round()
          : 0,
      'totalAlerts': totalAlerts,
      'fulfilledAlerts': fulfilledAlerts,
      'successRate': totalAlerts > 0
          ? ((fulfilledAlerts / totalAlerts) * 100).round()
          : 0,
    };
  }

  /// Network types
  static const List<Map<String, String>> networkTypes = [
    {
      'type': 'family',
      'name': 'Family Network',
      'icon': '👨‍👩‍👧‍👦',
      'description': 'Connect with family members for blood emergencies',
    },
    {
      'type': 'workplace',
      'name': 'Workplace Network',
      'icon': '🏢',
      'description': 'Colleagues who can help in emergency',
    },
    {
      'type': 'alumni',
      'name': 'Alumni Network',
      'icon': '🎓',
      'description': 'School/college alumni support group',
    },
    {
      'type': 'community',
      'name': 'Community Network',
      'icon': '🏘️',
      'description': 'Neighbors and community members',
    },
    {
      'type': 'friends',
      'name': 'Friends Network',
      'icon': '🤝',
      'description': 'Close friends circle',
    },
    {
      'type': 'religious',
      'name': 'Religious Network',
      'icon': '🕌',
      'description': 'Mosque/temple/church members',
    },
  ];
}
