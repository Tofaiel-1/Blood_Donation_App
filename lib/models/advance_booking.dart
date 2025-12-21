import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending, // Payment pending
  confirmed, // Payment completed
  processing, // Finding donor
  matched, // Donor matched
  completed, // Blood donated
  cancelled, // Booking cancelled
  expired, // Booking expired
  refunded, // Payment refunded
}

enum BookingPriority {
  standard, // Normal booking
  urgent, // Need within 7 days
  critical, // Need within 24-48 hours
}

class AdvanceBloodBooking {
  final String id;
  final String userId; // Who is booking
  final String userName;
  final String userPhone;
  final String bloodGroup;

  // Patient Details
  final String patientName;
  final String patientAge;
  final String patientGender;
  final String patientBloodGroup;
  final String patientCondition; // Why blood needed

  // Location Details
  final String hospitalName;
  final String hospitalAddress;
  final String division;
  final String district;
  final String upazila;
  final double? latitude;
  final double? longitude;

  // Booking Details
  final int unitsRequired; // Number of blood bags needed (1-5)
  final DateTime requiredDate; // When blood is needed
  final BookingPriority priority;
  final BookingStatus status;

  // Payment Details
  final double bookingAmount; // Base price per unit
  final double priorityCharge; // Extra for urgent/critical
  final double platformFee; // Admin commission
  final double totalAmount;
  final bool isPaid;
  final String? paymentMethod; // bKash, Nagad, Card, etc.
  final String? transactionId;
  final DateTime? paidAt;

  // Donor Matching
  final String? matchedDonorId;
  final String? matchedDonorName;
  final String? matchedDonorPhone;
  final DateTime? matchedAt;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  // Additional Info
  final String? specialInstructions;
  final String? cancellationReason;
  final List<String> notifiedDonorIds;
  final int notificationsSent;

