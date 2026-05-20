import 'user.dart';

class Client {
  final User user;

  Client({required this.user});

  factory Client.fromJson(Map<String, dynamic> json) {
    User userData;

    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      userData = User.fromJson(json['user']);
    } else {
      userData = User(
        idUser: json['id_user'] ?? json['IDUser'] ?? json['ID'] ?? json['id'] ?? 0,
        firstName: json['first_name'] ?? json['firstName'] ?? '',
        middleName: json['middle_name'] ?? json['middleName'] ?? '',
        lastName: json['last_name'] ?? json['lastName'] ?? '',
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
        password: '',
        creationDate: DateTime.tryParse(json['creation_date'] ?? json['creationDate'] ?? '') ?? DateTime.now(),
        avatarUrl: json['avatar_url'] ?? json['avatarUrl'] ?? '',
        role: json['role'] ?? json['Role'],
      );
    }

    return Client(user: userData);
  }

  String get name => user.username.isNotEmpty ? user.username : user.fullName;
  String get phone => user.phoneNumber;
  String get email => user.email;
  int get id => user.idUser;
  String get fullName => user.fullName;
  String get avatarUrl => user.avatarUrl;
}