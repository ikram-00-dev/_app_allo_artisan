import 'user.dart';

class Artisan {
  final User user;
  final String status;
  final bool isAvailable;
  final String category;
  final String activesStatus;
  final String diploma;
  final String bio;
  final String province;
  final String city;
  final String district;
  final double? latitude;
  final double? longitude;
  final int experience;
  final double? rating;
  final int? reviewCount;
  final List<dynamic>? followers;

  Artisan({
    required this.user,
    required this.status,
    required this.isAvailable,
    required this.category,
    required this.activesStatus,
    required this.diploma,
    required this.bio,
    required this.province,
    required this.city,
    required this.district,
    this.latitude,
    this.longitude,
    required this.experience,
    this.rating,
    this.reviewCount,
    this.followers,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    User userData;

    if (json['User'] != null) {
      userData = User.fromJson(json['User']);
    } else {
      userData = User(
        idUser: json['ID'] ?? json['id'] ?? 0,
        firstName: json['FirstName'] ?? json['firstName'] ?? '',
        middleName: json['MiddleName'] ?? json['middleName'] ?? '',
        lastName: json['LastName'] ?? json['lastName'] ?? '',
        username: json['Username'] ?? json['username'] ?? '',
        email: json['Email'] ?? json['email'] ?? '',
        password: '',
        creationDate: DateTime.tryParse(json['CreationDate'] ?? json['creationDate'] ?? '') ?? DateTime.now(),
        phoneNumber: json['PhoneNumber'] ?? json['phoneNumber'] ?? '',
        avatarUrl: json['AvatarURL'] ?? json['avatarUrl'] ?? '',
        role: json['Role'] ?? json['role'],
      );
    }

    return Artisan(
      user: userData,
      status: json['Status'] ?? json['status'] ?? 'pending',
      isAvailable: json['IsAvailable'] ?? json['isAvailable'] ?? false,
      category: json['Category'] ?? json['category'] ?? '',
      activesStatus: json['ActivesStatus'] ?? json['activesStatus'] ?? 'inactive',
      diploma: json['Diploma'] ?? json['diploma'] ?? '',
      bio: json['Bio'] ?? json['bio'] ?? '',
      province: json['Province'] ?? json['province'] ?? '',
      city: json['City'] ?? json['city'] ?? '',
      district: json['District'] ?? json['district'] ?? '',
      latitude: json['Latitude'] ?? json['latitude'],
      longitude: json['Longitude'] ?? json['longitude'],
      experience: json['Experience'] ?? json['experience'] ?? 0,
      rating: (json['Rating'] ?? json['rating'])?.toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      followers: json['Followers'] ?? json['followers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': user.firstName,
      'lastName': user.lastName,
      'category': category,
      'province': province,
      'city': city,
      'district': district,
      'avatarUrl': user.avatarUrl,
      'diploma': diploma,
      'activesStatus': activesStatus,
      'experience': experience,
    };
  }

  // Helper getters for UI compatibility
  String get fullName => '${user.firstName} ${user.lastName}'.trim();
  String get fullAddress => '$province, $city, $district';
  String get location => fullAddress;
  String get phone => user.phoneNumber;
  String get email => user.email;
  int get id => user.idUser;
  bool get isActive => activesStatus == 'active' || isAvailable;
  String get avatarUrl => user.avatarUrl.isNotEmpty ? user.avatarUrl : "https://i.pravatar.cc/300";

  // CopyWith method
  Artisan copyWith({
    User? user,
    String? status,
    bool? isAvailable,
    String? category,
    String? activesStatus,
    String? diploma,
    String? bio,
    String? province,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    int? experience,
    double? rating,
    int? reviewCount,
    List<dynamic>? followers,
  }) {
    return Artisan(
      user: user ?? this.user,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      activesStatus: activesStatus ?? this.activesStatus,
      diploma: diploma ?? this.diploma,
      bio: bio ?? this.bio,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      followers: followers ?? this.followers,
    );
  }
}