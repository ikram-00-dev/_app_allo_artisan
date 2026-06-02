import 'user.dart';

class Artisan {
  final User user;
  final String status;          // 'pending', 'active', 'rejected', 'suspended'
  final bool isAvailable;
  final String category;
  final String activesStatus;
  final String diploma;
  final String bio;
  final String officialDoc;     // ✅ Added - matches backend
  final String province;
  final String city;
  final String district;
  final double? latitude;
  final double? longitude;
  final int experience;
  final double? rating;
  final int? reviewCount;
  final List<dynamic>? followers;
  final List<Map<String, dynamic>>? availability;

  Artisan({
    required this.user,
    required this.status,
    required this.isAvailable,
    required this.category,
    required this.activesStatus,
    required this.diploma,
    required this.bio,
    required this.officialDoc,
    required this.province,
    required this.city,
    required this.district,
    this.latitude,
    this.longitude,
    required this.experience,
    this.rating,
    this.reviewCount,
    this.followers,
    this.availability,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    // Extract user data - backend sends User embedded
    User userData;

    if (json['User'] != null && json['User'] is Map<String, dynamic>) {
      final userMap = json['User'] as Map<String, dynamic>;
      userData = User(
        idUser: userMap['ID'] ?? userMap['id'] ?? 0,
        firstName: userMap['FirstName'] ?? userMap['firstName'] ?? '',
        middleName: userMap['MiddleName'] ?? userMap['middleName'] ?? '',
        lastName: userMap['LastName'] ?? userMap['lastName'] ?? '',
        username: userMap['Username'] ?? userMap['username'] ?? '',
        email: userMap['Email'] ?? userMap['email'] ?? '',
        password: '',
        creationDate: _parseDate(userMap['CreationDate'] ?? userMap['creationDate']),
        phoneNumber: userMap['PhoneNumber'] ?? userMap['phoneNumber'] ?? '',
        avatarUrl: userMap['AvatarURL'] ?? userMap['avatarUrl'] ?? '',
        role: userMap['Role'] ?? userMap['role'] ?? 'artisan',
      );
    } else {
      // Fallback: data might be flat
      userData = User(
        idUser: json['ID'] ?? json['id'] ?? 0,
        firstName: json['FirstName'] ?? json['firstName'] ?? '',
        middleName: json['MiddleName'] ?? json['middleName'] ?? '',
        lastName: json['LastName'] ?? json['lastName'] ?? '',
        username: json['Username'] ?? json['username'] ?? '',
        email: json['Email'] ?? json['email'] ?? '',
        password: '',
        creationDate: _parseDate(json['CreationDate'] ?? json['creationDate']),
        phoneNumber: json['PhoneNumber'] ?? json['phoneNumber'] ?? '',
        avatarUrl: json['AvatarURL'] ?? json['avatarUrl'] ?? '',
        role: json['Role'] ?? json['role'] ?? 'artisan',
      );
    }

    // Parse availability if present - FIXED type conversion
    List<Map<String, dynamic>>? availabilityData;
    if (json['availability'] != null && json['availability'] is List) {
      availabilityData = (json['availability'] as List).map((item) {
        if (item is Map) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }

    // Get review count - backend might send it as part of rating calculation
    int reviewCount = 0;
    if (json['reviewCount'] != null) {
      reviewCount = json['reviewCount'] is int ? json['reviewCount'] : int.tryParse(json['reviewCount'].toString()) ?? 0;
    }

    return Artisan(
      user: userData,
      status: json['Status'] ?? json['status'] ?? 'pending',
      isAvailable: json['IsAvailable'] ?? json['isAvailable'] ?? false,
      category: json['Category'] ?? json['category'] ?? '',
      activesStatus: json['ActivesStatus'] ?? json['activesStatus'] ?? 'inactive',
      diploma: json['Diploma'] ?? json['diploma'] ?? '',
      bio: json['Bio'] ?? json['bio'] ?? '',
      officialDoc: json['OfficialDoc'] ?? json['officialDoc'] ?? '',
      province: json['Province'] ?? json['province'] ?? '',
      city: json['City'] ?? json['city'] ?? '',
      district: json['District'] ?? json['district'] ?? '',
      latitude: (json['Latitude'] ?? json['latitude'])?.toDouble(),
      longitude: (json['Longitude'] ?? json['longitude'])?.toDouble(),
      experience: json['Experience'] ?? json['experience'] ?? 0,
      rating: (json['Rating'] ?? json['rating'])?.toDouble(),
      reviewCount: reviewCount,
      followers: json['Followers'] ?? json['followers'],
      availability: availabilityData,
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    }
    return DateTime.now();
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
      'isAvailable': isAvailable,
      'bio': bio,
      'officialDoc': officialDoc,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Helper getters for UI compatibility
  String get fullName => '${user.firstName} ${user.lastName}'.trim();
  String get fullAddress => '$province, $city, $district';
  String get location => fullAddress;
  String get phone => user.phoneNumber;
  String get email => user.email;
  int get id => user.idUser;

  // Only show artisans with status 'active'
  bool get isActive => status == 'active' && (activesStatus == 'active' || isAvailable);

  // For search filtering - only show approved artisans
  bool get isApproved => status == 'active';

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
    String? officialDoc,
    String? province,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    int? experience,
    double? rating,
    int? reviewCount,
    List<dynamic>? followers,
    List<Map<String, dynamic>>? availability,
  }) {
    return Artisan(
      user: user ?? this.user,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      activesStatus: activesStatus ?? this.activesStatus,
      diploma: diploma ?? this.diploma,
      bio: bio ?? this.bio,
      officialDoc: officialDoc ?? this.officialDoc,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      followers: followers ?? this.followers,
      availability: availability ?? this.availability,
    );
  }
}