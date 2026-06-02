// request_controller.dart - Complete version with all methods
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';

class RequestController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================
  var isLoading = false.obs;
  var requests = <Map<String, dynamic>>[].obs;
  var urgentRequests = <Map<String, dynamic>>[].obs;
  var normalRequests = <Map<String, dynamic>>[].obs;

  // For artisan view - requests that match their category and zone
  var availableRequests = <Map<String, dynamic>>[].obs;
  var urgentAvailableRequests = <Map<String, dynamic>>[].obs;
  var normalAvailableRequests = <Map<String, dynamic>>[].obs;

  // For client view - their own requests
  var myRequests = <Map<String, dynamic>>[].obs;

  // Hidden requests (ignored/declined)
  var hiddenRequestIds = <int>{}.obs;

  // ============================================================
  // INIT
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  // ============================================================
  // FETCH REQUESTS
  // ============================================================
  Future<void> fetchRequests() async {
    await loadRequests();
  }

  // ============================================================
  // LOAD ALL REQUESTS
  // ============================================================
  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getRequests();

      final allRequests = List<Map<String, dynamic>>.from(response);
      requests.value = allRequests;

      // Filter out hidden requests
      final visibleRequests = allRequests
          .where((req) => !hiddenRequestIds.contains(_getRequestId(req)))
          .toList();

      // Separate normal/simple and urgent requests
      normalRequests.value = visibleRequests
          .where((req) =>
      req['type'] == 'simple' ||
          req['type'] == 'normal' ||
          req['isUrgent'] == false)
          .toList();

      urgentRequests.value = visibleRequests
          .where((req) =>
      req['type'] == 'urgent' ||
          req['isUrgent'] == true)
          .toList();

    } catch (e) {
      print('Error loading requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to get request ID from different field names
  int _getRequestId(Map<String, dynamic> request) {
    return request['idRequest'] ??
        request['IDRequest'] ??
        request['id'] ??
        0;
  }

  // ============================================================
  // LOAD REQUESTS FOR ARTISAN (filtered by category and zone)
  // ============================================================
  Future<void> loadRequestsForArtisan({
    required String artisanCategory,
    required double artisanLatitude,
    required double artisanLongitude,
    required int maxDistanceKm,
  }) async {
    try {
      isLoading.value = true;
      final response = await ApiService.getRequests();

      final allRequests = List<Map<String, dynamic>>.from(response);

      // Filter out hidden requests
      final visibleRequests = allRequests
          .where((req) => !hiddenRequestIds.contains(_getRequestId(req)))
          .toList();

      // Filter requests that match artisan's category
      final categoryMatch = visibleRequests.where((req) =>
      req['category']?.toLowerCase() == artisanCategory.toLowerCase()
      ).toList();

      // Further filter by distance for urgent requests
      final filteredRequests = <Map<String, dynamic>>[];
      final urgentFiltered = <Map<String, dynamic>>[];
      final normalFiltered = <Map<String, dynamic>>[];

      for (var request in categoryMatch) {
        final isUrgent = request['isUrgent'] == true || request['type'] == 'urgent';
        final requestLat = (request['latitude'] ?? request['lat']) as double?;
        final requestLng = (request['longitude'] ?? request['lng']) as double?;

        if (isUrgent && requestLat != null && requestLng != null) {
          // Calculate distance for urgent requests
          final distance = _calculateDistance(
              artisanLatitude,
              artisanLongitude,
              requestLat,
              requestLng
          );

          if (distance <= maxDistanceKm) {
            request['distance'] = distance;
            filteredRequests.add(request);
            urgentFiltered.add(request);
          }
        } else if (!isUrgent) {
          // Normal requests are visible to all artisans in same category
          filteredRequests.add(request);
          normalFiltered.add(request);
        }
      }

      availableRequests.value = filteredRequests;
      urgentAvailableRequests.value = urgentFiltered;
      normalAvailableRequests.value = normalFiltered;

    } catch (e) {
      print('Error loading requests for artisan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD CLIENT'S OWN REQUESTS
  // ============================================================
  Future<void> loadMyRequests(int clientId) async {
    try {
      isLoading.value = true;
      final response = await ApiService.getRequests();

      final allRequests = List<Map<String, dynamic>>.from(response);
      myRequests.value = allRequests
          .where((req) =>
      (req['clientId'] == clientId ||
          req['clientID'] == clientId ||
          req['client_id'] == clientId ||
          req['client']?['id'] == clientId))
          .toList();

      print('Loaded ${myRequests.length} requests for client $clientId');
    } catch (e) {
      print('Error loading my requests: $e');
      myRequests.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // CREATE REQUEST (CLIENT)
  // ============================================================
  // ============================================================
// CREATE REQUEST (CLIENT)
// ============================================================
  Future<bool> createRequest({
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required bool isUrgent,
    int? zoneKm,
    int? clientId,
  }) async {
    try {
      isLoading.value = true;

      // Ensure clientId is not null
      if (clientId == null) {
        Get.snackbar(
          'Erreur',
          'Client non identifié',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final data = {
        'description': description.trim(),
        'type': isUrgent ? 'urgent' : 'simple',
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'active',
        'clientId': clientId, // Make sure this is always included
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Only add zoneKm if it's urgent and has a value
      if (isUrgent && zoneKm != null && zoneKm > 0) {
        data['zoneKm'] = zoneKm;
      }

      print('Creating request with data: $data');

      final response = await ApiService.createRequest(data);

      print('Request created successfully: $response');

      // Refresh lists
      await loadRequests();
      await loadMyRequests(clientId);

      Get.snackbar(
        'Succès',
        'Demande ${isUrgent ? "urgente" : "normale"} envoyée avec succès!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      print('Error creating request: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de créer la demande: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // ACCEPT REQUEST (ARTISAN) - Creates appointment
  // ============================================================
  Future<bool> acceptRequest(int requestId) async {
    try {
      // First, get the request details to get clientId
      final request = requests.firstWhere(
            (req) => _getRequestId(req) == requestId,
        orElse: () => {},
      );

      if (request.isEmpty) {
        throw Exception('Request not found');
      }

      final authController = Get.find<AuthController>();
      final artisanId = authController.user.value?['id'] ?? authController.user.value?['ID'];
      final clientId = request['clientId'] ??
          request['clientID'] ??
          request['client']?['id'];

      // Create appointment
      final appointmentData = {
        'scheduledTime': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        'status': 'pending',
        'clientId': clientId,
        'artisanId': artisanId,
        'requestId': requestId,
      };

      await ApiService.createAppointment(appointmentData);

      // Update request status
      await ApiService.updateRequest(requestId, {
        'status': 'accepted',
        'acceptedAt': DateTime.now().toIso8601String(),
      });

      // Remove from local lists
      _removeRequestFromLists(requestId);

      // Create notification for client
      try {
        await ApiService.post('/notifications', {
          'targetRole': 'client',
          'clientId': clientId,
          'content': '✅ Votre demande a été acceptée. Un rendez-vous a été créé.',
        });
      } catch (e) {
        print('Error sending notification: $e');
      }

      Get.snackbar(
        "Succès",
        "Demande acceptée! Rendez-vous créé.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error accepting request: $e');
      Get.snackbar(
        "Erreur",
        "Impossible d'accepter la demande",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // ============================================================
  // DECLINE REQUEST - Hides it from screen
  // ============================================================
  Future<bool> declineRequest(int requestId) async {
    try {
      // Update request status
      await ApiService.updateRequest(requestId, {'status': 'declined'});

      // Add to hidden list
      hiddenRequestIds.add(requestId);

      // Remove from local lists
      _removeRequestFromLists(requestId);

      Get.snackbar(
        "Succès",
        "Demande refusée",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error declining request: $e');
      Get.snackbar(
        "Erreur",
        "Impossible de refuser la demande",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // ============================================================
  // IGNORE REQUEST (Normal demand) - Hides it from screen
  // ============================================================
  Future<bool> ignoreRequest(int requestId) async {
    try {
      // Add to hidden list
      hiddenRequestIds.add(requestId);

      // Remove from local lists
      _removeRequestFromLists(requestId);

      Get.snackbar(
        "Info",
        "Demande ignorée",
        backgroundColor: Colors.grey,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      print('Error ignoring request: $e');
      return false;
    }
  }

  // ============================================================
  // DELETE REQUEST (CLIENT)
  // ============================================================
  Future<bool> deleteRequest(int requestId) async {
    try {
      isLoading.value = true;
      await ApiService.deleteRequest(requestId);

      // Remove from all local lists
      _removeRequestFromLists(requestId);

      // Also remove from myRequests
      myRequests.removeWhere((req) => _getRequestId(req) == requestId);

      Get.snackbar(
        "Succès",
        "Demande supprimée",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return true;
    } catch (e) {
      print('Error deleting request: $e');
      Get.snackbar(
        "Erreur",
        "Impossible de supprimer la demande",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // UPDATE REQUEST STATUS
  // ============================================================
  Future<bool> updateRequestStatus(int requestId, String status) async {
    try {
      await ApiService.updateRequest(requestId, {'status': status});
      await loadRequests();
      return true;
    } catch (e) {
      print('Error updating request status: $e');
      return false;
    }
  }

  // Helper to remove request from all local lists
  void _removeRequestFromLists(int requestId) {
    urgentRequests.removeWhere((req) => _getRequestId(req) == requestId);
    normalRequests.removeWhere((req) => _getRequestId(req) == requestId);
    availableRequests.removeWhere((req) => _getRequestId(req) == requestId);
    urgentAvailableRequests.removeWhere((req) => _getRequestId(req) == requestId);
    normalAvailableRequests.removeWhere((req) => _getRequestId(req) == requestId);
    requests.removeWhere((req) => _getRequestId(req) == requestId);
  }

  // ============================================================
  // HELPER: Calculate distance between two coordinates
  // ============================================================
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
            _sin(dLon / 2) * _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _sin(double x) => math.sin(x);
  double _cos(double x) => math.cos(x);
  double _sqrt(double x) => math.sqrt(x);
  double _atan2(double y, double x) => math.atan2(y, x);

  // ============================================================
  // REFRESH REQUESTS
  // ============================================================
  Future<void> refreshRequests() async {
    await loadRequests();
  }

  // ============================================================
  // GET REQUESTS BY CATEGORY
  // ============================================================
  List<Map<String, dynamic>> getRequestsByCategory(String category) {
    return requests.where((req) => req['category'] == category).toList();
  }

  // ============================================================
  // GET PENDING REQUESTS
  // ============================================================
  List<Map<String, dynamic>> getPendingRequests() {
    return requests.where((req) => req['status'] == 'pending').toList();
  }

  // ============================================================
  // GET HIGH PRIORITY URGENT REQUESTS
  // ============================================================
  List<Map<String, dynamic>> getHighPriorityUrgentRequests() {
    return urgentRequests.where((req) =>
    req['priorityLevel'] == 'high' ||
        req['priorityLevel'] == 'High' ||
        (req['zoneKm'] != null && req['zoneKm'] <= 10)
    ).toList();
  }

  // Clear hidden requests (for testing)
  void clearHiddenRequests() {
    hiddenRequestIds.clear();
    refreshRequests();
  }
}