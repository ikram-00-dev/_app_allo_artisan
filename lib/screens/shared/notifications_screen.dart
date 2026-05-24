import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../models/notification.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      setState(() => isLoading = true);
      final response = await ApiService.getNotifications();
      setState(() {
        notifications = (response as List).map((e) => NotificationModel.fromJson(e)).toList();
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await ApiService.markNotificationAsRead(id);
      setState(() {
        final index = notifications.indexWhere((n) => n.idNotif == id);
        if (index != -1) {
          notifications[index] = NotificationModel(
            idNotif: notifications[index].idNotif,
            content: notifications[index].content,
            isRead: true,
            createdAt: notifications[index].createdAt,
            targetRole: notifications[index].targetRole,
            clientId: notifications[index].clientId,
            artisanId: notifications[index].artisanId,
            adminId: notifications[index].adminId,
            moderatorId: notifications[index].moderatorId,
          );
        }
      });
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    for (var notif in notifications.where((n) => !n.isRead)) {
      await markAsRead(notif.idNotif);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: markAllAsRead,
              child: const Text("Tout lire", style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(child: Text("Aucune notification"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return GestureDetector(
            onTap: () => markAsRead(notif.idNotif),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: notif.isRead ? Colors.white : const Color(0xffEAF3FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: notif.isRead ? Colors.grey.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.content,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: notif.isRead ? Colors.black87 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        notif.formattedTime,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Spacer(),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}