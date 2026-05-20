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
  }) async {
    try {
      isLoading.value = true;

      final response = await ApiService.login(
        email: email,
        password: password,
      );

      debugPrint('Login response: $response');

      // Check if response contains token
      if (response['token'] == null) {
        throw Exception('Invalid response from server');
      }

      token.value = response['token'];

      // Extract role from user object
      final userData = response['user'];
      if (userData != null) {
        final userRole = userData['Role'] ?? userData['role'] ?? '';
        role.value = userRole.toString().toLowerCase();
        user.value = userData;

        await StorageService.saveRole(role.value);
        await StorageService.saveUser(userData);
      }

      Get.snackbar(
        "Succès",
        "Connexion réussie",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Redirect based on role
      if (role.value == "artisan") {
        Get.offAllNamed("/artisan-home");
      } else {
        Get.offAllNamed("/client-home");
      }

      return true;
    } catch (e) {
      debugPrint('Login error: $e');
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
    required String firstName,
    String? middleName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      isLoading.value = true;

      debugPrint('Registering client with: first=$firstName, last=$lastName, email=$email');

      await ApiService.registerClient(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );

      debugPrint('Registration successful');

      Get.snackbar(
        "Succès",
        "Compte client créé avec succès",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      Get.snackbar(
        "Erreur",
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    String? middleName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    required String category,
    required String province,
    required String city,
    required String district,
    String? avatarUrl,
    String? diploma,
    int? experience,
  }) async {
    try {
      isLoading.value = true;

      debugPrint('Registering artisan: $firstName $lastName, email=$email');

      await ApiService.registerArtisan(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        category: category,
        province: province,
        city: city,
        district: district,
        avatarUrl: avatarUrl,
        diploma: diploma,
        experience: experience,
      );

      debugPrint('Artisan registration successful');

      Get.snackbar(
        "Succès",
        "Compte artisan créé avec succès",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      Get.snackbar(
        "Erreur",
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      debugPrint('Current user response: $response');
      user.value = response;
      if (response['Role'] != null) {
        role.value = response['Role'].toString().toLowerCase();
      } else if (response['role'] != null) {
        role.value = response['role'].toString().toLowerCase();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
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

    Get.offAllNamed("/login");

    Get.snackbar(
      "Déconnexion",
      "Vous avez été déconnecté",
      snackPosition: SnackPosition.TOP,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  bool get isClient => role.value == 'client';
  bool get isArtisan => role.value == 'artisan';
  bool get isLoggedIn => token.value.isNotEmpty;
}