import 'package:cloud_firestore/cloud_firestore.dart';

/// Universal Donor (O-) Super Rewards System
/// O- donors are the most valuable - they can donate to ANYONE
class UniversalDonorRewardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // O- benefits multipliers
  static const Map<String, dynamic> universalDonorBenefits = {
    'cashBonus': 3.0, // 3x cash (৳150 instead of ৳50)
    'prioritySupport': true, // 24/7 premium support
    'fastTrackVerification': true, // Instant verification (no ৳50 fee)
    'exclusiveBadges': true, // Special O- crown badge 👑
    'emergencyPriority': true, // Get called first for emergencies
    'freeHealthCheckup': true, // Free annual health checkup
    'insuranceDiscount': 20, // 20% discount on health insurance
    'lifetimeRewards': true, // Accumulate lifetime benefits
  };

  /// Check if user is universal donor
  Future<bool> isUniversalDonor(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data()?['bloodType'] == 'O-';
  }

  /// Award super rewards to O- donor
  Future<void> awardUniversalDonorRewards({
    required String donorId,
    required String donationId,
  }) async {
    // Get donor data
    final donorDoc = await _firestore.collection('users').doc(donorId).get();
    final donorData = donorDoc.data()!;
    final bloodType = donorData['bloodType'];

    if (bloodType != 'O-') return; // Only for O-

    final currentWallet = (donorData['wallet'] ?? 0.0).toDouble();
    final lifetimeRewards = (donorData['lifetimeRewards'] ?? 0.0).toDouble();

    // Calculate super bonus
    final superBonus = 150.0; // ৳150 per donation

    // Update donor wallet and lifetime rewards
    await _firestore.collection('users').doc(donorId).update({
      'wallet': currentWallet + superBonus,
      'lifetimeRewards': lifetimeRewards + superBonus,
      'universalDonorStatus': 'active',
      'lastRewardDate': FieldValue.serverTimestamp(),
      'totalSuperRewards': FieldValue.increment(1),
    });

    // Create reward transaction
    await _firestore.collection('rewards').add({
      'donorId': donorId,
      'donationId': donationId,
      'bloodType': bloodType,
      'rewardType': 'universal_donor_bonus',
      'amount': superBonus,
      'description': '🌟 Universal Donor Super Bonus - You saved a life!',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Unlock special benefits
    await _unlockUniversalDonorBenefits(donorId);

    // Send congratulations notification
    await _sendCongratulationsNotification(donorId, superBonus);
  }

  /// Unlock exclusive O- benefits
  Future<void> _unlockUniversalDonorBenefits(String donorId) async {
    await _firestore.collection('users').doc(donorId).update({
      'isPremium': true, // Auto-premium for O-
      'isVerified': true, // Auto-verified
      'emergencyPriority': 1, // Top priority
      'specialBadge': 'universal_hero', // 👑 Universal Hero
      'supportTier': 'vip', // VIP support
      'healthCheckupEligible': true,
    });
  }

  /// Send special congratulations
  Future<void> _sendCongratulationsNotification(
    String donorId,
    double amount,
  ) async {
    await _firestore.collection('notifications').add({
      'userId': donorId,
      'type': 'universal_donor_reward',
      'title': '🌟 Universal Hero Reward!',
      'message':
          '''
আপনি O- Universal Donor! 

✅ ৳${amount.toInt()} Bonus Earned
✅ Premium Membership Unlocked
✅ Priority Emergency Access
✅ Free Health Checkup
✅ VIP Support 24/7

You're a SUPERHERO! 💪🩸
      ''',
      'priority': 'high',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Get O- leaderboard (top universal donors)
  Future<List<Map<String, dynamic>>> getUniversalDonorLeaderboard({
    int limit = 10,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .where('bloodType', isEqualTo: 'O-')
        .orderBy('totalDonations', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
          (doc) => {
            'id': doc.id,
            'name': doc.data()['name'],
            'totalDonations': doc.data()['totalDonations'] ?? 0,
            'lifetimeRewards': doc.data()['lifetimeRewards'] ?? 0.0,
            'photoURL': doc.data()['photoURL'],
          },
        )
        .toList();
  }

  /// Calculate total O- impact
  Future<Map<String, dynamic>> getUniversalDonorImpact(String donorId) async {
    final donorDoc = await _firestore.collection('users').doc(donorId).get();
    final donationsSnapshot = await _firestore
        .collection('donations')
        .where('donorId', isEqualTo: donorId)
        .get();

    final totalDonations = donationsSnapshot.docs.length;
    final potentialLivesSaved =
        totalDonations * 8; // 1 donation = 8 blood types

    return {
      'totalDonations': totalDonations,
      'potentialLivesSaved': potentialLivesSaved,
      'universalHeroStatus': totalDonations >= 10,
      'lifetimeRewards': donorDoc.data()?['lifetimeRewards'] ?? 0.0,
      'description':
          'As O- donor, you can save ALL blood types. You\'re a true Universal Hero!',
    };
  }

  /// Monthly O- appreciation event
  Future<void> monthlyUniversalDonorAppreciation() async {
    // Get all O- donors who donated this month
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));

    final donationsSnapshot = await _firestore
        .collection('donations')
        .where('donationDate', isGreaterThan: Timestamp.fromDate(oneMonthAgo))
        .get();

    final oDonorIds = <String>{};

    for (var doc in donationsSnapshot.docs) {
      final donorId = doc.data()['donorId'];
      final donorDoc = await _firestore.collection('users').doc(donorId).get();
      if (donorDoc.data()?['bloodType'] == 'O-') {
        oDonorIds.add(donorId);
      }
    }

    // Send special appreciation message + bonus
    for (var donorId in oDonorIds) {
      await _firestore.collection('users').doc(donorId).update({
        'wallet': FieldValue.increment(100), // ৳100 monthly bonus
      });

      await _firestore.collection('notifications').add({
        'userId': donorId,
        'type': 'monthly_appreciation',
        'title': '🏆 Universal Hero Monthly Award',
        'message': '''
আপনাকে ধন্যবাদ!

এই মাসে আপনার অবদান অসাধারণ। O- Universal Donor হিসেবে আপনি বাংলাদেশের সবচেয়ে মূল্যবান দাতা।

🎁 ৳100 Appreciation Bonus
👑 Universal Hero Badge
💖 You saved multiple lives this month!
        ''',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// O- emergency matching (priority)
  Future<List<String>> getUniversalDonorsForEmergency({
    required String location,
    required double latitude,
    required double longitude,
    int maxDistance = 10,
  }) async {
    // Get all O- donors
    final donorsSnapshot = await _firestore
        .collection('users')
        .where('bloodType', isEqualTo: 'O-')
        .where('availability', isEqualTo: 'available')
        .get();

    // Filter by distance (you can add location-based query here)
    final nearbyODonors = donorsSnapshot.docs
        .where((doc) {
          // Add distance calculation logic
          return true; // Simplified
        })
        .map((doc) => doc.id)
        .toList();

    return nearbyODonors;
  }

  /// Special O- donor certificate
  Future<String> generateUniversalDonorCertificate(String donorId) async {
    final donorDoc = await _firestore.collection('users').doc(donorId).get();
    final donorData = donorDoc.data()!;

    return '''
╔══════════════════════════════════════╗
║   🩸 UNIVERSAL DONOR CERTIFICATE 👑    ║
╠══════════════════════════════════════╣
║                                      ║
║   ${donorData['name']}                
║   Blood Type: O- (Universal Donor)   ║
║   Total Donations: ${donorData['totalDonations']}        ║
║   Lives Potentially Saved: ${(donorData['totalDonations'] ?? 0) * 8}       ║
║                                      ║
║   This certifies that the above      ║
║   person is a UNIVERSAL BLOOD DONOR  ║
║   and can donate to ALL blood types. ║
║                                      ║
║   You are a TRUE HERO! 💪🩸           ║
║                                      ║
╚══════════════════════════════════════╝

Issued by: PSTU Bloodbank App
Date: ${DateTime.now().toString().split(' ')[0]}
Certificate ID: ${donorId.substring(0, 8).toUpperCase()}
    ''';
  }
}
