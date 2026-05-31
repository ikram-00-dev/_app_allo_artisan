import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class ApiService {
  // ============================================================
  // BASE URL - FOR ANDROID EMULATOR
  // ============================================================
  static const String baseUrl = 'http://192.168.1.36:8081/api/v1';
  // FOR PHYSICAL DEVICE (uncomment and use your computer's IP):
  // static const String baseUrl = 'http://192.168.1.36:8081/api/v1';

  // ============================================================
  // FILE UPLOAD
  // ============================================================
  static Future<Map<String, dynamic>> uploadFile(String endpoint, String filePath) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    final file = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(file);

    final token = await StorageService.getToken();
    request.headers['Authorization'] = 'Bearer $token';

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    return jsonDecode(responseBody);
  }

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

  static Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('📤 GET: $uri');

      final response = await http.get(
        uri,
        headers: await _headers(),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('📤 POST: $uri');
      debugPrint('📤 Body: $data');

      final response = await http.post(
        uri,
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('📤 PUT: $uri');

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

  static Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('📤 DELETE: $uri');

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
    if (response.body.isEmpty) {
      debugPrint('❌ Empty response body');
      throw Exception('Empty response from server');
    }

    dynamic body;
    try {
      body = jsonDecode(response.body);
      debugPrint('✅ JSON parsed successfully');
    } catch (e) {
      debugPrint('❌ JSON Decode error: $e');
      debugPrint('❌ Raw response: ${response.body}');
      throw Exception('Invalid JSON response from server');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 400) {
      final message = body['message'] ?? body['error'] ?? 'Bad request';
      throw Exception(message);
    } else if (response.statusCode == 401) {
      throw Exception('Email ou mot de passe incorrect');
    } else if (response.statusCode == 403) {
      throw Exception('Accès non autorisé');
    } else if (response.statusCode == 404) {
      throw Exception('Service non trouvé. Vérifiez que le backend est démarré.');
    } else if (response.statusCode == 409) {
      throw Exception('Cet email est déjà utilisé');
    } else if (response.statusCode == 500) {
      throw Exception('Erreur serveur. Veuillez réessayer plus tard.');
    } else {
      final message = body['message'] ?? body['error'] ?? 'Erreur serveur: ${response.statusCode}';
      throw Exception(message);
    }
  }

  // ============================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    debugPrint('🔐 Login to: $baseUrl/auth/login');

    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });

    debugPrint('✅ Login response received');

    if (response['token'] != null) {
      setToken(response['token']);
      debugPrint('✅ Token saved');
    } else {
      debugPrint('❌ No token in response');
    }

    return response;
  }

  static Future<Map<String, dynamic>> registerClient({
    required String firstName,
    String? middleName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    debugPrint('📝 Registering client to: $baseUrl/auth/register/client');

    final response = await post('/auth/register/client', {
      'firstName': firstName,
      'middleName': middleName ?? '',
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber ?? '',
      'avatarUrl': avatarUrl ?? '',
    });

    debugPrint('✅ Client registered successfully');
    return response;
  }

  static Future<Map<String, dynamic>> registerArtisan({
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
    String? diplomaUrl,
    String? officialDocUrl,
    int? experience,
  }) async {
    debugPrint('📝 Registering artisan to: $baseUrl/auth/register/artisan');

    final response = await post('/auth/register/artisan', {
      'firstName': firstName,
      'middleName': middleName ?? '',
      'lastName': lastName,
      'username': username,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl ?? '',
      'diplomaUrl': diplomaUrl ?? '',
      'officialDocUrl': officialDocUrl ?? '',
      'category': category,
      'province': province,
      'city': city,
      'district': district,
      'experience': experience ?? 0,
    });

    debugPrint('✅ Artisan registered successfully');
    return response;
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('/auth/me');
  }

// ============================================================
// ARTISAN ENDPOINTS (IMPROVED)
// ============================================================

  static Future<List<dynamic>> getArtisans({
    String? category,
    String? province,
    double? rating,
    String? search,
  }) async {
    try {
      String endpoint = '/artisans';

      final queryParams = <String, String>{};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty && category != 'all') {
        queryParams['category'] = category;
      }
      if (province != null && province.isNotEmpty) {
        queryParams['province'] = province;
      }
      if (rating != null && rating > 0) {
        queryParams['rating'] = rating.toString();
      }

      // Build URL with query parameters
      if (queryParams.isNotEmpty) {
        endpoint += '?';
        endpoint += queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }

      debugPrint('📤 GET Artisans: $baseUrl$endpoint');

      final response = await get(endpoint); // Reuse your existing get() method

      if (response is List) {
        return response;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('❌ Error fetching artisans: $e');
      return [];
    }
  }
  // Add these methods inside ApiService class

  static Future<Map<String, dynamic>> getArtisanById(int id) async {
    return await get('/artisans/$id');
  }

  static Future<Map<String, dynamic>> updateArtisan(int id, Map<String, dynamic> data) async {
    return await put('/artisans/$id', data);
  }
  // ============================================================
  // POST ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getPosts({int? limit, String? sort}) async {
    return await get('/posts');
  }

  static Future<Map<String, dynamic>> createPost(Map<String, dynamic> data) async {
    return await post('/posts', data);
  }

  static Future<void> deletePost(int id) async {
    await delete('/posts/$id');
  }

  // ============================================================
  // MESSAGE ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getMessages(int contactId) async {
    return await get('/messages/$contactId');
  }

  static Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> data) async {
    return await post('/messages', data);
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

  static Future<Map<String, dynamic>> updateRequest(int id, Map<String, dynamic> data) async {
    return await put('/requests/$id', data);
  }

  static Future<void> deleteRequest(int id) async {
    await delete('/requests/$id');
  }

  // ============================================================
  // APPOINTMENT ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getAppointments() async {
    return await get('/appointments');
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus(int id, String status) async {
    return await put('/appointments/$id', {'status': status});
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
}