import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { superAdmin, orgAdmin, user }

/// User availability status for blood donation
enum DonorAvailability { available, unavailable, busy }

/// Achievement badges for donors
enum DonorBadge {
  firstTimeDonor, // 1st donation
  bronzeDonor, // 3 donations
  silverDonor, // 5 donations
  goldDonor, // 10 donations
  platinumDonor, // 20 donations
  legendaryDonor, // 50 donations
  lifeSaver, // Donated to 10+ recipients
  regularDonor, // Donated every year for 3+ years
  emergencyHero, // Responded to 5+ urgent requests
}

class User {
  final String? id;
  final String email;
  final String name;
  final String bloodType;
  final String? phone;
  final UserRole role;
  final int? age;
  final String? gender;
  final String? address;

  // Bangladesh location fields
  final String? division;
  final String? district;
  final String? upazila;
  final String? village; // Village/Union
  final double? latitude; // Current location
  final double? longitude; // Current location

  final DateTime? lastDonationDate;

  // Enhanced fields for donation tracking
  final int totalDonations;
  final int livesSaved; // 1 completed donation = 1 life saved
  final DonorAvailability availability;
  final List<DonorBadge> badges;
  final double? weight; // in kg - for eligibility
  final String? medicalConditions; // any conditions that affect donation
  final DateTime? dateOfBirth;
  final bool isEligibleToDonate;
  final DateTime? nextEligibleDate;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Premium & Monetization fields
  final bool isPremium;
  final String? premiumPlan; // 'monthly', 'quarterly', 'yearly'
  final DateTime? premiumExpiryDate;
  final bool isVerified; // For verification service
  final DateTime? verifiedAt;
  final String? verificationTransactionId;
  final bool isHospitalPartner; // For hospitals/blood banks
  final String? partnershipId; // Link to HospitalPartnership

  User({
    this.id,
    required this.email,
    required this.name,
    required this.bloodType,
    this.phone,
    this.role = UserRole.user,
    this.age,
    this.gender,
    this.address,
    this.division,
    this.district,
    this.upazila,
    this.village,
    this.latitude,
    this.longitude,
    this.lastDonationDate,
    this.totalDonations = 0,
    this.livesSaved = 0,
    this.availability = DonorAvailability.available,
    this.badges = const [],
    this.weight,
    this.medicalConditions,
    this.dateOfBirth,
    this.isEligibleToDonate = true,
    this.nextEligibleDate,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.isPremium = false,
    this.premiumPlan,
    this.premiumExpiryDate,
    this.isVerified = false,
    this.verifiedAt,
    this.verificationTransactionId,
    this.isHospitalPartner = false,
    this.partnershipId,
  });

  /// Check if user can donate now (120 days rule)
  bool get canDonateNow {
    if (!isEligibleToDonate) return false;
    if (lastDonationDate == null) return true;
    final daysSinceLastDonation = DateTime.now()
        .difference(lastDonationDate!)
        .inDays;
    return daysSinceLastDonation >= 120;
  }

  /// Days remaining until next donation
  int get daysUntilNextDonation {
    if (lastDonationDate == null) return 0;
    final daysSinceLastDonation = DateTime.now()
        .difference(lastDonationDate!)
        .inDays;
    final remaining = 120 - daysSinceLastDonation;
    return remaining > 0 ? remaining : 0;
  }

  /// Get current badge based on total donations
  DonorBadge? get currentBadge {
    if (totalDonations >= 50) return DonorBadge.legendaryDonor;
    if (totalDonations >= 20) return DonorBadge.platinumDonor;
    if (totalDonations >= 10) return DonorBadge.goldDonor;
    if (totalDonations >= 5) return DonorBadge.silverDonor;
    if (totalDonations >= 3) return DonorBadge.bronzeDonor;
    if (totalDonations >= 1) return DonorBadge.firstTimeDonor;
    return null;
  }

  /// Get badge display name
  static String getBadgeName(DonorBadge badge) {
    switch (badge) {
      case DonorBadge.firstTimeDonor:
        return 'First Time Donor';
      case DonorBadge.bronzeDonor:
        return 'Bronze Donor';
      case DonorBadge.silverDonor:
        return 'Silver Donor';
      case DonorBadge.goldDonor:
        return 'Gold Donor';
      case DonorBadge.platinumDonor:
        return 'Platinum Donor';
      case DonorBadge.legendaryDonor:
        return 'Legendary Donor';
      case DonorBadge.lifeSaver:
        return 'Life Saver';
      case DonorBadge.regularDonor:
        return 'Regular Donor';
      case DonorBadge.emergencyHero:
        return 'Emergency Hero';
    }
  }

  /// Get badge icon
  static String getBadgeEmoji(DonorBadge badge) {
    switch (badge) {
      case DonorBadge.firstTimeDonor:
        return '🩸';
      case DonorBadge.bronzeDonor:
        return '🥉';
      case DonorBadge.silverDonor:
        return '🥈';
      case DonorBadge.goldDonor:
        return '🥇';
      case DonorBadge.platinumDonor:
        return '💎';
      case DonorBadge.legendaryDonor:
        return '👑';
      case DonorBadge.lifeSaver:
        return '💝';
      case DonorBadge.regularDonor:
        return '⭐';
      case DonorBadge.emergencyHero:
        return '🦸';
    }
  }

