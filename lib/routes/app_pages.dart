// lib/routes/app_pages.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_client_screen.dart';
import '../screens/auth/register_artisan_screen.dart';
import '../screens/client/client_home_screen.dart';
import '../screens/artisan/artisan_home_screen.dart';
import '../screens/artisan/artisan_private_profile_screen.dart';
import '../screens/client/artisan_profile_screen.dart';
import '../screens/client/search_screen.dart';
import '../screens/shared/messages_screen.dart';
import '../screens/shared/chat_screen.dart';
import '../screens/shared/notifications_screen.dart';
import '../screens/shared/reservations_screen.dart';
import '../screens/shared/settings_screen.dart';
import '../screens/shared/qr_scan_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/client/client_profile_screen.dart';
import '../models/client.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import 'app_routes.dart';
import '../screens/client/client_requests_screen.dart';
import '../screens/admin/add_moderator_screen.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/admin/pending_artisans_screen.dart';
import '../middleware/admin_middleware.dart';
import '../middleware/auth_middleware.dart';
import '../controllers/artisan_controller.dart';
import '../controllers/artisan_private_profile_controller.dart';
import '../controllers/artisan_public_profile_controller.dart';
import '../controllers/post_controller.dart';

class AppPages {
  // Helper method to get profile screen based on role
  static Future<Widget> _getProfileScreen() async {
    final role = await StorageService.getRole();
    final user = await StorageService.getUser();

    if (role == 'artisan') {
      // Initialize controllers before showing screen
      if (!Get.isRegistered<ArtisanController>()) {
        Get.put(ArtisanController());
      }

      // Load artisan data
      final artisanController = Get.find<ArtisanController>();
      await artisanController.loadDashboard();

      // Initialize private profile controller
      if (!Get.isRegistered<ArtisanPrivateProfileController>()) {
        Get.put(ArtisanPrivateProfileController());
      }

      return const ArtisanPrivateProfileScreen();
    } else {
      // Create client object from user data
      final client = Client(
        user: User(
          idUser: user?['ID'] ?? user?['id'] ?? 0,
          firstName: user?['FirstName'] ?? user?['firstName'] ?? '',
          middleName: user?['MiddleName'] ?? user?['middleName'] ?? '',
          lastName: user?['LastName'] ?? user?['lastName'] ?? '',
          username: user?['Username'] ?? user?['username'] ?? '',
          email: user?['Email'] ?? user?['email'] ?? '',
          phoneNumber: user?['PhoneNumber'] ?? user?['phoneNumber'] ?? '',
          password: '',
          creationDate: DateTime.now(),
          avatarUrl: user?['AvatarURL'] ?? user?['avatarUrl'] ?? '',
          role: role,
        ),
      );
      return ClientProfileScreen(client: client, isPrivate: true);
    }
  }

  static final pages = [
    // ============================================================
    // PUBLIC ROUTES (No authentication required)
    // ============================================================
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.registerClient, page: () => const RegisterClientScreen()),
    GetPage(name: AppRoutes.registerArtisan, page: () => const RegisterArtisanScreen()),
    GetPage(name: AppRoutes.clientHome, page: () => const ClientHomeScreen()),
    GetPage(name: AppRoutes.artisanHome, page: () => const ArtisanHomeScreen()),
    GetPage(name: AppRoutes.artisanProfile, page: () => ArtisanProfileScreen(artisanId: Get.arguments)),
    GetPage(name: AppRoutes.search, page: () => const SearchScreen()),
    GetPage(name: AppRoutes.qrScan, page: () => const ScanQRScreen()),

    // ============================================================
    // PROTECTED ROUTES (Require authentication)
    // ============================================================

    // Client Requests Screen
    GetPage(
      name: AppRoutes.clientRequests,
      page: () => const ClientRequestsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Artisan Private Profile - WITH CONTROLLER INITIALIZATION
    GetPage(
      name: AppRoutes.artisanPrivateProfile,
      page: () => FutureBuilder(
        future: _initializeArtisanProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const ArtisanPrivateProfileScreen();
        },
      ),
      middlewares: [AuthMiddleware()],
    ),

    // Messages - Use renamed class MessagesListScreen
    GetPage(
      name: AppRoutes.messages,
      page: () => const MessagesListScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Chat Screen
    GetPage(
      name: AppRoutes.chat,
      page: () => ChatScreen(
        contactId: Get.arguments['contactId'] ?? 0,
        contactName: Get.arguments['contactName'] ?? 'Contact',
        appointmentId: Get.arguments['appointmentId'],
      ),
      middlewares: [AuthMiddleware()],
    ),

    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Reservations
    GetPage(
      name: AppRoutes.reservations,
      page: () => ReservationScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // Profile - dynamically loads based on user role
    GetPage(
      name: AppRoutes.profile,
      page: () => FutureBuilder(
        future: _getProfileScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return snapshot.data as Widget;
          }
          return const Scaffold(
            body: Center(child: Text('Erreur de chargement du profil')),
          );
        },
      ),
      middlewares: [AuthMiddleware()],
    ),

    // ============================================================
    // ADMIN ROUTES (Require admin/moderator role)
    // ============================================================
    GetPage(
      name: AppRoutes.adminPanel,
      page: () => const AdminPanelScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: AppRoutes.pendingArtisans,
      page: () => const PendingArtisansScreen(),
      middlewares: [AdminMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addModerator,
      page: () => const AddModeratorScreen(),
      middlewares: [AdminMiddleware()],
    ),
  ];
}

// Helper function to initialize artisan profile
Future<void> _initializeArtisanProfile() async {
  if (!Get.isRegistered<ArtisanController>()) {
    Get.put(ArtisanController());
  }

  final artisanController = Get.find<ArtisanController>();
  await artisanController.loadDashboard();

  if (!Get.isRegistered<ArtisanPrivateProfileController>()) {
    Get.put(ArtisanPrivateProfileController());
  }
}