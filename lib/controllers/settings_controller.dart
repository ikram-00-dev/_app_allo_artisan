import 'package:get/get.dart';
import '../services/api_service.dart';

class SettingsController extends GetxController {
  final ApiService api;

  SettingsController(this.api);

  // =====================
  // STATE
  // =====================
  var isLoading = false.obs;

  var name = ''.obs;
  var phone = ''.obs;
  var zone = ''.obs;
  var bio = ''.obs;
  var birthdate = ''.obs;
  var location = ''.obs;

  var selectedLanguage = 'fr'.obs;

  var currentPassword = '';
  var newPassword = '';
  var confirmPassword = '';

  var newEmail = '';
  var emailPassword = '';

  // =====================
  // LOAD PROFILE
  // =====================
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final res = await ApiService.get("/users/profile");

      name.value = res['name'] ?? '';
      phone.value = res['phone'] ?? '';
      zone.value = res['zone'] ?? '';
      bio.value = res['bio'] ?? '';
      birthdate.value = res['birthdate'] ?? '';
      location.value = res['location'] ?? '';
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile");
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // UPDATE PROFILE
  // =====================
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      await ApiService.put("/users/profile", {
        "name": name.value,
        "phone": phone.value,
        "zone": zone.value,
        "bio": bio.value,
        "birthdate": birthdate.value,
        "location": location.value,
      });

      Get.snackbar("Success", "Profile updated");
    } catch (e) {
      Get.snackbar("Error", "Update failed");
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // CHANGE PASSWORD
  // =====================
  Future<void> changePassword() async {
    try {
      isLoading.value = true;

      await ApiService.put("/users/password", {
        "current_password": currentPassword,
        "new_password": newPassword,
      });

      Get.snackbar("Success", "Password updated");
    } catch (e) {
      Get.snackbar("Error", "Password update failed");
    } finally {
      isLoading.value = false;
    }
  }

  // =====================
  // CHANGE EMAIL
  // =====================
  Future<void> changeEmail() async {
    try {
      isLoading.value = true;

      await ApiService.put("/users/email", {
        "email": newEmail,
        "password": emailPassword,
      });

      Get.snackbar("Success", "Email updated");
    } catch (e) {
      Get.snackbar("Error", "Email update failed");
    } finally {
      isLoading.value = false;
    }
  }
}