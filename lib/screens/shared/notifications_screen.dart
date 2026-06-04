// screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../controllers/auth_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.find<NotificationController>();
    final AuthController authController = Get.find<AuthController>();
    final isArtisan = authController.isArtisan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.unreadCount > 0) {
              return IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: () => controller.markAllAsRead(),
                tooltip: 'Tout marquer comme lu',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Aucune notification',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Les notifications apparaîtront ici',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            final isUnread = !notification.isRead;

            return GestureDetector(
              onTap: () => controller.handleNotificationTap(notification),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isUnread ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnread ? Colors.blue : Colors.grey.shade200,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _getNotificationIcon(notification.content),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getNotificationTitle(notification.content),
                                  style: TextStyle(
                                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getNotificationBody(notification.content),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notification.formattedTime,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnread)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _getNotificationIcon(String content) {
    IconData icon;
    Color color;

    if (content.contains('urgente') || content.contains('urgent')) {
      icon = Icons.warning_amber_rounded;
      color = Colors.red;
    } else if (content.contains('accepté')) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (content.contains('message')) {
      icon = Icons.message;
      color = Colors.blue;
    } else if (content.contains('évaluation') || content.contains('evaluation')) {
      icon = Icons.star;
      color = Colors.amber;
    } else {
      icon = Icons.notifications;
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  String _getNotificationTitle(String content) {
    if (content.contains('urgente')) return '🚨 Demande urgente';
    if (content.contains('accepté')) return '✅ Demande acceptée';
    if (content.contains('message')) return '💬 Nouveau message';
    if (content.contains('évaluation') || content.contains('evaluation')) return '⭐ Nouvelle évaluation';
    return '📢 Notification';
  }

  String _getNotificationBody(String content) {
    if (content.contains(':')) {
      return content.split(':').last.trim();
    }
    return content;
  }
}