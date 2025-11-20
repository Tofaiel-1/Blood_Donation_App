class SearchResult {
  final String id;
  final String name;
  final String bloodType;
  final String location;
  final double distance;
  final DateTime lastDonation;
  final bool isAvailable;
  final String phone;
  final String? email;

  SearchResult({
    required this.id,
    required this.name,
    required this.bloodType,
    required this.location,
    required this.distance,
    required this.lastDonation,
    required this.isAvailable,
    required this.phone,
    this.email,
  });

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      id: map['id'],
      name: map['name'],
      bloodType: map['bloodType'],
      location: map['location'],
      distance: map['distance'].toDouble(),
      lastDonation: DateTime.parse(map['lastDonation']),
      isAvailable: map['isAvailable'],
      phone: map['phone'],
      email: map['email'],
    );
  }
}

class SearchFilter {
  final String? bloodType;
  final String? location;
  final double? maxDistance;
  final bool? availableOnly;

  SearchFilter({
    this.bloodType,
    this.location,
    this.maxDistance,
    this.availableOnly,
  });

  Map<String, dynamic> toMap() {
    return {
      'bloodType': bloodType,
      'location': location,
      'maxDistance': maxDistance,
      'availableOnly': availableOnly,
    };
  }
}