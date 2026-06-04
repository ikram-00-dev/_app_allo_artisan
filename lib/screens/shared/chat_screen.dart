import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';
import '../../services/evaluation_service.dart';
import '../../core/widgets/evaluation_dialog.dart';
import '../../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final int contactId;
  final String contactName;
  final int? appointmentId; // ADD THIS - ID of the completed task

  const ChatScreen({
    super.key,
    required this.contactId,
    required this.contactName,
    this.appointmentId, // Optional, only for completed tasks
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
  bool _canEvaluate = false;
  bool _alreadyEvaluated = false;
  int _remainingHours = 0;
  bool _isLoadingEvaluation = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    controller.fetchMessages(widget.contactId);
    if (widget.appointmentId != null) {
      _checkEvaluationStatus();
    }
  }

  Future<void> _loadUserInfo() async {
    final role = await StorageService.getRole();
    final user = await StorageService.getUser();

    setState(() {
      isArtisan = role == 'artisan';
      currentUserId = user?['ID'] ?? user?['id'] ?? 0;
    });
  }

  Future<void> _checkEvaluationStatus() async {
    if (widget.appointmentId == null) {
      setState(() => _isLoadingEvaluation = false);
      return;
    }

    setState(() => _isLoadingEvaluation = true);

    try {
      final canEvaluate = await EvaluationService.canEvaluate(widget.appointmentId!);
      final alreadyEvaluated = await EvaluationService.isAlreadyEvaluated(widget.appointmentId!);
      final remainingHours = await EvaluationService.getRemainingHours(widget.appointmentId!);

      setState(() {
        _canEvaluate = canEvaluate && !alreadyEvaluated;
        _alreadyEvaluated = alreadyEvaluated;
        _remainingHours = remainingHours;
        _isLoadingEvaluation = false;
      });
    } catch (e) {
      debugPrint('Error checking evaluation status: $e');
      setState(() => _isLoadingEvaluation = false);
    }
  }

  void _showEvaluationDialog() {
    if (!_canEvaluate) {
      if (_alreadyEvaluated) {
        Get.snackbar(
          'Déjà évalué',
          'Vous avez déjà évalué cet artisan pour cette prestation.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (_remainingHours <= 0) {
        Get.snackbar(
          'Délai expiré',
          'Vous ne pouvez plus évaluer cette prestation car le délai de 24 heures est dépassé.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EvaluationDialog(
        artisanName: widget.contactName,
        artisanId: widget.contactId,
        appointmentId: widget.appointmentId!,
        onSubmit: _submitEvaluation,
      ),
    );
  }

  Future<void> _submitEvaluation(double rating, String comment) async {
    if (widget.appointmentId == null) return;

    final success = await EvaluationService.submitEvaluation(
      appointmentId: widget.appointmentId!,
      rating: rating,
      comment: comment,
    );

    if (success) {
      Get.snackbar(
        'Merci !',
        'Votre évaluation a été enregistrée avec succès.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      await _checkEvaluationStatus(); // Refresh status
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'enregistrer votre évaluation. Veuillez réessayer.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
        // ADD THE "TASK ENDED" BUTTON FOR CLIENTS ONLY
        actions: [
          if (!isArtisan && widget.appointmentId != null)
            _buildTaskEndedButton(),
        ],
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

  Widget _buildTaskEndedButton() {
    if (_isLoadingEvaluation) {
      return Container(
        margin: const EdgeInsets.only(right: 16),
        width: 40,
        height: 40,
        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: ElevatedButton.icon(
        onPressed: _showEvaluationDialog,
        icon: Icon(
          _alreadyEvaluated ? Icons.star : Icons.star_border,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          _alreadyEvaluated ? 'Déjà évalué' : 'Évaluer',
          style: const TextStyle(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _alreadyEvaluated ? Colors.grey : Colors.amber,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
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