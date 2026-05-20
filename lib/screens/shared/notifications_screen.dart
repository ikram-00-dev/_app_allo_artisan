// lib/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NotificationModel {
  final int idNotif;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({required this.idNotif, required this.content, required this.isRead, this.createdAt});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotif: json['id_notif'] ?? json['IDNotif'] ?? 0,
      content: json['content'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }

  String get formattedTime {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours}h";
    if (diff.inDays < 7) return "Il y a ${diff.inDays}j";
    return '${createdAt!.day}/${createdAt!.month}';
  }
}

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
      final role = await StorageService.getRole();
      String endpoint;
      if (role == 'clients') endpoint = '/notifications_clients';
      else if (role == 'artisans') endpoint = '/notifications_artisans';
      else endpoint = '/notifications_admins';

      final response = await ApiService.get(endpoint);
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
      final role = await StorageService.getRole();
      final endpoint = '/notifications_${role}s/$id';
      await ApiService.put(endpoint, {'is_read': true});
      setState(() {
        final index = notifications.indexWhere((n) => n.idNotif == id);
        if (index != -1) {
          notifications[index] = NotificationModel(
            idNotif: notifications[index].idNotif,
            content: notifications[index].content,
            isRead: true,
            createdAt: notifications[index].createdAt,
          );
        }
      });
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final role = await StorageService.getRole();
      await ApiService.put('/notifications_${role}s/read-all', {});
      setState(() {
        notifications = notifications.map((n) => NotificationModel(
          idNotif: n.idNotif, content: n.content, isRead: true, createdAt: n.createdAt,
        )).toList();
      });
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: markAllAsRead,
              child: const Text("Tout lire", style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
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
                border: Border.all(color: notif.isRead ? Colors.grey.shade200 : Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.content, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: notif.isRead ? Colors.black87 : Colors.black)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(notif.formattedTime, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const Spacer(),
                      if (!notif.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
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