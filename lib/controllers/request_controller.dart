import 'package:get/get.dart';
import '../services/api_service.dart';

class RequestController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================
  var isLoading = false.obs;
  var requests = <Map<String, dynamic>>[].obs;
  var urgentRequests = <Map<String, dynamic>>[].obs;
  var simpleRequests = <Map<String, dynamic>>[].obs;

  // ============================================================
  // INIT
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    loadAllRequests();
  }

  // ============================================================
  // LOAD REQUESTS
  // ============================================================
  Future<void> loadAllRequests() async {
    await loadRequests();
  }

  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getRequests();

      // Split requests by type
      final allRequests = List<Map<String, dynamic>>.from(response);
      requests.value = allRequests;

      // Separate simple and urgent requests
      simpleRequests.value = allRequests
          .where((req) => req['type'] == 'simple')
          .toList();

      urgentRequests.value = allRequests
          .where((req) => req['type'] == 'urgent')
          .toList();

    } catch (e) {
      print('Error loading requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE SIMPLE REQUEST
  // ============================================================
  Future<bool> createSimpleRequest({
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    int? clientId,
  }) async {
    try {
      isLoading.value = true;

      final data = {
        'description': description,
        'type': 'simple',
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending',
        if (clientId != null) 'clientId': clientId,
      };

      await ApiService.createRequest(data);
      await loadRequests();

      Get.snackbar("Succès", "Demande créée avec succès");
      return true;
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de créer la demande");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE URGENT REQUEST
  // ============================================================
  Future<bool> createUrgentRequest({
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required String priorityLevel, // 'low', 'medium', 'high'
    int? clientId,
  }) async {
    try {
      isLoading.value = true;

      final data = {
        'description': description,
        'type': 'urgent',
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'priorityLevel': priorityLevel.toLowerCase(),
        'status': 'pending',
        if (clientId != null) 'clientId': clientId,
      };

      await ApiService.createRequest(data);
      await loadRequests();

      Get.snackbar("Succès", "Demande urgente créée avec succès");
      return true;
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de créer la demande urgente");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DELETE REQUEST
  // ============================================================
  Future<void> deleteRequest(int id) async {
    try {
      await ApiService.delete('/requests/$id');
      requests.removeWhere((req) => req['idRequest'] == id || req['IDRequest'] == id);
      simpleRequests.removeWhere((req) => req['idRequest'] == id || req['IDRequest'] == id);
      urgentRequests.removeWhere((req) => req['idRequest'] == id || req['IDRequest'] == id);

      Get.snackbar("Succès", "Demande supprimée");
    } catch (e) {
      print('Error deleting request: $e');
      Get.snackbar("Erreur", "Impossible de supprimer la demande");
    }
  }

  // ============================================================
  // UPDATE REQUEST STATUS
  // ============================================================
  Future<void> updateRequestStatus(int id, String status) async {
    try {
      await ApiService.put('/requests/$id', {'status': status});
      await loadRequests();

      Get.snackbar("Succès", "Statut mis à jour");
    } catch (e) {
      print('Error updating request status: $e');
      Get.snackbar("Erreur", "Impossible de mettre à jour le statut");
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================
  List<Map<String, dynamic>> getRequestsByCategory(String category) {
    return requests.where((req) => req['category'] == category).toList();
  }

  List<Map<String, dynamic>> getPendingRequests() {
    return requests.where((req) => req['status'] == 'pending').toList();
  }

  List<Map<String, dynamic>> getHighPriorityUrgentRequests() {
    return urgentRequests.where((req) =>
    req['priorityLevel'] == 'high' || req['priorityLevel'] == 'High'
    ).toList();
  }
}