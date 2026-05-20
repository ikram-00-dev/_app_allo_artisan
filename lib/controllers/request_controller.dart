import 'package:get/get.dart';
import '../services/api_service.dart';

class RequestController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================
  var isLoading = false.obs;
  var simpleRequests = <Map<String, dynamic>>[].obs;
  var urgentRequests = <Map<String, dynamic>>[].obs;

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
    await Future.wait([
      loadSimpleRequests(),
      loadUrgentRequests(),
    ]);
  }

  Future<void> loadSimpleRequests() async {
    try {
      final response = await ApiService.getSimpleRequests();
      simpleRequests.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading simple requests: $e');
    }
  }

  Future<void> loadUrgentRequests() async {
    try {
      final response = await ApiService.getUrgentRequests();
      urgentRequests.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading urgent requests: $e');
    }
  }

  // ============================================================
  // CREATE REQUESTS
  // ============================================================
  Future<bool> createSimpleRequest({
    required String description,
    required int contactId,
    required int messageId,
  }) async {
    try {
      isLoading.value = true;

      final data = {
        'description': description,
        'request_date': DateTime.now().toIso8601String(),
        'status': 'pending',
        'message_id': messageId,
        'contact_id': contactId,
      };

      await ApiService.createSimpleRequest(data);
      await loadSimpleRequests();

      Get.snackbar("Succès", "Demande simple créée");
      return true;
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de créer la demande");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createUrgentRequest({
    required String description,
    required DateTime deadline,
    required String priorityLevel, // 'Low', 'Medium', 'High'
    required int clientId,
  }) async {
    try {
      isLoading.value = true;

      final data = {
        'description': description,
        'request_date': DateTime.now().toIso8601String(),
        'status': 'pending',
        'deadline': deadline.toIso8601String(),
        'priority_level': priorityLevel,
        'client_id': clientId,
      };

      await ApiService.createUrgentRequest(data);
      await loadUrgentRequests();

      Get.snackbar("Succès", "Demande urgente créée");
      return true;
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de créer la demande urgente");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================
  Future<void> deleteSimpleRequest(int id) async {
    try {
      await ApiService.delete('/simple_requests/$id');
      simpleRequests.removeWhere((req) => req['id_request'] == id);
    } catch (e) {
      print('Error deleting request: $e');
    }
  }

  Future<void> deleteUrgentRequest(int id) async {
    try {
      await ApiService.delete('/urgent_requests/$id');
      urgentRequests.removeWhere((req) => req['id_request'] == id);
    } catch (e) {
      print('Error deleting urgent request: $e');
    }
  }
}