// lib/screens/client/artisan_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../controllers/artisan_controller.dart';
import '../../models/artisan.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final int artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  final ArtisanController controller = Get.find<ArtisanController>();
  bool showProfileDetails = false;
  bool showCalendarDetails = false;
  bool showQRCode = false;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    controller.loadArtisanById(widget.artisanId);
    controller.loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (controller.isLoading.value || controller.artisan.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final Artisan artisan = controller.artisan.value!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(artisan),
              const SizedBox(height: 16),
              _buildProfileButton(),
              if (showProfileDetails) _buildProfileDetails(artisan),
              const SizedBox(height: 16),
              _buildCalendarButton(),
              if (showCalendarDetails) _buildCalendar(),
              const SizedBox(height: 16),
              _buildPostsSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(Artisan artisan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(artisan.avatarUrl.isNotEmpty ? artisan.avatarUrl : "https://i.pravatar.cc/300"),
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
                            artisan.fullName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (artisan.rating != null) const Icon(Icons.verified, color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(artisan.category, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        Expanded(
                          child: Text(
                            artisan.fullAddress,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text((artisan.rating ?? 0).toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text("(${artisan.reviewCount ?? 0})", style: const TextStyle(color: Colors.grey)),
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
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey[200] : Colors.green,
                    foregroundColor: isFollowing ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => setState(() => isFollowing = !isFollowing),
                  icon: Icon(isFollowing ? Icons.check : Icons.person_add),
                  label: Text(isFollowing ? "Following" : "Follow"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Get.toNamed("/messages"),
                  icon: const Icon(Icons.message),
                  label: const Text("Message"),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Colors.grey)),
                onPressed: () => setState(() => showQRCode = !showQRCode),
                icon: const Icon(Icons.qr_code),
              ),
            ],
          ),
          if (showQRCode) ...[
            const SizedBox(height: 20),
            QrImageView(
              data: "artisan:${widget.artisanId}",
              version: QrVersions.auto,
              size: 200,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () => setState(() => showProfileDetails = !showProfileDetails),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.info, color: Colors.blue),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Professional Information", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("Experience, diploma, specialties", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(showProfileDetails ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(Artisan artisan) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(artisan.bio.isNotEmpty ? artisan.bio : "No description provided",
              style: const TextStyle(height: 1.5, color: Colors.black87)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _infoCard("Diploma", artisan.diploma.isNotEmpty ? artisan.diploma : "Not specified")),
              const SizedBox(width: 12),
              Expanded(child: _infoCard("Status", artisan.activesStatus)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _infoCard("Experience", "${artisan.experience} years")),
              const SizedBox(width: 12),
              Expanded(child: _infoCard("Rating", (artisan.rating ?? 0).toStringAsFixed(1))),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Contact", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.phone, size: 18, color: Colors.grey), const SizedBox(width: 10), Text(artisan.phone)]),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.email, size: 18, color: Colors.grey), const SizedBox(width: 10), Expanded(child: Text(artisan.email))]),
        ],
      ),
    );
  }

  Widget _buildCalendarButton() {
    return GestureDetector(
      onTap: () => setState(() => showCalendarDetails = !showCalendarDetails),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.calendar_month, color: Colors.green),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Availability", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("See available slots", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(showCalendarDetails ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          const Text("Availability Calendar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: List.generate(24, (index) {
              final available = index >= 8 && index < 18;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: available ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("${index.toString().padLeft(2, '0')}h",
                    style: TextStyle(color: available ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    return Obx(() {
      if (controller.posts.isEmpty) return const SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text("Publications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ...controller.posts.map((post) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(post.image, width: double.infinity, height: 250, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 50))),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.content),
                      const SizedBox(height: 12),
                      Text(_formatDate(post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}