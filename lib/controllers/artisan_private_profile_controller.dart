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

  Future<void> createPost() async {
    if (postContent.value.trim().isEmpty) {
      Get.snackbar("Erreur", "Veuillez écrire quelque chose");
      return;
    }

    isCreatingPost.value = true;
    bool success = await artisanController.createPost(
      postContent.value.trim(),
      null, // You can add image picker here later
    );
    isCreatingPost.value = false;

    if (success) {
      postContent.value = '';
    }
  }

  String getInitials() {
    if (artisanController.artisan.value == null) return "?";
    final firstName = artisanController.artisan.value!.user.firstName?? "";
    final lastName = artisanController.artisan.value!.user.lastName ?? "";
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return "${firstName[0]}${lastName[0]}".toUpperCase();
    }
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : "?";
  }

  String getFullName() {
    if (artisanController.artisan.value == null) return "Chargement...";
    return "${artisanController.artisan.value!.user.firstName ?? ''} ${artisanController.artisan.value!.user.lastName ?? ''}".trim();
  }

  String getCategory() {
    return artisanController.artisan.value?.category ?? "Artisan";
  }

  double getRating() {
    return artisanController.artisan.value?.rating ?? 4.5;
  }

  String getEmail() {
    return artisanController.artisan.value?.email ?? "email@exemple.com";
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