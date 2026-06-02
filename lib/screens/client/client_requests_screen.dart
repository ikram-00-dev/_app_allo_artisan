// client_requests_screen.dart - Fixed version with proper async handling
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/request_controller.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({super.key});

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  final AuthController authController = Get.find<AuthController>();
  final RequestController requestController = Get.find<RequestController>();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final user = authController.user.value;
    final clientId = user?['id'] ?? user?['clientId'] ?? user?['ID'];
    if (clientId != null && clientId is int) {
      await requestController.loadMyRequests(clientId);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'accepted':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'declined':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'ACTIF';
      case 'accepted':
        return 'ACCEPTÉ';
      case 'pending':
        return 'EN ATTENTE';
      case 'declined':
        return 'REFUSÉ';
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
            onPressed: () async {
              Get.back();
              final success = await requestController.deleteRequest(id);
              if (success) {
                await _loadRequests(); // Refresh list - added await
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _editRequest(Map<String, dynamic> request) {
    Get.snackbar('Info', 'Modification de la demande bientôt disponible',
        backgroundColor: Colors.blue, colorText: Colors.white);
  }

  String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.offAllNamed(AppRoutes.clientHome);
          },
          tooltip: 'Retour à l\'accueil',
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: Obx(() {
        if (requestController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (requestController.myRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.request_page, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucune demande', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text('Cliquez sur "Partager une demande" pour commencer',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadRequests, // This is correct - _loadRequests returns Future<void>
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requestController.myRequests.length,
            itemBuilder: (context, index) {
              final req = requestController.myRequests[index];
              final isUrgent = req['isUrgent'] == true || req['type'] == 'urgent';
              final status = _safeString(req['status'], defaultValue: 'active');

              // Safe extraction of values
              final category = _safeString(req['category'], defaultValue: 'Général');
              final description = _safeString(req['description']);
              final zoneKm = req['zoneKm'];
              final createdAt = req['createdAt'];

              final requestId = req['idRequest'] ?? req['IDRequest'] ?? req['id'];
              if (requestId == null) return const SizedBox.shrink();

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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusLabel(status),
                              style: TextStyle(
                                color: _getStatusColor(status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
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
                            category,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(zoneKm != null ? '$zoneKm km • ${_formatDate(createdAt)}' : _formatDate(createdAt)),
                              const Spacer(),
                            ],
                          ),
                          if (status == 'accepted')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                                    SizedBox(width: 8),
                                    Text('Accepté par un artisan',
                                        style: TextStyle(fontSize: 12, color: Colors.green)),
                                  ],
                                ),
                              ),
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
                              onPressed: () => _deleteRequest(requestId),
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
      }),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'Récemment';
    try {
      DateTime date;
      if (dateStr is DateTime) {
        date = dateStr;
      } else if (dateStr is String) {
        date = DateTime.parse(dateStr);
      } else {
        return 'Récemment';
      }

      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) {
        return 'Il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
      } else if (diff.inHours > 0) {
        return 'Il y a ${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
      } else if (diff.inMinutes > 0) {
        return 'Il y a ${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      return 'Récemment';
    }
  }
}