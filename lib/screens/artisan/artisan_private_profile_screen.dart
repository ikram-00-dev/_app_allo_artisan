// lib/screens/artisan/artisan_private_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/artisan_controller.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';

class ArtisanPrivateProfileScreen extends StatelessWidget {
   ArtisanPrivateProfileScreen({super.key});

  final ArtisanController controller = Get.put(ArtisanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      body: Obx(() {
        final artisan = controller.artisan.value;

        if (controller.isLoading.value || artisan == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildAvailabilityCard(),
              const SizedBox(height: 16),
              _buildFollowersCard(),
              const SizedBox(height: 16),
              _buildCreatePost(),
              const SizedBox(height: 16),
              _buildPostsList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    final artisan = controller.artisan.value!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  artisan.avatarUrl.isEmpty
                      ? "https://i.pravatar.cc/150"
                      : artisan.avatarUrl,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisan.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      artisan.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artisan.category,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Get.toNamed('/settings');
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Active status"),
              Switch(
                value: artisan.isActive,
                onChanged: (val) => controller.toggleActive(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Get.dialog(_buildQrDialog());
            },
            icon: const Icon(Icons.qr_code),
            label: const Text("Show QR"),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Disponibilité",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.availability.isEmpty) {
              return const Center(child: Text("Aucune disponibilité"));
            }
            return Column(
              children: List.generate(controller.availability.length, (dayIndex) {
                final day = controller.availability[dayIndex];
                return ExpansionTile(
                  title: Text(day["dayName"] ?? "Jour ${day["day"]}"),
                  children: [
                    Wrap(
                      spacing: 6,
                      children: List.generate(24, (hour) {
                        final slot = day["slots"][hour];
                        final available = slot["available"];
                        return GestureDetector(
                          onTap: () => controller.toggleSlot(dayIndex, hour),
                          child: Chip(
                            label: Text("$hour h"),
                            backgroundColor: available ? Colors.green[100] : Colors.red[100],
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFollowersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Abonnés",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.followers.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text("Aucun abonné pour le moment"),
                ),
              );
            }
            return Column(
              children: controller.followers.map((f) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(f["name"][0].toUpperCase()),
                  ),
                  title: Text(f["name"]),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCreatePost() {
    final textController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          TextField(
            controller: textController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Partagez votre travail...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              controller.createPost(textController.text, null);
              textController.clear();
            },
            child: const Text("Publier"),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return Obx(() {
      if (controller.posts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text("Aucune publication. Créez votre première publication!"),
          ),
        );
      }

      return Column(
        children: controller.posts.map((post) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, size: 50),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(post.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () => controller.deletePost(post.idPost),
                      child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildQrDialog() {
    return AlertDialog(
      title: const Text("QR Code"),
      content: const Icon(Icons.qr_code, size: 120),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Fermer"),
        ),
      ],
    );
  }
}