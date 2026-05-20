import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/message.dart';

class MessageController extends GetxController {
  var isLoading = false.obs;
  var messages = <Message>[].obs;
  var selectedMessage = Rxn<Message>();

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      final res = await ApiService.get("/messages");
      messages.value = (res as List).map((e) => Message.fromJson(e)).toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to load messages");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage({
    required String text,
    required int contactId,
    required bool isSentToClient,
  }) async {
    try {
      final data = {
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
        'is_sent_to_client': isSentToClient,
        'seen': false,
        'contact_id': contactId,
      };

      final response = await ApiService.sendMessage(data);
      final newMessage = Message.fromJson(response);
      messages.add(newMessage);

      // No auto-scroll - simple and works!

    } catch (e) {
      Get.snackbar("Erreur", "Impossible d'envoyer le message");
    }
  }

  void clear() {
    messages.clear();
    selectedMessage.value = null;
  }
}