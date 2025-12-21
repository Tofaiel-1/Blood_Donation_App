import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/advance_booking.dart';
import '../models/user.dart' as app_user;
import 'notification_service.dart';
import 'payment_service.dart';
import 'activity_log_service.dart';

class AdvanceBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ActivityLogService _activityLog = ActivityLogService();

  // Collection reference
  CollectionReference get _bookingsCollection =>
      _firestore.collection('advance_bookings');

  // Pricing Configuration (Can be updated from admin panel)
  static const double BASE_PRICE_PER_UNIT = 300.0; // ৳300 per unit
  static const double PLATFORM_FEE_PERCENTAGE = 0.15; // 15% commission

  // Create a new advance booking
  Future<String> createBooking({
    required String patientName,
    required String patientAge,
    required String patientGender,
    required String patientBloodGroup,
    required String patientCondition,
    required String hospitalName,
    required String hospitalAddress,
    required String division,
    required String district,
    required String upazila,
    double? latitude,
    double? longitude,
    required int unitsRequired,
    required DateTime requiredDate,
    required BookingPriority priority,
    String? specialInstructions,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get user details
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = app_user.User.fromMap(userDoc.data()!);

      // Calculate pricing
      final bookingAmount = BASE_PRICE_PER_UNIT * unitsRequired;
      final priorityCharge = AdvanceBloodBooking.calculatePriorityCharge(
        priority,
        requiredDate,
      );
      final platformFee = bookingAmount * PLATFORM_FEE_PERCENTAGE;
      final totalAmount = bookingAmount + priorityCharge + platformFee;

      // Create booking object
      final booking = AdvanceBloodBooking(
        id: '',
        userId: user.uid,
        userName: userData.name,
        userPhone: userData.phone ?? '',
        bloodGroup: patientBloodGroup,
        patientName: patientName,
        patientAge: patientAge,
        patientGender: patientGender,
        patientBloodGroup: patientBloodGroup,
        patientCondition: patientCondition,
        hospitalName: hospitalName,
        hospitalAddress: hospitalAddress,
        division: division,
        district: district,
        upazila: upazila,
        latitude: latitude,
        longitude: longitude,
        unitsRequired: unitsRequired,
        requiredDate: requiredDate,
        priority: priority,
        status: BookingStatus.pending,
        bookingAmount: bookingAmount,
        priorityCharge: priorityCharge,
        platformFee: platformFee,
        totalAmount: totalAmount,
        isPaid: false,
        specialInstructions: specialInstructions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final docRef = await _bookingsCollection.add(booking.toMap());

      // Log activity
      await _activityLog.logBooking(
        action: 'Advance Booking Created',
        description:
            '$patientName ($patientBloodGroup) booked $unitsRequired units at $hospitalName',
        status: ActivityStatus.pending,
      );

      // Return booking ID for payment
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update booking after payment
  Future<void> confirmPayment({
    required String bookingId,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'isPaid': true,
        'status': BookingStatus.confirmed.toString().split('.').last,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId,
        'paidAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Log activity
      await _activityLog.logBooking(
        action: 'Booking Payment Confirmed',
        description: 'Payment confirmed for booking ID: $bookingId',
        status: ActivityStatus.success,
      );

      // Start processing - find donors
      await _startFindingDonors(bookingId);
    } catch (e) {
      throw Exception('Failed to confirm payment: $e');
    }
  }

  // Find and notify eligible donors
  Future<void> _startFindingDonors(String bookingId) async {
    try {
      final bookingDoc = await _bookingsCollection.doc(bookingId).get();
      final booking = AdvanceBloodBooking.fromMap(
        bookingDoc.data() as Map<String, dynamic>,
        bookingDoc.id,
      );

      // Update status to processing
      await _bookingsCollection.doc(bookingId).update({
        'status': BookingStatus.processing.toString().split('.').last,
        'updatedAt': Timestamp.now(),
      });

      // Find eligible donors
      final donorsQuery = await _firestore
          .collection('users')
          .where('bloodGroup', isEqualTo: booking.bloodGroup)
          .where('isAvailable', isEqualTo: true)
          .where('district', isEqualTo: booking.district)
          .limit(50)
          .get();

      List<String> notifiedDonorIds = [];

      // Send notifications to donors
      for (var donorDoc in donorsQuery.docs) {
        final donor = app_user.User.fromMap(donorDoc.data());

        // Check if donor can donate (last donation > 3 months ago)
        if (_canDonate(donor)) {
          // Send notification to donor
          try {
            await NotificationService().sendEmergencyAlert(
              bloodType: booking.bloodGroup,
              hospitalName: booking.hospitalName,
              location: booking.district,
              contactPhone: booking.userPhone,
              patientName: booking.patientName,
            );
          } catch (e) {
            print('Failed to send notification: $e');
          }
          notifiedDonorIds.add(donor.email);
        }
      }

      // Update booking with notified donors
      await _bookingsCollection.doc(bookingId).update({
        'notifiedDonorIds': notifiedDonorIds,
        'notificationsSent': notifiedDonorIds.length,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error finding donors: $e');
    }
  }

  // Check if donor can donate
  bool _canDonate(app_user.User donor) {
    if (donor.lastDonationDate == null) return true;

    final daysSinceLastDonation = DateTime.now()
        .difference(donor.lastDonationDate!)
        .inDays;

    return daysSinceLastDonation >= 90; // 3 months
  }

  // Donor accepts booking
  Future<void> acceptBooking({
    required String bookingId,
    required String donorId,
  }) async {
    try {
      // Get donor details
      final donorDoc = await _firestore.collection('users').doc(donorId).get();
      final donor = app_user.User.fromMap(donorDoc.data()!);

      // Update booking with donor match
      await _bookingsCollection.doc(bookingId).update({
        'status': BookingStatus.matched.toString().split('.').last,
        'matchedDonorId': donorId,
        'matchedDonorName': donor.name,
        'matchedDonorPhone': donor.phone ?? '',
        'matchedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Notify the user who booked
      final bookingDoc = await _bookingsCollection.doc(bookingId).get();
      final booking = AdvanceBloodBooking.fromMap(
        bookingDoc.data() as Map<String, dynamic>,
        bookingDoc.id,
      );

      // Notification would be sent here
      // For now, just log it
      print('Donor matched: ${donor.name} for booking $bookingId');
    } catch (e) {
      throw Exception('Failed to accept booking: $e');
    }
  }

  // Mark booking as completed
  Future<void> completeBooking(String bookingId) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'status': BookingStatus.completed.toString().split('.').last,
        'completedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Update donor's last donation date
      final bookingDoc = await _bookingsCollection.doc(bookingId).get();
      final booking = AdvanceBloodBooking.fromMap(
        bookingDoc.data() as Map<String, dynamic>,
        bookingDoc.id,
      );

      if (booking.matchedDonorId != null) {
        await _firestore
            .collection('users')
            .doc(booking.matchedDonorId)
            .update({
              'lastDonationDate': Timestamp.now(),
              'donationCount': FieldValue.increment(booking.unitsRequired),
            });

        // Log activity
        await _activityLog.logBooking(
          action: 'Booking Completed',
          description:
              'Booking completed: ${booking.patientName} received ${booking.unitsRequired} units',
          status: ActivityStatus.completed,
        );
      }
    } catch (e) {
      throw Exception('Failed to complete booking: $e');
    }
  }

  // Cancel booking
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
    bool refund = false,
  }) async {
    try {
      final updates = {
        'status': BookingStatus.cancelled.toString().split('.').last,
        'cancelledAt': Timestamp.now(),
        'cancellationReason': reason,
        'updatedAt': Timestamp.now(),
      };

      if (refund) {
        updates['status'] = BookingStatus.refunded.toString().split('.').last;
      }

      await _bookingsCollection.doc(bookingId).update(updates);

      // Process refund if needed
      if (refund) {
        await _processRefund(bookingId);
      }
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  // Process refund
  Future<void> _processRefund(String bookingId) async {
    try {
      final bookingDoc = await _bookingsCollection.doc(bookingId).get();
      final booking = AdvanceBloodBooking.fromMap(
        bookingDoc.data() as Map<String, dynamic>,
        bookingDoc.id,
      );

      // Initiate refund through payment gateway
      // This will be implemented based on payment gateway
      await PaymentService().processRefund(
        transactionId: booking.transactionId!,
        amount: booking.totalAmount,
        bookingId: bookingId,
      );
    } catch (e) {
      print('Refund processing error: $e');
    }
  }

  // Get user's bookings
  Stream<List<AdvanceBloodBooking>> getUserBookings(String userId) {
    return _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AdvanceBloodBooking.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Get all bookings (admin)
  Stream<List<AdvanceBloodBooking>> getAllBookings({
    BookingStatus? status,
    String? bloodGroup,
    String? district,
  }) {
    Query query = _bookingsCollection;

    if (status != null) {
      query = query.where(
        'status',
        isEqualTo: status.toString().split('.').last,
      );
    }
    if (bloodGroup != null) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }
    if (district != null) {
      query = query.where('district', isEqualTo: district);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AdvanceBloodBooking.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  // Get booking by ID
  Future<AdvanceBloodBooking> getBookingById(String bookingId) async {
    try {
      final doc = await _bookingsCollection.doc(bookingId).get();
      if (!doc.exists) throw Exception('Booking not found');

      return AdvanceBloodBooking.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      throw Exception('Failed to get booking: $e');
    }
  }

  // Get income statistics (for admin dashboard)
  Future<Map<String, dynamic>> getIncomeStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _bookingsCollection.where('isPaid', isEqualTo: true);

      if (startDate != null) {
        query = query.where(
          'paidAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'paidAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();

      double totalRevenue = 0;
      double totalPlatformFees = 0;
      double totalPriorityCharges = 0;
      int totalBookings = snapshot.docs.length;
      int completedBookings = 0;
      int cancelledBookings = 0;

      Map<String, int> bookingsByBloodGroup = {};
      Map<String, double> revenueByDistrict = {};

      for (var doc in snapshot.docs) {
        final booking = AdvanceBloodBooking.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );

        totalRevenue += booking.totalAmount;
        totalPlatformFees += booking.platformFee;
        totalPriorityCharges += booking.priorityCharge;

        if (booking.status == BookingStatus.completed) completedBookings++;
        if (booking.status == BookingStatus.cancelled ||
            booking.status == BookingStatus.refunded)
          cancelledBookings++;

        // Group by blood group
        bookingsByBloodGroup[booking.bloodGroup] =
            (bookingsByBloodGroup[booking.bloodGroup] ?? 0) + 1;

        // Revenue by district
        revenueByDistrict[booking.district] =
            (revenueByDistrict[booking.district] ?? 0) + booking.totalAmount;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalPlatformFees': totalPlatformFees,
        'totalPriorityCharges': totalPriorityCharges,
        'totalBookings': totalBookings,
        'completedBookings': completedBookings,
        'cancelledBookings': cancelledBookings,
        'averageBookingValue': totalBookings > 0
            ? totalRevenue / totalBookings
            : 0,
        'completionRate': totalBookings > 0
            ? (completedBookings / totalBookings * 100)
            : 0,
        'bookingsByBloodGroup': bookingsByBloodGroup,
        'revenueByDistrict': revenueByDistrict,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // Get daily revenue data for charts
  Future<List<Map<String, dynamic>>> getDailyRevenue({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Simplified query to avoid complex index requirements
      final snapshot = await _bookingsCollection
          .where('isPaid', isEqualTo: true)
          .get();

      // Filter by date on client side
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final paidAt = data['paidAt'] as Timestamp?;
        if (paidAt == null) return false;

        final paidDate = paidAt.toDate();
        return paidDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            paidDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      Map<String, double> dailyRevenue = {};

      for (var doc in filteredDocs) {
        try {
          final booking = AdvanceBloodBooking.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );

          if (booking.paidAt != null) {
            final dateKey =
                '${booking.paidAt!.year}-${booking.paidAt!.month.toString().padLeft(2, '0')}-${booking.paidAt!.day.toString().padLeft(2, '0')}';
            dailyRevenue[dateKey] =
                (dailyRevenue[dateKey] ?? 0) + booking.totalAmount;
          }
        } catch (e) {
          // Skip invalid documents
          continue;
        }
      }

      final resultList = dailyRevenue.entries
          .map((e) => {'date': e.key, 'revenue': e.value})
          .toList();
      resultList.sort(
        (a, b) => (a['date'] as String).compareTo(b['date'] as String),
      );
      return resultList;
    } catch (e) {
      throw Exception('Failed to get daily revenue: $e');
    }
  }
}
