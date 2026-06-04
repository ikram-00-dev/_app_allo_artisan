import 'package:allo_artisan_gpt/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_artisan_gpt/core/widgets/client_tile.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/request_controller.dart';
import '../../routes/app_routes.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/share_post_modal.dart';
import '../../models/request_model.dart';

class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  State<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends State<ArtisanHomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final RequestController requestController = Get.put(RequestController());
  bool isActiveMode = true;

  // These are for fallback ONLY - will be replaced by real data
  final List<Map<String, dynamic>> _fallbackNormalDemands = [
    {
      'idRequest': 1,
      'clientId': 101,
      'name': 'Client Test',
      'time': 'Il y a 2 heures',
      'category': 'Plomberie',
      'location': 'Ghalma 12ème',
      'description': 'Recherche plombier pour rénover une salle de bain complète.',
      'isUrgent': false,
    },
  ];

  final List<Map<String, dynamic>> _fallbackUrgentDemands = [
    {
      'idRequest': 2,
      'clientId': 102,
      'name': 'Client Urgent',
      'time': 'Il y a 10 min',
      'category': 'Plomberie - Fuite d\'eau',
      'location': 'Alger 15ème',
      'description': "Fuite d'eau importante dans la salle de bain!",
      'isUrgent': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load real data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRealRequests();
    });
  }

  Future<void> _loadRealRequests() async {
    await requestController.loadAllRequests();
    setState(() {});
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadRealRequests();
          },
          child: Obx(() {
            // Show loading indicator while fetching real data
            if (requestController.isLoading.value &&
                requestController.urgentRequests.isEmpty &&
                requestController.normalRequests.isEmpty) {
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

  Widget _buildArtisanPostButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => SharePostModal(
              onPostCreated: () {
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
  // 📰 Dynamic Demands Feed - LOADS REAL DATA
  // ============================================================
  Widget _buildDynamicDemandsFeed() {
    // Convert RequestModel to Map for display (keeping your exact design)
    final List<Map<String, dynamic>> realUrgentDemands =
    requestController.urgentRequests.map((req) => _requestModelToMap(req)).toList();

    final List<Map<String, dynamic>> realNormalDemands =
    requestController.normalRequests.map((req) => _requestModelToMap(req)).toList();

    // Use real data if available, fallback to mock only if absolutely empty
    final displayUrgentDemands = realUrgentDemands.isNotEmpty ? realUrgentDemands : _fallbackUrgentDemands;
    final displayNormalDemands = realNormalDemands.isNotEmpty ? realNormalDemands : _fallbackNormalDemands;

    // Filter based on artisan's category (only show relevant requests)
    final artisanCategory = authController.user.value?['category'] ?? '';
    final filteredUrgent = displayUrgentDemands.where((demand) {
      if (artisanCategory.isEmpty) return true;
      return demand['category']?.toLowerCase().contains(artisanCategory.toLowerCase()) ?? true;
    }).toList();

    final filteredNormal = displayNormalDemands.where((demand) {
      if (artisanCategory.isEmpty) return true;
      return demand['category']?.toLowerCase().contains(artisanCategory.toLowerCase()) ?? true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔴 Urgent Demands Section
          if (filteredUrgent.isNotEmpty) ...[
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
                    '${filteredUrgent.length} demande${filteredUrgent.length > 1 ? 's' : ''}',
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
            ...filteredUrgent.map((demand) => _buildUrgentDemandCard(demand, context)),
            const SizedBox(height: 32),
          ],

          // 🟢 Normal Demands Section
          if (filteredNormal.isNotEmpty) ...[
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
                    '${filteredNormal.length} demande${filteredNormal.length > 1 ? 's' : ''}',
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
            ...filteredNormal.map((demand) => _buildNormalDemandCard(demand, context)),
          ],

          if (filteredUrgent.isEmpty && filteredNormal.isEmpty)
            _buildEmptyState(),
        ],
      ),
    );
  }

  // Helper: Convert RequestModel to Map<String, dynamic> for card compatibility
  Map<String, dynamic> _requestModelToMap(RequestModel req) {
    // Get client name - try to fetch from storage or use fallback
    String clientName = 'Client #${req.clientId}';

    return {
      'idRequest': req.idRequest,
      'IDRequest': req.idRequest,
      'clientId': req.clientId,
      'clientID': req.clientId,
      'ClientID': req.clientId,
      'name': clientName,
      'clientName': clientName,
      'time': _formatDate(req.requestDate),
      'createdAt': req.requestDate.toIso8601String(),
      'category': req.category,
      'location': req.zoneKm != null && req.zoneKm! > 0 ? 'Zone ${req.zoneKm} km' : 'Non spécifié',
      'zone': req.zoneKm != null ? 'Zone ${req.zoneKm} km' : 'Non spécifié',
      'zoneKm': req.zoneKm,
      'description': req.description,
      'isUrgent': req.isUrgent,
      'type': req.type,
      'status': req.status,
      'latitude': req.latitude,
      'longitude': req.longitude,
      'imageUrl': req.imageUrl,
    };
  }

  // ============================================================
  // 🟢 Normal Demand Card - PRESERVED YOUR DESIGN
  // ============================================================
  Widget _buildNormalDemandCard(Map<String, dynamic> demand, BuildContext context) {
    final clientName = demand['client']?['username'] ??
        demand['name'] ??
        demand['clientName'] ??
        'Client #${demand['clientId'] ?? '?'}';
    final clientId = demand['clientId'] ?? demand['clientID'] ?? demand['ClientID'];
    final category = demand['category'] ?? 'Général';
    final location = demand['location'] ?? demand['zone'] ?? 'Non spécifié';
    final description = demand['description'] ?? '';
    final imageUrl = demand['imageUrl'];

    String createdAt;
    if (demand['time'] != null) {
      createdAt = demand['time'];
    } else if (demand['createdAt'] != null) {
      createdAt = _formatDate(DateTime.tryParse(demand['createdAt']) ?? DateTime.now());
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
                ClientTile(
                  clientId: clientId,
                  name: clientName,
                  showAsAvatar: true,
                  avatarRadius: 24,
                ),
                const SizedBox(width: 12),
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
          if (imageUrl != null && imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
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
                maxLines: 3,
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
                      'Contacter',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final requestId = demand['idRequest'] ?? demand['IDRequest'] ?? demand['id'];
                      if (requestId != null) {
                        final confirm = await _showIgnoreDialog(context);
                        if (confirm) {
                          await requestController.ignoreRequest(requestId);
                          await _loadRealRequests();
                          setState(() {});
                        }
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
  // 🔴 Urgent Demand Card - PRESERVED YOUR DESIGN
  // ============================================================
  Widget _buildUrgentDemandCard(Map<String, dynamic> demand, BuildContext context) {
    final clientName = demand['client']?['username'] ??
        demand['name'] ??
        demand['clientName'] ??
        'Client #${demand['clientId'] ?? '?'}';
    final clientId = demand['clientId'] ?? demand['clientID'] ?? demand['ClientID'];
    final category = demand['category'] ?? 'Général';
    final location = demand['location'] ?? demand['zone'] ?? 'Non spécifié';
    final description = demand['description'] ?? '';
    final imageUrl = demand['imageUrl'];

    String createdAt;
    if (demand['time'] != null) {
      createdAt = demand['time'];
    } else if (demand['createdAt'] != null) {
      createdAt = _formatDate(DateTime.tryParse(demand['createdAt']) ?? DateTime.now());
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
                ClientTile(
                  clientId: clientId,
                  name: clientName,
                  showAsAvatar: true,
                  avatarRadius: 24,
                ),
                const SizedBox(width: 12),
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
          if (imageUrl != null && imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
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
                maxLines: 3,
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
                      final requestId = demand['idRequest'] ?? demand['IDRequest'] ?? demand['id'];
                      if (requestId != null) {
                        final confirm = await _showDeclineConfirmationDialog(context);
                        if (confirm) {
                          await requestController.declineRequest(requestId);
                          await _loadRealRequests();
                          setState(() {});
                        }
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

  // ============================================================
  // Helper Methods
  // ============================================================
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
    final requestId = demand['idRequest'] ?? demand['IDRequest'] ?? demand['id'];
    final isUrgent = demand['isUrgent'] == true || demand['type'] == 'urgent';

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
                color: isUrgent ? const Color(0xFFEF4444).withOpacity(0.1) : const Color(0xFF22C55E).withOpacity(0.1),
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
              Get.back();
              Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

              if (requestId != null) {
                final success = await requestController.acceptRequest(requestId);
                Get.back();

                if (success && mounted) {
                  await _loadRealRequests();
                  setState(() {});
                  Get.snackbar(
                    'Succès',
                    '✅ Demande acceptée! Rendez-vous créé.',
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
