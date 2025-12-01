import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';

/// Service to sync donation stats (totalDonations and livesSaved)
/// Ensures Firebase data is consistent: 1 completed donation = 1 life saved
class DonationStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  /// Sync user's lives saved count based on completed donations
  /// This ensures 1 donation = 1 life saved
  Future<void> syncLivesSaved(String userId) async {
    try {
      // Get completed donations count
      final donationsSnapshot = await _firestore
          .collection('donations')
          .where('donorId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      final completedDonations = donationsSnapshot.docs.length;

      // Update user document
      await _firestore.collection('users').doc(userId).update({
        'totalDonations': completedDonations,
        'livesSaved': completedDonations, // 1 donation = 1 life saved
      });
    } catch (e) {
      debugPrint('Error syncing lives saved: $e');
    }
  }

  /// Sync lives saved for current logged-in user
  Future<void> syncCurrentUserStats() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await syncLivesSaved(currentUser.uid);
    }
  }

  /// Get user stats from Firebase
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() ?? {};
        return {
          'totalDonations': data['totalDonations'] ?? 0,
          'livesSaved': data['livesSaved'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint('Error getting user stats: $e');
    }

    return {'totalDonations': 0, 'livesSaved': 0};
  }

  /// Batch sync for all users (Admin only - for data migration)
  Future<void> syncAllUsers() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      for (var userDoc in usersSnapshot.docs) {
        await syncLivesSaved(userDoc.id);
      }
    } catch (e) {
      debugPrint('Error syncing all users: $e');
    }
  }
}
