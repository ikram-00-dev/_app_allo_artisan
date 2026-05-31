import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';

class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({super.key});

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  final AuthController authController = Get.find<AuthController>();

  // Mock data for client's posted demands (similar to artisan home)
  final List<Map<String, dynamic>> myRequests = [
    {
      'id': 1,
      'category': 'Plomberie',
      'isUrgent': true,
      'zone': '15 km',
      'description': "Fuite d'eau importante dans la salle de bain, besoin d'intervention rapide!",
      'status': 'active', // active, pending, completed, cancelled
      'time': 'Il y a 2 heures',
      'responses': 3,
    },
    {
      'id': 2,
      'category': 'Électricité',
      'isUrgent': false,
      'zone': '25 km',
      'description': 'Installation nouvelle prise et réparation disjoncteur.',
      'status': 'pending',
      'time': 'Il y a 1 jour',
      'responses': 1,
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'ACTIF';
      case 'pending':
        return 'EN ATTENTE';
      case 'cancelled':
        return 'ANNULÉ';
      default:
        return status.toUpperCase();
    }
  }

  void _deleteRequest(int id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Supprimer la demande'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette demande ?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Non')),
          TextButton(
            onPressed: () {
              Get.back();
              setState(() {
                myRequests.removeWhere((req) => req['id'] == id);
              });
              Get.snackbar('Succès', 'Demande supprimée', backgroundColor: Colors.green, colorText: Colors.white);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _editRequest(Map<String, dynamic> request) {
    Get.snackbar('Info', 'Modification de la demande bientôt disponible', backgroundColor: Colors.blue);
    // TODO: Open edit modal similar to request modal in client_home_screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Demandes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: myRequests.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.request_page, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune demande', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: myRequests.length,
        itemBuilder: (context, index) {
          final req = myRequests[index];
          final isUrgent = req['isUrgent'] == true;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUrgent ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isUrgent ? 'URGENTE' : 'NORMALE',
                          style: TextStyle(
                            color: isUrgent ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        req['category'],
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req['description'],
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text('${req['zone']} • ${req['time']}'),
                          const Spacer(),
                          Text(
                            '${req['responses']} réponses',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editRequest(req),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Modifier'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteRequest(req['id']),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Supprimer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}