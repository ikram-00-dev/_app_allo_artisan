// lib/screens/shared/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';
import '../../routes/app_routes.dart';
import '../../core/widgets/bottom_nav_bar.dart';

// Rename class to avoid conflict with ChatScreen
class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.red),
            onPressed: () => _showReportDialog(context),
            tooltip: 'Signaler un problème',
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucun message', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text('Envoyez un message à un artisan ou client', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        }

        // Group messages by contactId
        final Map<int, List<dynamic>> groupedMessages = {};
        for (var msg in controller.messages) {
          groupedMessages.putIfAbsent(msg.contactId, () => []).add(msg);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedMessages.length,
          itemBuilder: (context, index) {
            final contactId = groupedMessages.keys.elementAt(index);
            final messages = groupedMessages[contactId]!;
            final lastMessage = messages.last;
            final contactName = lastMessage.isSentByCurrentUser(false, 0)
                ? 'Artisan'
                : 'Client #$contactId';

            return GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.chat,
                  arguments: {
                    'contactId': contactId,
                    'contactName': contactName,
                  },
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        contactName.isNotEmpty ? contactName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contactName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastMessage.text.length > 50 ? '${lastMessage.text.substring(0, 50)}...' : lastMessage.text,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          lastMessage.formattedTime,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        if (!lastMessage.seen && !lastMessage.isSentByCurrentUser(false, 0))
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showReportDialog(BuildContext context) {
    final TextEditingController reportController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.flag, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Signaler un problème', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Décrivez le problème que vous rencontrez avec la messagerie :',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reportController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Ex: Messages non reçus, problème technique, harcèlement...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (reportController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                Get.snackbar(
                  'Rapport envoyé',
                  'Merci pour votre signalement. Nous traiterons votre demande rapidement.',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 4),
                );
              } else {
                Get.snackbar('Erreur', 'Veuillez décrire le problème', backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}