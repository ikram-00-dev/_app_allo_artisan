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

      // Auto-navigate based on saved role
      _navigateBasedOnRole(role.value);
    }
  }

  // ============================================================
  // LOGIN - FIXED to use selected role
  // ============================================================
  Future<bool> login({
    required String email,
    required String password,
    required String userRole,
  }) async {
    try {
      isLoading.value = true;

      debugPrint('Login attempt with selected role: $userRole');

      final response = await ApiService.login(
        email: email,
        password: password,
        role: userRole,
      );

      debugPrint('Login response: $response');

      // Check if response contains token
      if (response['token'] == null) {
        throw Exception('Invalid response from server');
      }

      token.value = response['token'];

      // CRITICAL: Use the SELECTED role from login screen, NOT from backend
      // Convert 'clients' -> 'client' and 'artisans' -> 'artisan' for navigation
      String selectedRoleForNav = '';
      if (userRole == 'clients') {
        selectedRoleForNav = 'client';
      } else if (userRole == 'artisans') {
        selectedRoleForNav = 'artisan';
      } else {
        selectedRoleForNav = userRole.toLowerCase();
      }

      role.value = selectedRoleForNav;
      debugPrint('Using selected role: $selectedRoleForNav');

      // Save role to storage immediately
      await StorageService.saveRole(selectedRoleForNav);

      // Save user data if available
      final userData = response['user'];
      if (userData != null) {
        user.value = userData;
        await StorageService.saveUser(userData);
      }

      Get.snackbar(
        "Succès",
        "Connexion réussie en tant que $selectedRoleForNav",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Navigate based on SELECTED role
      if (selectedRoleForNav == "artisan") {
        debugPrint('Navigating to Artisan Home (selected role: artisan)');
        Get.offAllNamed("/artisan-home");
      } else {
        debugPrint('Navigating to Client Home (selected role: client)');
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


  // In auth_controller.dart, update registerClient and registerArtisan methods:

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

      debugPrint('Registering client with: email=$email');

      final response = await ApiService.registerClient(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );

      debugPrint('Registration response: $response');

      Get.snackbar(
        "Succès",
        "Compte client créé avec succès!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // AUTO-LOGIN after registration with 'clients' role
      final loginSuccess = await login(
        email: email,
        password: password,
        userRole: 'clients',  // ← Important: use 'clients' not 'client'
      );

      return loginSuccess;
    } catch (e) {
      debugPrint('Register error: $e');
      Get.snackbar(
        "Erreur",
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

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
    String? diplomaUrl,  // ADD THIS
    String? officialDocUrl, // ADD THIS
    String? diploma,
    int? experience,
  }) async {
    try {
      isLoading.value = true;

      debugPrint('Registering artisan with: email=$email');

      final response = await ApiService.registerArtisan(
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
        diplomaUrl: diplomaUrl,  // ADD THIS
        officialDocUrl: officialDocUrl, // ADD THIS
        experience: experience,
      );

      debugPrint('Registration response: $response');

      Get.snackbar(
        "Succès",
        "Compte artisan créé avec succès!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // AUTO-LOGIN after registration with 'artisans' role
      final loginSuccess = await login(
        email: email,
        password: password,
        userRole: 'artisans',  // ← Important: use 'artisans' not 'artisan'
      );

      return loginSuccess;
    } catch (e) {
      debugPrint('Register error: $e');
      Get.snackbar(
        "Erreur",
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  // Helper method for navigation based on role
  void _navigateBasedOnRole(String role) {
    if (role == "artisan") {
      Get.offAllNamed("/artisan-home");
    } else {
      Get.offAllNamed("/client-home");
    }
  }
  // ============================================================
  Future<void> loadCurrentUser() async {
    try {
      final response = await ApiService.getCurrentUser();
      debugPrint('Current user response: $response');
      user.value = response;

      // Don't override role from backend if we already have it
      // Only set if not already set
      if (role.value.isEmpty) {
        if (response['Role'] != null) {
          role.value = response['Role'].toString().toLowerCase();
        } else if (response['role'] != null) {
          role.value = response['role'].toString().toLowerCase();
        }
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