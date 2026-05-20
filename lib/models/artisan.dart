import 'user.dart';

class Artisan {
  final User user;
  final String firstName;
  final String lastName;
  final String category;
  final String wilaya;
  final String baladeya;
  final String zone;
  final String photoUrl;
  final String diplomaUrl;
  final String officialDocUrl;
  final String activesStatus;
  final int experience;
  final double? rating;

  Artisan({
    required this.user,
    required this.firstName,
    required this.lastName,
    required this.category,
    required this.wilaya,
    required this.baladeya,
    required this.zone,
    required this.photoUrl,
    required this.diplomaUrl,
    required this.officialDocUrl,
    required this.activesStatus,
    required this.experience,
    this.rating,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    // Handle nested user or flat structure
    User userData;
    if (json['User'] != null) {
      userData = User.fromJson(json['User']);
    } else {
      userData = User(
        idUser: json['id'] ?? json['ID'] ?? 0,
        username: json['username'] ?? '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}',
        email: json['email'] ?? '',
        password: '',
        creationDate: DateTime.tryParse(json['creation_date'] ?? '') ?? DateTime.now(),
        phoneNumber: json['phone_number'] ?? '',
        avatarUrl: json['avatar_url'] ?? json['photo_url'] ?? '',
      );
    }

    return Artisan(
      user: userData,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      category: json['category'] ?? '',
      wilaya: json['wilaya'] ?? '',
      baladeya: json['baladeya'] ?? '',
      zone: json['zone'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      diplomaUrl: json['diploma_url'] ?? '',
      officialDocUrl: json['official_doc_url'] ?? '',
      activesStatus: json['actives_status'] ?? 'active',
      experience: json['experience'] ?? 0,
      rating: json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'category': category,
      'wilaya': wilaya,
      'baladeya': baladeya,
      'zone': zone,
      'photo_url': photoUrl,
      'diploma_url': diplomaUrl,
      'official_doc_url': officialDocUrl,
      'actives_status': activesStatus,
      'experience': experience,
    };
  }

  // Helper getters for UI compatibility
  String get fullName => '$firstName $lastName';
  String get fullAddress => '$wilaya, $baladeya, $zone';
  String get location => fullAddress;  // For backward compatibility
  String get bio => '';  // Backend doesn't have bio - use empty or from somewhere else
  String get diploma => diplomaUrl;  // For backward compatibility
  String get phone => user.phoneNumber;
  String get email => user.email;
  int get id => user.idUser;
  bool get isActive => activesStatus == 'active';
  String get avatarUrl => photoUrl.isNotEmpty ? photoUrl : user.avatarUrl;

  // CopyWith method
  Artisan copyWith({
    User? user,
    String? firstName,
    String? lastName,
    String? category,
    String? wilaya,
    String? baladeya,
    String? zone,
    String? photoUrl,
    String? diplomaUrl,
    String? officialDocUrl,
    String? activesStatus,
    int? experience,
    double? rating,
  }) {
    return Artisan(
      user: user ?? this.user,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      category: category ?? this.category,
      wilaya: wilaya ?? this.wilaya,
      baladeya: baladeya ?? this.baladeya,
      zone: zone ?? this.zone,
      photoUrl: photoUrl ?? this.photoUrl,
      diplomaUrl: diplomaUrl ?? this.diplomaUrl,
      officialDocUrl: officialDocUrl ?? this.officialDocUrl,
      activesStatus: activesStatus ?? this.activesStatus,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
    );
  }
}