import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/message.dart';
import '../services/storage_service.dart';

class MessageController extends GetxController {
  var isLoading = false.obs;
  var messages = <Message>[].obs;
  var selectedMessage = Rxn<Message>();
  var currentUserId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentUserId();
  }

  Future<void> loadCurrentUserId() async {
    try {
      final user = await ApiService.getCurrentUser();
      currentUserId.value = user['ID'] ?? user['id'] ?? 0;
    } catch (e) {
      print('Error loading user id: $e');
    }
  }

  Future<void> fetchMessages(int contactId) async {
    try {
      isLoading.value = true;
      final res = await ApiService.getMessages(contactId);
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
    required bool isSentByArtisan,
  }) async {
    try {
      final data = {
        'text': text,
        'contactId': contactId,
        'senderId': currentUserId.value,
        'seen': false,
      };

      final response = await ApiService.sendMessage(data);
      final newMessage = Message.fromJson(response);
      messages.add(newMessage);
    } catch (e) {
      Get.snackbar("Erreur", "Impossible d'envoyer le message");
    }
  }

  void clear() {
    messages.clear();
    selectedMessage.value = null;
  }
}