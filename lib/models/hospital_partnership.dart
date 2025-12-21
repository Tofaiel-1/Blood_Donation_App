import 'package:cloud_firestore/cloud_firestore.dart';

enum PartnershipPlan { basic, standard, premium }

enum PartnershipStatus { pending, active, suspended, expired, cancelled }

class HospitalPartnership {
  final String id;
  final String userId; // Hospital/Blood Bank admin user
  final String hospitalName;
  final String registrationNumber;
  final String contactPerson;
  final String contactPhone;
  final String contactEmail;
  final String address;
  final String? division;
  final String? district;
  final String? upazila;
  final double? latitude;
  final double? longitude;
  final PartnershipPlan plan;
  final PartnershipStatus status;
  final double monthlyFee;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final List<String> availableBloodGroups;
  final bool hasBloodBank;
  final bool hasEmergencyService;
  final String? website;
  final String? logoUrl;
  final bool isVerified;
  final bool isFeatured; // For premium partners
  final int commissionPercentage; // For blood donation transactions
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? paymentTransactionId;
  final Map<String, dynamic>? metadata;

  HospitalPartnership({
    required this.id,
    required this.userId,
    required this.hospitalName,
    required this.registrationNumber,
    required this.contactPerson,
    required this.contactPhone,
    required this.contactEmail,
    required this.address,
    this.division,
    this.district,
    this.upazila,
    this.latitude,
    this.longitude,
    required this.plan,
    required this.status,
    required this.monthlyFee,
    required this.startDate,
    required this.endDate,
    this.autoRenew = false,
    this.availableBloodGroups = const [],
    this.hasBloodBank = false,
    this.hasEmergencyService = false,
    this.website,
    this.logoUrl,
    this.isVerified = false,
    this.isFeatured = false,
    this.commissionPercentage = 10,
    required this.createdAt,
    this.verifiedAt,
    this.paymentTransactionId,
    this.metadata,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isActive => status == PartnershipStatus.active && !isExpired;

  static double getPlanPrice(PartnershipPlan plan) {
    switch (plan) {
      case PartnershipPlan.basic:
        return 500; // 500 BDT per month
      case PartnershipPlan.standard:
        return 1000; // 1000 BDT per month
      case PartnershipPlan.premium:
        return 2000; // 2000 BDT per month
    }
  }

  static String getPlanName(PartnershipPlan plan) {
    switch (plan) {
      case PartnershipPlan.basic:
        return 'Basic Partnership';
      case PartnershipPlan.standard:
        return 'Standard Partnership';
      case PartnershipPlan.premium:
        return 'Premium Partnership';
    }
  }

  static List<String> getPlanFeatures(PartnershipPlan plan) {
    switch (plan) {
      case PartnershipPlan.basic:
        return [
          'Hospital listing',
          'Basic profile',
          'Emergency contact visibility',
        ];
      case PartnershipPlan.standard:
        return [
          'All Basic features',
          'Priority listing',
          'Blood bank management',
          'Analytics dashboard',
          '5% commission on transactions',
        ];
      case PartnershipPlan.premium:
        return [
          'All Standard features',
          'Featured listing',
          'Custom branding',
          'Priority support',
          '10% commission on transactions',
          'API access',
        ];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'hospitalName': hospitalName,
      'registrationNumber': registrationNumber,
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'address': address,
      'division': division,
      'district': district,
      'upazila': upazila,
      'latitude': latitude,
      'longitude': longitude,
      'plan': plan.toString().split('.').last,
      'status': status.toString().split('.').last,
      'monthlyFee': monthlyFee,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'autoRenew': autoRenew,
      'availableBloodGroups': availableBloodGroups,
      'hasBloodBank': hasBloodBank,
      'hasEmergencyService': hasEmergencyService,
      'website': website,
      'logoUrl': logoUrl,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'commissionPercentage': commissionPercentage,
      'createdAt': Timestamp.fromDate(createdAt),
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'paymentTransactionId': paymentTransactionId,
      'metadata': metadata,
    };
  }

  factory HospitalPartnership.fromMap(Map<String, dynamic> map) {
    return HospitalPartnership(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
      address: map['address'] ?? '',
      division: map['division'],
      district: map['district'],
      upazila: map['upazila'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      plan: PartnershipPlan.values.firstWhere(
        (e) => e.toString().split('.').last == map['plan'],
        orElse: () => PartnershipPlan.basic,
      ),
      status: PartnershipStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => PartnershipStatus.pending,
      ),
      monthlyFee: (map['monthlyFee'] ?? 0).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      autoRenew: map['autoRenew'] ?? false,
      availableBloodGroups: List<String>.from(
        map['availableBloodGroups'] ?? [],
      ),
      hasBloodBank: map['hasBloodBank'] ?? false,
      hasEmergencyService: map['hasEmergencyService'] ?? false,
      website: map['website'],
      logoUrl: map['logoUrl'],
      isVerified: map['isVerified'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      commissionPercentage: map['commissionPercentage'] ?? 10,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      verifiedAt: map['verifiedAt'] != null
          ? (map['verifiedAt'] as Timestamp).toDate()
          : null,
      paymentTransactionId: map['paymentTransactionId'],
      metadata: map['metadata'],
    );
  }
}
