enum UserRole { superAdmin, orgAdmin, user }

class User {
  final String email;
  final String name;
  final String bloodType;
  final String? phone;
  final UserRole role;

  User({
    required this.email,
    required this.name,
    required this.bloodType,
    this.phone,
    this.role = UserRole.user,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    UserRole role = UserRole.user;
    if (map['role'] == 'superAdmin') {
      role = UserRole.superAdmin;
    } else if (map['role'] == 'orgAdmin') {
      role = UserRole.orgAdmin;
    }

    return User(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      bloodType: map['bloodType'] ?? 'N/A',
      phone: map['phone'],
      role: role,
    );
  }
}
