import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  premiumSubscription,
  transactionFee,
  emergencyRequest,
  hospitalSubscription,
  verification,
  advertisement,
  advanceBooking, // Added for advance blood booking
}

enum TransactionStatus { pending, completed, failed, refunded }

enum PaymentMethod { bkash, nagad, rocket, card, bankTransfer }

class PaymentTransaction {
  final String id;
  final String userId;
  final String? recipientId; // For transaction fees
  final TransactionType type;
  final TransactionStatus status;
  final PaymentMethod paymentMethod;
  final double amount;
  final String currency;
  final String? transactionId; // From payment gateway
  final String? phoneNumber; // Mobile wallet number
  final String? description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.id,
    required this.userId,
    this.recipientId,
    required this.type,
    required this.status,
    required this.paymentMethod,
    required this.amount,
    this.currency = 'BDT',
    this.transactionId,
    this.phoneNumber,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'recipientId': recipientId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'phoneNumber': phoneNumber,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'metadata': metadata,
    };
  }

  factory PaymentTransaction.fromMap(Map<String, dynamic> map) {
    return PaymentTransaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      recipientId: map['recipientId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => TransactionType.transactionFee,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == map['paymentMethod'],
        orElse: () => PaymentMethod.bkash,
      ),
      amount: (map['amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'BDT',
      transactionId: map['transactionId'],
      phoneNumber: map['phoneNumber'],
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      metadata: map['metadata'],
    );
  }

  PaymentTransaction copyWith({
    String? id,
    String? userId,
    String? recipientId,
    TransactionType? type,
    TransactionStatus? status,
    PaymentMethod? paymentMethod,
    double? amount,
    String? currency,
    String? transactionId,
    String? phoneNumber,
    String? description,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionId: transactionId ?? this.transactionId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
