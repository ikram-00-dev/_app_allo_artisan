// lib/middleware/admin_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    final role = authController.role.value;

    debugPrint('🔐 AdminMiddleware - Current role: "$role"');

    // Allow access for both admin and moderator roles
    if (role != 'admin' && role != 'moderator') {
      debugPrint('❌ Access denied - Not admin or moderator. Redirecting to login');
      return const RouteSettings(name: '/login');
    }

    debugPrint('✅ Access granted for role: $role');
    return null;
  }

  @override
  int? get priority => 0;
}