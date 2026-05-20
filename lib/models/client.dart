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
        idUser: json['id_user'] ?? json['IDUser'] ?? 0,
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        password: '',
        creationDate: DateTime.tryParse(json['creation_date'] ?? '') ?? DateTime.now(),
        phoneNumber: json['phone_number'] ?? '',
      );
    }

    return Client(user: userData);
  }

  String get name => user.username;
  String get phone => user.phoneNumber;
  String get email => user.email;
  int get id => user.idUser;
}