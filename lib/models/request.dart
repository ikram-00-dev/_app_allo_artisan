enum PriorityLevel { low, medium, high }

class Request {
  final int idRequest;
  final DateTime requestDate;
  final String status;
  final String description;

  Request({
    required this.idRequest,
    required this.requestDate,
    required this.status,
    required this.description,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      idRequest: json['id_request'] ?? json['IDRequest'] ?? 0,
      requestDate: DateTime.tryParse(json['request_date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
    );
  }
}

class UrgentRequest {
  final Request request;
  final DateTime deadline;
  final PriorityLevel priorityLevel;
  final int clientId;
  final Map<String, dynamic>? client;

  UrgentRequest({
    required this.request,
    required this.deadline,
    required this.priorityLevel,
    required this.clientId,
    this.client,
  });

  factory UrgentRequest.fromJson(Map<String, dynamic> json) {
    return UrgentRequest(
      request: Request.fromJson(json),
      deadline: DateTime.tryParse(json['deadline'] ?? '') ?? DateTime.now(),
      priorityLevel: _parsePriorityLevel(json['priority_level']),
      clientId: json['client_id'] ?? 0,
      client: json['client'],
    );
  }

  static PriorityLevel _parsePriorityLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'high':
        return PriorityLevel.high;
      case 'medium':
        return PriorityLevel.medium;
      default:
        return PriorityLevel.low;
    }
  }

  String get clientName => client?['username'] ?? 'Client';
  bool get isUrgent => priorityLevel == PriorityLevel.high;
}