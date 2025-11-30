class Donation {
  final String id;
  final String donorId;
  final String donorName;
  final String bloodType;
  final DateTime donationDate;
  final String location;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;
  // Recipient information (who received the blood)
  final String? recipientRequestId;
  final String? recipientPatientName;
  final String? recipientHospital;
  final String? recipientBloodType;
  final String? recipientContactPhone;

  Donation({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.bloodType,
    required this.donationDate,
    required this.location,
    required this.status,
    this.notes,
    this.recipientRequestId,
    this.recipientPatientName,
    this.recipientHospital,
    this.recipientBloodType,
    this.recipientContactPhone,
  });

  // Check if this donation has a recipient
  bool get hasRecipient =>
      recipientPatientName != null && recipientPatientName!.isNotEmpty;

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      id: map['id'],
      donorId: map['donorId'],
      donorName: map['donorName'],
      bloodType: map['bloodType'],
      donationDate: DateTime.parse(map['donationDate']),
      location: map['location'],
      status: map['status'],
      notes: map['notes'],
      recipientRequestId: map['recipientRequestId'],
      recipientPatientName: map['recipientPatientName'],
      recipientHospital: map['recipientHospital'],
      recipientBloodType: map['recipientBloodType'],
      recipientContactPhone: map['recipientContactPhone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donorId': donorId,
      'donorName': donorName,
      'bloodType': bloodType,
      'donationDate': donationDate.toIso8601String(),
      'location': location,
      'status': status,
      'notes': notes,
      'recipientRequestId': recipientRequestId,
      'recipientPatientName': recipientPatientName,
      'recipientHospital': recipientHospital,
      'recipientBloodType': recipientBloodType,
      'recipientContactPhone': recipientContactPhone,
    };
  }
}

class DonationCenter {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final List<String> operatingHours;
  final bool isActive;

  DonationCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.operatingHours,
    required this.isActive,
  });

  factory DonationCenter.fromMap(Map<String, dynamic> map) {
    return DonationCenter(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
      phone: map['phone'],
      operatingHours: List<String>.from(map['operatingHours']),
      isActive: map['isActive'],
    );
  }
}
