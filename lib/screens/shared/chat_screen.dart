import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/message_controller.dart';
import '../../models/message.dart';
import '../../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final int contactId;
  final String contactName;

  const ChatScreen({
    super.key,
    required this.contactId,
    required this.contactName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController controller = Get.find();

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isArtisan = false;
  int currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    controller.fetchMessages(widget.contactId);
  }

  Future<void> _loadUserRole() async {
    final role = await StorageService.getRole();
    setState(() {
      isArtisan = role == 'artisan';
    });

    final user = await StorageService.getUser();
    if (user != null) {
      currentUserId = user['ID'] ?? user['id'] ?? 0;
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() async {
    if (textController.text.trim().isEmpty) return;

    await controller.sendMessage(
      text: textController.text.trim(),
      contactId: widget.contactId,
      isSentByArtisan: isArtisan,
    );

    textController.clear();
    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECE5DD),

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xff075E54),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactName,
                style: const TextStyle(fontSize: 16)),
            const Text(
              "en ligne",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),

      /// ================= BODY =================
      body: Column(
        children: [

          /// ================= MESSAGES =================
          Expanded(
            child: Obx(() {
              // Filter messages for this contact
              final messages = controller.messages
                  .where((m) => m.contactId == widget.contactId)
                  .toList();

              if (controller.isLoading.value && messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];

                  final isMe = msg.isSentByCurrentUser(
                    isArtisan,
                    currentUserId,
                  );

                  return Align(
                    alignment: isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xffDCF8C6)
                            : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(
                            isMe ? 12 : 0,
                          ),
                          bottomRight: Radius.circular(
                            isMe ? 0 : 12,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          /// TEXT
                          Text(
                            msg.text,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),

                          /// TIME + SEEN
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg.formattedTime,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 5),
                              if (isMe)
                                Icon(
                                  msg.seen
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 14,
                                  color: msg.seen
                                      ? Colors.blue
                                      : Colors.grey,
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
          ),

          /// ================= INPUT =================
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            color: Colors.white,
            child: Row(
              children: [

                /// TEXT FIELD
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      filled: true,
                      fillColor:
                      const Color(0xffF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                /// SEND BUTTON
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xff075E54),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}