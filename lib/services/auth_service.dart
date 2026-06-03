import 'api_service.dart';

class AuthService {
  // =========================
  // LOGIN - FIXED
  // =========================
  static Future<dynamic> login({
    required String email,
    required String password,
    required String role,
  }) async {
    // ✅ Your backend uses /auth/login (not /auth/login/{role})
    return await ApiService.post(
      '/auth/login',
      {
        "email": email,
        "password": password,
        "role": role,  // Role is in body, not URL
      },
    );
  }

  // =========================
  // REGISTER CLIENT
  // =========================
  static Future<dynamic> registerClient(Map<String, dynamic> data) async {
    return await ApiService.post(
      '/auth/register/client',
      data,
    );
  }

  // =========================
  // REGISTER ARTISAN
  // =========================
  static Future<dynamic> registerArtisan(Map<String, dynamic> data) async {
    return await ApiService.post(
      '/auth/register/artisan',
      data,
    );
  }
}