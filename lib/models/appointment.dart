class Appointment {
  final int idAppointment;
  final DateTime createdAt;
  final DateTime scheduledTime;
  final String status;
  final int clientId;
  final int artisanId;
  final int? requestId;

  Appointment({
    required this.idAppointment,
    required this.createdAt,
    required this.scheduledTime,
    required this.status,
    required this.clientId,
    required this.artisanId,
    this.requestId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      idAppointment: json['IDAppointment'] ?? json['idAppointment'] ?? 0,
      createdAt: DateTime.tryParse(json['CreatedAt'] ?? json['createdAt'] ?? '') ?? DateTime.now(),
      scheduledTime: DateTime.tryParse(json['ScheduledTime'] ?? json['scheduledTime'] ?? '') ?? DateTime.now(),
      status: json['Status'] ?? json['status'] ?? 'pending',
      clientId: json['ClientID'] ?? json['clientId'] ?? 0,
      artisanId: json['ArtisanID'] ?? json['artisanId'] ?? 0,
      requestId: json['RequestID'] ?? json['requestId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': status,
      'clientId': clientId,
      'artisanId': artisanId,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}