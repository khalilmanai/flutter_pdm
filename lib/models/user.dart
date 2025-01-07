// lib/models/user.dart
enum UserRole { PROJECT_MANAGER, MEMBER }

class User {
  final String id;
  final String username;
  final String email;
  final UserRole role; // Change to enum type
  final String? status;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.MEMBER,
      ),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'role': role.toString().split('.').last,
      'status': status,
    };
  }
}
