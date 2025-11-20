class Donation {
  final String id;
  final String donorId;
  final String donorName;
  final String bloodType;
  final DateTime donationDate;
  final String location;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? notes;

  Donation({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.bloodType,
    required this.donationDate,
    required this.location,
    required this.status,
    this.notes,
  });

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