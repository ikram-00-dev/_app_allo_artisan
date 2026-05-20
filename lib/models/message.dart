import 'package:intl/intl.dart';

class Message {
  final int id;
  final int contactId;
  final int senderId;
  final String text;
  final DateTime createdAt;
  final bool seen;

  Message({
    required this.id,
    required this.contactId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.seen,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['ID'] ?? json['id'] ?? 0,
      contactId: json['ContactID'] ?? json['contactId'] ?? 0,
      senderId: json['SenderID'] ?? json['senderId'] ?? 0,
      text: json['Text'] ?? json['text'] ?? '',
      createdAt: DateTime.tryParse(json['CreatedAt'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      seen: json['Seen'] ?? json['seen'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'contactId': contactId,
      'senderId': senderId,
      'seen': seen,
    };
  }

  bool isSentByCurrentUser(bool isArtisan, int currentUserId) {
    return senderId == currentUserId;
  }

  String get formattedTime {
    final now = DateTime.now();
    if (createdAt.day == now.day && createdAt.month == now.month) {
      return DateFormat('HH:mm').format(createdAt);
    } else if (createdAt.difference(now).inDays > -7) {
      return DateFormat('EEE', 'fr_FR').format(createdAt);
    } else {
      return DateFormat('dd/MM', 'fr_FR').format(createdAt);
    }
  }
}