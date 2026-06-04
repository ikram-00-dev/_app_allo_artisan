import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import controllers and screens
import 'package:allo_artisan_gpt/controllers/auth_controller.dart';
import 'package:allo_artisan_gpt/controllers/notification_controller.dart';
import 'package:allo_artisan_gpt/routes/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final NotificationController notificationController = Get.find<NotificationController>();
    final unreadCount = notificationController.unreadCount;

    return Obx(() => BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        // If already on the current screen, do nothing
        if (index == currentIndex) return;

        switch (index) {
          case 0: // Home
            if (authController.isArtisan) {
              Get.offAllNamed(AppRoutes.artisanHome);
            } else {
              Get.offAllNamed(AppRoutes.clientHome);
            }
            break;

          case 1: // Reservations (Artisan) / My Demands (Client)
            if (authController.isArtisan) {
              Get.toNamed(AppRoutes.reservations);
            } else {
              Get.toNamed(AppRoutes.clientRequests);
            }
            break;

          case 2: // Messages
            Get.toNamed(AppRoutes.messages);
            break;

          case 3: // Notifications
            Get.toNamed(AppRoutes.notifications);
            break;

          case 4: // Profile
            Get.toNamed(AppRoutes.profile);
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: authController.isArtisan
              ? const Icon(Icons.calendar_today_outlined)
              : const Icon(Icons.request_page_outlined),
          activeIcon: authController.isArtisan
              ? const Icon(Icons.calendar_today)
              : const Icon(Icons.request_page),
          label: authController.isArtisan ? 'Rendez-vous' : 'Demandes',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined),
              if (unreadCount > 0) // Fixed: removed .value
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount', // Fixed: removed .value
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          activeIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications),
              if (unreadCount > 0) // Fixed: removed .value
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount', // Fixed: removed .value
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    ));
  }
}