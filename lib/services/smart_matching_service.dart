import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'blood_compatibility_service.dart';

/// AI-Powered Smart Matching Service
/// Automatically match donors to blood requests with high success rate
class SmartMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final SmartMatchingService _instance =
      SmartMatchingService._internal();
  factory SmartMatchingService() => _instance;
  SmartMatchingService._internal();

  /// Match donors to a blood request with blood compatibility
  Future<List<Map<String, dynamic>>> matchDonorsToRequest({
    required String requestId,
    required String bloodType,
    required double latitude,
    required double longitude,
    required String urgency, // critical, urgent, normal
    int maxResults = 20,
    double maxDistance = 50.0, // Maximum distance in km
  }) async {
    // Get compatible blood types for recipient
    final compatibleBloodTypes = BloodCompatibilityService.getCompatibleDonors(
      bloodType,
    );

    // Query donors with compatible blood types
    final donorsSnapshot = await _firestore
        .collection('users')
        .where(
          'bloodType',
          whereIn: compatibleBloodTypes.isEmpty
              ? [bloodType]
              : compatibleBloodTypes,
        )
        .where('isAvailableToDonate', isEqualTo: true)
        .get();

    final matches = <Map<String, dynamic>>[];

    for (var doc in donorsSnapshot.docs) {
      final donorData = doc.data();
      final donorId = doc.id;

      // Calculate distance first
      final distance = _calculateDistance(
        latitude,
        longitude,
        donorData['latitude'] ?? 0.0,
        donorData['longitude'] ?? 0.0,
      );

      // Skip donors beyond max distance
      if (distance > maxDistance) continue;

      // Calculate blood compatibility score
      final compatibilityScore = BloodCompatibilityService.getPriorityScore(
        donorBloodType: donorData['bloodType'] ?? '',
        recipientBloodType: bloodType,
      );

      // Calculate match score
      final score = await _calculateMatchScore(
        donorId: donorId,
        donorData: donorData,
        requestLatitude: latitude,
        requestLongitude: longitude,
        urgency: urgency,
        compatibilityScore: compatibilityScore,
      );

      matches.add({
        'donorId': donorId,
        'name': donorData['name'],
        'bloodType': donorData['bloodType'],
        'phone': donorData['phone'],
        'location': donorData['district'] ?? 'Unknown',
        'latitude': donorData['latitude'] ?? 0.0,
        'longitude': donorData['longitude'] ?? 0.0,
        'totalDonations': donorData['totalDonations'] ?? 0,
        'lastDonationDate': donorData['lastDonationDate'],
        'score': score,
        'distance': distance,
        'distanceFormatted': '${distance.toStringAsFixed(1)} km',
        'reliability': _calculateReliability(donorData),
        'responseTime': _estimateResponseTime(donorData),
        'compatibilityScore': compatibilityScore,
        'isExactMatch': donorData['bloodType'] == bloodType,
      });
    }

    // Sort by score (highest first) and then by distance (nearest first)
    matches.sort((a, b) {
      final scoreCompare = b['score'].compareTo(a['score']);
      if (scoreCompare != 0) return scoreCompare;
      return (a['distance'] as double).compareTo(b['distance'] as double);
    });

    // Return top matches
    return matches.take(maxResults).toList();
  }

  /// Calculate match score (0-100)
  Future<double> _calculateMatchScore({
    required String donorId,
    required Map<String, dynamic> donorData,
    required double requestLatitude,
    required double requestLongitude,
    required String urgency,
    required int compatibilityScore,
  }) async {
    double score = 0.0;

    // 1. Distance Score (35%) - Higher weight for critical cases
    final distance = _calculateDistance(
      requestLatitude,
      requestLongitude,
      donorData['latitude'] ?? 0.0,
      donorData['longitude'] ?? 0.0,
    );
    final distanceScore = _getDistanceScore(distance);
    score += (distanceScore * 0.35);

    // 2. Blood Compatibility Score (20%)
    score += (compatibilityScore / 100.0) * 20;

    // 3. Availability Score (20%)
    final availabilityScore = _getAvailabilityScore(donorData);
    score += (availabilityScore * 0.20);

    // 4. Reliability Score (15%)
    final reliabilityScore = await _getReliabilityScore(donorId);
    score += (reliabilityScore * 0.15);

    // 5. Response Time Score (10%)
    final responseScore = await _getResponseTimeScore(donorId);
    score += (responseScore * 0.10);

    // Urgency multiplier
    if (urgency == 'critical') {
      // For critical cases, heavily prioritize distance and availability
      score *= 1.3;
      if (distance <= 5.0) score *= 1.2; // Extra boost for very close donors
    } else if (urgency == 'urgent') {
      score *= 1.15;
    }

    return score.clamp(0.0, 100.0);
  }

  /// Distance score (100 = nearest, 0 = farthest)
  double _getDistanceScore(double distanceKm) {
    if (distanceKm <= 2) return 100;
    if (distanceKm <= 5) return 90;
    if (distanceKm <= 10) return 75;
    if (distanceKm <= 20) return 50;
    if (distanceKm <= 30) return 30;
    if (distanceKm <= 50) return 15;
    return 5; // Very far
  }

  /// Availability score
  double _getAvailabilityScore(Map<String, dynamic> donorData) {
    final availability = donorData['availability'] ?? 'available';
    if (availability == 'available') return 100;
    if (availability == 'busy') return 50;
    return 0;
  }

  /// Reliability score (based on past behavior)
  Future<double> _getReliabilityScore(String donorId) async {
    // Get past request responses
    final responsesSnapshot = await _firestore
        .collection('requestResponses')
        .where('donorId', isEqualTo: donorId)
        .limit(10)
        .get();

    if (responsesSnapshot.docs.isEmpty) return 80; // Default for new donors

    int total = responsesSnapshot.docs.length;
    int successful = responsesSnapshot.docs
        .where((doc) => doc.data()['status'] == 'fulfilled')
        .length;

    return (successful / total) * 100;
  }

  /// Eligibility score (can donate now?)
  double _getEligibilityScore(Map<String, dynamic> donorData) {
    final lastDonationDate = donorData['lastDonationDate'] as Timestamp?;
    if (lastDonationDate == null) return 100; // Never donated

    final daysSinceLastDonation = DateTime.now()
        .difference(lastDonationDate.toDate())
        .inDays;

    if (daysSinceLastDonation >= 120) return 100; // Fully eligible
    if (daysSinceLastDonation >= 110) return 80; // Almost eligible
    if (daysSinceLastDonation >= 100) return 60; // Getting close
    return 30; // Not eligible yet but in queue
  }

  /// Response time score (how fast they usually respond)
  Future<double> _getResponseTimeScore(String donorId) async {
    final responsesSnapshot = await _firestore
        .collection('requestResponses')
        .where('donorId', isEqualTo: donorId)
        .orderBy('respondedAt', descending: true)
        .limit(5)
        .get();

    if (responsesSnapshot.docs.isEmpty) return 70; // Default

    int totalMinutes = 0;
    for (var doc in responsesSnapshot.docs) {
      final data = doc.data();
      final requestedAt = (data['requestedAt'] as Timestamp).toDate();
      final respondedAt = (data['respondedAt'] as Timestamp?)?.toDate();
      if (respondedAt != null) {
        totalMinutes += respondedAt.difference(requestedAt).inMinutes;
      }
    }

    final avgResponseMinutes = totalMinutes / responsesSnapshot.docs.length;

    if (avgResponseMinutes <= 15) return 100; // Very fast
    if (avgResponseMinutes <= 30) return 90; // Fast
    if (avgResponseMinutes <= 60) return 75; // Moderate
    if (avgResponseMinutes <= 120) return 50; // Slow
    return 25; // Very slow
  }

  /// Calculate distance between two points (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;

  double _calculateReliability(Map<String, dynamic> donorData) {
    final totalDonations = donorData['totalDonations'] ?? 0;
    if (totalDonations >= 10) return 1.0;
    if (totalDonations >= 5) return 0.9;
    if (totalDonations >= 3) return 0.8;
    if (totalDonations >= 1) return 0.7;
    return 0.6;
  }

  int _estimateResponseTime(Map<String, dynamic> donorData) {
    // Estimate based on availability and past behavior
    final availability = donorData['availability'] ?? 'available';
    if (availability == 'available') return 15; // 15 minutes
    if (availability == 'busy') return 60; // 1 hour
    return 120; // 2 hours
  }

  /// Send invitations to top matches
  Future<void> sendBulkInvitations({
    required String requestId,
    required List<String> donorIds,
    required String bloodType,
    required String hospitalName,
    required String urgency,
  }) async {
    final batch = _firestore.batch();

    for (var donorId in donorIds) {
      // Create notification
      final notifRef = _firestore.collection('notifications').doc();
      batch.set(notifRef, {
        'userId': donorId,
        'type': 'blood_request',
        'title': urgency == 'critical'
            ? '🚨 CRITICAL: $bloodType Needed!'
            : '🩸 $bloodType Blood Needed',
        'message': 'Hospital: $hospitalName\nUrgency: ${urgency.toUpperCase()}',
        'requestId': requestId,
        'priority': urgency == 'critical' ? 'urgent' : 'normal',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Track invitation
      final trackRef = _firestore.collection('requestResponses').doc();
      batch.set(trackRef, {
        'requestId': requestId,
        'donorId': donorId,
        'status': 'invited',
        'invitedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Get matching statistics
  Future<Map<String, dynamic>> getMatchingStats() async {
    final requestsSnapshot = await _firestore
        .collection('bloodRequests')
        .where('status', whereIn: ['approved', 'fulfilled'])
        .get();

    int totalRequests = requestsSnapshot.docs.length;
    int fulfilledRequests = requestsSnapshot.docs
        .where((doc) => doc.data()['status'] == 'fulfilled')
        .length;
    int avgResponseTime = 0;

    if (totalRequests > 0) {
      int totalMinutes = 0;
      for (var doc in requestsSnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'fulfilled') {
          final requestDate = (data['requestDate'] as Timestamp).toDate();
          final fulfilledDate = (data['fulfilledDate'] as Timestamp?)?.toDate();
          if (fulfilledDate != null) {
            totalMinutes += fulfilledDate.difference(requestDate).inMinutes;
          }
        }
      }
      if (fulfilledRequests > 0) {
        avgResponseTime = (totalMinutes / fulfilledRequests).round();
      }
    }

    return {
      'totalRequests': totalRequests,
      'fulfilledRequests': fulfilledRequests,
      'successRate': totalRequests > 0
          ? (fulfilledRequests / totalRequests * 100).round()
          : 0,
      'avgResponseTime': avgResponseTime,
      'avgResponseTimeFormatted': _formatTime(avgResponseTime),
    };
  }

  String _formatTime(int minutes) {
    if (minutes < 60) return '$minutes minutes';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '$hours hours ${mins} minutes';
  }
}
