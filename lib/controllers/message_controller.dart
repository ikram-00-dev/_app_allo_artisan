// lib/controllers/message_controller.dart
import 'package:get/get.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class MessageController extends GetxController {
  var messages = <Message>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStaticMessages();
  }

  void loadStaticMessages() {
    // Add some static messages for demonstration
    messages.value = [
      Message(
        id: 1,
        contactId: 101,
        senderId: 101,
        text: 'Bonjour, je suis intéressé par vos services',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        seen: true,
      ),
      Message(
        id: 2,
        contactId: 101,
        senderId: 0, // Current user
        text: 'Bonjour! Je serais ravi de vous aider. Quel est votre besoin?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        seen: true,
      ),
      Message(
        id: 3,
        contactId: 101,
        senderId: 101,
        text: 'J\'ai une fuite d\'eau dans ma salle de bain',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        seen: true,
      ),
      Message(
        id: 4,
        contactId: 102,
        senderId: 102,
        text: 'Besoin d\'un électricien pour installation',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        seen: false,
      ),
    ];
  }

  Future<void> fetchMessages(int contactId) async {
    try {
      isLoading.value = true;
      // For static demo, just filter existing messages
      // In production, you would call API
      // final response = await ApiService.getMessages(contactId);
      // messages.value = (response as List).map((json) => Message.fromJson(json)).toList();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error fetching messages: $e');
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
      isLoading.value = true;

      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch,
        contactId: contactId,
        senderId: isSentByArtisan ? 0 : contactId, // Simplified for demo
        text: text,
        createdAt: DateTime.now(),
        seen: false,
      );

      messages.add(newMessage);

      // In production, call API
      // await ApiService.sendMessage({
      //   'text': text,
      //   'contactId': contactId,
      // });
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addStaticMessage({
    required String text,
    required bool isMe,
    required int contactId,
    required DateTime time,
    required bool seen,
  }) {
    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      contactId: contactId,
      senderId: isMe ? 0 : contactId,
      text: text,
      createdAt: time,
      seen: seen,
    );
    messages.add(newMessage);
  }

  void markAsRead(int messageId) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      messages[index] = Message(
        id: messages[index].id,
        contactId: messages[index].contactId,
        senderId: messages[index].senderId,
        text: messages[index].text,
        createdAt: messages[index].createdAt,
        seen: true,
      );
      messages.refresh();
    }
  }
}