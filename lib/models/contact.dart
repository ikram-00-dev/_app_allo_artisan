class Contact {
  final int id;
  final int clientId;
  final int artisanId;
  final DateTime createdAt;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? artisan;
  String? lastMessage;
  DateTime? lastMessageTime;
  int unreadCount;
  bool isOnline;

  Contact({
    required this.id,
    required this.clientId,
    required this.artisanId,
    required this.createdAt,
    this.client,
    this.artisan,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? json['ID'] ?? 0,
      clientId: json['client_id'] ?? 0,
      artisanId: json['artisan_id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      client: json['client'],
      artisan: json['artisan'],
    );
  }

  String get name {
    if (client != null) {
      return client?['username'] ?? 'Client';
    }
    if (artisan != null) {
      return artisan?['username'] ?? 'Artisan';
    }
    return 'Contact';
  }

  String get avatar {
    final name = this.name;
    if (name.isNotEmpty && name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '??';
  }
}