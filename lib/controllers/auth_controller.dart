import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  // ============================================================
  // STATE - Make sure these are Rx types
  // ============================================================
  var isLoading = false.obs;
  var token = ''.obs;
  var role = ''.obs;  // ✅ This is RxString
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
        role.value = savedRole;  // ✅ Use .value
      }
      await loadCurrentUser();

      // Auto-navigate based on saved role
      _navigateBasedOnRole(role.value);
    }
  }

  Future<void> setAdminMode() async {
    role.value = 'admin';  // ✅ Use .value
    await StorageService.saveRole('admin');
    token.value = 'admin_token';
    user.value = {
      'email': 'ikram2005@gmail.com',
      'role': 'admin',
      'firstName': 'Admin',
      'lastName': 'System',
    };
    await StorageService.saveUser(user.value!);
  }

  Future<void> setModeratorMode() async {
    role.value = 'moderator';  // ✅ Use .value
    await StorageService.saveRole('moderator');
    token.value = 'moderator_session_token';
    user.value = {
      'email': 'amiraamira@gmail.com',
      'role': 'moderator',
      'firstName': 'Amira',
      'lastName': 'Moderator',
    };
    await StorageService.saveUser(user.value!);
    debugPrint('✅ Moderator mode set in AuthController');
  }

  // ============================================================
  // LOGIN - FIXED
  // ============================================================
  // LOGIN - FIXED with better user data storage
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

      if (response['token'] == null) {
        throw Exception('Invalid response from server');
      }

      token.value = response['token'];

      // Convert role for navigation
      String selectedRoleForNav = '';
      if (userRole == 'clients') {
        selectedRoleForNav = 'client';
      } else if (userRole == 'artisans') {
        selectedRoleForNav = 'artisan';
      } else {
        selectedRoleForNav = userRole.toLowerCase();
      }

      role.value = selectedRoleForNav;
      debugPrint('Using selected role: ${role.value}');

      // Save token to storage
      await StorageService.saveToken(response['token']);

      // Save role to storage
      await StorageService.saveRole(selectedRoleForNav);

      // Save user data - CRITICAL FIX
      final userData = response['user'] ?? response;
      if (userData != null && userData is Map<String, dynamic>) {
        // Make sure we have the ID field properly
        Map<String, dynamic> enhancedUserData = Map.from(userData);

        // Ensure we have an 'id' field (not 'ID' or 'clientId')
        if (enhancedUserData['ID'] != null && enhancedUserData['id'] == null) {
          enhancedUserData['id'] = enhancedUserData['ID'];
          debugPrint('✅ Added "id" field from "ID": ${enhancedUserData['id']}');
        }

        if (enhancedUserData['clientId'] != null && enhancedUserData['id'] == null) {
          enhancedUserData['id'] = enhancedUserData['clientId'];
          debugPrint('✅ Added "id" field from "clientId": ${enhancedUserData['id']}');
        }

        // Also ensure clientId field exists for RequestController
        if (enhancedUserData['id'] != null && enhancedUserData['clientId'] == null) {
          enhancedUserData['clientId'] = enhancedUserData['id'];
          debugPrint('✅ Added "clientId" field from "id": ${enhancedUserData['clientId']}');
        }

        user.value = enhancedUserData;
        await StorageService.saveUser(enhancedUserData);

        debugPrint('✅ User data saved to storage:');
        debugPrint('   - id: ${enhancedUserData['id']}');
        debugPrint('   - clientId: ${enhancedUserData['clientId']}');
        debugPrint('   - role: ${enhancedUserData['role']}');
        debugPrint('   - email: ${enhancedUserData['email']}');
      } else {
        debugPrint('⚠️ No user data in response');
      }

      Get.snackbar(
        "Succès",
        "Connexion réussie en tant que $selectedRoleForNav",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Navigate based on role
      if (selectedRoleForNav == "artisan") {
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
  // SMART LOGIN - Complete implementation
  // ============================================================
  Future<bool> smartLogin({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final bool isEmail = emailOrPhone.contains('@') && emailOrPhone.contains('.');

      debugPrint('Smart login with: $emailOrPhone (${isEmail ? "email" : "phone"})');

      // Try both roles
      List<String> rolesToTry = ['clients', 'artisans'];

      for (String roleToTry in rolesToTry) {
        try {
          final response = await ApiService.login(
            email: isEmail ? emailOrPhone : '',
            password: password,
            role: roleToTry,
          );

          if (response['token'] != null) {
            token.value = response['token'];

            String selectedRoleForNav = roleToTry == 'clients' ? 'client' : 'artisan';
            role.value = selectedRoleForNav;  // ✅ Use .value

            await StorageService.saveRole(selectedRoleForNav);

            final userData = response['user'] ?? response;
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

            if (selectedRoleForNav == "artisan") {
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
  // SWITCH ROLE
  // ============================================================
  Future<void> switchRole(String newRole) async {
    try {
      if (role.value == newRole) {  // ✅ Use .value
        Get.snackbar(
          "Information",
          "Vous êtes déjà en mode ${newRole == 'artisan' ? 'Artisan' : 'Client'}",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      isLoading.value = true;
      role.value = newRole;  // ✅ Use .value
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

      Get.snackbar(
        "Succès",
        "Compte client créé avec succès!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return await login(
        email: finalEmail,
        password: password,
        userRole: 'clients',
      );
    } catch (e) {
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
}