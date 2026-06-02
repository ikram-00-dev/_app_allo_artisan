import 'package:allo_artisan_gpt/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_artisan_gpt/core/widgets/client_tile.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/request_controller.dart';
import '../../routes/app_routes.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/share_post_modal.dart';

class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final RequestController requestController = Get.put(RequestController());
  bool isActiveMode = true;

  // ============================================================
  // 📝 MOCK DATA - Example posts to show design
  // ============================================================
  final List<Map<String, dynamic>> mockNormalDemands = [
    {
      'idRequest': 1,  // Add this
      'clientId': 101,  // Add this
      'clientID': 101,  // Add for compatibility
      'name': 'Aymen Bousahah',
      'time': 'Il y a 2 heures',
      'category': 'Plomberie',
      'location': 'Ghalma 12ème',
      'description': 'Recherche plombier pour rénover une salle de bain complète. Projet prévu dans 2 semaines.',
      'isUrgent': false,
    },
  ];

  final List<Map<String, dynamic>> mockUrgentDemands = [
    {
      'idRequest': 2,  // Add this
      'clientId': 102,  // Add this
      'clientID': 102,  // Add for compatibility
      'name': 'Sarah Benamama',
      'time': 'Il y a 10 min',
      'category': 'Plomberie - Fuite d\'eau',
      'location': 'Alger 15ème',
      'description': "Fuite d'eau importante dans la salle de bain, besoin d'intervention rapide!",
      'isUrgent': true,
    },
  ];

  void onNavBarTapped(int index) {
    switch (index) {
      case 0:
        break; // Already on home

      case 1: // Reservations
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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await requestController.fetchRequests();
          },
          child: Obx(() {
            // Show loading indicator only if no mock data and no real data
            if (requestController.isLoading.value &&
                requestController.urgentRequests.isEmpty &&
                requestController.normalRequests.isEmpty &&
                mockUrgentDemands.isEmpty &&
                mockNormalDemands.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 10, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildArtisanHeader(),
                  const SizedBox(height: 10),
                  _buildArtisanPostButton(context),
                  const SizedBox(height: 24),
                  _buildDynamicDemandsFeed(),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ============================================================
// 👤 Artisan Header - Simple icon + greeting
// ============================================================
  Widget _buildArtisanHeader() {
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
            'Artisan',
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
  // ============================================================
  // 🔘 Share Work Button
  // ============================================================
  // Update the share post button in artisan_home_screen.dart
// Replace the _buildArtisanPostButton method with:

  Widget _buildArtisanPostButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          // Show the share post modal
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => SharePostModal(
              onPostCreated: () {
                // Navigate to private profile after posting
                Get.toNamed(AppRoutes.artisanPrivateProfile);
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 20),
            SizedBox(width: 8),
            Text(
              'Partager votre travail',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📰 Dynamic Demands Feed (Real data + Mock examples)
  // ============================================================
  Widget _buildDynamicDemandsFeed() {
    // Use real data if available, otherwise use mock data as examples
    final hasRealUrgent = requestController.urgentRequests.isNotEmpty;
    final hasRealNormal = requestController.normalRequests.isNotEmpty;

    final displayUrgentDemands = hasRealUrgent
        ? requestController.urgentRequests
        : mockUrgentDemands;

    final displayNormalDemands = hasRealNormal
        ? requestController.normalRequests
        : mockNormalDemands;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // 🔴 Urgent Demands Section
          // ============================================================
          if (displayUrgentDemands.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Demandes urgentes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${displayUrgentDemands.length} demande',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...displayUrgentDemands.map((demand) =>
                _buildUrgentDemandCard(demand, context)),
            const SizedBox(height: 32),
          ],

          // ============================================================
          // 🟢 Normal Demands Section
          // ============================================================
          if (displayNormalDemands.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Demandes normales',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${displayNormalDemands.length} demande',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...displayNormalDemands.map((demand) =>
                _buildNormalDemandCard(demand, context)),
          ],

          if (displayUrgentDemands.isEmpty && displayNormalDemands.isEmpty)
            _buildEmptyState(),
        ],
      ),
    );
  }

  // ============================================================
  // 🟢 Normal Demand Card
  // ============================================================
  // ============================================================
  // 🟢 Normal Demand Card
  // ============================================================
  Widget _buildNormalDemandCard(Map<String, dynamic> demand, BuildContext context) {
    // Support both real API data and mock data format
    final clientName = demand['client']?['username'] ?? demand['name'] ?? demand['clientName'] ?? 'Client';
    // In _buildNormalDemandCard and _buildUrgentDemandCard
    final clientId = demand['clientId'] ??
        demand['clientID'] ??
        demand['ClientID'] ??
        demand['client']?['id'] ??  // If client is an object
        demand['client']?['idUser'] ??  // Check nested user id
        demand['userId'];  // Alternative field name
    final category = demand['category'] ?? 'Général';
    final location = demand['location'] ?? demand['zone'] ?? 'Non spécifié';
    final description = demand['description'] ?? '';

    String createdAt;
    if (demand['time'] != null) {
      createdAt = demand['time'];
    } else if (demand['createdAt'] != null) {
      createdAt = _formatDate(DateTime.parse(demand['createdAt']));
    } else {
      createdAt = 'Récemment';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                // Clickable Avatar using ClientTile
                ClientTile(
                  clientId: clientId,
                  name: clientName,
                  showAsAvatar: true,
                  avatarRadius: 24,
                ),
                const SizedBox(width: 12),

                // Clickable Name using ClientTile
                Expanded(
                  child: ClientTile(
                    clientId: clientId,
                    name: clientName,
                    child: Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),

                const Icon(Icons.access_time, color: Color(0xFF3B82F6), size: 20),
              ],
            ),
          ),
          const Divider(height: 8, thickness: 0.5, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.work, size: 16, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // ENVOYER - Open chat screen
                      Get.toNamed(
                        AppRoutes.messages,
                        arguments: {
                          'contactId': clientId,
                          'contactName': clientName,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 42),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Envoyer',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final requestId = demand['idRequest'] ??
                          demand['IDRequest'] ??
                          demand['id'];

                      if (requestId != null) {
                        // Show confirmation dialog
                        final confirm = await _showIgnoreDialog(context);
                        if (confirm) {
                          await requestController.ignoreRequest(requestId);
                          setState(() {}); // Refresh UI
                        }
                      } else {
                        // For mock data - just remove locally
                        setState(() {
                          mockNormalDemands.removeWhere((d) =>
                          d['idRequest'] == requestId ||
                              d['IDRequest'] == requestId);
                        });
                        Get.snackbar('Info', 'Demande ignorée');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      foregroundColor: const Color(0xFF3B82F6),
                      minimumSize: const Size(double.infinity, 42),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Ignorer',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // ============================================================
  // 🔴 Urgent Demand Card
  // ============================================================
  // ============================================================
  // 🔴 Urgent Demand Card
  // ============================================================
  Widget _buildUrgentDemandCard(Map<String, dynamic> demand, BuildContext context) {
    // Support both real API data and mock data format
    final clientName = demand['client']?['username'] ?? demand['name'] ?? demand['clientName'] ?? 'Client';
    final clientId = demand['clientId'] ?? demand['clientID'] ?? demand['ClientID'];

    final category = demand['category'] ?? 'Général';
    final location = demand['location'] ?? demand['zone'] ?? 'Non spécifié';
    final description = demand['description'] ?? '';

    String createdAt;
    if (demand['time'] != null) {
      createdAt = demand['time'];
    } else if (demand['createdAt'] != null) {
      createdAt = _formatDate(DateTime.parse(demand['createdAt']));
    } else {
      createdAt = 'Récemment';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                // Clickable Avatar
                ClientTile(
                  clientId: clientId,
                  name: clientName,
                  showAsAvatar: true,
                  avatarRadius: 24,
                ),
                const SizedBox(width: 12),

                // Clickable Name
                Expanded(
                  child: ClientTile(
                    clientId: clientId,
                    name: clientName,
                    child: Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),

                const Icon(Icons.timer, color: Color(0xFFEF4444), size: 20),
              ],
            ),
          ),
          const Divider(height: 8, thickness: 0.5, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.work, size: 16, color: Color(0xFFEF4444)),
                    const SizedBox(width: 6),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showAcceptDialog(context, demand);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 42),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Accepter',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final requestId = demand['idRequest'] ??
                          demand['IDRequest'] ??
                          demand['id'];

                      if (requestId != null) {
                        final confirm = await _showDeclineConfirmationDialog(context);
                        if (confirm) {
                          await requestController.declineRequest(requestId);
                          setState(() {}); // Refresh UI
                        }
                      } else {
                        // For mock data
                        setState(() {
                          mockUrgentDemands.removeWhere((d) =>
                          d['idRequest'] == requestId ||
                              d['IDRequest'] == requestId);
                        });
                        Get.snackbar('Info', 'Demande refusée');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      foregroundColor: const Color(0xFFEF4444),
                      minimumSize: const Size(double.infinity, 42),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Refuser',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Add these helper methods to the _ArtisanHomeScreenState class:

  Future<bool> _showIgnoreDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 28),
            SizedBox(width: 12),
            Text('Ignorer la demande'),
          ],
        ),
        content: const Text(
          'Cette demande disparaîtra de votre fil. Vous pourrez toujours y accéder depuis vos archives.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('Ignorer'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showDeclineConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 12),
            Text('Refuser la demande urgente'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir refuser cette demande urgente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAcceptDialog(BuildContext context, Map<String, dynamic> demand) {
    final clientName = demand['client']?['username'] ??
        demand['client']?['name'] ??
        demand['name'] ??
        demand['clientName'] ??
        'ce client';

    final clientId = demand['clientId'] ??
        demand['clientID'] ??
        demand['ClientID'] ??
        demand['client']?['id'] ??
        demand['client']?['idUser'];

    final requestId = demand['idRequest'] ??
        demand['IDRequest'] ??
        demand['id'];

    final isUrgent = demand['isUrgent'] == true ||
        demand['type'] == 'urgent';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isUrgent ? Icons.warning_amber_rounded : Icons.check_circle,
              color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              isUrgent ? 'Accepter la demande urgente' : 'Accepter la demande',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voulez-vous accepter la demande${isUrgent ? ' urgente' : ''} de $clientName?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUrgent
                    ? const Color(0xFFEF4444).withOpacity(0.1)
                    : const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isUrgent
                    ? '⚠️ Demande urgente - Un rendez-vous sera créé automatiquement'
                    : '✅ Le client sera notifié immédiatement',
                style: TextStyle(
                  fontSize: 12,
                  color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler', style: TextStyle(fontSize: 14)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog

              // Show loading
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              if (requestId != null) {
                // FIXED: Call acceptRequest with single parameter
                // The appointment creation should happen inside the controller
                final success = await requestController.acceptRequest(requestId);

                // Close loading dialog
                Get.back();

                if (success) {
                  // FIXED: Use mounted check and refresh
                  if (mounted) {
                    setState(() {});
                  }

                  Get.snackbar(
                    'Succès',
                    '✅ Demande acceptée! Rendez-vous créé. Vérifiez vos réservations.',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                    duration: const Duration(seconds: 4),
                    mainButton: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.reservations),
                      child: const Text('VOIR', style: TextStyle(color: Colors.white)),
                    ),
                  );
                }
              } else {
                // Close loading dialog
                Get.back();

                // For mock data
                if (mounted) {
                  setState(() {
                    mockUrgentDemands.removeWhere((d) => d['idRequest'] == requestId);
                  });
                }

                Get.snackbar(
                  'Succès',
                  '✅ Demande acceptée! Rendez-vous créé.',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }
  void _showDeclineDialog(BuildContext context, int? requestId) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 12),
            const Text('Refuser la demande'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir refuser cette demande?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              if (requestId != null) {
                final success = await requestController.declineRequest(requestId);
                if (success) {
                  Get.snackbar('Info', 'Demande refusée');
                }
              } else {
                // Mock action for example data
                Get.snackbar('Info', 'Demande refusée');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Aucune demande pour le moment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Activez votre mode pour recevoir des demandes',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}