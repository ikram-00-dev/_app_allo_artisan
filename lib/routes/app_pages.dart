// lib/routes/app_pages.dart
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_client_screen.dart';
import '../screens/auth/register_artisan_screen.dart';
import '../screens/client/client_home_screen.dart';
import '../screens/artisan/artisan_home_screen.dart';
import '../screens/artisan/artisan_dashboard_screen.dart';
import '../screens/client/artisan_profile_screen.dart';
import '../screens/client/search_screen.dart';
import '../screens/shared/messages_screen.dart';
import '../screens/shared/notifications_screen.dart';
import '../screens/shared/reservations_screen.dart';
import '../screens/shared/settings_screen.dart';
import '../screens/shared/qr_scan_screen.dart';
import '../screens/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.registerClient, page: () => const RegisterClientScreen()),
    GetPage(name: AppRoutes.registerArtisan, page: () => const RegisterArtisanScreen()),
    GetPage(name: AppRoutes.clientHome, page: () => const ClientHomeScreen()),
    GetPage(name: AppRoutes.artisanHome, page: () => const ArtisanHomeScreen()),
    GetPage(name: AppRoutes.artisanDashboard, page: () => ArtisanDashboardScreen()),
    GetPage(name: AppRoutes.artisanProfile, page: () => ArtisanProfileScreen(artisanId: Get.arguments)),
    GetPage(name: AppRoutes.search, page: () => const SearchScreen()),
    GetPage(name: AppRoutes.messages, page: () => const MessagesScreen()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsScreen()),
    GetPage(name: AppRoutes.reservations, page: () =>  ReservationScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(name: AppRoutes.qrScan, page: () => const ScanQRScreen()),
  ];
}