class Appointment {
  final int idAppointment;
  final DateTime scheduledTime;
  final String status;

  Appointment({
    required this.idAppointment,
    required this.scheduledTime,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      idAppointment: json['id_appointment'] ?? json['IDAppointment'] ?? 0,
      scheduledTime: DateTime.tryParse(json['scheduled_time'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduled_time': scheduledTime.toIso8601String(),
      'status': status,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}

class AppointmentUrgent {
  final Appointment appointment;
  final int requestId;
  final int clientId;
  final Map<String, dynamic>? urgentRequest;

  AppointmentUrgent({
    required this.appointment,
    required this.requestId,
    required this.clientId,
    this.urgentRequest,
  });

  factory AppointmentUrgent.fromJson(Map<String, dynamic> json) {
    return AppointmentUrgent(
      appointment: Appointment.fromJson(json),
      requestId: json['request_id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      urgentRequest: json['urgent_request'],
    );
  }
}

class AppointmentSimple {
  final Appointment appointment;
  final int messageId;
  final int contactId;
  final int requestId;
  final Map<String, dynamic>? simpleRequest;

  AppointmentSimple({
    required this.appointment,
    required this.messageId,
    required this.contactId,
    required this.requestId,
    this.simpleRequest,
  });

  factory AppointmentSimple.fromJson(Map<String, dynamic> json) {
    return AppointmentSimple(
      appointment: Appointment.fromJson(json),
      messageId: json['message_id'] ?? 0,
      contactId: json['contact_id'] ?? 0,
      requestId: json['request_id'] ?? 0,
      simpleRequest: json['simple_request'],
    );
  }
}