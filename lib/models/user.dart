import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { superAdmin, orgAdmin, user }

class User {
  final String email;
  final String name;
  final String bloodType;
  final String? phone;
  final UserRole role;
  final int? age;
  final String? gender;
  final String? address;
  final DateTime? lastDonationDate;

  User({
    required this.email,
    required this.name,
    required this.bloodType,
    this.phone,
    this.role = UserRole.user,
    this.age,
    this.gender,
    this.address,
    this.lastDonationDate,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    UserRole role = UserRole.user;
    final roleStr = map['role']?.toString().toLowerCase() ?? '';

    if (roleStr == 'superadmin' || roleStr == 'admin') {
      role = UserRole.superAdmin;
    } else if (roleStr == 'orgadmin') {
      role = UserRole.orgAdmin;
    }

    return User(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      bloodType: map['bloodType'] ?? 'N/A',
      phone: map['phone'],
      role: role,
      age: map['age'],
      gender: map['gender'],
      address: map['address'],
      lastDonationDate: (map['lastDonationDate'] as Timestamp?)?.toDate(),
    );
  }
}
