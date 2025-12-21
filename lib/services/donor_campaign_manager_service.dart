import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Donor Campaign Manager Service
/// Create and manage blood donation campaigns
class DonorCampaignManagerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final DonorCampaignManagerService _instance =
      DonorCampaignManagerService._internal();
  factory DonorCampaignManagerService() => _instance;
  DonorCampaignManagerService._internal();

  /// Create a campaign
  Future<String> createCampaign({
    required String organizerId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    required double latitude,
    required double longitude,
    required List<String> targetBloodTypes,
    required int targetDonations,
    String? venue,
    String? contactNumber,
    List<String>? incentives,
    String? bannerUrl,
  }) async {
    final docRef = await _firestore.collection('campaigns').add({
      'organizerId': organizerId,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'venue': venue,
      'contactNumber': contactNumber,
      'targetBloodTypes': targetBloodTypes,
      'targetDonations': targetDonations,
      'currentDonations': 0,
      'incentives': incentives ?? [],
      'bannerUrl': bannerUrl,
      'registrations': [],
      'registrationCount': 0,
      'status': 'upcoming', // upcoming, active, completed, cancelled
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify relevant donors
    await _notifyRelevantDonors(
      campaignId: docRef.id,
      bloodTypes: targetBloodTypes,
      location: location,
      title: title,
    );

    return docRef.id;
  }

  /// Notify relevant donors
  Future<void> _notifyRelevantDonors({
    required String campaignId,
    required List<String> bloodTypes,
    required String location,
    required String title,
  }) async {
    for (var bloodType in bloodTypes) {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('bloodType', isEqualTo: bloodType)
          .where('district', isEqualTo: location)
          .where('isAvailableToDonate', isEqualTo: true)
          .limit(100)
          .get();

      final batch = _firestore.batch();

      for (var doc in usersSnapshot.docs) {
        final notifRef = _firestore.collection('notifications').doc();
        batch.set(notifRef, {
          'userId': doc.id,
          'type': 'campaign',
          'title': '📢 New Campaign: $title',
          'message': 'A blood donation campaign is happening near you!',
          'campaignId': campaignId,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      await batch.commit();
    }
  }

  /// Register for campaign
  Future<void> registerForCampaign(String campaignId, String userId) async {
    await _firestore.collection('campaigns').doc(campaignId).update({
      'registrations': FieldValue.arrayUnion([userId]),
      'registrationCount': FieldValue.increment(1),
    });

    // Send confirmation
    await _firestore.collection('notifications').add({
      'userId': userId,
      'type': 'campaign_registered',
      'title': '✅ Registration Confirmed',
      'message': 'You are registered for the campaign. See you there!',
      'campaignId': campaignId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Record donation at campaign
  Future<void> recordCampaignDonation({
    required String campaignId,
    required String donorId,
    required String bloodType,
  }) async {
    // Update campaign stats
    await _firestore.collection('campaigns').doc(campaignId).update({
      'currentDonations': FieldValue.increment(1),
    });

    // Create donation record
    await _firestore.collection('campaignDonations').add({
      'campaignId': campaignId,
      'donorId': donorId,
      'bloodType': bloodType,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Award donor (campaign bonus ৳75)
    await _firestore.collection('users').doc(donorId).update({
      'wallet': FieldValue.increment(75),
      'totalDonations': FieldValue.increment(1),
      'lastDonationDate': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('transactions').add({
      'userId': donorId,
      'type': 'campaign_donation_bonus',
      'amount': 75,
      'description': 'Campaign donation bonus',
      'relatedId': campaignId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Check if target reached
    final campaignDoc = await _firestore
        .collection('campaigns')
        .doc(campaignId)
        .get();
    final currentDonations = campaignDoc.data()?['currentDonations'] ?? 0;
    final targetDonations = campaignDoc.data()?['targetDonations'] ?? 0;

    if (currentDonations >= targetDonations) {
      await _firestore.collection('campaigns').doc(campaignId).update({
        'status': 'target_reached',
      });
    }
  }

  /// Get active campaigns
  Future<List<Map<String, dynamic>>> getActiveCampaigns({
    String? bloodType,
    String? location,
  }) async {
    Query query = _firestore
        .collection('campaigns')
        .where('status', whereIn: ['upcoming', 'active']);

    if (bloodType != null) {
      query = query.where('targetBloodTypes', arrayContains: bloodType);
    }

    if (location != null) {
      query = query.where('location', isEqualTo: location);
    }

    final snapshot = await query.orderBy('startDate').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Get campaign details
  Future<Map<String, dynamic>?> getCampaignDetails(String campaignId) async {
    final doc = await _firestore.collection('campaigns').doc(campaignId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;

      // Calculate progress
      final current = data['currentDonations'] ?? 0;
      final target = data['targetDonations'] ?? 1;
      data['progress'] = (current / target * 100).clamp(0, 100).toInt();

      return data;
    }
    return null;
  }

  /// Get campaign statistics
  Future<Map<String, dynamic>> getCampaignStats(String campaignId) async {
    final campaignDoc = await _firestore
        .collection('campaigns')
        .doc(campaignId)
        .get();
    final campaignData = campaignDoc.data()!;

    final donationsSnapshot = await _firestore
        .collection('campaignDonations')
        .where('campaignId', isEqualTo: campaignId)
        .get();

    final bloodTypeCount = <String, int>{};
    for (var doc in donationsSnapshot.docs) {
      final bloodType = doc.data()['bloodType'] ?? '';
      bloodTypeCount[bloodType] = (bloodTypeCount[bloodType] ?? 0) + 1;
    }

    return {
      'totalDonations': campaignData['currentDonations'] ?? 0,
      'targetDonations': campaignData['targetDonations'] ?? 0,
      'registrations': campaignData['registrationCount'] ?? 0,
      'progress':
          ((campaignData['currentDonations'] ?? 0) /
                  (campaignData['targetDonations'] ?? 1) *
                  100)
              .clamp(0, 100)
              .toInt(),
      'bloodTypeBreakdown': bloodTypeCount,
    };
  }

  /// Send campaign reminder (1 day before)
  Future<void> sendCampaignReminders() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final tomorrowEnd = tomorrowStart.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('campaigns')
        .where(
          'startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(tomorrowStart),
        )
        .where('startDate', isLessThan: Timestamp.fromDate(tomorrowEnd))
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final registrations = List<String>.from(data['registrations'] ?? []);

      final batch = _firestore.batch();

      for (var userId in registrations) {
        final notifRef = _firestore.collection('notifications').doc();
        batch.set(notifRef, {
          'userId': userId,
          'type': 'campaign_reminder',
          'title': '⏰ Campaign Tomorrow!',
          'message': 'Don\'t forget: ${data['title']} is tomorrow!',
          'campaignId': doc.id,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }

      await batch.commit();
    }
  }

  /// Get campaign leaderboard (top campaigns by donations)
  Future<List<Map<String, dynamic>>> getCampaignLeaderboard({
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('campaigns')
        .where('status', isEqualTo: 'completed')
        .orderBy('currentDonations', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Cancel campaign
  Future<void> cancelCampaign(String campaignId, String reason) async {
    await _firestore.collection('campaigns').doc(campaignId).update({
      'status': 'cancelled',
      'cancellationReason': reason,
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    // Notify registered users
    final campaignDoc = await _firestore
        .collection('campaigns')
        .doc(campaignId)
        .get();
    final registrations = List<String>.from(
      campaignDoc.data()?['registrations'] ?? [],
    );

    for (var userId in registrations) {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'campaign_cancelled',
        'title': '❌ Campaign Cancelled',
        'message': 'The campaign has been cancelled. Reason: $reason',
        'campaignId': campaignId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  /// Get my campaigns (as organizer)
  Future<List<Map<String, dynamic>>> getMyCampaigns(String organizerId) async {
    final snapshot = await _firestore
        .collection('campaigns')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Get overall campaign statistics
  Future<Map<String, dynamic>> getOverallStats() async {
    final campaignsSnapshot = await _firestore.collection('campaigns').get();

    int totalCampaigns = campaignsSnapshot.docs.length;
    int activeCampaigns = campaignsSnapshot.docs
        .where((doc) => doc.data()['status'] == 'active')
        .length;
    int completedCampaigns = campaignsSnapshot.docs
        .where((doc) => doc.data()['status'] == 'completed')
        .length;
    int totalDonations = campaignsSnapshot.docs.fold(
      0,
      (sum, doc) => sum + ((doc.data()['currentDonations'] ?? 0) as int),
    );
    int totalRegistrations = campaignsSnapshot.docs.fold(
      0,
      (sum, doc) => sum + ((doc.data()['registrationCount'] ?? 0) as int),
    );

    return {
      'totalCampaigns': totalCampaigns,
      'activeCampaigns': activeCampaigns,
      'completedCampaigns': completedCampaigns,
      'totalDonations': totalDonations,
      'totalRegistrations': totalRegistrations,
      'avgDonationsPerCampaign': completedCampaigns > 0
          ? (totalDonations / completedCampaigns).round()
          : 0,
    };
  }
}
