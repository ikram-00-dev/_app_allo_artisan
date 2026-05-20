import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class ApiService {
  // ============================================================
  // BASE URL - Matches your Go backend
  // ============================================================
  static const String baseUrl = 'http://192.168.1.39:8081/api/v1';
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
  // RESPONSE HANDLER
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
  }) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response['token'] != null) {
      setToken(response['token']);
    }

    return response;
  }

  static Future<void> registerClient({
    required String firstName,
    String? middleName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    await post('/auth/register/client', {
      'firstName': firstName,
      'middleName': middleName ?? '',
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber ?? '',
      'avatarUrl': avatarUrl ?? '',
    });
  }

  static Future<void> registerArtisan({
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
    await post('/auth/register/artisan', {
      'firstName': firstName,
      'middleName': middleName ?? '',
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl ?? '',
      'category': category,
      'diploma': diploma ?? '',
      'province': province,
      'city': city,
      'district': district,
      'experience': experience ?? 0,
    });
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('/auth/me');
  }

  // ============================================================
  // ARTISAN ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getArtisans({
    String? category,
    String? province,
    double? rating,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (province != null) params['province'] = province;
    if (rating != null) params['rating'] = rating;
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

  static Future<Map<String, dynamic>> updateMessage(int messageId, Map<String, dynamic> data) async {
    return await put('/messages/$messageId', data);
  }

  static Future<void> deleteMessage(int messageId) async {
    await delete('/messages/$messageId');
  }

  // ============================================================
  // REQUEST ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getRequests() async {
    return await get('/requests');
  }

  static Future<Map<String, dynamic>> createRequest(Map<String, dynamic> data) async {
    return await post('/requests', data);
  }

  // ============================================================
  // APPOINTMENT ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getAppointments() async {
    return await get('/appointments');
  }

  static Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> data) async {
    return await post('/appointments', data);
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus(int id, String status) async {
    return await put('/appointments/$id', {'status': status});
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

  static Future<List<dynamic>> getNotifications() async {
    return await get('/notifications');
  }

  static Future<void> markNotificationAsRead(int id) async {
    await put('/notifications/$id', {'isRead': true});
  }

  // ============================================================
  // REPORT ENDPOINTS
  // ============================================================

  static Future<Map<String, dynamic>> createReport(Map<String, dynamic> data) async {
    return await post('/reports', data);
  }
}