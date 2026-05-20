import 'package:intl/intl.dart';

enum NotificationType { urgentRequest, message, appointment, system }

class NotificationModel {
  final int idNotif;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.idNotif,
    required this.content,
    required this.isRead,
    this.createdAt,
  });

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
    final now = DateTime.now();
    final diff = now.difference(createdAt!);

    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours}h";
    if (diff.inDays < 7) return "Il y a ${diff.inDays}j";
    return DateFormat('dd/MM/yyyy').format(createdAt!);
  }
}

class NotificationClient {
  final NotificationModel notification;
  final int clientId;
  final Map<String, dynamic>? client;

  NotificationClient({
    required this.notification,
    required this.clientId,
    this.client,
  });

  factory NotificationClient.fromJson(Map<String, dynamic> json) {
    return NotificationClient(
      notification: NotificationModel.fromJson(json),
      clientId: json['client_id'] ?? 0,
      client: json['client'],
    );
  }
}

class NotificationArtisan {
  final NotificationModel notification;
  final int artisanId;
  final Map<String, dynamic>? artisan;

  NotificationArtisan({
    required this.notification,
    required this.artisanId,
    this.artisan,
  });

  factory NotificationArtisan.fromJson(Map<String, dynamic> json) {
    return NotificationArtisan(
      notification: NotificationModel.fromJson(json),
      artisanId: json['artisan_id'] ?? 0,
      artisan: json['artisan'],
    );
  }
}