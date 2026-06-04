// lib/controllers/artisan_private_profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'artisan_controller.dart';

class ArtisanPrivateProfileController extends GetxController {
  final ArtisanController artisanController = Get.find<ArtisanController>();

  // Local UI state
  var showAvailability = false.obs;
  var showFollowers = false.obs;
  var postContent = ''.obs;
  var isCreatingPost = false.obs;

  // Calendar data derived from artisanController
  RxMap<DateTime, Map<String, dynamic>> dayStatus = <DateTime, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to artisan availability changes
    ever(artisanController.availability, (_) => _syncCalendarData());
    _syncCalendarData();
  }

  void _syncCalendarData() {
    dayStatus.clear();
    for (var day in artisanController.availability) {
      if (day['date'] != null) {
        final date = day['date'] as DateTime;
        dayStatus[date] = {
          'available': day['available'] ?? true,
          'note': day['note'] ?? '',
        };
      }
    }
  }

  void toggleDay(DateTime date) {
    artisanController.toggleDayAvailability(date);
  }

  void openNoteDialog(DateTime date, BuildContext context) {
    final TextEditingController noteController = TextEditingController(
      text: dayStatus[date]?['note'] ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: Text("Note pour le ${date.day}/${date.month}/${date.year}"),
        content: TextField(
          controller: noteController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Ajouter des détails (ex: rendez-vous, congé, etc.)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              artisanController.updateDayNote(date, noteController.text.trim());
              Get.back();
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  // DYNAMIC - Get initials from registered artisan
  String getInitials() {
    if (artisanController.artisan.value == null) return "?";
    final firstName = artisanController.artisan.value!.user.firstName ??
        artisanController.artisan.value!.user.firstName ?? '';
    final lastName = artisanController.artisan.value!.user.lastName ??
        artisanController.artisan.value!.user.lastName?? '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return "${firstName[0]}${lastName[0]}".toUpperCase();
    }
    if (firstName.isNotEmpty) return firstName[0].toUpperCase();
    if (lastName.isNotEmpty) return lastName[0].toUpperCase();
    return "?";
  }

  // DYNAMIC - Get full name from registered artisan
  String getFullName() {
    if (artisanController.artisan.value == null) return "Chargement...";
    final firstName = artisanController.artisan.value!.user.firstName ??
        artisanController.artisan.value!.user.firstName ?? '';
    final lastName = artisanController.artisan.value!.user.lastName ??
        artisanController.artisan.value!.user.lastName ?? '';
    return "$firstName $lastName".trim();
  }

  // DYNAMIC - Get category from registered artisan
  String getCategory() {
    return artisanController.artisan.value?.category ?? "Artisan";
  }

  // DYNAMIC - Get rating from registered artisan
  double getRating() {
    return artisanController.artisan.value?.rating ?? 0.0;
  }

  // DYNAMIC - Get email from registered artisan
  String getEmail() {
    return artisanController.artisan.value?.user.email ??
        artisanController.artisan.value?.email ??
        "email@exemple.com";
  }

  // DYNAMIC - Get phone number from registered artisan
  String getPhoneNumber() {
    return artisanController.artisan.value?.user.phoneNumber ??
        artisanController.artisan.value?.user.phoneNumber ??
        "Non renseigné";
  }

  // DYNAMIC - Get bio from registered artisan
  String getBio() {
    return artisanController.artisan.value?.bio ?? "Aucune bio pour le moment";
  }

  // DYNAMIC - Get experience from registered artisan
  String getExperience() {
    final exp = artisanController.artisan.value?.experience ?? 0;
    if (exp == 0) return "Non renseignée";
    if (exp == 1) return "1 an";
    return "$exp ans";
  }

  // DYNAMIC - Get diploma from registered artisan
  String getDiploma() {
    return artisanController.artisan.value?.diploma ?? "Non renseigné";
  }

  // DYNAMIC - Get location (city + province)
  String getLocation() {
    final city = artisanController.artisan.value?.city ?? "";
    final province = artisanController.artisan.value?.province ?? "";
    if (city.isNotEmpty && province.isNotEmpty) return "$city, $province";
    if (city.isNotEmpty) return city;
    if (province.isNotEmpty) return province;
    return "Localisation non renseignée";
  }

  // DYNAMIC - Get service zone
  String getServiceZone() {
    return artisanController.artisan.value?.district ?? "5km";
  }

  // DYNAMIC - Get avatar URL
  String getAvatarUrl() {
    return artisanController.artisan.value?.user.avatarUrl ??
        artisanController.artisan.value?.avatarUrl ?? '';
  }

  int getFollowersCount() {
    return artisanController.followers.length;
  }

  List<Map<String, dynamic>> getFollowers() {
    return artisanController.followers;
  }

  List<Map<String, dynamic>> getCurrentMonthDays() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    List<Map<String, dynamic>> calendarDays = [];

    // Add empty cells for days before month starts
    for (int i = 1; i < startingWeekday; i++) {
      calendarDays.add({'isEmpty': true});
    }

    // Add actual days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final status = dayStatus[date];
      calendarDays.add({
        'isEmpty': false,
        'day': day,
        'date': date,
        'available': status?['available'] ?? true,
        'hasNote': (status?['note']?.isNotEmpty ?? false),
      });
    }

    return calendarDays;
  }
}