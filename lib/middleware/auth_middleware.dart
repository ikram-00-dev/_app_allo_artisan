import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final authController = Get.find<AuthController>();

    // List of routes that require authentication
    final protectedRoutes = [
      AppRoutes.profile,
      AppRoutes.messages,
      AppRoutes.notifications,
      AppRoutes.reservations,
      AppRoutes.clientRequests,
      AppRoutes.artisanPrivateProfile,
      AppRoutes.settings,
    ];

    // Check if current route is protected and user is not logged in
    if (protectedRoutes.contains(route.location) && !authController.isLoggedIn) {
      // Redirect to login with return URL
      return GetNavConfig.fromRoute('${AppRoutes.login}?redirect=${route.location}');
    }

    return null;
  }
}