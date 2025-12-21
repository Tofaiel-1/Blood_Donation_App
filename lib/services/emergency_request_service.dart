import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_request.dart';

class EmergencyRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create emergency request
  Future<EmergencyRequest> createEmergencyRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String bloodGroup,
    String? hospitalName,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    required String urgencyLevel,
    String? message,
    int unitsNeeded = 1,
  }) async {
    try {
      final docRef = _firestore.collection('emergency_requests').doc();

      final request = EmergencyRequest(
        id: docRef.id,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        bloodGroup: bloodGroup,
        hospitalName: hospitalName,
        location: location,
        address: address,
        latitude: latitude,
        longitude: longitude,
        urgencyLevel: urgencyLevel,
        message: message,
        unitsNeeded: unitsNeeded,
        status: EmergencyStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(
          const Duration(hours: 48),
        ), // 48 hours validity
      );

      await docRef.set(request.toMap());
      return request;
    } catch (e) {
      throw Exception('Failed to create emergency request: $e');
    }
  }

  // Activate emergency request after payment
  Future<void> activateEmergencyRequest(
    String requestId,
    String transactionId,
  ) async {
    try {
      await _firestore.collection('emergency_requests').doc(requestId).update({
        'status': EmergencyStatus.active.toString().split('.').last,
        'isPaid': true,
        'paymentTransactionId': transactionId,
      });

      // Get the request to send notifications
      final doc = await _firestore
          .collection('emergency_requests')
          .doc(requestId)
          .get();
      if (doc.exists) {
        final request = EmergencyRequest.fromMap(doc.data()!);
        await _notifyNearbyDonors(request);
      }
    } catch (e) {
      throw Exception('Failed to activate emergency request: $e');
    }
  }

  // Notify nearby donors
  Future<void> _notifyNearbyDonors(EmergencyRequest request) async {
    try {
      // Find donors with matching blood group
      final donorsQuery = await _firestore
          .collection('users')
          .where('bloodType', isEqualTo: request.bloodGroup)
          .where('isEligibleToDonate', isEqualTo: true)
          .limit(100)
          .get();

      List<String> notifiedDonorIds = [];

      for (var doc in donorsQuery.docs) {
        final donorId = doc.id;

        // TODO: Send push notification to donor
        // For now, just mark as notified
        notifiedDonorIds.add(donorId);
      }

      // Update emergency request with notified donors
      await _firestore.collection('emergency_requests').doc(request.id).update({
        'notifiedDonorIds': FieldValue.arrayUnion(notifiedDonorIds),
      });
    } catch (e) {
      print('Error notifying donors: $e');
    }
  }

  // Respond to emergency request
  Future<void> respondToEmergency(String requestId, String donorId) async {
    try {
      await _firestore.collection('emergency_requests').doc(requestId).update({
        'respondedDonorIds': FieldValue.arrayUnion([donorId]),
      });
    } catch (e) {
      throw Exception('Failed to respond to emergency: $e');
    }
  }

  // Mark emergency as fulfilled
  Future<void> fulfillEmergency(String requestId, String donorId) async {
    try {
      await _firestore.collection('emergency_requests').doc(requestId).update({
        'status': EmergencyStatus.fulfilled.toString().split('.').last,
        'fulfilledByDonorId': donorId,
        'fulfilledAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to fulfill emergency: $e');
    }
  }

  // Cancel emergency request
  Future<void> cancelEmergency(String requestId) async {
    try {
      await _firestore.collection('emergency_requests').doc(requestId).update({
        'status': EmergencyStatus.cancelled.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to cancel emergency: $e');
    }
  }

  // Get active emergency requests
  Stream<List<EmergencyRequest>> getActiveEmergencyRequests() {
    return _firestore
        .collection('emergency_requests')
        .where(
          'status',
          isEqualTo: EmergencyStatus.active.toString().split('.').last,
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyRequest.fromMap(doc.data()))
              .where((req) => !req.isExpired)
              .toList(),
        );
  }

  // Get user's emergency requests
  Stream<List<EmergencyRequest>> getUserEmergencyRequests(String userId) {
    return _firestore
        .collection('emergency_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyRequest.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get emergency requests by blood group
  Stream<List<EmergencyRequest>> getEmergencyRequestsByBloodGroup(
    String bloodGroup,
  ) {
    return _firestore
        .collection('emergency_requests')
        .where('bloodGroup', isEqualTo: bloodGroup)
        .where(
          'status',
          isEqualTo: EmergencyStatus.active.toString().split('.').last,
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EmergencyRequest.fromMap(doc.data()))
              .where((req) => !req.isExpired)
              .toList(),
        );
  }
}
