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
  final MessageController controller = Get.find<MessageController>();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isArtisan = false;
  int currentUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    controller.fetchMessages(widget.contactId);
  }

  Future<void> _loadUserInfo() async {
    final role = await StorageService.getRole();
    final user = await StorageService.getUser();

    setState(() {
      isArtisan = role == 'artisan';
      currentUserId = user?['ID'] ?? user?['id'] ?? 0;
    });
  }

  void _scrollToBottom() {
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

  Future<void> _sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    await controller.sendMessage(
      text: text,
      contactId: widget.contactId,
      isSentByArtisan: isArtisan,
    );

    textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffECE5DD),
      appBar: AppBar(
        backgroundColor: const Color(0xff075E54),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactName, style: const TextStyle(fontSize: 16)),
            const Text("en ligne", style: TextStyle(fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              final messages = controller.messages
                  .where((m) => m.contactId == widget.contactId)
                  .toList();

              if (controller.isLoading.value && messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(12),
                reverse: false,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.isSentByCurrentUser(isArtisan, currentUserId);

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xffDCF8C6) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isMe ? 12 : 0),
                          bottomRight: Radius.circular(isMe ? 0 : 12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            msg.text,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                msg.formattedTime,
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 5),
                                Icon(
                                  msg.seen ? Icons.done_all : Icons.done,
                                  size: 14,
                                  color: msg.seen ? Colors.blue : Colors.grey,
                                ),
                              ],
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

          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xffF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xff075E54),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}