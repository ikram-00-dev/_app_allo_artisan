// lib/controllers/artisan_public_profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'artisan_controller.dart';

class ArtisanPublicProfileController extends GetxController {
  final ArtisanController artisanController = Get.find<ArtisanController>();

  // UI State
  var showProfileDetails = false.obs;
  var showCalendarDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Ensure artisan data is loaded
    if (artisanController.artisan.value == null && Get.arguments != null) {
      final artisanId = Get.arguments is int
          ? Get.arguments as int
          : Get.arguments['artisanId'] as int;
      artisanController.loadArtisanById(artisanId);
    }
  }

  String getInitials() {
    final artisan = artisanController.artisan.value;
    if (artisan == null) return '?';
    final fullName = artisan.fullName;
    if (fullName.isEmpty) return '?';
    List<String> parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  bool get isActive {
    return artisanController.artisan.value?.activesStatus == 'active';
  }

  double get rating {
    return artisanController.artisan.value?.rating ?? 4.5;
  }

  int get reviewCount {
    return artisanController.artisan.value?.reviewCount ?? 0;
  }

  String get category {
    return artisanController.artisan.value?.category ?? 'Artisan';
  }

  String get location {
    final artisan = artisanController.artisan.value;
    if (artisan == null) return '';
    final province = artisan.province ?? '';
    final city = artisan.city ?? '';
    if (province.isNotEmpty && city.isNotEmpty) {
      return '$province, $city';
    }
    return province.isNotEmpty ? province : city;
  }

  String get fullName {
    return artisanController.artisan.value?.fullName ?? 'Artisan';
  }

  String get bio {
    return artisanController.artisan.value?.bio ?? 'Aucune description disponible.';
  }

  String get diploma {
    return artisanController.artisan.value?.diploma ?? 'Non spécifié';
  }

  int get experience {
    return artisanController.artisan.value?.experience ?? 0;
  }

  String get phone {
    final phoneNumber = artisanController.artisan.value?.user.phoneNumber ?? '';
    return phoneNumber.isNotEmpty ? phoneNumber : 'Non renseigné';
  }

  String get email {
    return artisanController.artisan.value?.email ?? 'Non renseigné';
  }

  String get statusText {
    return isActive ? 'Actif' : 'Inactif';
  }

  Color get statusColor {
    return isActive ? Colors.green : Colors.red;
  }

  bool get isFollowing {
    return artisanController.isFollowing.value;
  }

  List<dynamic> get posts {
    return artisanController.posts;
  }

  List<Map<String, dynamic>> get availability {
    return artisanController.availability;
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void toggleProfileDetails() {
    showProfileDetails.value = !showProfileDetails.value;
  }

  void toggleCalendarDetails() {
    showCalendarDetails.value = !showCalendarDetails.value;
  }

  void toggleFollow() {
    final artisanId = artisanController.artisan.value?.id;
    if (artisanId != null) {
      artisanController.toggleFollow(artisanId);
    }
  }

  void sendMessage() {
    final artisan = artisanController.artisan.value;
    if (artisan != null) {
      Get.toNamed("/messages", arguments: {
        'artisanId': artisan.id,
        'artisanName': artisan.fullName
      });
    }
  }

  void goBack() {
    Get.back();
  }
}