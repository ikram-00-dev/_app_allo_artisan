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
      if (savedRole != null) {
        role.value = savedRole;
      }
      await loadCurrentUser();
      _navigateBasedOnRole(role.value);
    }
  }

  Future<void> setAdminMode() async {
    role.value = 'admin';
    await StorageService.saveRole('admin');
    token.value = 'admin_token';
    user.value = {
      'email': 'ikram2005@gmail.com',
      'role': 'admin',
      'firstName': 'Admin',
      'lastName': 'System',
      'id': 1,
    };
    await StorageService.saveUser(user.value!);
  }

  Future<void> setModeratorMode() async {
    role.value = 'moderator';
    await StorageService.saveRole('moderator');
    token.value = 'moderator_session_token';
    user.value = {
      'email': 'amiraamira@gmail.com',
      'role': 'moderator',
      'firstName': 'Amira',
      'lastName': 'Moderator',
      'id': 2,
    };
    await StorageService.saveUser(user.value!);
    debugPrint('✅ Moderator mode set in AuthController');
  }

  // ============================================================
  // LOGIN
  // ============================================================
  // Replace the login method in AuthController with:

  Future<bool> login({
    required String email,
    required String password,
    required String userRole,
  }) async {
    try {
      isLoading.value = true;

      debugPrint('Login attempt with selected role: $userRole');
      debugPrint('Email: $email');

      final response = await ApiService.login(
        email: email,
        password: password,
        role: userRole,  // ✅ Pass role to API
      );

      debugPrint('Login response: $response');

      if (response['token'] == null) {
        throw Exception('Invalid response from server');
      }

      token.value = response['token'];
      role.value = userRole;
      debugPrint('Using selected role: ${role.value}');

      await StorageService.saveToken(response['token']);
      await StorageService.saveRole(userRole);

      // Handle user data from response
      final userData = response['user'];
      if (userData != null && userData is Map<String, dynamic>) {
        Map<String, dynamic> enhancedUserData = Map.from(userData);

        // Normalize ID field
        if (enhancedUserData['ID'] != null && enhancedUserData['id'] == null) {
          enhancedUserData['id'] = enhancedUserData['ID'];
        }
        if (enhancedUserData['id'] != null && enhancedUserData['clientId'] == null) {
          enhancedUserData['clientId'] = enhancedUserData['id'];
        }

        user.value = enhancedUserData;
        await StorageService.saveUser(enhancedUserData);

        debugPrint('✅ User data saved: id=${enhancedUserData['id']}, role=${enhancedUserData['role']}');
      }

      Get.snackbar(
        "Succès",
        "Connexion réussie en tant que $userRole",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      if (userRole == "artisan") {
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
  // SMART LOGIN - PRESERVED FROM ORIGINAL
  // ============================================================
  Future<bool> smartLogin({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final bool isEmail = emailOrPhone.contains('@') && emailOrPhone.contains('.');
      final String email = isEmail ? emailOrPhone : '';
      final String phone = !isEmail ? emailOrPhone : '';

      debugPrint('Smart login with: $emailOrPhone (${isEmail ? "email" : "phone"})');

      List<String> rolesToTry = ['client', 'artisan'];

      for (String roleToTry in rolesToTry) {
        try {
          final response = await ApiService.login(
            email: email,
            password: password,
            role: roleToTry,
          );

          if (response['token'] != null) {
            token.value = response['token'];
            role.value = roleToTry;

            await StorageService.saveToken(response['token']);
            await StorageService.saveRole(roleToTry);

            final userData = response['user'];
            if (userData != null && userData is Map<String, dynamic>) {
              user.value = userData;
              await StorageService.saveUser(userData);
            }

            Get.snackbar(
              "Succès",
              "Connexion réussie",
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            if (roleToTry == "artisan") {
              Get.offAllNamed("/artisan-home");
            } else {
              Get.offAllNamed("/client-home");
            }

            return true;
          }
        } catch (e) {
          debugPrint('Failed as $roleToTry: $e');
        }
      }

      throw Exception('Email/Phone or password incorrect');
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
  // SWITCH ROLE - PRESERVED FROM ORIGINAL
  // ============================================================
  Future<void> switchRole(String newRole) async {
    try {
      if (role.value == newRole) {
        Get.snackbar(
          "Information",
          "Vous êtes déjà en mode ${newRole == 'artisan' ? 'Artisan' : 'Client'}",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      isLoading.value = true;
      role.value = newRole;
      await StorageService.saveRole(newRole);

      Get.snackbar(
        "Mode changé",
        "Vous êtes maintenant en mode ${newRole == 'artisan' ? 'Artisan' : 'Client'}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      _navigateBasedOnRole(newRole);
    } catch (e) {
      debugPrint('Error switching role: $e');
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
    String? email,
    String? phoneNumber,
    required String password,
    String? avatarUrl,
  }) async {
    try {
      if ((email == null || email.trim().isEmpty) &&
          (phoneNumber == null || phoneNumber.trim().isEmpty)) {
        Get.snackbar(
          "Erreur",
          "Veuillez fournir au moins un email ou un numéro de téléphone",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      isLoading.value = true;

      final String finalEmail = (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : "${username}@temp.user";

      final String finalPhone = (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          ? phoneNumber.trim()
          : '';

      final response = await ApiService.registerClient(
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        username: username,
        email: finalEmail,
        password: password,
        phoneNumber: finalPhone,
        avatarUrl: avatarUrl,
      );

      debugPrint('Registration response: $response');

      if (response['message'] != null || response['user'] != null) {
        Get.snackbar(
          "Succès",
          "Compte client créé avec succès!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final loginSuccess = await login(
          email: finalEmail,
          password: password,
          userRole: 'client',
        );

        return loginSuccess;
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
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
    required String phoneNumber,
    required String password,
    required String category,
    required String province,
    required String city,
    required String district,
    String? avatarUrl,
    String? diplomaUrl,
    String? officialDocUrl,
    int? experience,
  }) async {
    try {
      isLoading.value = true;

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
        diplomaUrl: diplomaUrl,
        officialDocUrl: officialDocUrl,
        experience: experience,
      );

      Get.snackbar(
        "Succès",
        "Compte artisan créé avec succès! En attente d'approbation.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed("/login");
      return true;
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de créer le compte: ${e.toString().replaceFirst('Exception: ', '')}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================
  void _navigateBasedOnRole(String roleValue) {
    if (roleValue == "artisan") {
      Get.offAllNamed("/artisan-home");
    } else if (roleValue == "client") {
      Get.offAllNamed("/client-home");
    }
  }

  Future<void> loadCurrentUser() async {
    try {
      final response = await ApiService.getCurrentUser();
      user.value = response;
      if (role.value.isEmpty && response['role'] != null) {
        role.value = response['role'].toString().toLowerCase();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    token.value = '';
    role.value = '';
    user.value = null;
    Get.offAllNamed("/login");
  }

  // ============================================================
  // GETTERS
  // ============================================================
  bool get isClient => role.value == 'client';
  bool get isArtisan => role.value == 'artisan';
  bool get isLoggedIn => token.value.isNotEmpty;
  // Add to ApiService for testing

}