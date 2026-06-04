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

  // STATIC DEMANDS DATA
  final List<Map<String, dynamic>> _urgentDemands = [
    {
      'idRequest': 1,
      'clientId': 101,
      'clientName': 'Karim B.',
      'category': 'Plomberie',
      'location': 'Alger Centre',
      'description': 'Fuite d\'eau importante dans la salle de bain, besoin d\'intervention rapide!',
      'isUrgent': true,
      'time': 'Il y a 5 min',
    },
    {
      'idRequest': 2,
      'clientId': 102,
      'clientName': 'Nadia L.',
      'category': 'Électricité',
      'location': 'Hydra',
      'description': 'Problème de court-circuit dans tout l\'appartement, urgence!',
      'isUrgent': true,
      'time': 'Il y a 15 min',
    },
  ];

  final List<Map<String, dynamic>> _normalDemands = [
    {
      'idRequest': 3,
      'clientId': 103,
      'clientName': 'Sofiane M.',
      'category': 'Menuiserie',
      'location': 'Birkhadem',
      'description': 'Besoin de refaire une cuisine complète sur mesure.',
      'isUrgent': false,
      'time': 'Il y a 2 heures',
    },
    {
      'idRequest': 4,
      'clientId': 104,
      'clientName': 'Fatima Z.',
      'category': 'Peinture',
      'location': 'El Biar',
      'description': 'Peinture d\'un appartement de 120m², devis souhaité.',
      'isUrgent': false,
      'time': 'Il y a 1 jour',
    },
  ];

  @override
  void initState() {
    super.initState();
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

  void _removeDemand(int requestId, bool isUrgent) {
    setState(() {
      if (isUrgent) {
        _urgentDemands.removeWhere((d) => d['idRequest'] == requestId);
      } else {
        _normalDemands.removeWhere((d) => d['idRequest'] == requestId);
      }
    });
    Get.snackbar('Succès', 'Demande supprimée', backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
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
          const Icon(Icons.handyman_rounded, size: 22, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Text('Artisan', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
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
                // After creating post, go to private profile to see it
                Get.toNamed(AppRoutes.artisanPrivateProfile);
              },
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 20),
            SizedBox(width: 8),
            Text('Partager votre travail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicDemandsFeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Urgent Demands Section
          if (_urgentDemands.isNotEmpty) ...[
            Row(
              children: [
                Container(width: 6, height: 24, decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 12),
                const Text('Demandes urgentes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${_urgentDemands.length} demande${_urgentDemands.length > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._urgentDemands.map((demand) => _buildUrgentDemandCard(demand, context)),
            const SizedBox(height: 32),
          ],

          // Normal Demands Section
          if (_normalDemands.isNotEmpty) ...[
            Row(
              children: [
                Container(width: 6, height: 24, decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 12),
                const Text('Demandes normales', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${_normalDemands.length} demande${_normalDemands.length > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._normalDemands.map((demand) => _buildNormalDemandCard(demand, context)),
          ],

          if (_urgentDemands.isEmpty && _normalDemands.isEmpty) _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildNormalDemandCard(Map<String, dynamic> demand, BuildContext context) {
    final clientName = demand['clientName'];
    final clientId = demand['clientId'];
    final category = demand['category'];
    final location = demand['location'];
    final description = demand['description'];
    final time = demand['time'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B82F6), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                ClientTile(clientId: clientId, name: clientName, showAsAvatar: true, avatarRadius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: ClientTile(
                    clientId: clientId,
                    name: clientName,
                    child: Text(clientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
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
                Row(children: [const Icon(Icons.work, size: 16, color: Color(0xFF3B82F6)), const SizedBox(width: 6), Text(category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Open chat with this client
                      Get.toNamed(AppRoutes.chat, arguments: {'contactId': clientId, 'contactName': clientName});
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white),
                    child: const Text('Contacter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showIgnoreDialog(context, demand['idRequest'], false);
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF3B82F6)), foregroundColor: const Color(0xFF3B82F6)),
                    child: const Text('Ignorer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentDemandCard(Map<String, dynamic> demand, BuildContext context) {
    final clientName = demand['clientName'];
    final clientId = demand['clientId'];
    final category = demand['category'];
    final location = demand['location'];
    final description = demand['description'];
    final time = demand['time'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                ClientTile(clientId: clientId, name: clientName, showAsAvatar: true, avatarRadius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: ClientTile(
                    clientId: clientId,
                    name: clientName,
                    child: Text(clientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
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
                Row(children: [const Icon(Icons.work, size: 16, color: Color(0xFFEF4444)), const SizedBox(width: 6), Text(category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
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
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), foregroundColor: Colors.white),
                    child: const Text('Accepter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showDeclineDialog(context, demand['idRequest'], true);
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444)), foregroundColor: const Color(0xFFEF4444)),
                    child: const Text('Refuser', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, Map<String, dynamic> demand) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 28),
            const SizedBox(width: 12),
            const Text('Accepter la demande', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Voulez-vous accepter la demande urgente de ${demand['clientName']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Remove the demand from list
              setState(() {
                _urgentDemands.removeWhere((d) => d['idRequest'] == demand['idRequest']);
              });
              Get.snackbar('Succès', 'Demande acceptée!', backgroundColor: Colors.green, colorText: Colors.white);
              // Navigate to reservations screen
              Get.toNamed(AppRoutes.reservations);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, int requestId, bool isUrgent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 12),
            const Text('Refuser la demande', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Êtes-vous sûr de vouloir refuser cette demande?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeDemand(requestId, isUrgent);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
  }

  void _showIgnoreDialog(BuildContext context, int requestId, bool isUrgent) {
    showDialog(
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
        content: const Text('Cette demande disparaîtra de votre fil.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeDemand(requestId, isUrgent);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('Ignorer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: const Column(
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Aucune demande pour le moment', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text('Activez votre mode pour recevoir des demandes', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}