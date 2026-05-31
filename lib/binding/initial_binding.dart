import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/artisan_controller.dart';
import '../controllers/message_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/request_controller.dart';
import '../controllers/reservation_controller.dart';
import '../controllers/artisan_search_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/user_controller.dart';
import '../services/api_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ============================================================
    // 1. Register SERVICE first (no dependencies)
    // ============================================================
    Get.put<ApiService>(ApiService(), permanent: true);

    // ============================================================
    // 2. Register ALL CONTROLLERS
    // ============================================================

    // Auth Controller (no dependencies)
    Get.put<AuthController>(AuthController(), permanent: true);

    // Artisan Controller (no dependencies)
    Get.put<ArtisanController>(ArtisanController(), permanent: true);

    // Message Controller (no dependencies)
    Get.put<MessageController>(MessageController(), permanent: true);

    // Notification Controller (no dependencies)
    Get.put<NotificationController>(NotificationController(), permanent: true);

    // Request Controller (no dependencies)
    Get.put<RequestController>(RequestController(), permanent: true);

    // Reservation Controller (no dependencies)
    Get.put<ReservationController>(ReservationController(), permanent: true);

    // Search Controller (no dependencies)
    Get.put<ArtisanSearchController>(ArtisanSearchController(), permanent: true);

    // ============================================================
    // Controllers that REQUIRE ApiService parameter
    // ============================================================

    // Settings Controller - requires ApiService
    Get.put<SettingsController>(
      SettingsController(Get.find<ApiService>()),
      permanent: true,
    );

    // User Controller - requires ApiService
    Get.put<UserController>(
      UserController(Get.find<ApiService>()),
      permanent: true,
    );
  }
}