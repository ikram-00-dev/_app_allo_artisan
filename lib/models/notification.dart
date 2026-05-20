import 'package:intl/intl.dart';

class NotificationModel {
  final int idNotif;
  final String content;
  final bool isRead;
  final DateTime? createdAt;
  final String? targetRole;
  final int? clientId;
  final int? artisanId;
  final int? adminId;
  final int? moderatorId;

  NotificationModel({
    required this.idNotif,
    required this.content,
    required this.isRead,
    this.createdAt,
    this.targetRole,
    this.clientId,
    this.artisanId,
    this.adminId,
    this.moderatorId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotif: json['IDNotif'] ?? json['idNotif'] ?? 0,
      content: json['Content'] ?? json['content'] ?? '',
      isRead: json['IsRead'] ?? json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['CreatedAt'] ?? json['createdAt'] ?? ''),
      targetRole: json['TargetRole'] ?? json['targetRole'],
      clientId: json['ClientID'] ?? json['clientId'],
      artisanId: json['ArtisanID'] ?? json['artisanId'],
      adminId: json['AdminID'] ?? json['adminId'],
      moderatorId: json['ModeratorID'] ?? json['moderatorId'],
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