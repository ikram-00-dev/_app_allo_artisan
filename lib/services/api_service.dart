import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'package:dio/dio.dart';

class ApiService {
  // ============================================================
  // BASE URL - FOR ANDROID EMULATOR
  // ============================================================
  static const String baseUrl = 'http://192.168.1.36:8081/api/v1';
  // FOR PHYSICAL DEVICE (uncomment and use your computer's IP):
  // static const String baseUrl = 'http://192.168.1.36:8081/api/v1';

  // ============================================================
  // DIO INSTANCE
  // ============================================================
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // ============================================================
  // TOKEN MANAGEMENT
  // ============================================================
  static String? _cachedToken;

  static Future<Map<String, String>> _headers() async {
    final token = await StorageService.getToken();
    debugPrint('🔑 Token for request: ${token != null ? 'Present (length: ${token.length})' : 'NULL'}');

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, String>> _dioHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
  // HTTP METHODS WITH HTTP PACKAGE (Existing)
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
  // DIO METHODS (For GET ALL ARTISANS and future use)
  // ============================================================

  static Future<dynamic> dioGet(String path) async {
    try {
      final headers = await _dioHeaders();
      final response = await _dio.get(
        path,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<dynamic> dioPost(String path, dynamic data) async {
    try {
      final headers = await _dioHeaders();
      final response = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<dynamic> dioPut(String path, dynamic data) async {
    try {
      final headers = await _dioHeaders();
      final response = await _dio.put(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  static Future<dynamic> dioDelete(String path) async {
    try {
      final headers = await _dioHeaders();
      final response = await _dio.delete(
        path,
        options: Options(headers: headers),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ============================================================
  // RESPONSE HANDLERS
  // ============================================================

  static dynamic _handleResponse(http.Response response) {
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.body.isEmpty) {
      debugPrint('❌ Empty response body');
      throw Exception('Empty response from server');
    }

    dynamic body;
    try {
      body = jsonDecode(response.body);
      debugPrint('✅ JSON parsed successfully: $body');
    } catch (e) {
      debugPrint('❌ JSON Decode error: $e');
      debugPrint('❌ Raw response: ${response.body}');
      throw Exception('Invalid JSON response from server: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // For 201 Created, return the body directly
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

  static Exception _handleDioError(DioException error) {
    String message = 'Something went wrong';

    if (error.response != null) {
      switch (error.response?.statusCode) {
        case 400:
          message = 'Bad request';
          break;
        case 401:
          message = 'Unauthorized';
          break;
        case 403:
          message = 'Forbidden';
          break;
        case 404:
          message = 'Not found';
          break;
        case 500:
          message = 'Internal server error';
          break;
        default:
          message = error.response?.data['message'] ?? message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Receive timeout';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection';
    }

    return Exception(message);
  }

  // ============================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================

  // In api_service.dart, replace the login method with:

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    debugPrint('🔐 Login to: $baseUrl/auth/login');
    debugPrint('📤 Request body: {"email": "$email", "password": "***", "role": "$role"}');

    final response = await post('/auth/login', {
      'email': email,
      'password': password,
      'role': role,  // ✅ Add role to request body
    });

    debugPrint('✅ Login response received: $response');

    if (response['token'] != null) {
      setToken(response['token']);
      debugPrint('✅ Token saved');
    } else {
      debugPrint('❌ No token in response');
      throw Exception('No token received from server');
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

    final Map<String, dynamic> requestBody = {
      'firstName': firstName,
      'middleName': middleName ?? '',
      'lastName': lastName,
      'username': username,
      'email': email.trim(),
      'password': password,
      'phoneNumber': phoneNumber ?? '',
      'avatarUrl': avatarUrl ?? '',
    };

    debugPrint('Request body: ${jsonEncode(requestBody)}');

    final response = await post('/auth/register/client', requestBody);

    debugPrint('✅ Client registered successfully, response: $response');
    return response as Map<String, dynamic>;
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
      'diploma': diplomaUrl ?? '',
      'officialDoc': officialDocUrl ?? '',
      'category': category,
      'province': province,
      'city': city,
      'district': district,
      'experience': experience ?? 0,
    });

    debugPrint('✅ Artisan registered successfully');
    return response;
  }
  // In api_service.dart, add this method:

  static Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> data) async {
    final response = await post('/appointments', data);
    return response;
  }


  // ============================================================
  // ARTISAN ENDPOINTS
  // ============================================================

  static Future<List<dynamic>> getAllArtisans() async {
    try {
      // Using Dio for this request
      final response = await dioGet('/artisans');
      if (response is List) {
        return response;
      } else if (response['data'] is List) {
        return response['data'];
      } else if (response['artisans'] is List) {
        return response['artisans'];
      }
      return [];
    } catch (e) {
      debugPrint('Error getting all artisans: $e');
      return [];
    }
  }

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

      if (queryParams.isNotEmpty) {
        endpoint += '?';
        endpoint += queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }

      debugPrint('📤 GET Artisans: $baseUrl$endpoint');

      final response = await get(endpoint);

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

  static Future<Map<String, dynamic>> updateArtisan(int id, Map<String, dynamic> data) async {
    return await put('/artisans/$id', data);
  }

  // ============================================================
  // PROFILE ENDPOINTS
  // ============================================================

  static Future<Map<String, dynamic>> getCurrentUser() async {
    debugPrint('👤 Getting current user from: $baseUrl/auth/me');
    return await get('/auth/me');
  }

  static Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      return await get('/auth/me');
    } catch (e) {
      debugPrint('Error fetching current user: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getArtisanById(int id) async {
    return await get('/artisans/$id');
  }

  static Future<Map<String, dynamic>> getArtisanProfile(int id) async {
    return await get('/artisans/$id');
  }

  static Future<Map<String, dynamic>> getClientProfile(int id) async {
    return await get('/clients/$id');
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await put('/users/profile', data);
  }

  // ============================================================
  // FOLLOW ENDPOINTS
  // ============================================================

  static Future<Map<String, dynamic>> followArtisan(int artisanId) async {
    return await post('/artisans/$artisanId/follow', {});
  }

  static Future<Map<String, dynamic>> unfollowArtisan(int artisanId) async {
    return await delete('/artisans/$artisanId/follow');
  }

  static Future<Map<String, dynamic>> checkFollowing(int artisanId) async {
    return await get('/artisans/$artisanId/is-following');
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
// REQUEST ENDPOINTS - MATCHING GENERIC CRUD CONTROLLER
// ============================================================

// GET all requests (matches GenericController.GetAll)
  // GET all requests - ADD DEBUG PRINT
  static Future<List<dynamic>> getRequests() async {
    try {
      debugPrint('📤 GETTING REQUESTS from: /requests');
      final response = await get('/requests');

      debugPrint('📥 GET REQUESTS response type: ${response.runtimeType}');
      debugPrint('📥 GET REQUESTS response: $response');

      if (response is List) {
        debugPrint('✅ Response is List with ${response.length} items');
        return response;
      }

      if (response is Map && response['data'] is List) {
        debugPrint('✅ Response has data array with ${response['data'].length} items');
        return response['data'];
      }

      debugPrint('⚠️ Unexpected response format: $response');
      return [];
    } catch (e) {
      debugPrint('❌ Error getting requests: $e');
      return [];
    }
  }

// Get single request (matches GenericController.GetOne)
  static Future<Map<String, dynamic>> getRequest(int id) async {
    return await get('/requests/$id');
  }

// Upload image for request
  static Future<String> uploadRequestImage(String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/upload/image');
      final request = http.MultipartRequest('POST', uri);

      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.headers['Accept'] = 'application/json';

      debugPrint('📤 Uploading image to: $uri');

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(responseBody);
        return decoded['url'] ?? decoded['fileUrl'] ?? decoded['imageUrl'] ?? '';
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      rethrow;
    }
  }

// CREATE request (matches GenericController.Create)
  // In api_service.dart - REPLACE the createRequest method with this:

// CREATE request (matches GenericController.Create)
  // In api_service.dart - Update createRequest method:

 /* static Future<Map<String, dynamic>> createRequest(Map<String, dynamic> data, {String? imagePath}) async {
    try {
      // Upload image first if provided
      String? imageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          imageUrl = await uploadRequestImage(imagePath);
          debugPrint('✅ Image uploaded: $imageUrl');
        } catch (e) {
          debugPrint('⚠️ Warning: Could not upload image: $e');
        }
      }

      // Get client ID from the data or from storage
      int? clientId = data['clientId'] ?? data['ClientID'];

      // If clientId is not in data, try to get from stored user
      if (clientId == null) {
        try {
          final user = await StorageService.getUser();
          if (user != null) {
            clientId = user['id'] ?? user['ID'] ?? user['clientId'] ?? user['ClientId'];
            debugPrint('🔍 Retrieved clientId from storage: $clientId');
          }
        } catch (e) {
          debugPrint('⚠️ Could not get client ID from storage: $e');
        }
      }

      if (clientId == null) {
        throw Exception('Client ID not found. Please login again.');
      }

      // Build request body matching Go struct exactly
      final Map<String, dynamic> requestBody = {
        'Description': data['description']?.toString() ?? data['Description'] ?? '',
        'Type': data['type']?.toString() ?? data['Type'] ?? 'simple',
        'Category': data['category']?.toString() ?? data['Category'] ?? '',
        'ClientID': clientId,
        'Status': data['status']?.toString() ?? data['Status'] ?? 'active',
        'RequestDate': DateTime.now().toIso8601String(),
      };

      // Add optional fields
      if (data['latitude'] != null) {
        requestBody['Latitude'] = data['latitude'] is double
            ? data['latitude']
            : (data['latitude'] as num).toDouble();
      }

      if (data['longitude'] != null) {
        requestBody['Longitude'] = data['longitude'] is double
            ? data['longitude']
            : (data['longitude'] as num).toDouble();
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        requestBody['ImageUrl'] = imageUrl;
      }

      // For urgent requests
      final isUrgent = data['type'] == 'urgent' || data['isUrgent'] == true;
      if (isUrgent) {
        requestBody['PriorityLevel'] = data['priorityLevel'] ?? 'High';
        if (data['zoneKm'] != null) {
          requestBody['ZoneKm'] = data['zoneKm'];
        }
      }

      debugPrint('📤 Creating request with body: ${jsonEncode(requestBody)}');

      final uri = Uri.parse('$baseUrl/requests');
      final headers = await _headers();

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        debugPrint('❌ JSON Parse error: $e');
        throw Exception('Invalid JSON response from server: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ Request created successfully');
        return responseData;
      } else {
        final errorMsg = responseData['message'] ??
            responseData['error'] ??
            'Server error: ${response.statusCode}';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Create request error: $e');
      rethrow;
    }
  }*/
  // CREATE request - DEBUG VERSION
  // CREATE request - FIXED VERSION matching Go backend JSON tags exactly
  static Future<Map<String, dynamic>> createRequest(Map<String, dynamic> data, {String? imagePath}) async {
    debugPrint('========== CREATE REQUEST ==========');

    try {
      int? clientId = data['clientId'];
      if (clientId == null) {
        final userJson = await StorageService.getUser();
        clientId = userJson?['id'] ?? userJson?['ID'];
      }

      if (clientId == null) {
        throw Exception('Client ID not found');
      }

      String priorityLevel = data['priorityLevel'] ?? 'medium';
      priorityLevel = priorityLevel.toLowerCase();
      if (!['low', 'medium', 'high'].contains(priorityLevel)) {
        priorityLevel = 'medium';
      }

      // Build request body - ADD ZONEKM
      final Map<String, dynamic> requestBody = {
        'description': data['description'] ?? '',
        'category': data['category'] ?? '',
        'clientId': clientId,
        'latitude': data['latitude'] ?? 0.0,
        'longitude': data['longitude'] ?? 0.0,
        'isUrgent': data['type'] == 'urgent',
        'priorityLevel': priorityLevel,
        'zoneKm': data['zoneKm'] ?? 0, // ADD THIS
      };

      debugPrint('Sending: ${jsonEncode(requestBody)}');

      final token = await StorageService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/requests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
// UPDATE request (matches GenericController.Update)
  static Future<Map<String, dynamic>> updateRequest(int id, Map<String, dynamic> data, {String? imagePath, bool removeImage = false}) async {
    try {
      String? imageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        try {
          imageUrl = await uploadImage(imagePath);
        } catch (e) {
          debugPrint('Image upload failed: $e');
        }
      }

      final updateData = <String, dynamic>{};

      if (data.containsKey('description')) {
        updateData['description'] = data['description'];
      }
      if (data.containsKey('category')) {
        updateData['category'] = data['category'];
      }
      if (data.containsKey('status')) {
        updateData['status'] = data['status'];
      }
      // IMPORTANT: Send zoneKm, not zone_km (the JSON field name)
      if (data.containsKey('zoneKm')) {
        updateData['zoneKm'] = data['zoneKm'];
      }
      if (removeImage) {
        updateData['imageUrl'] = '';
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        updateData['imageUrl'] = imageUrl;
      }

      if (updateData.isEmpty) {
        return {'success': true, 'message': 'No changes provided'};
      }

      debugPrint('📤 Updating request $id with data: $updateData');

      final token = await StorageService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/requests/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      ).timeout(const Duration(seconds: 30));

      debugPrint('📥 PUT Response status: ${response.statusCode}');
      debugPrint('📥 PUT Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : {'success': true};
      } else {
        throw Exception('Update failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Update error: $e');
      rethrow;
    }
  }

// DELETE request (matches GenericController.Delete)
  // DELETE request - FIXED VERSION
  static Future<Map<String, dynamic>> deleteRequest(int requestId) async {
    try {
      debugPrint('📤 DELETE request: /requests/$requestId');

      final token = await StorageService.getToken();
      final uri = Uri.parse('$baseUrl/requests/$requestId');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('📥 DELETE Response status: ${response.statusCode}');
      debugPrint('📥 DELETE Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true};
        }
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {'success': true};
        }
      } else if (response.statusCode == 204) {
        // No content - success
        return {'success': true};
      } else {
        throw Exception('Delete failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Delete request error: $e');
      rethrow;
    }
  }

// Delete request by query (matches GenericController.DeleteByQuery)
  static Future<Map<String, dynamic>> deleteRequestsByQuery(Map<String, String> queryParams) async {
    try {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final endpoint = '/requests?$queryString';
      debugPrint('📤 DELETE by query: $endpoint');
      final response = await delete(endpoint);
      return {'success': true, 'data': response};
    } catch (e) {
      debugPrint('❌ Delete by query error: $e');
      rethrow;
    }
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

  // ============================================================
  // FILE UPLOAD ENDPOINTS - UNIFIED
  // ============================================================

  /// Upload a file and get back the filename
  /// Returns the filename (not full URL)
  static Future<String> uploadImage(String filePath) async {
    try {
      final uri = Uri.parse('$baseUrl/files/upload');
      final request = http.MultipartRequest('POST', uri);

      final file = await http.MultipartFile.fromPath('file', filePath);
      request.files.add(file);

      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('📤 Uploading image to: $uri');

      final response = await request.send().timeout(const Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      debugPrint('📥 Upload response: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(responseBody);
        // Backend returns: {"status":"ok","file":"filename.ext","url":"http://localhost:8081/uploads/filename.ext"}
        final filename = decoded['file'] ?? decoded['url'] ?? '';
        debugPrint('✅ File uploaded: $filename');
        return filename;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      rethrow;
    }
  }

  /// Get the full download URL for a file
  static String getFileUrl(String filename) {
    if (filename.isEmpty) return '';
    // If it's already a full URL, return as-is
    if (filename.startsWith('http')) return filename;
    // Otherwise construct the URL
    return 'http://192.168.1.36:8081/uploads/$filename';
  }

  /// Legacy method - delegates to uploadImage for backward compatibility
  static Future<Map<String, dynamic>> uploadFile(String endpoint, String filePath) async {
    try {
      final filename = await uploadImage(filePath);
      final url = getFileUrl(filename);
      return {
        'status': 'ok',
        'file': filename,
        'url': url,
      };
    } catch (e) {
      debugPrint('❌ Upload file error: $e');
      rethrow;
    }
  }
  // Add this diagnostic method to ApiService class
  // Add this diagnostic method to ApiService class
  static Future<void> testCreateRequest() async {
    debugPrint('========== DIAGNOSTIC TEST ==========');

    // Test 1: Check if server is reachable
    try {
      final uri = Uri.parse('$baseUrl/requests');
      debugPrint('Test 1: Checking server at $uri');

      final token = await StorageService.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      debugPrint('Server response status: ${response.statusCode}');
      debugPrint('Server response body: ${response.body}');
    } catch (e) {
      debugPrint('Server not reachable: $e');
    }

    // Test 2: Check token
    final token = await StorageService.getToken();
    debugPrint('Test 2: Token exists: ${token != null}');
    if (token != null) {
      debugPrint('Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    }

    // Test 3: Check user data
    final userJson = await StorageService.getUser();
    debugPrint('Test 3: User data exists: ${userJson != null}');
    if (userJson != null) {
      try {
        // FIXED: Don't redeclare, just use userJson directly since it's already a Map
        debugPrint('User fields: ${userJson.keys}');
        debugPrint('User id fields: id=${userJson['id']}, ID=${userJson['ID']}, clientId=${userJson['clientId']}, ClientID=${userJson['ClientID']}');
      } catch (e) {
        debugPrint('Error parsing user JSON: $e');
      }
    }
  }
  static Future<void> testRequestCreation(Map<String, dynamic> testData) async {
    debugPrint('========== TESTING REQUEST CREATION ==========');

    final token = await StorageService.getToken();
    final uri = Uri.parse('$baseUrl/requests');

    debugPrint('URL: $uri');
    debugPrint('Token exists: ${token != null}');
    debugPrint('Sending data: ${jsonEncode(testData)}');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(testData),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('ERROR: ${response.body}');
    }
  }
  static Future<Map<String, dynamic>> reactivateRequest(int requestId) async {
    // When reactivating, set status back to 'active' and update createdAt to now
    final now = DateTime.now().toIso8601String();
    return await updateRequest(requestId, {
      'status': 'active',
      'requestDate': now,  // Reset the date so it's not expired
    });
  }
}