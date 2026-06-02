// lib/models/request_model.dart - Add zoneKm property
import 'package:flutter/material.dart';

class RequestModel {
  final int? idRequest;
  final DateTime requestDate;
  final String status;
  final String description;
  final String type; // 'simple' or 'urgent'
  final String category;
  final int clientId;
  final double? latitude;
  final double? longitude;
  final String? priorityLevel; // 'Low', 'Medium', 'High'
  final String? imageUrl;
  final int? zoneKm; // ADD THIS - for urgent requests distance
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Add these methods to the RequestModel class

  bool get isExpired {
    if (createdAt == null) return false;
    final expiryTime = createdAt!.add(const Duration(hours: 72));
    return DateTime.now().isAfter(expiryTime);
  }

  bool get canBeActivated {
    return isExpired && status.toLowerCase() != 'accepted';
  }

  String get displayStatus {
    if (isExpired && status.toLowerCase() != 'accepted') {
      return 'EXPIRÉE';
    }
    return statusLabel;
  }

  Color get displayStatusColor {
    if (isExpired && status.toLowerCase() != 'accepted') {
      return Colors.grey;
    }
    return statusColor;
  }

  RequestModel({
    this.idRequest,
    required this.requestDate,
    required this.status,
    required this.description,
    required this.type,
    required this.category,
    required this.clientId,
    this.latitude,
    this.longitude,
    this.priorityLevel,
    this.imageUrl,
    this.zoneKm, // ADD THIS
    this.createdAt,
    this.updatedAt,
  });

  // Factory to create from JSON (matches Go JSON tags)
  factory RequestModel.fromJson(Map<String, dynamic> json) {
    // Backend returns 'imageUrl' field
    String? imageUrl = json['imageUrl'] ?? json['ImageUrl'];

    return RequestModel(
      idRequest: json['idRequest'] ?? json['IDRequest'],
      requestDate: _parseDateTime(json['requestDate'] ?? json['RequestDate']),
      status: json['status'] ?? json['Status'] ?? 'pending',
      description: json['description'] ?? json['Description'] ?? '',
      type: json['type'] ?? json['Type'] ?? 'simple',
      category: json['category'] ?? json['Category'] ?? '',
      clientId: json['clientId'] ?? json['ClientID'] ?? json['ClientId'] ?? 0,
      latitude: (json['latitude'] ?? json['Latitude'])?.toDouble(),
      longitude: (json['longitude'] ?? json['Longitude'])?.toDouble(),
      priorityLevel: json['priorityLevel'] ?? json['PriorityLevel'],
      imageUrl: imageUrl,
      zoneKm: json['zoneKm'] ?? json['ZoneKm'],
      createdAt: _parseDateTime(json['createdAt'] ?? json['CreatedAt']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['UpdatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // Convert to JSON for API requests (matches Go struct fields)
  Map<String, dynamic> toJson() {
    return {
      if (idRequest != null) 'IDRequest': idRequest,
      'RequestDate': requestDate.toIso8601String(),
      'Status': status,
      'Description': description,
      'Type': type,
      'Category': category,
      'ClientID': clientId,
      if (latitude != null) 'Latitude': latitude,
      if (longitude != null) 'Longitude': longitude,
      if (priorityLevel != null) 'PriorityLevel': priorityLevel,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (zoneKm != null) 'ZoneKm': zoneKm, // ADD THIS
      if (createdAt != null) 'CreatedAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'UpdatedAt': updatedAt!.toIso8601String(),
    };
  }

  bool get isUrgent => type == 'urgent';

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'active': return 'ACTIF';
      case 'accepted': return 'ACCEPTÉ';
      case 'pending': return 'EN ATTENTE';
      case 'declined': return 'REFUSÉ';
      case 'cancelled': return 'ANNULÉ';
      default: return status.toUpperCase();
    }
  }


  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'accepted': return Colors.blue;
      case 'pending': return Colors.orange;
      case 'declined': case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}