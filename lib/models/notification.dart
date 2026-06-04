// models/notification_model.dart
import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String content;
  bool isRead;
  final DateTime timestamp;
  final String type;
  final int relatedId;

  NotificationModel({
    required this.id,
    required this.content,
    required this.isRead,
    required this.timestamp,
    required this.type,
    required this.relatedId,
  });

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'À l\'instant';
    if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays} j';
    return DateFormat('dd/MM/yyyy').format(timestamp);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isRead': isRead,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'relatedId': relatedId,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      content: json['content'],
      isRead: json['isRead'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      relatedId: json['relatedId'] ?? 0,
    );
  }
}