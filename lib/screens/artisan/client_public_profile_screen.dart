// client_public_profile_screen.dart (FIXED)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/client.dart';
import '../../models/artisan.dart';
import '../../models/user.dart';
import '../../routes/app_routes.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';

class ClientPublicProfileScreen extends StatefulWidget {
  final Client client;

  const ClientPublicProfileScreen({
    super.key,
    required this.client,
  });

  @override
  State<ClientPublicProfileScreen> createState() => _ClientPublicProfileScreenState();
}

class _ClientPublicProfileScreenState extends State<ClientPublicProfileScreen> {
  bool showFollowing = false;
  bool isSendingMessage = false;

  // =========================================================
  // MOCK FOLLOWING LIST
  // =========================================================
  final List<Artisan> following = [
    Artisan(
      user: User(
        idUser: 1,
        firstName: "Jean",
        middleName: "",
        lastName: "Dupont",
        username: "jean.dupont",
        email: "jean@test.com",
        phoneNumber: "0555000000",
        password: "",
        creationDate: DateTime.now(),
        avatarUrl: "",
        role: "artisan",
      ),
      status: "active",
      isAvailable: true,
      category: "Plomberie",
      activesStatus: "active",
      diploma: "CAP",
      bio: "Professional plumber",
      province: "Île-de-France",
      city: "Paris",
      district: "15ème",
      latitude: null,
      longitude: null,
      experience: 5,
      rating: 4.8,
      reviewCount: 120,
      followers: null,
    ),
    Artisan(
      user: User(
        idUser: 2,
        firstName: "Marie",
        middleName: "",
        lastName: "Martin",
        username: "marie.martin",
        email: "marie@test.com",
        phoneNumber: "0666000000",
        password: "",
        creationDate: DateTime.now(),
        avatarUrl: "",
        role: "artisan",
      ),
      status: "active",
      isAvailable: true,
      category: "Électricité",
      activesStatus: "active",
      diploma: "BTS",
      bio: "Electric specialist",
      province: "Auvergne-Rhône-Alpes",
      city: "Lyon",
      district: "3ème",
      latitude: null,
      longitude: null,
      experience: 7,
      rating: 4.5,
      reviewCount: 85,
      followers: null,
    ),
  ];

  void _sendMessage() {
    setState(() {
      isSendingMessage = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isSendingMessage = false;
        });

        Get.snackbar(
          "Message",
          "Chat with ${widget.client.name} will open here",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Profil de ${widget.client.name}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(widget.client),
            const SizedBox(height: 16),
            _buildFollowingSection(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PROFILE HEADER (FIXED - removed creationDate)
  // =========================================================
  Widget _buildProfileHeader(Client client) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: NetworkImage(
                  client.avatarUrl.isNotEmpty
                      ? client.avatarUrl
                      : "https://i.pravatar.cc/300?img=${client.id}",
                ),
                child: client.avatarUrl.isEmpty
                    ? Text(
                  client.name.isNotEmpty ? client.name[0].toUpperCase() : "C",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.mail_outline,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            client.email,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          client.phone,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // REMOVED: "Membre depuis" row because creationDate doesn't exist in Client model
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // MESSAGE BUTTON
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSendingMessage ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: Colors.green.shade300,
                  ),
                  icon: isSendingMessage
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.message),
                  label: Text(
                    isSendingMessage ? "Envoi..." : "Envoyer un message",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),

          // Report button
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              _showReportDialog();
            },
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: const Text("Signaler ce profil"),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FOLLOWING SECTION
  // =========================================================
  Widget _buildFollowingSection() {
    if (following.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.favorite,
                color: Colors.pink.shade600,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Abonnements",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Aucun artisan suivi",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              showFollowing = !showFollowing;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.pink.shade600,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Abonnements",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${following.length} artisans suivis",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  showFollowing
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        if (showFollowing) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: following.map((artisan) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          artisan.avatarUrl.isNotEmpty
                              ? artisan.avatarUrl
                              : "https://i.pravatar.cc/150?img=${artisan.id}",
                        ),
                        child: artisan.avatarUrl.isEmpty
                            ? Text(
                          artisan.fullName.isNotEmpty ? artisan.fullName[0].toUpperCase() : "A",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artisan.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              artisan.category,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed(
                            "/artisan-profile",
                            arguments: artisan.id,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Voir"),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Signaler ce profil"),
          content: const Text("Voulez-vous vraiment signaler ce profil ? Nous examinerons votre signalement."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Get.snackbar(
                  "Signalement",
                  "Merci pour votre signalement. Nous allons l'examiner.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Signaler"),
            ),
          ],
        );
      },
    );
  }
}