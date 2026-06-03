// lib/controllers/request_controller.dart - COMPLETELY FIXED

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import '../models/request_model.dart';
import '../services/storage_service.dart';

class RequestController extends GetxController {
  var isLoading = false.obs;
  var isDeleting = false.obs;
  var isUpdating = false.obs;
  var isCreating = false.obs;

  var requests = <RequestModel>[].obs;
  var myRequests = <RequestModel>[].obs;
  var urgentRequests = <RequestModel>[].obs;
  var normalRequests = <RequestModel>[].obs;

  final List<String> categories = [
    'Plombier',
    'Électricien',
    'Menuisier',
    'Maçon',
    'Peintre en bâtiment',
    'Carreleur',
    'Couvreur',
    'Soudeur',
    'Forgeron',
    'Plaquiste',
    'Coffreur',
    'Technicien CVC',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    await loadAllRequests();
  }

  // Load all requests (for explore feed)
  // Load all requests (for explore feed)
  Future<void> loadAllRequests() async {
    try {
      isLoading.value = true;
      debugPrint('🔄 Loading all requests...');

      final response = await ApiService.getRequests();
      debugPrint('📦 Raw response from API: $response');

      final List<dynamic> responseData = response is List ? response : [];
      debugPrint('📊 Response data length: ${responseData.length}');

      final allRequests = responseData.map((json) {
        debugPrint('📝 Converting JSON to RequestModel: $json');
        return RequestModel.fromJson(json);
      }).toList();

      debugPrint('✅ Converted ${allRequests.length} requests');

      requests.value = allRequests;
      urgentRequests.value = allRequests.where((r) => r.type == 'urgent').toList();
      normalRequests.value = allRequests.where((r) => r.type == 'simple').toList();

      debugPrint('📊 Urgent: ${urgentRequests.length}, Normal: ${normalRequests.length}');
    } catch (e) {
      debugPrint('❌ Error loading requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

// Load client's own requests - FIXED
  // Load client's own requests - FIXED with filter for valid data
  Future<void> loadMyRequests(int clientId) async {
    try {
      isLoading.value = true;
      debugPrint('🔄 Loading requests for client ID: $clientId');

      final response = await ApiService.getRequests();

      final List<dynamic> responseData = response is List ? response : [];
      debugPrint('📊 Total requests from API: ${responseData.length}');

      final allRequests = responseData
          .map((json) => RequestModel.fromJson(json))
          .where((req) =>
      req.clientId == clientId &&
          req.idRequest != null &&
          req.description.isNotEmpty) // Filter out empty demands
          .toList();

      myRequests.value = allRequests;
      debugPrint('✅ Loaded ${myRequests.length} requests for client $clientId');
    } catch (e) {
      debugPrint('❌ Error loading my requests: $e');
      myRequests.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // In request_controller.dart - Update the createRequest method:

// CREATE REQUEST
  // CREATE REQUEST - FIXED VERSION
  // CREATE REQUEST - SIMPLIFIED FIXED VERSION
  Future<bool> createRequest({
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required bool isUrgent,
    int? zoneKm,
    String? imagePath,
    String? priorityLevel,
  }) async {
    try {
      isCreating.value = true;

      final authController = Get.find<AuthController>();
      final user = authController.user.value;

      debugPrint('========== REQUEST CONTROLLER ==========');
      debugPrint('User object: $user');

      // Try multiple possible field names for client ID
      int? clientId = user?['id'] ??
          user?['ID'] ??
          user?['clientId'] ??
          user?['ClientId'] ??
          user?['ClientID'];

      debugPrint('Extracted clientId: $clientId');

      if (clientId == null) {
        debugPrint('❌ ERROR: Could not find clientId. User data: $user');
        Get.snackbar('Erreur', 'Client non identifié. Veuillez vous reconnecter.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }

      debugPrint('✅ Using clientId: $clientId for request creation');

      String? imageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          imageUrl = await ApiService.uploadImage(imagePath);
          debugPrint('✅ Image uploaded: $imageUrl');
        } catch (e) {
          debugPrint('⚠️ Image upload failed (continuing without image): $e');
        }
      }

      // Prepare data with correct field names (lowercase as backend expects)
      final Map<String, dynamic> data = {
        'description': description.trim(),
        'type': isUrgent ? 'urgent' : 'simple',
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'clientId': clientId,  // This matches backend's json:"clientId"
      };

      if (isUrgent && zoneKm != null && zoneKm > 0) {
        data['zoneKm'] = zoneKm;  // Matches backend's json:"zoneKm"
      }

      if (priorityLevel != null && priorityLevel.isNotEmpty) {
        data['priorityLevel'] = priorityLevel;
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        data['imageUrl'] = imageUrl;
      }

      debugPrint('📤 Sending data to ApiService: $data');

      await ApiService.createRequest(data);

      debugPrint('✅ Request created successfully');

      // Refresh the requests lists
      await loadMyRequests(clientId);
      await loadAllRequests();

      Get.snackbar('Succès', 'Demande envoyée avec succès!',
          backgroundColor: Colors.green, colorText: Colors.white);

      return true;
    } catch (e) {
      debugPrint('❌ Error creating request: $e');
      Get.snackbar('Erreur', 'Impossible de créer la demande: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isCreating.value = false;
    }
  }

  // UPDATE REQUEST
  Future<bool> updateRequest(int requestId, {
    required String description,
    required String category,
    required bool isUrgent,
    int? zoneKm,
    String? imagePath,
    bool removeImage = false,
    String? priorityLevel,
  }) async {
    try {
      isUpdating.value = true;

      String? imageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          imageUrl = await ApiService.uploadImage(imagePath);
        } catch (e) {
          print('Image upload failed: $e');
        }
      }

      final Map<String, dynamic> updateData = {
        'description': description.trim(),
        'category': category,
        'type': isUrgent ? 'urgent' : 'simple',
        'status': 'active',
      };

      if (removeImage) {
        updateData['imageUrl'] = '';
      } else if (imageUrl != null) {
        updateData['imageUrl'] = imageUrl;
      }

      if (isUrgent && zoneKm != null && zoneKm > 0) {
        updateData['zoneKm'] = zoneKm;
      } else if (!isUrgent) {
        updateData['zoneKm'] = 0; // optional
      }

      if (priorityLevel != null) {
        updateData['priorityLevel'] = priorityLevel;
      }

      await ApiService.updateRequest(requestId, updateData);

      final authController = Get.find<AuthController>();
      final int? clientId = authController.user.value?['id'];
      if (clientId != null) {
        await loadMyRequests(clientId);
      }
      await loadAllRequests();

      Get.snackbar('Succès', 'Demande modifiée avec succès!',
          backgroundColor: Colors.green, colorText: Colors.white);

      return true;
    } catch (e) {
      print('Error updating request: $e');
      Get.snackbar('Erreur', 'Impossible de modifier la demande: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isUpdating.value = false;
    }
  }
  // DELETE REQUEST - FIXED VERSION
  Future<bool> deleteRequest(int requestId) async {
    try {
      isDeleting.value = true;
      debugPrint('Deleting request with ID: $requestId');

      await ApiService.deleteRequest(requestId);

      // Remove from all lists
      myRequests.removeWhere((req) => req.idRequest == requestId);
      requests.removeWhere((req) => req.idRequest == requestId);
      urgentRequests.removeWhere((req) => req.idRequest == requestId);
      normalRequests.removeWhere((req) => req.idRequest == requestId);

      Get.snackbar(
          "Succès",
          "Demande supprimée",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2)
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting request: $e');
      Get.snackbar(
          "Erreur",
          "Impossible de supprimer la demande: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }
  // REACTIVATE REQUEST (make it active again)
  // REACTIVATE REQUEST
  Future<bool> reactivateRequest(int requestId) async {
    try {
      isLoading.value = true;

      final updateData = {
        'status': 'active',
      };

      await ApiService.updateRequest(requestId, updateData);

      final authController = Get.find<AuthController>();
      final int? clientId = authController.user.value?['id'] ?? authController.user.value?['clientId'];
      if (clientId != null) {
        await loadMyRequests(clientId);
      }
      await loadAllRequests();

      Get.snackbar(
        "Succès",
        "Demande réactivée avec succès!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error reactivating request: $e');
      Get.snackbar(
        "Erreur",
        "Impossible de réactiver la demande: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  // ACCEPT REQUEST
  Future<bool> acceptRequest(int requestId) async {
    try {
      isLoading.value = true;

      final request = requests.firstWhere(
            (req) => req.idRequest == requestId,
        orElse: () => throw Exception('Request not found'),
      );

      final authController = Get.find<AuthController>();
      final artisan = authController.user.value;
      final int? artisanId = artisan?['id'] ?? artisan?['ID'];
      final int clientId = request.clientId;

      final Map<String, dynamic> appointmentData = {
        'scheduledTime': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'status': 'pending',
        'clientId': clientId,
        'artisanId': artisanId,
        'requestId': requestId,
      };

      await ApiService.createAppointment(appointmentData);
      await ApiService.updateRequest(requestId, {'status': 'accepted'});
      await loadAllRequests();

      Get.snackbar("Succès", "Demande acceptée! Rendez-vous créé.",
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } catch (e) {
      print('Error accepting request: $e');
      Get.snackbar("Erreur", "Impossible d'accepter la demande",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // DECLINE REQUEST
  Future<bool> declineRequest(int requestId) async {
    try {
      isLoading.value = true;
      await ApiService.updateRequest(requestId, {'status': 'declined'});

      requests.removeWhere((req) => req.idRequest == requestId);
      urgentRequests.removeWhere((req) => req.idRequest == requestId);
      normalRequests.removeWhere((req) => req.idRequest == requestId);
      await loadAllRequests();

      Get.snackbar("Succès", "Demande refusée",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return true;
    } catch (e) {
      print('Error declining request: $e');
      Get.snackbar("Erreur", "Impossible de refuser la demande",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // IGNORE REQUEST
  Future<bool> ignoreRequest(int requestId) async {
    try {
      requests.removeWhere((req) => req.idRequest == requestId);
      normalRequests.removeWhere((req) => req.idRequest == requestId);

      Get.snackbar("Info", "Demande ignorée",
          backgroundColor: Colors.grey, colorText: Colors.white,
          duration: const Duration(seconds: 2));
      return true;
    } catch (e) {
      print('Error ignoring request: $e');
      return false;
    }
  }

  Future<void> refreshRequests() async {
    final authController = Get.find<AuthController>();
    final user = authController.user.value;
    final int? clientId = user?['id'] ?? user?['clientId'] ?? user?['ID'];
    if (clientId != null) {
      await loadMyRequests(clientId);
    }
    await loadAllRequests();
  }

  RequestModel? getRequestById(int id) {
    try {
      return requests.firstWhere((req) => req.idRequest == id);
    } catch (e) {
      return null;
    }
  }
}