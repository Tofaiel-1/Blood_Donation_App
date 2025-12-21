import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Blood Buddy System Service
/// Match first-time donors with experienced mentors
class BloodBuddyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final BloodBuddyService _instance = BloodBuddyService._internal();
  factory BloodBuddyService() => _instance;
  BloodBuddyService._internal();

  /// Register as a buddy (experienced donor)
  Future<void> registerAsBuddy({
    required String userId,
    required String bloodType,
    required String location,
    required List<String> languages,
    String? specialization, // 'first_timer', 'fear_counseling', etc.
  }) async {
    await _firestore.collection('buddies').doc(userId).set({
      'userId': userId,
      'bloodType': bloodType,
      'location': location,
      'languages': languages,
      'specialization': specialization,
      'totalMentored': 0,
      'successfulReferrals': 0,
      'rating': 5.0,
      'isActive': true,
      'availability': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update user profile
    await _firestore.collection('users').doc(userId).update({
      'isBuddy': true,
      'buddyStatus': 'active',
    });
  }

  /// Find a buddy for first-timer
  Future<Map<String, dynamic>?> findBuddy({
    required String bloodType,
    required String location,
    String? preferredLanguage,
  }) async {
    Query query = _firestore
        .collection('buddies')
        .where('isActive', isEqualTo: true)
        .where('bloodType', isEqualTo: bloodType)
        .where('location', isEqualTo: location);

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      // Fallback: Find any buddy with same blood type
      final fallbackSnapshot = await _firestore
          .collection('buddies')
          .where('isActive', isEqualTo: true)
          .where('bloodType', isEqualTo: bloodType)
          .limit(5)
          .get();

      if (fallbackSnapshot.docs.isNotEmpty) {
        // Return highest rated buddy
        var bestBuddy = fallbackSnapshot.docs.first.data();
        var bestRating = bestBuddy['rating'] ?? 0.0;

        for (var doc in fallbackSnapshot.docs) {
          final data = doc.data();
          final rating = data['rating'] ?? 0.0;
          if (rating > bestRating) {
            bestBuddy = data;
            bestRating = rating;
          }
        }
        return bestBuddy;
      }
      return null;
    }

    // Filter by language if specified
    var matches = snapshot.docs.toList();
    if (preferredLanguage != null) {
      matches = matches.where((doc) {
        final buddyData = doc.data();
        if (buddyData == null) return false;
        final buddy = buddyData as Map<String, dynamic>;
        final languages = buddy['languages'] as List?;
        return languages?.contains(preferredLanguage) ?? false;
      }).toList();
    }

    if (matches.isEmpty) {
      final firstData = snapshot.docs.first.data();
      if (firstData == null) return null;
      return Map<String, dynamic>.from(firstData as Map<String, dynamic>);
    }

    // Return highest rated available buddy
    matches.sort((a, b) {
      final aDataObj = a.data();
      final bDataObj = b.data();
      if (aDataObj == null || bDataObj == null) return 0;
      final aData = aDataObj as Map<String, dynamic>;
      final bData = bDataObj as Map<String, dynamic>;
      final bRating = ((bData['rating'] ?? 0.0) as num);
      final aRating = ((aData['rating'] ?? 0.0) as num);
      return bRating.compareTo(aRating);
    });

    final resultData = matches.first.data();
    if (resultData == null) return null;
    return Map<String, dynamic>.from(resultData as Map<String, dynamic>);
  }

  /// Create buddy relationship
  Future<String> createBuddyRelationship({
    required String newDonorId,
    required String buddyId,
    String? message,
  }) async {
    final docRef = await _firestore.collection('buddyRelationships').add({
      'newDonorId': newDonorId,
      'buddyId': buddyId,
      'status': 'pending', // pending, active, completed, cancelled
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });

    // Notify buddy
    await _firestore.collection('notifications').add({
      'userId': buddyId,
      'type': 'buddy_request',
      'title': 'New Buddy Request!',
      'message': 'A first-time donor needs your help. Accept to mentor them.',
      'relatedId': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    return docRef.id;
  }

  /// Accept buddy request
  Future<void> acceptBuddyRequest(String relationshipId) async {
    await _firestore
        .collection('buddyRelationships')
        .doc(relationshipId)
        .update({
          'status': 'active',
          'acceptedAt': FieldValue.serverTimestamp(),
        });

    // Get relationship details
    final doc = await _firestore
        .collection('buddyRelationships')
        .doc(relationshipId)
        .get();
    final data = doc.data()!;
    final newDonorId = data['newDonorId'];

    // Notify new donor
    await _firestore.collection('notifications').add({
      'userId': newDonorId,
      'type': 'buddy_accepted',
      'title': 'Buddy Accepted! 🎉',
      'message': 'Your buddy has accepted your request. They will guide you!',
      'relatedId': relationshipId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Complete buddy relationship (after successful donation)
  Future<void> completeBuddyRelationship({
    required String relationshipId,
    required bool wasSuccessful,
    double? rating,
    String? feedback,
  }) async {
    await _firestore
        .collection('buddyRelationships')
        .doc(relationshipId)
        .update({
          'status': 'completed',
          'wasSuccessful': wasSuccessful,
          'rating': rating,
          'feedback': feedback,
          'completedAt': FieldValue.serverTimestamp(),
        });

    // Get relationship details
    final doc = await _firestore
        .collection('buddyRelationships')
        .doc(relationshipId)
        .get();
    final data = doc.data()!;
    final buddyId = data['buddyId'];

    // Update buddy stats
    if (wasSuccessful) {
      await _firestore.collection('buddies').doc(buddyId).update({
        'totalMentored': FieldValue.increment(1),
        'successfulReferrals': FieldValue.increment(1),
      });

      // Award buddy bonus (৳50)
      await _firestore.collection('users').doc(buddyId).update({
        'wallet': FieldValue.increment(50),
      });

      // Create transaction record
      await _firestore.collection('transactions').add({
        'userId': buddyId,
        'type': 'buddy_bonus',
        'amount': 50,
        'description': 'Buddy mentorship bonus',
        'relatedId': relationshipId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await _firestore.collection('buddies').doc(buddyId).update({
        'totalMentored': FieldValue.increment(1),
      });
    }

    // Update buddy rating
    if (rating != null) {
      final buddyDoc = await _firestore
          .collection('buddies')
          .doc(buddyId)
          .get();
      final currentRating = buddyDoc.data()?['rating'] ?? 5.0;
      final totalMentored = buddyDoc.data()?['totalMentored'] ?? 1;
      final newRating =
          ((currentRating * (totalMentored - 1)) + rating) / totalMentored;

      await _firestore.collection('buddies').doc(buddyId).update({
        'rating': newRating,
      });
    }
  }

  /// Get buddy leaderboard
  Future<List<Map<String, dynamic>>> getBuddyLeaderboard({
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('buddies')
        .orderBy('successfulReferrals', descending: true)
        .limit(limit)
        .get();

    final leaderboard = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final buddyData = doc.data();
      final userId = buddyData['userId'];

      // Get user details
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      leaderboard.add({
        'buddyId': userId,
        'name': userData?['name'] ?? 'Unknown',
        'bloodType': buddyData['bloodType'],
        'totalMentored': buddyData['totalMentored'] ?? 0,
        'successfulReferrals': buddyData['successfulReferrals'] ?? 0,
        'rating': buddyData['rating'] ?? 5.0,
        'photoURL': userData?['photoURL'],
      });
    }

    return leaderboard;
  }

  /// Get buddy statistics
  Future<Map<String, int>> getBuddyStats() async {
    final buddiesSnapshot = await _firestore.collection('buddies').get();
    final relationshipsSnapshot = await _firestore
        .collection('buddyRelationships')
        .get();

    int activeBuddies = 0;
    int totalMentored = 0;
    int successfulReferrals = 0;

    for (var doc in buddiesSnapshot.docs) {
      final data = doc.data();
      if (data['isActive'] == true) activeBuddies++;
      totalMentored += (data['totalMentored'] ?? 0) as int;
      successfulReferrals += (data['successfulReferrals'] ?? 0) as int;
    }

    final activeRelationships = relationshipsSnapshot.docs
        .where((doc) => doc.data()['status'] == 'active')
        .length;

    return {
      'totalBuddies': buddiesSnapshot.docs.length,
      'activeBuddies': activeBuddies,
      'totalMentored': totalMentored,
      'successfulReferrals': successfulReferrals,
      'activeRelationships': activeRelationships,
      'successRate': totalMentored > 0
          ? ((successfulReferrals / totalMentored) * 100).round()
          : 0,
    };
  }

  /// Get my buddy relationships
  Future<List<Map<String, dynamic>>> getMyRelationships(String userId) async {
    // As buddy
    final asBuddySnapshot = await _firestore
        .collection('buddyRelationships')
        .where('buddyId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    // As new donor
    final asNewDonorSnapshot = await _firestore
        .collection('buddyRelationships')
        .where('newDonorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    final relationships = <Map<String, dynamic>>[];

    for (var doc in [...asBuddySnapshot.docs, ...asNewDonorSnapshot.docs]) {
      final data = doc.data();
      data['id'] = doc.id;
      relationships.add(data);
    }

    return relationships;
  }

  /// Buddy tips and guidelines
  static const List<Map<String, String>> buddyTips = [
    {
      'title': 'Be Friendly',
      'tip': 'Greet warmly and introduce yourself. Make them feel comfortable.',
      'icon': '😊',
    },
    {
      'title': 'Share Your Story',
      'tip':
          'Tell them about your first donation experience. It helps them relate.',
      'icon': '📖',
    },
    {
      'title': 'Answer Questions',
      'tip': 'Be patient with their questions. No question is silly.',
      'icon': '❓',
    },
    {
      'title': 'Accompany Them',
      'tip':
          'Go with them to the donation center if possible. Physical presence helps.',
      'icon': '🚶',
    },
    {
      'title': 'Stay in Touch',
      'tip': 'Check on them 24 hours after donation. Show you care.',
      'icon': '📱',
    },
    {
      'title': 'Celebrate Success',
      'tip':
          'Congratulate them after successful donation. Make them feel proud!',
      'icon': '🎉',
    },
  ];
}
