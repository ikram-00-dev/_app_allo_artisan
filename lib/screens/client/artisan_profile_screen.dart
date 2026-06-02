// lib/screens/client/artisan_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/artisan_controller.dart';
import '../../controllers/artisan_public_profile_controller.dart';

class ArtisanProfileScreen extends StatelessWidget {
  final int? artisanId;

  const ArtisanProfileScreen({super.key, this.artisanId});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with artisanId if provided
    if (!Get.isRegistered<ArtisanPublicProfileController>()) {
      Get.put(ArtisanPublicProfileController());
    }

    final controller = Get.find<ArtisanPublicProfileController>();
    final artisanController = Get.find<ArtisanController>();

    // If artisanId is passed directly, load it
    if (artisanId != null && artisanController.artisan.value?.id != artisanId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        artisanController.loadArtisanById(artisanId!);
      });
    }

    return Obx(() {
      final artisan = artisanController.artisan.value;
      final isLoading = artisanController.isLoading.value;

      if (isLoading) {
        return _buildLoadingScreen();
      }

      if (artisan == null) {
        return _buildErrorScreen();
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(controller.fullName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => controller.goBack(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(controller),
              const SizedBox(height: 16),
              _buildProfileButton(controller),
              if (controller.showProfileDetails.value) _buildProfileDetails(controller),
              const SizedBox(height: 16),
              _buildCalendarButton(controller),
              if (controller.showCalendarDetails.value) _buildCalendar(controller),
              const SizedBox(height: 16),
              _buildPostsSection(controller),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profil Artisan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profil Artisan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Artisan non trouvé", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ArtisanPublicProfileController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  controller.getInitials(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.fullName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (controller.isActive)
                          const Icon(Icons.verified, color: Colors.blue, size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text(
                              controller.category,
                              style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        Expanded(
                          child: Text(
                            controller.location,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(controller.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text("(${controller.reviewCount})", style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: controller.statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 10, color: controller.statusColor),
                              const SizedBox(width: 6),
                              Text(
                                controller.statusText,
                                style: TextStyle(
                                  color: controller.statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Obx(() => ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isFollowing ? Colors.grey[300] : Colors.green,
                    foregroundColor: controller.isFollowing ? Colors.black : Colors.white,
                  ),
                  onPressed: () => controller.toggleFollow(),
                  icon: Icon(controller.isFollowing ? Icons.check : Icons.person_add),
                  label: Text(controller.isFollowing ? "Suivi" : "Suivre"),
                )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => controller.sendMessage(),
                  icon: const Icon(Icons.message),
                  label: const Text("Message"),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildProfileDetails(ArtisanPublicProfileController controller) {
    return Obx(() => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("À propos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(controller.bio, style: const TextStyle(height: 1.5, color: Colors.black87)),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(child: _infoCard("Diplôme", controller.diploma)),
              const SizedBox(width: 12),
              Expanded(child: _infoCard("Statut", controller.statusText)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _infoCard("Expérience", "${controller.experience} ans")),
              const SizedBox(width: 12),
              Expanded(child: _infoCard("Note", controller.rating.toStringAsFixed(1))),
            ],
          ),

          const SizedBox(height: 20),
          const Text("Contact", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.phone, size: 18, color: Colors.grey), const SizedBox(width: 10), Expanded(child: Text(controller.phone))]),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.email, size: 18, color: Colors.grey), const SizedBox(width: 10), Expanded(child: Text(controller.email))]),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Text(
              "• Actif : Reçoit les notifications et demandes\n"
                  "• Inactif : Ne reçoit pas de notifications",
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(ArtisanPublicProfileController controller) {
    return GestureDetector(
      onTap: () => controller.toggleProfileDetails(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Obx(() => Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.info, color: Colors.blue),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Informations professionnelles", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Expérience, diplôme, spécialités", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(controller.showProfileDetails.value ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
          ],
        )),
      ),
    );
  }

  Widget _buildCalendarButton(ArtisanPublicProfileController controller) {
    return GestureDetector(
      onTap: () => controller.toggleCalendarDetails(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Obx(() => Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.calendar_month, color: Colors.green),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Disponibilité", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Voir les créneaux disponibles", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(controller.showCalendarDetails.value ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
          ],
        )),
      ),
    );
  }

  Widget _buildCalendar(ArtisanPublicProfileController controller) {
    return Obx(() {
      final availabilityData = controller.availability;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            const Text("Calendrier de disponibilité", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(24, (index) {
                bool available = false;

                // Check availability based on backend data
                if (availabilityData.isNotEmpty) {
                  final now = DateTime.now();
                  final todayAvailability = availabilityData.firstWhere(
                        (day) {
                      final date = day['date'];
                      if (date is DateTime) {
                        return date.day == now.day &&
                            date.month == now.month &&
                            date.year == now.year;
                      }
                      return false;
                    },
                    orElse: () => {'available': false},
                  );
                  available = todayAvailability['available'] ?? false;
                } else {
                  // Default: available from 8 AM to 6 PM
                  available = index >= 8 && index < 18;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: available ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${index.toString().padLeft(2, '0')}h",
                    style: TextStyle(color: available ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text("Heures de travail (disponibilité générale)", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    });
  }

  Widget _buildPostsSection(ArtisanPublicProfileController controller) {
    return Obx(() {
      final posts = controller.posts;

      if (posts.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text("Publications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ...posts.map((post) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.image != null && post.image!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(
                      post.image!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.content),
                      const SizedBox(height: 12),
                      Text(controller.formatDate(post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Text("${post.likesCount ?? 0}"),
                          const SizedBox(width: 16),
                          const Icon(Icons.comment, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text("${post.commentsCount ?? 0}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      );
    });
  }
}