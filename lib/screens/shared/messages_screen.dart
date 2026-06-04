// messages_screen.dart - Simplified & Fixed
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/message_controller.dart';
import '../../routes/app_routes.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageController());

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      body: Obx(() => ListView.builder(
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final msg = controller.messages[index];
          return ListTile(
            leading: const CircleAvatar(),
            title: Text(msg.text),
            subtitle: Text(msg.formattedTime),
            onTap: () => Get.toNamed(
              AppRoutes.chat,
              arguments: {'contactId': msg.contactId, 'contactName': 'Artisan/Client'},
            ),
          );
        },
      )),
    );
  }
}