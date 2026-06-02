// switch_account_controller.dart
import 'package:flutter/material.dart'; // ← ADD THIS IMPORT
import 'package:get/get.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class SwitchAccountController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  var isLoading = false.obs;
  var hasArtisanAccount = false.obs;
  var checkingAccount = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (authController.isClient) {
      checkArtisanAccountExists();
    }
  }

  // Check if client has an artisan account with same email/phone
  Future<void> checkArtisanAccountExists() async {
    if (!authController.isClient) return;

    checkingAccount.value = true;
    try {
      final userEmail = authController.user.value?['email'] ?? '';
      final userPhone = authController.user.value?['phoneNumber'] ?? '';

      // Fetch all artisans to check if any matches client's email or phone
      final artisans = await ApiService.getAllArtisans();

      hasArtisanAccount.value = artisans.any((artisan) {
        final artisanEmail = artisan['User']?['Email']?.toString().toLowerCase() ??
            artisan['email']?.toString().toLowerCase() ?? '';
        final artisanPhone = artisan['User']?['PhoneNumber']?.toString() ??
            artisan['phoneNumber']?.toString() ?? '';

        return artisanEmail == userEmail.toLowerCase() ||
            artisanPhone == userPhone;
      });

    } catch (e) {
      print('Error checking artisan account: $e');
      hasArtisanAccount.value = false;
    } finally {
      checkingAccount.value = false;
    }
  }

  // Switch from client to artisan
  Future<void> switchToArtisan() async {
    if (hasArtisanAccount.value) {
      // Direct switch if artisan account exists
      await performSwitch('artisan');
    } else {
      // Show dialog to create artisan account
      _showCreateArtisanAccountDialog();
    }
  }

  // Direct switch for artisan to client
  Future<void> switchToClient() async {
    await performSwitch('client');
  }

  // Perform the actual role switch
  Future<void> performSwitch(String newRole) async {
    try {
      isLoading.value = true;

      // Get current user data
      final currentUser = authController.user.value;
      if (currentUser == null) {
        throw Exception('User data not found');
      }

      // For artisan switching to client, we need to ensure client exists
      if (newRole == 'client') {
        // Check if client account exists with same email/phone
        final clientExists = await _checkClientAccountExists(
          currentUser['email'] ?? '',
          currentUser['phoneNumber'] ?? '',
        );

        if (!clientExists) {
          Get.dialog(
            AlertDialog(
              title: const Text('Compte Client Introuvable'),
              content: const Text(
                'Vous n\'avez pas encore de compte client. '
                    'Veuillez créer un compte client d\'abord.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Fermer'),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    _navigateToClientRegistration();
                  },
                  child: const Text('Créer un compte'),
                ),
              ],
            ),
          );
          return;
        }
      }

      // Perform the switch using auth controller
      await authController.switchRole(newRole);

    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de changer de rôle: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if client account exists with given email/phone
  Future<bool> _checkClientAccountExists(String email, String phone) async {
    try {
      // Try to fetch clients list or use API endpoint if available
      // This is a placeholder - implement based on your backend API
      // You might need to add a getClientByEmail endpoint
      final response = await ApiService.get('/clients/check?email=$email&phone=$phone');
      return response['exists'] ?? false;
    } catch (e) {
      print('Error checking client account: $e');
      return false;
    }
  }

  // Show dialog to create artisan account
  void _showCreateArtisanAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Devenir Artisan'),
        content: const Text(
          'Vous n\'avez pas encore de compte artisan. '
              'Souhaitez-vous créer un compte artisan maintenant ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _navigateToArtisanRegistration();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Créer un compte Artisan'),
          ),
        ],
      ),
    );
  }

  void _navigateToArtisanRegistration() {
    // Navigate to artisan registration screen
    Get.toNamed('/artisan-register', arguments: {
      'fromSwitch': true,
      'clientData': authController.user.value,
    });
  }

  void _navigateToClientRegistration() {
    Get.toNamed('/client-register', arguments: {
      'fromSwitch': true,
      'artisanData': authController.user.value,
    });
  }

  // Switch based on current role
  Future<void> switchAccount() async {
    if (authController.isClient) {
      await switchToArtisan();
    } else if (authController.isArtisan) {
      await switchToClient();
    }
  }
}