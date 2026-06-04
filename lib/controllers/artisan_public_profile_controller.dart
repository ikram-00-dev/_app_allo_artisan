// lib/controllers/artisan_public_profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'artisan_controller.dart';
import '../routes/app_routes.dart';
import '../models/post.dart';

class ArtisanPublicProfileController extends GetxController {
  final ArtisanController artisanController = Get.find<ArtisanController>();

  var showProfileDetails = false.obs;
  var showCalendarDetails = false.obs;
  var isFollowing = false.obs;

  String get fullName => artisanController.artisan.value?.fullName ?? 'Artisan';
  String get category => artisanController.artisan.value?.category ?? 'Artisan';
  String get location => artisanController.artisan.value?.fullAddress ?? 'Localisation';
  double get rating => artisanController.artisan.value?.rating ?? 0.0;
  int get reviewCount => artisanController.artisan.value?.reviewCount ?? 0;
  String get bio => artisanController.artisan.value?.bio ?? 'Aucune description';
  String get diploma => artisanController.artisan.value?.diploma ?? 'Non renseigné';
  int get experience => artisanController.artisan.value?.experience ?? 0;
  String get phone => artisanController.artisan.value?.user.phoneNumber ?? 'Non renseigné';
  String get email => artisanController.artisan.value?.user.email ?? 'Non renseigné';

  bool get isActive => artisanController.artisan.value?.activesStatus == 'active';

  Color get statusColor => isActive ? Colors.green : Colors.grey;
  String get statusText => isActive ? 'Actif' : 'Inactif';

  var availability = <Map<String, dynamic>>[].obs;
  var posts = <PostModel>[].obs;

  String getInitials() {
    final artisan = artisanController.artisan.value;
    if (artisan != null) {
      String firstInitial = artisan.user.firstName.isNotEmpty ? artisan.user.firstName[0].toUpperCase() : '';
      String lastInitial = artisan.user.lastName.isNotEmpty ? artisan.user.lastName[0].toUpperCase() : '';
      if (firstInitial.isNotEmpty && lastInitial.isNotEmpty) {
        return '$firstInitial$lastInitial';
      }
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A';
  }

  void toggleProfileDetails() {
    showProfileDetails.toggle();
  }

  void toggleCalendarDetails() {
    showCalendarDetails.toggle();
  }

  void toggleFollow() async {
    isFollowing.toggle();
    if (isFollowing.value) {
      Get.snackbar('Suivi', 'Vous suivez maintenant cet artisan', backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Suivi', 'Vous ne suivez plus cet artisan', backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  void sendMessage() {
    final artisan = artisanController.artisan.value;
    if (artisan != null) {
      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          'contactId': artisan.id,
          'contactName': artisan.fullName,
        },
      );
    }
  }

  void goBack() {
    Get.back();
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void onInit() {
    super.onInit();
    ever(artisanController.artisan, (_) {
      if (artisanController.artisan.value != null) {
        availability.value = artisanController.availability;
        posts.value = artisanController.posts;
      }
    });
  }
}