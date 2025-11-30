import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? organization;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy; // Super admin ID
  final List<String> permissions;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.organization,
    required this.isActive,
    required this.createdAt,
    this.createdBy,
    this.permissions = const [],
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      organization: data['organization'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
      permissions: List<String>.from(data['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'organization': organization,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'permissions': permissions,
      'role': 'orgAdmin',
    };
  }

  AdminUser copyWith({
    String? name,
    String? phone,
    String? organization,
    bool? isActive,
    List<String>? permissions,
  }) {
    return AdminUser(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      organization: organization ?? this.organization,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      createdBy: createdBy,
      permissions: permissions ?? this.permissions,
    );
  }
}
