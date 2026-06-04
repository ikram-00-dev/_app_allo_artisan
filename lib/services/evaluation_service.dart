// lib/services/evaluation_service.dart
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'storage_service.dart';

class EvaluationService {
  static const int EVALUATION_WINDOW_HOURS = 24;

  // Check if user can evaluate (within 24 hours and not yet evaluated)
  static Future<bool> canEvaluate(int appointmentId) async {
    try {
      final response = await ApiService.checkEvaluationAvailability(appointmentId);
      return response['canEvaluate'] ?? false;
    } catch (e) {
      debugPrint('Error checking evaluation availability: $e');
      return false;
    }
  }

  // Check if already evaluated
  static Future<bool> isAlreadyEvaluated(int appointmentId) async {
    try {
      final response = await ApiService.getAppointmentEvaluationStatus(appointmentId);
      return response['evaluated'] ?? false;
    } catch (e) {
      debugPrint('Error checking evaluation status: $e');
      return false;
    }
  }

  // Get remaining hours for evaluation
  static Future<int> getRemainingHours(int appointmentId) async {
    try {
      final response = await ApiService.getAppointmentEvaluationStatus(appointmentId);
      return response['remainingHours'] ?? 0;
    } catch (e) {
      debugPrint('Error getting remaining hours: $e');
      return 0;
    }
  }

  // Submit evaluation
  static Future<bool> submitEvaluation({
    required int appointmentId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await ApiService.submitEvaluation(
        appointmentId: appointmentId,
        rating: rating,
        comment: comment,
      );
      return response['success'] ?? false;
    } catch (e) {
      debugPrint('Error submitting evaluation: $e');
      return false;
    }
  }

  // Format remaining time
  static String formatRemainingTime(int hours) {
    if (hours <= 0) return 'Expiré';
    if (hours < 1) return 'Moins d\'une heure';
    if (hours == 1) return '1 heure restante';
    return '$hours heures restantes';
  }
}