enum UserRole { client, artisan, administrator }

class User {
  final int idUser;
  final String username;
  final String email;
  final String phoneNumber;
  final String password;
  final DateTime creationDate;
  String avatarUrl;  // ← ADD THIS

  UserRole? role;

  User({
    required this.idUser,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.creationDate,
    required this.avatarUrl,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id'] ?? json['ID'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      password: json[''],
      creationDate: DateTime.tryParse(json['creation_date'] ?? '') ?? DateTime.now(),
      role: _parseRole(json['role']),
    );
  }

  static UserRole? _parseRole(dynamic role) {
    if (role == null) return null;
    final roleStr = role.toString().toLowerCase();
    switch (roleStr) {
      case 'client':
        return UserRole.client;
      case 'artisan':
        return UserRole.artisan;
      case 'administrator':
        return UserRole.administrator;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': idUser,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'creation_date': creationDate.toIso8601String(),

    };
  }
}