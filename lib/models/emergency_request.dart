import 'package:cloud_firestore/cloud_firestore.dart';

enum EmergencyStatus { pending, active, fulfilled, cancelled, expired }

class EmergencyRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String bloodGroup;
  final String? hospitalName;
  final String? location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String urgencyLevel; // 'critical', 'urgent', 'moderate'
  final String? message;
  final int unitsNeeded;
  final EmergencyStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? paymentTransactionId;
  final bool isPaid;
  final double paymentAmount;
  final List<String> notifiedDonorIds;
  final List<String> respondedDonorIds;
  final String? fulfilledByDonorId;
  final DateTime? fulfilledAt;

  EmergencyRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.bloodGroup,
    this.hospitalName,
    this.location,
    this.address,
    this.latitude,
    this.longitude,
    this.urgencyLevel = 'urgent',
    this.message,
    this.unitsNeeded = 1,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.paymentTransactionId,
    this.isPaid = false,
    this.paymentAmount = 150.0,
    this.notifiedDonorIds = const [],
    this.respondedDonorIds = const [],
    this.fulfilledByDonorId,
    this.fulfilledAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => status == EmergencyStatus.active && !isExpired;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'bloodGroup': bloodGroup,
      'hospitalName': hospitalName,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'urgencyLevel': urgencyLevel,
      'message': message,
      'unitsNeeded': unitsNeeded,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'paymentTransactionId': paymentTransactionId,
      'isPaid': isPaid,
      'paymentAmount': paymentAmount,
      'notifiedDonorIds': notifiedDonorIds,
      'respondedDonorIds': respondedDonorIds,
      'fulfilledByDonorId': fulfilledByDonorId,
      'fulfilledAt': fulfilledAt != null
          ? Timestamp.fromDate(fulfilledAt!)
          : null,
    };
  }

  factory EmergencyRequest.fromMap(Map<String, dynamic> map) {
    return EmergencyRequest(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      hospitalName: map['hospitalName'],
      location: map['location'],
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      urgencyLevel: map['urgencyLevel'] ?? 'urgent',
      message: map['message'],
      unitsNeeded: map['unitsNeeded'] ?? 1,
      status: EmergencyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => EmergencyStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
      paymentTransactionId: map['paymentTransactionId'],
      isPaid: map['isPaid'] ?? false,
      paymentAmount: (map['paymentAmount'] ?? 150.0).toDouble(),
      notifiedDonorIds: List<String>.from(map['notifiedDonorIds'] ?? []),
      respondedDonorIds: List<String>.from(map['respondedDonorIds'] ?? []),
      fulfilledByDonorId: map['fulfilledByDonorId'],
      fulfilledAt: map['fulfilledAt'] != null
          ? (map['fulfilledAt'] as Timestamp).toDate()
          : null,
    );
  }

  EmergencyRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? bloodGroup,
    String? hospitalName,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    String? urgencyLevel,
    String? message,
    int? unitsNeeded,
    EmergencyStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? paymentTransactionId,
    bool? isPaid,
    double? paymentAmount,
    List<String>? notifiedDonorIds,
    List<String>? respondedDonorIds,
    String? fulfilledByDonorId,
    DateTime? fulfilledAt,
  }) {
    return EmergencyRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      hospitalName: hospitalName ?? this.hospitalName,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      urgencyLevel: urgencyLevel ?? this.urgencyLevel,
      message: message ?? this.message,
      unitsNeeded: unitsNeeded ?? this.unitsNeeded,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      isPaid: isPaid ?? this.isPaid,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      notifiedDonorIds: notifiedDonorIds ?? this.notifiedDonorIds,
      respondedDonorIds: respondedDonorIds ?? this.respondedDonorIds,
      fulfilledByDonorId: fulfilledByDonorId ?? this.fulfilledByDonorId,
      fulfilledAt: fulfilledAt ?? this.fulfilledAt,
    );
  }
}
