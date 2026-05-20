import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/client.dart';
import '../../models/artisan_model.dart';

class ClientProfileScreen extends StatefulWidget {
  final Client client;

  /// true => owner profile
  /// false => public profile
  final bool isPrivate;

  const ClientProfileScreen({
    super.key,
    required this.client,
    this.isPrivate = true,
  });

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  bool showFollowing = false;

  // =========================================================
  // MOCK FOLLOWING LIST
  // =========================================================
  final List<Artisan> following = [
    Artisan(
      user: User(
        idUser: 1,
        username: "Jean Dupont",
        email: "jean@test.com",
        password: "",
        creationDate: DateTime.now(),
        phoneNumber: "0555000000",
      ),
      location: "Paris",
      category: "Plomberie",
      activesStatus: "active",
      diploma: "CAP",
      bio: "Professional plumber",
      rating: 4.8,
      reviewCount: 120,
    ),
    Artisan(
      user: User(
        idUser: 2,
        username: "Marie Martin",
        email: "marie@test.com",
        password: "",
        creationDate: DateTime.now(),
        phoneNumber: "0666000000",
      ),
      location: "Lyon",
      category: "Electrician",
      activesStatus: "active",
      diploma: "BTS",
      bio: "Electric specialist",
      rating: 4.5,
      reviewCount: 85,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final client = widget.client;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.isPrivate ? "My Profile" : "Client Profile",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =====================================================
            // PROFILE HEADER
            // =====================================================
            _buildProfileHeader(client),

            const SizedBox(height: 16),

            // =====================================================
            // FOLLOWING SECTION
            // =====================================================
            _buildFollowingSection(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PROFILE HEADER
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
              // PROFILE IMAGE
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/300?img=${client.id}",
                ),
              ),

              const SizedBox(width: 16),

              // INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME
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

                        // VERIFIED ICON
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

                    // EMAIL
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

                    // PHONE
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

                    const SizedBox(height: 8),

                    // ID
                    Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Client ID : ${client.id}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // =====================================================
          // PRIVATE ACTIONS
          // =====================================================
          if (widget.isPrivate) ...[
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/settings');
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    icon: const Icon(Icons.settings),
                    label: const Text("Settings"),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    icon: const Icon(Icons.message),
                    label: const Text("Message"),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // FOLLOWING SECTION
  // =========================================================
  Widget _buildFollowingSection() {
    return Column(
      children: [
        // HEADER BUTTON
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
                        "Following",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${following.length} artisans followed",
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

        // =====================================================
        // FOLLOWING LIST
        // =====================================================
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
                          "https://i.pravatar.cc/150?img=${artisan.id}",
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              artisan.name,
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
                            arguments: artisan,
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: const Text("View"),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ]
      ],
    );
  }
}