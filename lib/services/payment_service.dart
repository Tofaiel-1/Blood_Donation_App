import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_transaction.dart';
import '../models/premium_subscription.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a payment transaction
  Future<PaymentTransaction> createTransaction({
    required String userId,
    String? recipientId,
    required TransactionType type,
    required PaymentMethod paymentMethod,
    required double amount,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = _firestore.collection('payment_transactions').doc();

      final transaction = PaymentTransaction(
        id: docRef.id,
        userId: userId,
        recipientId: recipientId,
        type: type,
        status: TransactionStatus.pending,
        paymentMethod: paymentMethod,
        amount: amount,
        description: description,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await docRef.set(transaction.toMap());
      return transaction;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Complete a payment transaction
  Future<void> completeTransaction(
    String transactionId,
    String gatewayTransactionId,
  ) async {
    try {
      await _firestore
          .collection('payment_transactions')
          .doc(transactionId)
          .update({
            'status': TransactionStatus.completed.toString().split('.').last,
            'transactionId': gatewayTransactionId,
            'completedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to complete transaction: $e');
    }
  }

  // Fail a transaction
  Future<void> failTransaction(String transactionId, String reason) async {
    try {
      await _firestore
          .collection('payment_transactions')
          .doc(transactionId)
          .update({
            'status': TransactionStatus.failed.toString().split('.').last,
            'metadata.failureReason': reason,
          });
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Get user transactions
  Stream<List<PaymentTransaction>> getUserTransactions(String userId) {
    return _firestore
        .collection('payment_transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentTransaction.fromMap(doc.data()))
              .toList(),
        );
  }

  // bKash Payment Integration (Simulation)
  Future<Map<String, dynamic>> initiateBkashPayment({
    required String transactionId,
    required double amount,
    required String phoneNumber,
  }) async {
    // TODO: Implement actual bKash API integration
    // This is a simulation for now
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // In production, call bKash Grant Token API
      // Then call Create Payment API
      // Return payment URL for user to complete payment

      return {
        'success': true,
        'paymentUrl':
            'https://checkout.sandbox.bka.sh/v1.2.0-beta/checkout/payment/create',
        'bkashTransactionId': 'BKH${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Payment initiated. Please complete payment in bKash app.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to initiate bKash payment: $e',
      };
    }
  }

  // Nagad Payment Integration (Simulation)
  Future<Map<String, dynamic>> initiateNagadPayment({
    required String transactionId,
    required double amount,
    required String phoneNumber,
  }) async {
    // TODO: Implement actual Nagad API integration
    try {
      await Future.delayed(const Duration(seconds: 2));

      return {
        'success': true,
        'paymentUrl':
            'https://api.mynagad.com/remote-payment-gateway-1.0/api/dfs/check-out/initialize',
        'nagadTransactionId': 'NGD${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Payment initiated. Please complete payment in Nagad app.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to initiate Nagad payment: $e',
      };
    }
  }

  // Rocket Payment Integration (Simulation)
  Future<Map<String, dynamic>> initiateRocketPayment({
    required String transactionId,
    required double amount,
    required String phoneNumber,
  }) async {
    // TODO: Implement actual Rocket API integration
    try {
      await Future.delayed(const Duration(seconds: 2));

      return {
        'success': true,
        'paymentUrl': 'https://rocket.com.bd/payment',
        'rocketTransactionId': 'RKT${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Payment initiated. Please complete payment in Rocket app.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to initiate Rocket payment: $e',
      };
    }
  }

  // Process Premium Subscription Payment
  Future<Map<String, dynamic>> processPremiumSubscription({
    required String userId,
    required SubscriptionPlan plan,
    required PaymentMethod paymentMethod,
    required String phoneNumber,
  }) async {
    try {
      final amount = PremiumSubscription.getPlanPrice(plan);

      // Create transaction
      final transaction = await createTransaction(
        userId: userId,
        type: TransactionType.premiumSubscription,
        paymentMethod: paymentMethod,
        amount: amount,
        description:
            'Premium Subscription - ${PremiumSubscription.getPlanName(plan)}',
        metadata: {
          'plan': plan.toString().split('.').last,
          'phoneNumber': phoneNumber,
        },
      );

      // Initiate payment based on method
      Map<String, dynamic> paymentResult;
      switch (paymentMethod) {
        case PaymentMethod.bkash:
          paymentResult = await initiateBkashPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        case PaymentMethod.nagad:
          paymentResult = await initiateNagadPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        case PaymentMethod.rocket:
          paymentResult = await initiateRocketPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        default:
          throw Exception('Payment method not supported');
      }

      return {...paymentResult, 'transactionId': transaction.id};
    } catch (e) {
      return {'success': false, 'message': 'Failed to process payment: $e'};
    }
  }

  // Activate Premium Subscription after successful payment
  Future<void> activatePremiumSubscription({
    required String userId,
    required String transactionId,
    required SubscriptionPlan plan,
  }) async {
    try {
      final now = DateTime.now();
      DateTime endDate;

      switch (plan) {
        case SubscriptionPlan.monthly:
          endDate = now.add(const Duration(days: 30));
          break;
        case SubscriptionPlan.quarterly:
          endDate = now.add(const Duration(days: 90));
          break;
        case SubscriptionPlan.yearly:
          endDate = now.add(const Duration(days: 365));
          break;
        default:
          throw Exception('Invalid subscription plan');
      }

      final subscriptionRef = _firestore
          .collection('premium_subscriptions')
          .doc();

      final subscription = PremiumSubscription(
        id: subscriptionRef.id,
        userId: userId,
        plan: plan,
        amount: PremiumSubscription.getPlanPrice(plan),
        startDate: now,
        endDate: endDate,
        isActive: true,
        paymentTransactionId: transactionId,
        createdAt: now,
      );

      // Save subscription
      await subscriptionRef.set(subscription.toMap());

      // Update user's premium status
      await _firestore.collection('users').doc(userId).update({
        'isPremium': true,
        'premiumPlan': plan.toString().split('.').last,
        'premiumExpiryDate': Timestamp.fromDate(endDate),
      });

      // Complete transaction
      await completeTransaction(
        transactionId,
        'PREMIUM_ACTIVATED_${subscription.id}',
      );
    } catch (e) {
      throw Exception('Failed to activate premium subscription: $e');
    }
  }

  // Process Emergency Request Payment
  Future<Map<String, dynamic>> processEmergencyRequestPayment({
    required String userId,
    required String emergencyRequestId,
    required PaymentMethod paymentMethod,
    required String phoneNumber,
    double amount = 150.0,
  }) async {
    try {
      // Create transaction
      final transaction = await createTransaction(
        userId: userId,
        type: TransactionType.emergencyRequest,
        paymentMethod: paymentMethod,
        amount: amount,
        description: 'Emergency Blood Request',
        metadata: {
          'emergencyRequestId': emergencyRequestId,
          'phoneNumber': phoneNumber,
        },
      );

      // Initiate payment
      Map<String, dynamic> paymentResult;
      switch (paymentMethod) {
        case PaymentMethod.bkash:
          paymentResult = await initiateBkashPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        case PaymentMethod.nagad:
          paymentResult = await initiateNagadPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        case PaymentMethod.rocket:
          paymentResult = await initiateRocketPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        default:
          throw Exception('Payment method not supported');
      }

      return {...paymentResult, 'transactionId': transaction.id};
    } catch (e) {
      return {'success': false, 'message': 'Failed to process payment: $e'};
    }
  }

  // Process Verification Payment
  Future<Map<String, dynamic>> processVerificationPayment({
    required String userId,
    required PaymentMethod paymentMethod,
    required String phoneNumber,
    double amount = 50.0,
  }) async {
    try {
      // Create transaction
      final transaction = await createTransaction(
        userId: userId,
        type: TransactionType.verification,
        paymentMethod: paymentMethod,
        amount: amount,
        description: 'Account Verification',
        metadata: {'phoneNumber': phoneNumber},
      );

      // Initiate payment
      Map<String, dynamic> paymentResult;
      switch (paymentMethod) {
        case PaymentMethod.bkash:
          paymentResult = await initiateBkashPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        case PaymentMethod.nagad:
          paymentResult = await initiateNagadPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        case PaymentMethod.rocket:
          paymentResult = await initiateRocketPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        default:
          throw Exception('Payment method not supported');
      }

      return {...paymentResult, 'transactionId': transaction.id};
    } catch (e) {
      return {'success': false, 'message': 'Failed to process payment: $e'};
    }
  }

  // Verify user after successful payment
  Future<void> verifyUser(String userId, String transactionId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
        'verificationTransactionId': transactionId,
      });

      await completeTransaction(transactionId, 'USER_VERIFIED_$userId');
    } catch (e) {
      throw Exception('Failed to verify user: $e');
    }
  }

  // Process Advance Booking Payment
  Future<Map<String, dynamic>> processAdvanceBookingPayment({
    required String userId,
    required String bookingId,
    required PaymentMethod paymentMethod,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      // Create transaction
      final transaction = await createTransaction(
        userId: userId,
        type: TransactionType.advanceBooking,
        paymentMethod: paymentMethod,
        amount: amount,
        description: 'Advance Blood Booking',
        metadata: {'bookingId': bookingId, 'phoneNumber': phoneNumber},
      );

      // Initiate payment
      Map<String, dynamic> paymentResult;
      switch (paymentMethod) {
        case PaymentMethod.bkash:
          paymentResult = await initiateBkashPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        case PaymentMethod.nagad:
          paymentResult = await initiateNagadPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        case PaymentMethod.rocket:
          paymentResult = await initiateRocketPayment(
            transactionId: transaction.id,
            amount: amount,
            phoneNumber: phoneNumber,
          );
          break;
        default:
          throw Exception('Payment method not supported');
      }

      return {...paymentResult, 'transactionId': transaction.id};
    } catch (e) {
      return {'success': false, 'message': 'Failed to process payment: $e'};
    }
  }

  // Process refund for cancelled bookings
  Future<void> processRefund({
    required String transactionId,
    required double amount,
    required String bookingId,
  }) async {
    try {
      // In production, integrate with payment gateway refund API
      // For now, just mark as refunded in database

      await _firestore.collection('payment_transactions').add({
        'originalTransactionId': transactionId,
        'type': 'refund',
        'amount': amount,
        'status': 'completed',
        'bookingId': bookingId,
        'processedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Log refund activity
      await _firestore.collection('refund_logs').add({
        'transactionId': transactionId,
        'bookingId': bookingId,
        'amount': amount,
        'processedAt': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
    } catch (e) {
      throw Exception('Failed to process refund: $e');
    }
  }

  // Get revenue statistics (for admin)
  Future<Map<String, dynamic>> getRevenueStats({
    DateTime? startDate,
    DateTime? endDate,
    int? daysFilter,
  }) async {
    try {
      // Calculate startDate from daysFilter if provided
      if (daysFilter != null) {
        startDate = DateTime.now().subtract(Duration(days: daysFilter));
      }

      Query query = _firestore.collection('payment_transactions');

      query = query.where(
        'status',
        isEqualTo: TransactionStatus.completed.toString().split('.').last,
      );

      // Apply date filters if provided
      if (startDate != null) {
        query = query.where(
          'completedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'completedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final completedTransactions = await query.get();

      double totalRevenue = 0;
      Map<TransactionType, double> revenueByType = {};
      Map<TransactionType, int> countByType = {};

      for (var doc in completedTransactions.docs) {
        final transaction = PaymentTransaction.fromMap(
          doc.data() as Map<String, dynamic>,
        );
        totalRevenue += transaction.amount;

        revenueByType[transaction.type] =
            (revenueByType[transaction.type] ?? 0) + transaction.amount;
        countByType[transaction.type] =
            (countByType[transaction.type] ?? 0) + 1;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalTransactions': completedTransactions.size,
        'revenueByType': revenueByType.map(
          (k, v) => MapEntry(k.toString().split('.').last, v),
        ),
        'countByType': countByType.map(
          (k, v) => MapEntry(k.toString().split('.').last, v),
        ),
      };
    } catch (e) {
      throw Exception('Failed to get revenue stats: $e');
    }
  }
}
