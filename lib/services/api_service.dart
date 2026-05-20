import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class ApiService {
  // ============================================================
  // BASE URL - Matches your Go backend on port 8081
  // ============================================================
  static const String baseUrl = 'http://192.168.1.40:8081/api/v1';
  // For Android emulator: 'http://10.0.2.2:8081/api/v1'
  // For iOS simulator: 'http://localhost:8081/api/v1'

  // ============================================================
  // TOKEN MANAGEMENT
  // ============================================================
  static String? _cachedToken;

  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    _cachedToken = token;

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  static void setToken(String token) {
    _cachedToken = token;
    StorageService.saveToken(token);
  }

  static Future<void> clearToken() async {
    _cachedToken = null;
    await StorageService.clearToken();
  }

  // ============================================================
  // GENERIC HTTP METHODS
  // ============================================================

  static Future<dynamic> get(
      String endpoint, {
        Map<String, dynamic>? queryParams,
      }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams.map(
                (k, v) => MapEntry(k, v.toString())
        ));
      }

      if (kDebugMode) print('📤 GET: $uri');

      final response = await http.get(
        uri,
        headers: await _headers(),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) print('📥 Response: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      if (kDebugMode) print('📤 POST: $uri');
      if (kDebugMode) print('📤 Body: $data');

      final response = await http.post(
        uri,
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) print('📥 Response: ${response.statusCode}');

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> put(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      if (kDebugMode) print('📤 PUT: $uri');

      final response = await http.put(
        uri,
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> patch(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.patch(
        uri,
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      if (kDebugMode) print('📤 DELETE: $uri');

      final response = await http.delete(
        uri,
        headers: await _headers(),
      ).timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ============================================================
  // RESPONSE HANDLER - Matches your Go backend (raw response)
  // ============================================================

  static dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      throw Exception('Invalid JSON response');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please login again');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden: You don\'t have permission');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode == 409) {
      throw Exception('Conflict: Resource already exists');
    } else {
      final message = body['message'] ?? body['error'] ?? 'Server error: ${response.statusCode}';
      throw Exception(message);
    }
  }

  // ============================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role, // 'clients', 'artisans', 'administrators'
  }) async {
    final response = await post('/auth/login/$role', {
      'email': email,
      'password': password,
    });

    // Save token automatically
    if (response['token'] != null) {
      setToken(response['token']);
    }

    return response;
  }

  static Future<void> registerClient({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    await post('/auth/register/clients', {
      'username': username,
      'email': email,
      'password': password,
      'phone_number': phoneNumber ?? '',
    });
  }

  static Future<void> registerArtisan({
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
    String? diplomaUrl,
    String? officialDocUrl,
  }) async {
    await post('/auth/register/artisans', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'phone_number': phone,
      'category': category,
      'wilaya': wilaya,
      'baladeya': baladeya,
      'zone': zone,
      'photo_url': photoUrl ?? '',
      'diploma_url': diplomaUrl ?? '',
      'official_doc_url': officialDocUrl ?? '',
    });
  }

  static Future<Map<String, dynamic>> refreshToken() async {
    return await get('/auth/refresh');
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('/auth/me');
  }

  // ============================================================
  // ARTISAN ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getArtisans({
    String? category,
    String? wilaya,
    double? minRating,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (wilaya != null) params['wilaya'] = wilaya;
    if (minRating != null) params['rating'] = minRating;
    if (search != null) params['search'] = search;

    return await get('/artisans', queryParams: params);
  }

  static Future<Map<String, dynamic>> getArtisanById(int id) async {
    return await get('/artisans/$id');
  }

  static Future<Map<String, dynamic>> updateArtisan(int id, Map<String, dynamic> data) async {
    return await put('/artisans/$id', data);
  }

  // ============================================================
  // CLIENT ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getClients() async {
    return await get('/clients');
  }

  static Future<Map<String, dynamic>> getClientById(int id) async {
    return await get('/clients/$id');
  }

  // ============================================================
  // POST ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getPosts({int? limit, String? sort}) async {
    final params = <String, dynamic>{};
    if (limit != null) params['limit'] = limit;
    if (sort != null) params['sort'] = sort;

    return await get('/posts', queryParams: params);
  }

  static Future<Map<String, dynamic>> getPostById(int id) async {
    return await get('/posts/$id');
  }

  static Future<Map<String, dynamic>> createPost(Map<String, dynamic> data) async {
    return await post('/posts', data);
  }

  static Future<Map<String, dynamic>> updatePost(int id, Map<String, dynamic> data) async {
    return await put('/posts/$id', data);
  }

  static Future<void> deletePost(int id) async {
    await delete('/posts/$id');
  }

  // ============================================================
  // CONTACT & MESSAGE ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getContacts() async {
    return await get('/contacts');
  }

  static Future<Map<String, dynamic>> getContact(int id) async {
    return await get('/contacts/$id');
  }

  static Future<Map<String, dynamic>> createContact(Map<String, dynamic> data) async {
    return await post('/contacts', data);
  }

  static Future<List<dynamic>> getMessages(int contactId) async {
    return await get('/messages/$contactId');
  }

  static Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    return await post('/messages', data);
  }

  static Future<Map<String, dynamic>> updateMessage(int messageId, int contactId, Map<String, dynamic> data) async {
    return await put('/messages/$messageId/$contactId', data);
  }

  static Future<void> deleteMessage(int messageId, int contactId) async {
    await delete('/messages/$messageId/$contactId');
  }

  // ============================================================
  // REQUEST ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getSimpleRequests() async {
    return await get('/simple_requests');
  }

  static Future<Map<String, dynamic>> createSimpleRequest(Map<String, dynamic> data) async {
    return await post('/simple_requests', data);
  }

  static Future<List<dynamic>> getUrgentRequests() async {
    return await get('/urgent_requests');
  }

  static Future<Map<String, dynamic>> createUrgentRequest(Map<String, dynamic> data) async {
    return await post('/urgent_requests', data);
  }

  // ============================================================
  // APPOINTMENT ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getSimpleAppointments() async {
    return await get('/appointments_simple');
  }

  static Future<Map<String, dynamic>> createSimpleAppointment(Map<String, dynamic> data) async {
    return await post('/appointments_simple', data);
  }

  static Future<List<dynamic>> getUrgentAppointments() async {
    return await get('/appointments_urgent');
  }

  static Future<Map<String, dynamic>> createUrgentAppointment(Map<String, dynamic> data) async {
    return await post('/appointments_urgent', data);
  }

  // ============================================================
  // REVIEW ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getReviews({int? artisanId, int? clientId}) async {
    final params = <String, dynamic>{};
    if (artisanId != null) params['artisanId'] = artisanId;
    if (clientId != null) params['clientId'] = clientId;

    return await get('/reviews', queryParams: params);
  }

  static Future<Map<String, dynamic>> createReview(Map<String, dynamic> data) async {
    return await post('/reviews', data);
  }

  // ============================================================
  // NOTIFICATION ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getClientNotifications() async {
    return await get('/notifications_clients');
  }

  static Future<List<dynamic>> getArtisanNotifications() async {
    return await get('/notifications_artisans');
  }

  static Future<List<dynamic>> getAdminNotifications() async {
    return await get('/notifications_admins');
  }

  static Future<void> markNotificationAsRead(String type, int id) async {
    final endpoint = '/notifications_${type}s/$id';
    await put(endpoint, {'is_read': true});
  }

  // ============================================================
  // REPORT ENDPOINTS
  // ============================================================

  static Future<Map<String, dynamic>> createReport(Map<String, dynamic> data) async {
    return await post('/reports', data);
  }

  static Future<Map<String, dynamic>> createReportArtisan(Map<String, dynamic> data) async {
    return await post('/report_artisans', data);
  }

  static Future<Map<String, dynamic>> createReportPost(Map<String, dynamic> data) async {
    return await post('/report_posts', data);
  }
}