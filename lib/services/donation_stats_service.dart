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

      int fixedCount = 0;
      for (var userDoc in usersSnapshot.docs) {
        await syncLivesSaved(userDoc.id);
        fixedCount++;
      }

      debugPrint('✅ Synced $fixedCount users');
    } catch (e) {
      debugPrint('Error syncing all users: $e');
    }
  }

  /// Fix all users where livesSaved is 0 but totalDonations > 0
  Future<int> fixMismatchedLivesSaved() async {
    int fixedCount = 0;
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      for (var userDoc in usersSnapshot.docs) {
        final data = userDoc.data();
        final totalDonations = data['totalDonations'] ?? 0;
        final livesSaved = data['livesSaved'] ?? 0;

        // If mismatch found, fix it
        if (totalDonations > 0 && livesSaved == 0) {
          await _firestore.collection('users').doc(userDoc.id).update({
            'livesSaved': totalDonations,
          });
          fixedCount++;
          debugPrint(
            'Fixed user ${userDoc.id}: $totalDonations donations → $totalDonations lives saved',
          );
        }
      }

      debugPrint('✅ Fixed $fixedCount users with mismatched livesSaved');
    } catch (e) {
      debugPrint('Error fixing mismatched lives saved: $e');
    }
    return fixedCount;
  }

  /// Increment global donation statistics
  /// Called whenever a donation is added to the system
  Future<void> incrementGlobalStats() async {
    try {
      final globalStatsRef = _firestore
          .collection('globalStats')
          .doc('donations');

      await globalStatsRef.set({
        'totalDonations': FieldValue.increment(1),
        'totalLivesSaved': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Global stats incremented');
    } catch (e) {
      debugPrint('Error incrementing global stats: $e');
    }
  }

  /// Get global donation statistics
  Future<Map<String, int>> getGlobalStats() async {
    try {
      final globalStatsDoc = await _firestore
          .collection('globalStats')
          .doc('donations')
          .get();

      if (globalStatsDoc.exists) {
        final data = globalStatsDoc.data() ?? {};
        return {
          'totalDonations': data['totalDonations'] ?? 0,
          'totalLivesSaved': data['totalLivesSaved'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint('Error getting global stats: $e');
    }

    return {'totalDonations': 0, 'totalLivesSaved': 0};
  }

  /// Recalculate global stats from all donations (Admin utility)
  Future<void> recalculateGlobalStats() async {
    try {
      final donationsSnapshot = await _firestore
          .collection('donations')
          .where('status', isEqualTo: 'completed')
          .get();

      final totalCount = donationsSnapshot.docs.length;

      await _firestore.collection('globalStats').doc('donations').set({
        'totalDonations': totalCount,
        'totalLivesSaved': totalCount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Global stats recalculated: $totalCount donations');
    } catch (e) {
      debugPrint('Error recalculating global stats: $e');
    }
  }
}
