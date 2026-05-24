import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  bool isUrgent = false;
  bool _showLoginModal = false;
  bool _showRequestModal = false;
  String _selectedCategory = 'Plomberie';
  String _requestZone = '';
  String _requestDescription = '';

  final Set<String> likedPosts = {};

  // Static publications data as shown in your image
  final List<Map<String, dynamic>> publications = [
    {
      "id": "1",
      "name": "Jawad Ben Yahya",
      "category": "Plomberie",
      "rating": 4.8,
      "verified": true,
      "time": "Il y a 2 heures",
      "likes": 45,
      "comments": 8,
      "description":
      "Installation d'une nouvelle salle de bain complète avec robinetterie moderne et carrelage italien. Projet réalisé en 5 jours.",
      "image":
      "https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800",
    },
    {
      "id": "2",
      "name": "Ahmed Amerani",
      "category": "Électricité",
      "rating": 4.9,
      "verified": true,
      "time": "Il y a 5 heures",
      "likes": 67,
      "comments": 12,
      "description":
      "Rénovation complète de l'installation électrique.",
      "image":
      "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800",
    },
  ];

  // Helper method to get initials from name
  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return '?';
  }

  // Helper method to get consistent color based on name
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  void toggleLike(String id) {
    if (!authController.isLoggedIn) {
      setState(() => _showLoginModal = true);
      return;
    }
    setState(() {
      if (likedPosts.contains(id)) {
        likedPosts.remove(id);
      } else {
        likedPosts.add(id);
      }
    });
  }

  void handleRestrictedAction() {
    setState(() => _showLoginModal = true);
  }

  void handleSubmitRequest() {
    if (_selectedCategory.isEmpty || _requestDescription.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs obligatoires',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Succès',
      'Demande ${isUrgent ? "urgente" : "normale"} envoyée avec succès!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    setState(() {
      _showRequestModal = false;
      _requestZone = '';
      _requestDescription = '';
      _selectedCategory = 'Plomberie';
      isUrgent = false;
    });
  }

  void onNavBarTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Get.toNamed(AppRoutes.reservations);
        break;
      case 2:
        Get.toNamed(AppRoutes.messages);
        break;
      case 3:
        Get.toNamed(AppRoutes.notifications);
        break;
      case 4:
        Get.toNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.user.value;
    final isLoggedIn = authController.isLoggedIn;
    final username = user?['username'] ?? user?['Username'] ?? 'Visiteur';
    final firstName = username.split(' ')[0];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClientHeader(),
                  const SizedBox(height: 8),
                  _buildHeader(firstName, isLoggedIn),
                  const SizedBox(height: 16),

                  // Create Demand Button
                  ElevatedButton(
                    onPressed: () {
                      if (!isLoggedIn) {
                        setState(() => _showLoginModal = true);
                      } else {
                        setState(() => _showRequestModal = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Partager une demande',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Publications Section
                  const Text('Publications récentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Static Posts with initial avatar
                  ...publications.map((post) => _buildPostCard(post)),
                ],
              ),
            ),

            // Request Modal
            if (_showRequestModal) _buildRequestModal(),

            // Login Modal
            if (_showLoginModal) _buildLoginModal(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        showUnselectedLabels: true,
        onTap: onNavBarTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined, size: 24),
            activeIcon: Icon(Icons.calendar_today, size: 24),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined, size: 24),
            activeIcon: Icon(Icons.message, size: 24),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined, size: 24),
            activeIcon: Icon(Icons.notifications, size: 24),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 👤 Header - Minimal version
  // ============================================================
  Widget _buildClientHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.handyman_rounded,
            size: 22,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          Text(
            'Client',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String firstName, bool isLoggedIn) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.search),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text('Rechercher un artisan...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (isLoggedIn)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Get.toNamed(AppRoutes.qrScan),
                icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2563EB), size: 24),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final postId = post['id'];
    final isLiked = likedPosts.contains(postId);
    final likeCount = (post['likes'] as int) + (isLiked ? 1 : 0);
    final initials = _getInitials(post['name']);
    final avatarColor = _getAvatarColor(post['name']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar (Initials), Name, Category, Rating, Time
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // CircleAvatar with initials instead of image
                CircleAvatar(
                  radius: 24,
                  backgroundColor: avatarColor,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          if (post['verified'])
                            const Icon(Icons.verified, color: Colors.blue, size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(post['category'], style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(post['rating'].toString()),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(post['time'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),

          // Image
          ClipRRect(
            child: Image.network(
              post['image'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(post['description']),
          ),

          // Action Buttons: Like, Comment, Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: () => toggleLike(postId),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(likeCount.toString(), style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Comment Button
                GestureDetector(
                  onTap: handleRestrictedAction,
                  child: Row(
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 22, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(post['comments'].toString(), style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Share Button
                GestureDetector(
                  onTap: handleRestrictedAction,
                  child: const Icon(Icons.share_outlined, size: 22, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRequestModal() {
    final List<Map<String, String>> categories = [
      {'name': 'Plomberie', 'icon': '🔧'},
      {'name': 'Électricité', 'icon': '⚡'},
      {'name': 'Menuiserie', 'icon': '🪚'},
      {'name': 'Peinture', 'icon': '🎨'},
      {'name': 'Maçonnerie', 'icon': '🧱'},
      {'name': 'Jardinage', 'icon': '🌿'},
    ];

    return GestureDetector(
      onTap: () => setState(() => _showRequestModal = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Partager une demande',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Request Type Selection
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeButton(
                          label: 'Normale',
                          icon: Icons.edit_note_outlined,
                          isSelected: !isUrgent,
                          onTap: () => setState(() => isUrgent = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTypeButton(
                          label: 'Urgente',
                          icon: Icons.notifications_active,
                          isSelected: isUrgent,
                          onTap: () => setState(() => isUrgent = true),
                          isUrgent: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info Message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(isUrgent ? Icons.warning_amber_rounded : Icons.info_outline,
                            color: isUrgent ? Colors.red : Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isUrgent
                                ? '⚠️ Les artisans actifs seront notifiés immédiatement'
                                : 'ℹ️ Votre demande sera visible sur le fil des artisans',
                            style: TextStyle(fontSize: 12, color: isUrgent ? Colors.red : Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie *',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat['name'],
                        child: Text('${cat['icon']} ${cat['name']}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                  const SizedBox(height: 16),

                  // Zone Input
                  TextField(
                    onChanged: (value) => _requestZone = value,
                    decoration: const InputDecoration(
                      labelText: 'Zone',
                      hintText: 'Ex: Paris 15ème',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    onChanged: (value) => _requestDescription = value,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Décrivez votre besoin...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _showRequestModal = false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: handleSubmitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUrgent ? Colors.red : Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Envoyer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isUrgent = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? (isUrgent ? Colors.red : Colors.blue) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? (isUrgent ? Colors.red : Colors.blue) : Colors.grey),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? (isUrgent ? Colors.red : Colors.blue) : Colors.grey,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginModal() {
    return GestureDetector(
      onTap: () => setState(() => _showLoginModal = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(Icons.person, size: 30, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  const Text('Créez un compte', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Pour accéder à toutes les fonctionnalités, vous devez créer un compte',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _showLoginModal = false);
                      Get.toNamed(AppRoutes.registerClient);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Créer un compte Client', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _showLoginModal = false);
                      Get.toNamed(AppRoutes.registerArtisan);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Créer un compte Artisan', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _showLoginModal = false);
                      Get.toNamed(AppRoutes.login);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('J\'ai déjà un compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}