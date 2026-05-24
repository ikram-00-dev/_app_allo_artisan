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

class AppPages {
  // Helper method to get profile screen based on role
  static Future<Widget> _getProfileScreen() async {
    final role = await StorageService.getRole();
    final user = await StorageService.getUser();

    if (role == 'artisan') {
      return  ArtisanPrivateProfileScreen();
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
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.registerClient, page: () => const RegisterClientScreen()),
    GetPage(name: AppRoutes.registerArtisan, page: () => const RegisterArtisanScreen()),
    GetPage(name: AppRoutes.clientHome, page: () => const ClientHomeScreen()),
    GetPage(name: AppRoutes.artisanHome, page: () => const ArtisanHomeScreen()),
    GetPage(name: AppRoutes.artisanPrivateProfile, page: () =>  ArtisanPrivateProfileScreen()),
    GetPage(name: AppRoutes.artisanProfile, page: () => ArtisanProfileScreen(artisanId: Get.arguments)), // Not const
    GetPage(name: AppRoutes.search, page: () => const SearchScreen()),
    GetPage(name: AppRoutes.messages, page: () => const MessagesScreen()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsScreen()),
    GetPage(name: AppRoutes.reservations, page: () =>  ReservationScreen()), // Fixed: added const
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(name: AppRoutes.qrScan, page: () => const ScanQRScreen()),
    // Profile route - dynamically loads based on user role
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
    ),
  ];
}