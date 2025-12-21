import 'package:cloud_firestore/cloud_firestore.dart';

enum SubscriptionPlan { free, monthly, quarterly, yearly }

class PremiumSubscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool autoRenew;
  final String? paymentTransactionId;
  final DateTime createdAt;
  final DateTime? cancelledAt;

  PremiumSubscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    this.autoRenew = false,
    this.paymentTransactionId,
    required this.createdAt,
    this.cancelledAt,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  static double getPlanPrice(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.monthly:
        return 100; // 100 BDT per month
      case SubscriptionPlan.quarterly:
        return 250; // 250 BDT for 3 months (save 50 BDT)
      case SubscriptionPlan.yearly:
        return 900; // 900 BDT for 12 months (save 300 BDT)
    }
  }

  static String getPlanName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.monthly:
        return 'Monthly Premium';
      case SubscriptionPlan.quarterly:
        return 'Quarterly Premium';
      case SubscriptionPlan.yearly:
        return 'Yearly Premium';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'plan': plan.toString().split('.').last,
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'autoRenew': autoRenew,
      'paymentTransactionId': paymentTransactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }

  factory PremiumSubscription.fromMap(Map<String, dynamic> map) {
    return PremiumSubscription(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.toString().split('.').last == map['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      amount: (map['amount'] ?? 0).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      autoRenew: map['autoRenew'] ?? false,
      paymentTransactionId: map['paymentTransactionId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      cancelledAt: map['cancelledAt'] != null
          ? (map['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  PremiumSubscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? autoRenew,
    String? paymentTransactionId,
    DateTime? createdAt,
    DateTime? cancelledAt,
  }) {
    return PremiumSubscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      autoRenew: autoRenew ?? this.autoRenew,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }
}
