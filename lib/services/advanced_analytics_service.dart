import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Advanced Analytics Service
/// Track donor retention, engagement, and revenue insights
class AdvancedAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final AdvancedAnalyticsService _instance =
      AdvancedAnalyticsService._internal();
  factory AdvancedAnalyticsService() => _instance;
  AdvancedAnalyticsService._internal();

  /// Get donor retention rate
  Future<Map<String, dynamic>> getDonorRetentionRate() async {
    final usersSnapshot = await _firestore.collection('users').get();
    final totalDonors = usersSnapshot.docs.length;

    int activeDonors = 0;
    int inactiveDonors = 0;
    int newDonors = 0;

    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));

    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      final lastDonation = data['lastDonationDate'] as Timestamp?;
      final createdAt = data['createdAt'] as Timestamp?;

      if (lastDonation != null) {
        if (lastDonation.toDate().isAfter(sixMonthsAgo)) {
          activeDonors++;
        } else {
          inactiveDonors++;
        }
      }

      if (createdAt != null && createdAt.toDate().isAfter(sixMonthsAgo)) {
        newDonors++;
      }
    }

    return {
      'totalDonors': totalDonors,
      'activeDonors': activeDonors,
      'inactiveDonors': inactiveDonors,
      'newDonors': newDonors,
      'retentionRate': totalDonors > 0
          ? ((activeDonors / totalDonors) * 100).round()
          : 0,
      'churnRate': totalDonors > 0
          ? ((inactiveDonors / totalDonors) * 100).round()
          : 0,
    };
  }

  /// Get revenue analytics
  Future<Map<String, dynamic>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    startDate ??= DateTime.now().subtract(const Duration(days: 30));
    endDate ??= DateTime.now();

    final transactionsSnapshot = await _firestore
        .collection('transactions')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    double totalRevenue = 0;
    final revenueByType = <String, double>{
      'premium': 0,
      'emergency': 0,
      'verification': 0,
      'hospital': 0,
      'transaction': 0,
      'ads': 0,
    };

    int totalTransactions = transactionsSnapshot.docs.length;

    for (var doc in transactionsSnapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0.0).toDouble();
      final type = data['type'] ?? '';

      totalRevenue += amount;

      if (type.contains('premium')) {
        revenueByType['premium'] = (revenueByType['premium'] ?? 0) + amount;
      } else if (type.contains('emergency')) {
        revenueByType['emergency'] = (revenueByType['emergency'] ?? 0) + amount;
      } else if (type.contains('verification')) {
        revenueByType['verification'] =
            (revenueByType['verification'] ?? 0) + amount;
      } else if (type.contains('hospital')) {
        revenueByType['hospital'] = (revenueByType['hospital'] ?? 0) + amount;
      } else if (type.contains('transaction')) {
        revenueByType['transaction'] =
            (revenueByType['transaction'] ?? 0) + amount;
      } else if (type.contains('ads')) {
        revenueByType['ads'] = (revenueByType['ads'] ?? 0) + amount;
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'revenueByType': revenueByType,
      'totalTransactions': totalTransactions,
      'avgTransactionValue': totalTransactions > 0
          ? (totalRevenue / totalTransactions).round()
          : 0,
      'topRevenueSource': _getTopRevenueSource(revenueByType),
    };
  }

  String _getTopRevenueSource(Map<String, double> revenueByType) {
    var maxRevenue = 0.0;
    var topSource = 'premium';

    for (var entry in revenueByType.entries) {
      if (entry.value > maxRevenue) {
        maxRevenue = entry.value;
        topSource = entry.key;
      }
    }

    return topSource;
  }

  /// Get engagement metrics
  Future<Map<String, dynamic>> getEngagementMetrics() async {
    final usersSnapshot = await _firestore.collection('users').get();
    final requestsSnapshot = await _firestore.collection('bloodRequests').get();
    final donationsSnapshot = await _firestore.collection('donations').get();

    int totalUsers = usersSnapshot.docs.length;
    int premiumUsers = usersSnapshot.docs
        .where((doc) => doc.data()['isPremium'] == true)
        .length;
    int verifiedUsers = usersSnapshot.docs
        .where((doc) => doc.data()['isVerified'] == true)
        .length;

    int totalRequests = requestsSnapshot.docs.length;
    int fulfilledRequests = requestsSnapshot.docs
        .where((doc) => doc.data()['status'] == 'fulfilled')
        .length;

    int totalDonations = donationsSnapshot.docs.length;

    return {
      'totalUsers': totalUsers,
      'premiumUsers': premiumUsers,
      'verifiedUsers': verifiedUsers,
      'premiumConversionRate': totalUsers > 0
          ? ((premiumUsers / totalUsers) * 100).round()
          : 0,
      'verificationRate': totalUsers > 0
          ? ((verifiedUsers / totalUsers) * 100).round()
          : 0,
      'totalRequests': totalRequests,
      'fulfilledRequests': fulfilledRequests,
      'requestFulfillmentRate': totalRequests > 0
          ? ((fulfilledRequests / totalRequests) * 100).round()
          : 0,
      'totalDonations': totalDonations,
      'avgDonationsPerUser': totalUsers > 0
          ? (totalDonations / totalUsers).toStringAsFixed(1)
          : '0.0',
    };
  }

  /// Get blood type demand analysis
  Future<Map<String, dynamic>> getBloodTypeDemand() async {
    final requestsSnapshot = await _firestore.collection('bloodRequests').get();

    final demandByType = <String, int>{};
    final fulfilledByType = <String, int>{};

    for (var doc in requestsSnapshot.docs) {
      final data = doc.data();
      final bloodType = data['bloodType'] ?? '';
      final status = data['status'] ?? '';

      demandByType[bloodType] = (demandByType[bloodType] ?? 0) + 1;

      if (status == 'fulfilled') {
        fulfilledByType[bloodType] = (fulfilledByType[bloodType] ?? 0) + 1;
      }
    }

    // Calculate fulfillment rate by type
    final fulfillmentRateByType = <String, int>{};
    for (var entry in demandByType.entries) {
      final fulfilled = fulfilledByType[entry.key] ?? 0;
      fulfillmentRateByType[entry.key] = ((fulfilled / entry.value) * 100)
          .round();
    }

    return {
      'demandByType': demandByType,
      'fulfilledByType': fulfilledByType,
      'fulfillmentRateByType': fulfillmentRateByType,
      'mostDemanded': _getMostDemanded(demandByType),
      'leastFulfilled': _getLeastFulfilled(fulfillmentRateByType),
    };
  }

  String _getMostDemanded(Map<String, int> demandByType) {
    var maxDemand = 0;
    var mostDemanded = 'O+';

    for (var entry in demandByType.entries) {
      if (entry.value > maxDemand) {
        maxDemand = entry.value;
        mostDemanded = entry.key;
      }
    }

    return mostDemanded;
  }

  String _getLeastFulfilled(Map<String, int> fulfillmentRateByType) {
    var minRate = 100;
    var leastFulfilled = 'AB-';

    for (var entry in fulfillmentRateByType.entries) {
      if (entry.value < minRate) {
        minRate = entry.value;
        leastFulfilled = entry.key;
      }
    }

    return leastFulfilled;
  }

  /// Get user growth trend (last 12 months)
  Future<List<Map<String, dynamic>>> getUserGrowthTrend() async {
    final now = DateTime.now();
    final trend = <Map<String, dynamic>>[];

    for (int i = 11; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 1);

      final snapshot = await _firestore
          .collection('users')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(monthEnd))
          .get();

      trend.add({
        'month': _getMonthName(monthStart.month),
        'year': monthStart.year,
        'newUsers': snapshot.docs.length,
      });
    }

    return trend;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Get donation trends
  Future<List<Map<String, dynamic>>> getDonationTrends({int months = 6}) async {
    final now = DateTime.now();
    final trends = <Map<String, dynamic>>[];

    for (int i = months - 1; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 1);

      final snapshot = await _firestore
          .collection('donations')
          .where(
            'donationDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
          )
          .where('donationDate', isLessThan: Timestamp.fromDate(monthEnd))
          .get();

      trends.add({
        'month': _getMonthName(monthStart.month),
        'year': monthStart.year,
        'totalDonations': snapshot.docs.length,
      });
    }

    return trends;
  }

  /// Get comprehensive dashboard data
  Future<Map<String, dynamic>> getComprehensiveDashboard() async {
    final retention = await getDonorRetentionRate();
    final revenue = await getRevenueAnalytics();
    final engagement = await getEngagementMetrics();
    final bloodDemand = await getBloodTypeDemand();

    return {
      'retention': retention,
      'revenue': revenue,
      'engagement': engagement,
      'bloodDemand': bloodDemand,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Get real-time statistics
  Future<Map<String, int>> getRealTimeStats() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final usersSnapshot = await _firestore.collection('users').get();
    final requestsSnapshot = await _firestore
        .collection('bloodRequests')
        .where(
          'requestDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
        )
        .get();
    final donationsSnapshot = await _firestore
        .collection('donations')
        .where(
          'donationDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
        )
        .get();

    return {
      'totalUsers': usersSnapshot.docs.length,
      'todayRequests': requestsSnapshot.docs.length,
      'todayDonations': donationsSnapshot.docs.length,
      'activeRequests':
          (await _firestore
                  .collection('bloodRequests')
                  .where('status', isEqualTo: 'approved')
                  .get())
              .docs
              .length,
    };
  }
}
