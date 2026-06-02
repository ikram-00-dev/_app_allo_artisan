import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_artisan_gpt/services/api_service.dart';
import 'package:allo_artisan_gpt/models/notification.dart';
import 'package:allo_artisan_gpt/routes/app_routes.dart';
import 'package:allo_artisan_gpt/controllers/auth_controller.dart';

class NotificationController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================
  var isLoading = false.obs;
  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;

  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    startPolling();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (Get.isRegistered<AuthController>() && Get.find<AuthController>().isLoggedIn) {
        fetchNotifications(showLoading: false);
      }
    });
  }

  // ============================================================
  // GET ALL NOTIFICATIONS
  // ============================================================
  Future<void> fetchNotifications({bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;

      final response = await ApiService.get("/notifications");

      notifications.value = (response as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      _updateUnreadCount();
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // ============================================================
  // MARK AS READ (using PUT instead of PATCH)
  // ============================================================
  Future<void> markAsRead(int id) async {
    try {
      await ApiService.put("/notifications/$id/read", {});

      // Create a new list with updated notification
      final updatedNotifications = notifications.map((n) {
        if (n.idNotif == id) {
          return NotificationModel(
            idNotif: n.idNotif,
            content: n.content,
            isRead: true,
            createdAt: n.createdAt,
            targetRole: n.targetRole,
            clientId: n.clientId,
            artisanId: n.artisanId,
            adminId: n.adminId,
            moderatorId: n.moderatorId,
          );
        }
        return n;
      }).toList();

      notifications.value = updatedNotifications;
      _updateUnreadCount();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // ============================================================
  // MARK ALL AS READ (using PUT instead of PATCH)
  // ============================================================
  Future<void> markAllAsRead() async {
    try {
      await ApiService.put("/notifications/read-all", {});

      // Create a new list with all notifications marked as read
      final updatedNotifications = notifications.map((n) {
        return NotificationModel(
          idNotif: n.idNotif,
          content: n.content,
          isRead: true,
          createdAt: n.createdAt,
          targetRole: n.targetRole,
          clientId: n.clientId,
          artisanId: n.artisanId,
          adminId: n.adminId,
          moderatorId: n.moderatorId,
        );
      }).toList();

      notifications.value = updatedNotifications;
      unreadCount.value = 0;

      Get.snackbar(
        'Succès',
        'Toutes les notifications ont été marquées comme lues',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error marking all as read: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de marquer comme lu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================
  Future<void> deleteNotification(int id) async {
    try {
      await ApiService.delete("/notifications/$id");
      notifications.removeWhere((n) => n.idNotif == id);
      _updateUnreadCount();

      Get.snackbar(
        'Succès',
        'Notification supprimée',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error deleting notification: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ============================================================
  // HANDLE NOTIFICATION TAP
  // ============================================================
  void handleNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      await markAsRead(notification.idNotif);
    }

    // Navigate based on content
    if (notification.content.contains('urgente') || notification.content.contains('urgent')) {
      if (Get.isRegistered<AuthController>() && Get.find<AuthController>().isArtisan) {
        Get.toNamed(AppRoutes.artisanHome);
      } else {
        Get.toNamed(AppRoutes.clientRequests);
      }
    } else if (notification.content.contains('accepté')) {
      Get.toNamed(AppRoutes.clientRequests);
    } else if (notification.content.contains('message')) {
      Get.toNamed(AppRoutes.messages);
    } else {
      Get.toNamed(AppRoutes.notifications);
    }
  }
}