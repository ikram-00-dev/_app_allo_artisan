// lib/screens/client/artisan_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final int artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  bool showProfileDetails = false;
  bool showCalendarDetails = false;
  bool showQRCode = false;
  bool isFollowing = false;

  Map<String, dynamic> get _artisanData {
    if (widget.artisanId == 1) {
      return {
        'id': 1,
        'fullName': 'Jawad Ben Yahya',
        'email': 'jawadbenyahya@example.com',
        'phone': '+213 5555 55555',
        'category': 'Plomberie',
        'rating': 4.8,
        'reviewCount': 120,
        'bio': 'Plombier professionnel avec plus de 10 ans d\'expérience. Spécialisé dans l\'installation et la réparation de systèmes de plomberie.',
        'diploma': 'CAP Plomberie - 2015',
        'activesStatus': 'active',
        'experience': 10,
        'avatarUrl': '',
        'province': 'Alger',
        'city': 'Alger Centre',
        'district': 'Hydra',
        'verified': true,
      };
    } else {
      return {
        'id': 2,
        'fullName': 'Ahmed Amerani',
        'email': 'ahmed.amerani@example.com',
        'phone': '+213 5XX XX XX XX',
        'category': 'Électricité',
        'rating': 4.9,
        'reviewCount': 85,
        'bio': 'Électricien certifié avec 8 ans d\'expérience. Installation électrique, dépannage et mise aux normes.',
        'diploma': 'BTS Électrotechnique - 2017',
        'activesStatus': 'active',
        'experience': 8,
        'avatarUrl': '',
        'province': 'Alger',
        'city': 'Alger Centre',
        'district': 'El Biar',
        'verified': true,
      };
    }
  }

  final List<Map<String, dynamic>> _staticPosts = [
    {
      'id': 1,
      'content': 'Installation d\'une nouvelle salle de bain complète avec robinetterie moderne',
      'image': 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': 2,
      'content': 'Réparation d\'une fuite d\'eau urgente',
      'image': 'https://images.unsplash.com/photo-1584622650111-993b4268d8a0?w=800',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  String _getInitials(String fullName) {
    List<String> parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final artisan = _artisanData;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(artisan['fullName']),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
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
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> artisan) {
    final initials = _getInitials(artisan['fullName']);
    final isActive = artisan['activesStatus'] == 'active';

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
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  initials,
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
                        Expanded(child: Text(artisan['fullName'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                        if (artisan['verified']) const Icon(Icons.verified, color: Colors.blue, size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(artisan['category'], style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        Expanded(child: Text('${artisan['province']}, ${artisan['city']}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Rating + Status side by side
                    Row(
                      children: [
                        // Rating
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(artisan['rating'].toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text("(${artisan['reviewCount']})", style: const TextStyle(color: Colors.grey)),

                        const Spacer(),

                        // Active Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 10, color: isActive ? Colors.green : Colors.red),
                              const SizedBox(width: 6),
                              Text(
                                isActive ? 'Actif' : 'Inactif',
                                style: TextStyle(
                                  color: isActive ? Colors.green : Colors.red,
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
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: isFollowing ? Colors.grey[300] : Colors.green, foregroundColor: isFollowing ? Colors.black : Colors.white),
                  onPressed: () => setState(() => isFollowing = !isFollowing),
                  icon: Icon(isFollowing ? Icons.check : Icons.person_add),
                  label: Text(isFollowing ? "Suivi" : "Suivre"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  onPressed: () => Get.toNamed("/messages"),
                  icon: const Icon(Icons.message),
                  label: const Text("Message"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(Map<String, dynamic> artisan) {
    final isActive = artisan['activesStatus'] == 'active';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("À propos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(artisan['bio'], style: const TextStyle(height: 1.5, color: Colors.black87)),
          const SizedBox(height: 24),

          // Four equal info boxes (no overflow)
          Row(
            children: [
              Expanded(child: _infoCard("Diplôme", artisan['diploma'])),
              const SizedBox(width: 12),
              Expanded(child: _infoCard("Statut", isActive ? 'Actif' : 'Inactif')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _infoCard("Expérience", "${artisan['experience']} ans")),
              const SizedBox(width: 12),
              Expanded(child: _infoCard("Note", artisan['rating'].toStringAsFixed(1))),
            ],
          ),

          const SizedBox(height: 20),
          const Text("Contact", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.phone, size: 18, color: Colors.grey), const SizedBox(width: 10), Text(artisan['phone'])]),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.email, size: 18, color: Colors.grey), const SizedBox(width: 10), Expanded(child: Text(artisan['email']))]),

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
    );
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

  // Keep the rest of your methods (_buildProfileButton, _buildCalendarButton, etc.)
  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () => setState(() => showProfileDetails = !showProfileDetails),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.info, color: Colors.blue)),
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
            Icon(showProfileDetails ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
          ],
        ),
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
            Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.calendar_month, color: Colors.green)),
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
          const Text("Calendrier de disponibilité", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(24, (index) {
              final available = index >= 8 && index < 18;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: available ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("${index.toString().padLeft(2, '0')}h", style: TextStyle(color: available ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    if (_staticPosts.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text("Publications", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ..._staticPosts.map((post) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post['image'].toString().isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(post['image'], width: double.infinity, height: 250, fit: BoxFit.cover),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['content']),
                    const SizedBox(height: 12),
                    Text(_formatDate(post['createdAt']), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}