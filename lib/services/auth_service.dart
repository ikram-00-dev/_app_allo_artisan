import 'api_service.dart';

class AuthService {
  // =========================
  // LOGIN
  // =========================
  static Future<dynamic> login({
    required String email,
    required String password,
    required String role,
  }) async {
    return await ApiService.post(
      '/auth/login/$role',
      {
        "email": email,
        "password": password,
      },
    );
  }

  // =========================
  // REGISTER CLIENT
  // =========================
  static Future<dynamic> registerClient(
      Map<String, dynamic> data) async {
    return await ApiService.post(
      '/auth/register/client',
      data,
    );
  }

  // =========================
  // REGISTER ARTISAN
  // =========================
  static Future<dynamic> registerArtisan(
      Map<String, dynamic> data) async {
    return await ApiService.post(
      '/auth/register/artisan',
      data,
    );
  }
}