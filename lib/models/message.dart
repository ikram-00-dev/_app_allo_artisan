import 'package:intl/intl.dart';

class Message {
  final int idMessage;
  final String text;
  final DateTime timestamp;
  final bool isSentToClient;
  final bool seen;
  final int contactId;

  Message({
    required this.idMessage,
    required this.text,
    required this.timestamp,
    required this.isSentToClient,
    required this.seen,
    required this.contactId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      idMessage: json['id_message'] ?? json['IDMessage'] ?? 0,
      text: json['text'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isSentToClient: json['is_sent_to_client'] ?? false,
      seen: json['seen'] ?? false,
      contactId: json['contact_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'is_sent_to_client': isSentToClient,
      'seen': seen,
      'contact_id': contactId,
    };
  }

  bool isSentByCurrentUser(bool isArtisan) {
    if (isArtisan) {
      return isSentToClient;
    } else {
      return !isSentToClient;
    }
  }

  String get formattedTime {
    final now = DateTime.now();
    if (timestamp.day == now.day && timestamp.month == now.month) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (timestamp.difference(now).inDays > -7) {
      return DateFormat('EEE', 'fr_FR').format(timestamp);
    } else {
      return DateFormat('dd/MM', 'fr_FR').format(timestamp);
    }
  }
}