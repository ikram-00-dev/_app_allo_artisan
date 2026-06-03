// lib/models/request_model.dart - COMPLETE FIXED VERSION

import 'package:flutter/material.dart';

class RequestModel {
  final int? idRequest;
  final DateTime requestDate;
  final String status;
  final String description;
  final String type;
  final String category;
  final int clientId;
  final double? latitude;
  final double? longitude;
  final String? priorityLevel;
  final String? imageUrl;
  final int? zoneKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive {
    if (createdAt == null) return false;
    final expiryTime = createdAt!.add(const Duration(hours: 72));
    return DateTime.now().isBefore(expiryTime);
  }

  bool get isExpired {
    if (createdAt == null) return false;
    final expiryTime = createdAt!.add(const Duration(hours: 72));
    return DateTime.now().isAfter(expiryTime);
  }

  // ADD THIS MISSING GETTER
  bool get canBeActivated {
    return isExpired;
  }

  String get displayStatus {
    return isActive ? 'ACTIVE' : 'INACTIVE';
  }

  Color get displayStatusColor {
    return isActive ? Colors.green : Colors.grey;
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
    this.zoneKm,
    this.createdAt,
    this.updatedAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    // Prioritize createdAt, fallback to requestDate
    DateTime? createdAtValue = _parseDateTime(json['createdAt']);
    if (createdAtValue == DateTime.now() && json['requestDate'] != null) {
      createdAtValue = _parseDateTime(json['requestDate']);
    }

    return RequestModel(
      idRequest: json['idRequest'],
      requestDate: _parseDateTime(json['requestDate']),
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
      type: json['type'] ?? (json['priorityLevel'] != null ? 'urgent' : 'simple'),
      category: json['category'] ?? '',
      clientId: json['clientId'] ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      priorityLevel: json['priorityLevel'],
      imageUrl: json['imageUrl'],
      zoneKm: json['zoneKm'] ?? json['zone_km'] ?? 0,
      createdAt: createdAtValue,
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        // Handle ISO 8601 format with timezone
        String dateStr = value;
        // Replace Z with +00:00 for UTC
        if (dateStr.endsWith('Z')) {
          dateStr = dateStr.replaceAll('Z', '+00:00');
        }
        return DateTime.parse(dateStr).toLocal();
      } catch (e) {
        debugPrint('Failed to parse date: $value, error: $e');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  bool get isUrgent => type == 'urgent';
}