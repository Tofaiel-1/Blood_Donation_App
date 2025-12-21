import 'package:cloud_firestore/cloud_firestore.dart';

/// Rare Blood Group Incentive System
/// Rewards donors with rare blood groups (O-, AB-, A-, B-) with bonus payments
class RareBloodIncentiveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Rare blood group multipliers
  static const Map<String, double> rareBloodMultipliers = {
    'O-': 3.0, // 3x bonus - Universal donor (rarest)
    'AB-': 2.5, // 2.5x bonus - Very rare
    'A-': 2.0, // 2x bonus - Rare
    'B-': 2.0, // 2x bonus - Rare
    'AB+': 1.5, // 1.5x bonus - Universal recipient
    'O+': 1.2, // 1.2x bonus - Most common but high demand
    'A+': 1.0, // Base rate
    'B+': 1.0, // Base rate
  };

  // Base incentive amount for completing donation
  static const double baseDonationIncentive = 50.0; // ৳50 base

  /// Calculate incentive amount based on blood group rarity
  double calculateIncentive(String bloodGroup) {
    final multiplier = rareBloodMultipliers[bloodGroup] ?? 1.0;
    return baseDonationIncentive * multiplier;
  }

  /// Get incentive description
  String getIncentiveDescription(String bloodGroup) {
    final amount = calculateIncentive(bloodGroup);
    final multiplier = rareBloodMultipliers[bloodGroup] ?? 1.0;

    if (multiplier >= 2.5) {
      return 'Extra Rare Blood! Earn ৳${amount.toInt()} per donation 💎';
    } else if (multiplier >= 2.0) {
      return 'Rare Blood! Earn ৳${amount.toInt()} per donation 🌟';
    } else if (multiplier > 1.0) {
      return 'High Demand! Earn ৳${amount.toInt()} per donation ⭐';
    }
    return 'Earn ৳${amount.toInt()} per donation';
  }

  /// Award incentive to donor after successful donation
  Future<void> awardDonationIncentive({
    required String donorId,
    required String donationId,
    required String bloodGroup,
    required String recipientId,
  }) async {
    try {
      final incentiveAmount = calculateIncentive(bloodGroup);

      // Create incentive transaction record
      await _firestore.collection('incentive_transactions').add({
        'donorId': donorId,
        'donationId': donationId,
        'bloodGroup': bloodGroup,
        'amount': incentiveAmount,
        'type': 'donation_incentive',
        'status': 'pending', // pending → approved → paid
        'createdAt': FieldValue.serverTimestamp(),
        'recipientId': recipientId,
        'multiplier': rareBloodMultipliers[bloodGroup] ?? 1.0,
        'description': getIncentiveDescription(bloodGroup),
      });

      // Update donor's total incentives earned
      await _firestore.collection('users').doc(donorId).update({
        'totalIncentivesEarned': FieldValue.increment(incentiveAmount),
        'pendingIncentiveBalance': FieldValue.increment(incentiveAmount),
        'lastIncentiveDate': FieldValue.serverTimestamp(),
      });

      print('✅ Awarded ৳$incentiveAmount incentive to donor $donorId');
    } catch (e) {
      print('❌ Error awarding incentive: $e');
      rethrow;
    }
  }

  /// Get donor's total incentive earnings
  Future<Map<String, dynamic>> getDonorIncentiveStats(String donorId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(donorId).get();
      final userData = userDoc.data() ?? {};

      final transactionsSnapshot = await _firestore
          .collection('incentive_transactions')
          .where('donorId', isEqualTo: donorId)
          .get();

      double totalEarned = 0;
      double pendingBalance = 0;
      double paidOut = 0;
      int totalDonations = 0;

      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0.0) as double;
        final status = data['status'] ?? 'pending';

        totalEarned += amount;
        totalDonations++;

        if (status == 'pending' || status == 'approved') {
          pendingBalance += amount;
        } else if (status == 'paid') {
          paidOut += amount;
        }
      }

      return {
        'totalEarned': totalEarned,
        'pendingBalance': pendingBalance,
        'paidOut': paidOut,
        'totalIncentiveDonations': totalDonations,
        'bloodGroup': userData['bloodType'] ?? 'Unknown',
        'multiplier': rareBloodMultipliers[userData['bloodType']] ?? 1.0,
        'nextDonationIncentive': calculateIncentive(
          userData['bloodType'] ?? 'A+',
        ),
      };
    } catch (e) {
      print('❌ Error getting incentive stats: $e');
      return {};
    }
  }

  /// Request payout (donor can withdraw earned incentives)
  Future<void> requestPayout({
    required String donorId,
    required double amount,
    required String paymentMethod, // bKash, Nagad, Rocket
    required String phoneNumber,
  }) async {
    try {
      // Get pending balance
      final stats = await getDonorIncentiveStats(donorId);
      final pendingBalance = stats['pendingBalance'] ?? 0.0;

      if (amount > pendingBalance) {
        throw Exception('Insufficient balance. Available: ৳$pendingBalance');
      }

      if (amount < 100) {
        throw Exception('Minimum payout amount is ৳100');
      }

      // Create payout request
      await _firestore.collection('payout_requests').add({
        'donorId': donorId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'phoneNumber': phoneNumber,
        'status': 'pending', // pending → processing → completed
        'requestedAt': FieldValue.serverTimestamp(),
        'adminApprovalRequired': true,
      });

      print('✅ Payout request created: ৳$amount to $paymentMethod');
    } catch (e) {
      print('❌ Error requesting payout: $e');
      rethrow;
    }
  }

  /// Admin: Approve payout and process payment
  Future<void> processPayout({
    required String payoutRequestId,
    required String adminId,
  }) async {
    try {
      final payoutDoc = await _firestore
          .collection('payout_requests')
          .doc(payoutRequestId)
          .get();

      if (!payoutDoc.exists) {
        throw Exception('Payout request not found');
      }

      final data = payoutDoc.data()!;
      final donorId = data['donorId'];
      final amount = data['amount'];

      // Update payout status
      await _firestore
          .collection('payout_requests')
          .doc(payoutRequestId)
          .update({
            'status': 'completed',
            'processedAt': FieldValue.serverTimestamp(),
            'processedBy': adminId,
          });

      // Update donor's balance
      await _firestore.collection('users').doc(donorId).update({
        'pendingIncentiveBalance': FieldValue.increment(-amount),
        'totalPaidOut': FieldValue.increment(amount),
      });

      // Mark related transactions as paid
      final transactions = await _firestore
          .collection('incentive_transactions')
          .where('donorId', isEqualTo: donorId)
          .where('status', isEqualTo: 'pending')
          .get();

      double remaining = amount;
      for (var doc in transactions.docs) {
        if (remaining <= 0) break;

        final txAmount = (doc.data()['amount'] ?? 0.0) as double;
        if (txAmount <= remaining) {
          await doc.reference.update({
            'status': 'paid',
            'paidAt': FieldValue.serverTimestamp(),
          });
          remaining -= txAmount;
        }
      }

      print('✅ Payout processed: ৳$amount to donor $donorId');
    } catch (e) {
      print('❌ Error processing payout: $e');
      rethrow;
    }
  }

  /// Get rare blood group badge
  String getRareBloodBadge(String bloodGroup) {
    final multiplier = rareBloodMultipliers[bloodGroup] ?? 1.0;
    if (multiplier >= 2.5) return '💎'; // Diamond - Extra rare
    if (multiplier >= 2.0) return '🌟'; // Star - Rare
    if (multiplier >= 1.5) return '⭐'; // Star - Special
    return '❤️'; // Heart - Normal
  }

  /// Check if blood group is rare
  bool isRareBloodGroup(String bloodGroup) {
    return (rareBloodMultipliers[bloodGroup] ?? 1.0) >= 2.0;
  }
}
