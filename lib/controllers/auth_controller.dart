import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================
  var isLoading = false.obs;
  var token = ''.obs;
  var role = ''.obs;
  var user = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final savedToken = await StorageService.getToken();
    final savedRole = await StorageService.getRole();

    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      role.value = savedRole ?? '';
      await loadCurrentUser();
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================
  Future<bool> login({
    required String email,
    required String password,
    required String userRole,
  }) async {
    try {
      isLoading.value = true;

      final response = await ApiService.login(
        email: email,
        password: password,
        role: userRole,
      );

      token.value = response['token'];
      role.value = userRole;
      user.value = response['user'];

      await StorageService.saveRole(userRole);

      Get.snackbar(
        "Succès",
        "Connexion réussie",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Redirect based on role
      if (userRole == "clients") {
        Get.offAllNamed("/client-home");
      } else if (userRole == "artisans") {
        Get.offAllNamed("/artisan-home");
      } else {
        Get.offAllNamed("/admin-home");
      }

      return true;
    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REGISTER CLIENT
  // ============================================================
  Future<bool> registerClient({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      isLoading.value = true;

      await ApiService.registerClient(
        username: username,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      Get.snackbar("Succès", "Compte client créé avec succès");
      Get.back(); // Return to login
      return true;
    } catch (e) {
      Get.snackbar("Erreur", e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // REGISTER ARTISAN
  // ============================================================
  Future<bool> registerArtisan({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required String category,
    required String wilaya,
    required String baladeya,
    required String zone,
    String? photoUrl,
  }) async {
    try {
      isLoading.value = true;

      await ApiService.registerArtisan(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        category: category,
        wilaya: wilaya,
        baladeya: baladeya,
        zone: zone,
        photoUrl: photoUrl,
      );

      Get.snackbar("Succès", "Compte artisan créé avec succès");
      Get.back();
      return true;
    } catch (e) {
      Get.snackbar("Erreur", e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD CURRENT USER
  // ============================================================
  Future<void> loadCurrentUser() async {
    try {
      final response = await ApiService.getCurrentUser();
      user.value = response;
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  Future<void> logout() async {
    await ApiService.clearToken();
    token.value = '';
    role.value = '';
    user.value = null;

    Get.offAllNamed("/login-role");

    Get.snackbar(
      "Déconnexion",
      "Vous avez été déconnecté",
      snackPosition: SnackPosition.TOP,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  bool get isClient => role.value == 'clients';
  bool get isArtisan => role.value == 'artisans';
  bool get isAdmin => role.value == 'administrators';
  bool get isLoggedIn => token.value.isNotEmpty;
}