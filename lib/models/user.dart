class User {
  final int idUser;
  final String firstName;
  final String middleName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String password;
  final DateTime creationDate;
  String avatarUrl;
  dynamic role;

  User({
    required this.idUser,
    required this.firstName,
    required this.middleName,
    required this.lastName,
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
      idUser: json['ID'] ?? json['id'] ?? 0,
      firstName: json['FirstName'] ?? json['firstName'] ?? '',
      middleName: json['MiddleName'] ?? json['middleName'] ?? '',
      lastName: json['LastName'] ?? json['lastName'] ?? '',
      username: json['Username'] ?? json['username'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? json['phoneNumber'] ?? '',
      password: '',
      creationDate: DateTime.tryParse(json['CreationDate'] ?? json['creationDate'] ?? '') ?? DateTime.now(),
      avatarUrl: json['AvatarURL'] ?? json['avatarUrl'] ?? '',
      role: json['Role'] ?? json['role'],
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toJson() {
    return {
      'id': idUser,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
    };
  }
}