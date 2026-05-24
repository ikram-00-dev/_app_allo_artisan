import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/routes/app_routes.dart';
import '/controllers/auth_controller.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final isClient = authController.isClient;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        // If already on the current screen, do nothing
        if (index == currentIndex) return;

        switch (index) {
          case 0:
          // Navigate to home based on user role
            if (authController.isArtisan) {
              Get.offAllNamed(AppRoutes.artisanHome);
            } else {
              Get.offAllNamed(AppRoutes.clientHome);
            }
            break;
          case 1:
            Get.toNamed(AppRoutes.reservations);
            break;
          case 2:
            Get.toNamed(AppRoutes.messages);
            break;
          case 3:
            Get.toNamed(AppRoutes.notifications);
            break;
          case 4:
            Get.toNamed(AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: 'Rendez-vous',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}