  AdvanceBloodBooking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.bloodGroup,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.patientBloodGroup,
    required this.patientCondition,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.division,
    required this.district,
    required this.upazila,
    this.latitude,
    this.longitude,
    required this.unitsRequired,
    required this.requiredDate,
    required this.priority,
    required this.status,
    required this.bookingAmount,
    required this.priorityCharge,
    required this.platformFee,
    required this.totalAmount,
    required this.isPaid,
    this.paymentMethod,
    this.transactionId,
    this.paidAt,
    this.matchedDonorId,
    this.matchedDonorName,
    this.matchedDonorPhone,
    this.matchedAt,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.specialInstructions,
    this.cancellationReason,
    this.notifiedDonorIds = const [],
    this.notificationsSent = 0,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'bloodGroup': bloodGroup,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'patientBloodGroup': patientBloodGroup,
      'patientCondition': patientCondition,
      'hospitalName': hospitalName,
      'hospitalAddress': hospitalAddress,
      'division': division,
      'district': district,
      'upazila': upazila,
      'latitude': latitude,
      'longitude': longitude,
      'unitsRequired': unitsRequired,
      'requiredDate': Timestamp.fromDate(requiredDate),
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'bookingAmount': bookingAmount,
      'priorityCharge': priorityCharge,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
      'isPaid': isPaid,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'matchedDonorId': matchedDonorId,
      'matchedDonorName': matchedDonorName,
      'matchedDonorPhone': matchedDonorPhone,
      'matchedAt': matchedAt != null ? Timestamp.fromDate(matchedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
      'specialInstructions': specialInstructions,
      'cancellationReason': cancellationReason,
      'notifiedDonorIds': notifiedDonorIds,
      'notificationsSent': notificationsSent,
    };
  }

  // Create from Firestore Map
  factory AdvanceBloodBooking.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AdvanceBloodBooking(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      patientName: map['patientName'] ?? '',
      patientAge: map['patientAge'] ?? '',
      patientGender: map['patientGender'] ?? '',
      patientBloodGroup: map['patientBloodGroup'] ?? '',
      patientCondition: map['patientCondition'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      hospitalAddress: map['hospitalAddress'] ?? '',
      division: map['division'] ?? '',
      district: map['district'] ?? '',
      upazila: map['upazila'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      unitsRequired: map['unitsRequired'] ?? 1,
      requiredDate: (map['requiredDate'] as Timestamp).toDate(),
      priority: BookingPriority.values.firstWhere(
        (e) => e.toString().split('.').last == map['priority'],
        orElse: () => BookingPriority.standard,
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      bookingAmount: (map['bookingAmount'] ?? 0).toDouble(),
      priorityCharge: (map['priorityCharge'] ?? 0).toDouble(),
      platformFee: (map['platformFee'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      isPaid: map['isPaid'] ?? false,
      paymentMethod: map['paymentMethod'],
      transactionId: map['transactionId'],
      paidAt: map['paidAt'] != null
          ? (map['paidAt'] as Timestamp).toDate()
          : null,
      matchedDonorId: map['matchedDonorId'],
      matchedDonorName: map['matchedDonorName'],
      matchedDonorPhone: map['matchedDonorPhone'],
      matchedAt: map['matchedAt'] != null
          ? (map['matchedAt'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? (map['cancelledAt'] as Timestamp).toDate()
          : null,
      specialInstructions: map['specialInstructions'],
      cancellationReason: map['cancellationReason'],
      notifiedDonorIds: List<String>.from(map['notifiedDonorIds'] ?? []),
      notificationsSent: map['notificationsSent'] ?? 0,
    );
  }

  // Copy with method
  AdvanceBloodBooking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? bloodGroup,
    String? patientName,
    String? patientAge,
    String? patientGender,
    String? patientBloodGroup,
    String? patientCondition,
    String? hospitalName,
    String? hospitalAddress,
    String? division,
    String? district,
    String? upazila,
    double? latitude,
    double? longitude,
    int? unitsRequired,
    DateTime? requiredDate,
    BookingPriority? priority,
    BookingStatus? status,
    double? bookingAmount,
    double? priorityCharge,
    double? platformFee,
    double? totalAmount,
    bool? isPaid,
    String? paymentMethod,
    String? transactionId,
    DateTime? paidAt,
    String? matchedDonorId,
    String? matchedDonorName,
    String? matchedDonorPhone,
    DateTime? matchedAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? specialInstructions,
    String? cancellationReason,
    List<String>? notifiedDonorIds,
    int? notificationsSent,
  }) {
    return AdvanceBloodBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      patientBloodGroup: patientBloodGroup ?? this.patientBloodGroup,
      patientCondition: patientCondition ?? this.patientCondition,
      hospitalName: hospitalName ?? this.hospitalName,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      unitsRequired: unitsRequired ?? this.unitsRequired,
      requiredDate: requiredDate ?? this.requiredDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      bookingAmount: bookingAmount ?? this.bookingAmount,
      priorityCharge: priorityCharge ?? this.priorityCharge,
      platformFee: platformFee ?? this.platformFee,
      totalAmount: totalAmount ?? this.totalAmount,
      isPaid: isPaid ?? this.isPaid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      paidAt: paidAt ?? this.paidAt,
      matchedDonorId: matchedDonorId ?? this.matchedDonorId,
      matchedDonorName: matchedDonorName ?? this.matchedDonorName,
      matchedDonorPhone: matchedDonorPhone ?? this.matchedDonorPhone,
      matchedAt: matchedAt ?? this.matchedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      notifiedDonorIds: notifiedDonorIds ?? this.notifiedDonorIds,
      notificationsSent: notificationsSent ?? this.notificationsSent,
    );
  }

  // Get status color
  String getStatusColor() {
    switch (status) {
      case BookingStatus.pending:
        return '#FFA726';
      case BookingStatus.confirmed:
        return '#66BB6A';
      case BookingStatus.processing:
        return '#42A5F5';
      case BookingStatus.matched:
        return '#26A69A';
      case BookingStatus.completed:
        return '#4CAF50';
      case BookingStatus.cancelled:
        return '#EF5350';
      case BookingStatus.expired:
        return '#9E9E9E';
      case BookingStatus.refunded:
        return '#7E57C2';
    }
  }

  // Get status text in Bangla
  String getStatusTextBangla() {
    switch (status) {
      case BookingStatus.pending:
        return 'পেমেন্ট অপেক্ষমাণ';
      case BookingStatus.confirmed:
        return 'নিশ্চিত';
      case BookingStatus.processing:
        return 'ডোনার খোঁজা হচ্ছে';
      case BookingStatus.matched:
        return 'ডোনার পাওয়া গেছে';
      case BookingStatus.completed:
        return 'সম্পন্ন';
      case BookingStatus.cancelled:
        return 'বাতিল';
      case BookingStatus.expired:
        return 'মেয়াদ শেষ';
      case BookingStatus.refunded:
        return 'টাকা ফেরত';
    }
  }

  // Calculate priority charge based on urgency and date
  static double calculatePriorityCharge(
    BookingPriority priority,
    DateTime requiredDate,
  ) {
    final daysUntilRequired = requiredDate.difference(DateTime.now()).inDays;

    switch (priority) {
      case BookingPriority.critical:
        if (daysUntilRequired <= 2)
          return 200.0; // ৳200 for critical within 48 hours
        return 150.0; // ৳150 for critical

      case BookingPriority.urgent:
        if (daysUntilRequired <= 7)
          return 100.0; // ৳100 for urgent within 7 days
        return 50.0; // ৳50 for urgent

      case BookingPriority.standard:
        return 0.0; // No extra charge for standard
    }
  }

  // Calculate platform fee (admin commission)
  static double calculatePlatformFee(double bookingAmount, int units) {
    final baseAmount = bookingAmount * units;
    return baseAmount * 0.15; // 15% commission
  }
}