  factory User.fromMap(Map<String, dynamic> map) {
    UserRole role = UserRole.user;
    final roleStr = map['role']?.toString().toLowerCase() ?? '';

    if (roleStr == 'superadmin' || roleStr == 'admin') {
      role = UserRole.superAdmin;
    } else if (roleStr == 'orgadmin') {
      role = UserRole.orgAdmin;
    }

    // Parse availability
    DonorAvailability availability = DonorAvailability.available;
    final availStr = map['availability']?.toString().toLowerCase() ?? '';
    if (availStr == 'unavailable') {
      availability = DonorAvailability.unavailable;
    } else if (availStr == 'busy') {
      availability = DonorAvailability.busy;
    }

    // Parse badges
    List<DonorBadge> badges = [];
    if (map['badges'] != null && map['badges'] is List) {
      for (var badgeStr in map['badges']) {
        try {
          badges.add(
            DonorBadge.values.firstWhere(
              (b) => b.toString().split('.').last == badgeStr,
            ),
          );
        } catch (_) {}
      }
    }

    return User(
      id: map['id'],
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      bloodType: map['bloodType'] ?? 'N/A',
      phone: map['phone'],
      role: role,
      age: map['age'],
      gender: map['gender'],
      address: map['address'],
      division: map['division'],
      district: map['district'],
      upazila: map['upazila'],
      village: map['village'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      lastDonationDate: (map['lastDonationDate'] as Timestamp?)?.toDate(),
      totalDonations: map['totalDonations'] ?? 0,
      livesSaved: map['livesSaved'] ?? map['totalDonations'] ?? 0,
      availability: availability,
      badges: badges,
      weight: map['weight']?.toDouble(),
      medicalConditions: map['medicalConditions'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      isEligibleToDonate: map['isEligibleToDonate'] ?? true,
      nextEligibleDate: (map['nextEligibleDate'] as Timestamp?)?.toDate(),
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isPremium: map['isPremium'] ?? false,
      premiumPlan: map['premiumPlan'],
      premiumExpiryDate: (map['premiumExpiryDate'] as Timestamp?)?.toDate(),
      isVerified: map['isVerified'] ?? false,
      verifiedAt: (map['verifiedAt'] as Timestamp?)?.toDate(),
      verificationTransactionId: map['verificationTransactionId'],
      isHospitalPartner: map['isHospitalPartner'] ?? false,
      partnershipId: map['partnershipId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'name': name,
      'bloodType': bloodType,
      'phone': phone,
      'role': role.toString().split('.').last,
      'age': age,
      'gender': gender,
      'address': address,
      'division': division,
      'district': district,
      'upazila': upazila,
      'village': village,
      'latitude': latitude,
      'longitude': longitude,
      'lastDonationDate': lastDonationDate != null
          ? Timestamp.fromDate(lastDonationDate!)
          : null,
      'totalDonations': totalDonations,
      'livesSaved': livesSaved,
      'availability': availability.toString().split('.').last,
      'badges': badges.map((b) => b.toString().split('.').last).toList(),
      'weight': weight,
      'medicalConditions': medicalConditions,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'isEligibleToDonate': isEligibleToDonate,
      'nextEligibleDate': nextEligibleDate != null
          ? Timestamp.fromDate(nextEligibleDate!)
          : null,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isPremium': isPremium,
      'premiumPlan': premiumPlan,
      'premiumExpiryDate': premiumExpiryDate != null
          ? Timestamp.fromDate(premiumExpiryDate!)
          : null,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verificationTransactionId': verificationTransactionId,
      'isHospitalPartner': isHospitalPartner,
      'partnershipId': partnershipId,
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? bloodType,
    String? phone,
    UserRole? role,
    int? age,
    String? gender,
    String? address,
    String? division,
    String? district,
    String? upazila,
    String? village,
    double? latitude,
    double? longitude,
    DateTime? lastDonationDate,
    int? totalDonations,
    int? livesSaved,
    DonorAvailability? availability,
    List<DonorBadge>? badges,
    double? weight,
    String? medicalConditions,
    DateTime? dateOfBirth,
    bool? isEligibleToDonate,
    DateTime? nextEligibleDate,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPremium,
    String? premiumPlan,
    DateTime? premiumExpiryDate,
    bool? isVerified,
    DateTime? verifiedAt,
    String? verificationTransactionId,
    bool? isHospitalPartner,
    String? partnershipId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      village: village ?? this.village,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      totalDonations: totalDonations ?? this.totalDonations,
      livesSaved: livesSaved ?? this.livesSaved,
      availability: availability ?? this.availability,
      badges: badges ?? this.badges,
      weight: weight ?? this.weight,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isEligibleToDonate: isEligibleToDonate ?? this.isEligibleToDonate,
      nextEligibleDate: nextEligibleDate ?? this.nextEligibleDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPremium: isPremium ?? this.isPremium,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationTransactionId:
          verificationTransactionId ?? this.verificationTransactionId,
      isHospitalPartner: isHospitalPartner ?? this.isHospitalPartner,
      partnershipId: partnershipId ?? this.partnershipId,
    );
  }
}
