// controllers/notification_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/models/notification.dart';
import '../routes/app_routes.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadStaticNotifications();
  }

  void loadStaticNotifications() {
    notifications.value = [
      NotificationModel(
        id: '1',
        content: 'urgente: Demande urgente de plomberie de Karim B.',
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: 'urgent',
        relatedId: 1,
      ),
      NotificationModel(
        id: '2',
        content: 'accepté: Votre demande a été acceptée par l\'artisan',
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'accept',
        relatedId: 2,
      ),
      NotificationModel(
        id: '3',
        content: 'message: Nouveau message de Nadia L.',
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'message',
        relatedId: 102,
      ),
      NotificationModel(
        id: '4',
        content: 'évaluation: Vous avez reçu une nouvelle évaluation 5 étoiles',
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: 'review',
        relatedId: 0,
      ),
    ];
  }

  void markAllAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      notifications[i].isRead = true;
    }
    notifications.refresh();
    Get.snackbar('Succès', 'Toutes les notifications ont été marquées comme lues',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    // Mark as read
    markAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case 'urgent':
      case 'accept':
        Get.toNamed(AppRoutes.reservations);
        break;
      case 'message':
        Get.toNamed(AppRoutes.messages);
        break;
      case 'review':
        Get.toNamed(AppRoutes.artisanPrivateProfile);
        break;
      default:
        break;
    }
  }
}