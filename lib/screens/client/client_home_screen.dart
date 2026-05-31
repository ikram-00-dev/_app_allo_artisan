import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../client/artisan_profile_screen.dart';
import 'package:allo_artisan_gpt/screens/client/client_requests_screen.dart';
import 'package:allo_artisan_gpt/core/widgets/restricted_access_card.dart'; // Add this import

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

  // Updated with artisanId for navigation
  final List<Map<String, dynamic>> publications = [
    {
      "id": "1",
      "artisanId": 1,
      "name": "Jawad Ben Yahya",
      "category": "Plomberie",
      "rating": 4.8,
      "verified": true,
      "time": "Il y a 2 heures",
      "likes": 45,
      "comments": 8,
      "description": "Installation d'une nouvelle salle de bain complète avec robinetterie moderne et carrelage italien. Projet réalisé en 5 jours.",
      "image": "https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800",
    },
    {
      "id": "2",
      "artisanId": 2,
      "name": "Ahmed Amerani",
      "category": "Électricité",
      "rating": 4.9,
      "verified": true,
      "time": "Il y a 5 heures",
      "likes": 67,
      "comments": 12,
      "description": "Rénovation complète de l'installation électrique.",
      "image": "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800",
    },
  ];

  // Add this method to show restricted card
  void _showRestrictedCard() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RestrictedAccessCard(
          message: 'Connectez-vous ou créez un compte pour accéder à cette fonctionnalité.',
        ),
      ),
    );
  }

  // Navigate to Artisan Profile
  void _goToArtisanProfile(int artisanId) {
    if (artisanId > 0) {
      Get.to(() => ArtisanProfileScreen(artisanId: artisanId));
    }
  }

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
      _showRestrictedCard();
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
    _showRestrictedCard();
  }

  void handleSubmitRequest() {
    if (!authController.isLoggedIn) {
      _showRestrictedCard();
      return;
    }

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
    // Check if user is logged in for protected routes
    final isLoggedIn = authController.isLoggedIn;

    switch (index) {
      case 0:
        break; // Already on home - always accessible

      case 1: // My Demands / Reservations
        if (!isLoggedIn) {
          _showRestrictedCard();
        } else {
          Get.toNamed(AppRoutes.clientRequests);
        }
        break;

      case 2: // Messages
        if (!isLoggedIn) {
          _showRestrictedCard();
        } else {
          Get.toNamed(AppRoutes.messages);
        }
        break;

      case 3: // Notifications
        if (!isLoggedIn) {
          _showRestrictedCard();
        } else {
          Get.toNamed(AppRoutes.notifications);
        }
        break;

      case 4: // Profile
        if (!isLoggedIn) {
          _showRestrictedCard();
        } else {
          Get.toNamed(AppRoutes.profile);
        }
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
                        _showRestrictedCard();
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

            // Login Modal (keep for backward compatibility but won't be used much)
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
    final artisanId = post['artisanId'] ?? 0;
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
          // Clickable Header (Avatar + Name)
          Padding(
            padding: const EdgeInsets.all(14),
            child: GestureDetector(
              onTap: () => _goToArtisanProfile(artisanId),
              child: Row(
                children: [
                  // Clickable Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarColor,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clickable Name
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
          ),

          // Image (not clickable)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(0)),
            child: Image.network(
              post['image'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(height: 250, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 50));
              },
            ),
          ),

          // Description & Actions (same as before)
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(post['description']),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => toggleLike(postId),
                  child: Row(
                    children: [
                      Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey, size: 22),
                      const SizedBox(width: 6),
                      Text(likeCount.toString(), style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      const Icon(Icons.mode_comment_outlined, size: 22, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(post['comments'].toString(), style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.share_outlined, size: 22, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRequestModal() {
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, size: 28),
                        SizedBox(width: 8),
                        Text('Partager une demande', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                    const SizedBox(height: 20),

                    // ==================== INFO MESSAGE (KEPT AS REQUESTED) ====================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isUrgent ? Icons.warning_amber_rounded : Icons.info_outline,
                            color: isUrgent ? Colors.red : Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isUrgent
                                  ? '⚠️ Les artisans actifs seront notifiés immédiatement'
                                  : 'ℹ️ Votre demande sera visible sur le fil des artisans',
                              style: TextStyle(
                                fontSize: 12,
                                color: isUrgent ? Colors.red : Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category (Obligatory)
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie *',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Plomberie', child: Text('🔧 Plomberie')),
                        DropdownMenuItem(value: 'Électricité', child: Text('⚡ Électricité')),
                        DropdownMenuItem(value: 'Menuiserie', child: Text('🪚 Menuiserie')),
                        DropdownMenuItem(value: 'Peinture', child: Text('🎨 Peinture')),
                        DropdownMenuItem(value: 'Maçonnerie', child: Text('🧱 Maçonnerie')),
                        DropdownMenuItem(value: 'Jardinage', child: Text('🌿 Jardinage')),
                      ],
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                    const SizedBox(height: 16),

                    // Zone (Required only for Urgent)
                    DropdownButtonFormField<int>(
                      value: _requestZone.isEmpty ? null : int.tryParse(_requestZone),
                      decoration: InputDecoration(
                        labelText: isUrgent ? 'Zone (km) *' : 'Zone (km)',
                        border: const OutlineInputBorder(),
                      ),
                      items: const [5, 10, 20, 30, 35, 40, 45, 50]
                          .map((km) => DropdownMenuItem(
                        value: km,
                        child: Text('$km km'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _requestZone = value?.toString() ?? '');
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description (Obligatory)
                    TextField(
                      onChanged: (value) => _requestDescription = value,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Décrivez votre besoin en détail...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ==================== IMAGE UPLOAD (LAST POSITION) ====================
                    GestureDetector(
                      onTap: () => Get.snackbar("Info", "Fonctionnalité d'upload d'image bientôt disponible"),
                      child: Container(
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40, color: Colors.black54),
                              SizedBox(height: 8),
                              Text("Ajouter une photo (optionnel)", style: TextStyle(color: Colors.black54)),
                              Text("JPG, PNG - Max 5MB", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Submit Buttons
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
                            onPressed: _handleSubmitRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isUrgent ? Colors.red : const Color(0xFF2563EB),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Envoyer la demande', style: TextStyle(color: Colors.white)),
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
      ),
    );
  }

  void _handleSubmitRequest() {
    // Validation
    if (_selectedCategory.isEmpty) {
      Get.snackbar('Erreur', 'Veuillez choisir une catégorie', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_requestDescription.trim().isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer une description', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (isUrgent && _requestZone.isEmpty) {
      Get.snackbar('Erreur', 'La zone est obligatoire pour une demande urgente', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Success
    Get.snackbar(
      'Succès',
      'Demande ${isUrgent ? "urgente" : "normale"} envoyée avec succès!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Reset form
    setState(() {
      _showRequestModal = false;
      _requestZone = '';
      _requestDescription = '';
      _selectedCategory = 'Plomberie';
      isUrgent = false;
    });
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