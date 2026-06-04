// lib/screens/shared/reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';

class ReservationScreen extends StatelessWidget {
  ReservationScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  // STATIC RESERVATIONS DATA
  final RxList<Map<String, dynamic>> reservations = <Map<String, dynamic>>[
    {
      'id': '1',
      'clientName': 'Karim B.',
      'artisanName': 'Moi (Artisan)',
      'category': 'Plomberie',
      'date': '15 Mai 2026',
      'time': '14:00',
      'status': 'waiting',
      'address': 'Alger Centre',
    },
    {
      'id': '2',
      'clientName': 'Nadia L.',
      'artisanName': 'Moi (Artisan)',
      'category': 'Électricité',
      'date': '18 Mai 2026',
      'time': '10:00',
      'status': 'confirmed',
      'address': 'Hydra',
    },
  ].obs;

  Color statusColor(String status) {
    if (status == 'waiting') return Colors.orange;
    if (status == 'confirmed') return Colors.green;
    if (status == 'cancelled') return Colors.red;
    if (status == 'completed') return Colors.grey;
    return Colors.black;
  }

  String statusLabel(String status) {
    if (status == 'waiting') return "EN ATTENTE";
    if (status == 'confirmed') return "CONFIRMÉ";
    if (status == 'cancelled') return "ANNULÉ";
    if (status == 'completed') return "TERMINÉ";
    return status.toUpperCase();
  }

  void _cancelReservation(int index) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Non')),
          TextButton(
            onPressed: () {
              reservations[index]['status'] = 'cancelled';
              reservations.refresh();
              Navigator.pop(context);
              Get.snackbar('Succès', 'Réservation annulée', backgroundColor: Colors.green, colorText: Colors.white);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }

  void _confirmReservation(int index) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réservation'),
        content: const Text('Confirmez-vous cette réservation ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              reservations[index]['status'] = 'confirmed';
              reservations.refresh();
              Navigator.pop(context);
              Get.snackbar('Succès', 'Réservation confirmée', backgroundColor: Colors.green, colorText: Colors.white);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _completeReservation(int index) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la prestation'),
        content: const Text('La prestation est-elle terminée ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              reservations[index]['status'] = 'completed';
              reservations.refresh();
              Navigator.pop(context);
              Get.snackbar('Succès', 'Prestation terminée', backgroundColor: Colors.green, colorText: Colors.white);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArtisan = authController.isArtisan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (isArtisan) {
              Get.offAllNamed(AppRoutes.artisanHome);
            } else {
              Get.offAllNamed(AppRoutes.clientHome);
            }
          },
          tooltip: 'Retour à l\'accueil',
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: Obx(() => reservations.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Aucune réservation', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          final isWaiting = reservation['status'] == 'waiting';
          final isConfirmed = reservation['status'] == 'confirmed';
          final isCompleted = reservation['status'] == 'completed';
          final isCancelled = reservation['status'] == 'cancelled';
          final status = reservation['status'] as String;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isWaiting ? Colors.orange.shade200 : Colors.grey.shade200,
                width: isWaiting ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel(status),
                        style: TextStyle(color: statusColor(status), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      reservation['category']!,
                      style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isArtisan ? reservation['clientName']! : reservation['artisanName']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(reservation['date']!),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(reservation['time']!),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(reservation['address']!),
                  ],
                ),
                if (isWaiting) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'En attente de confirmation. Sera supprimée automatiquement si non confirmée.',
                            style: TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!isCompleted && !isCancelled) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _cancelReservation(index),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isWaiting)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _confirmReservation(index),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), foregroundColor: Colors.white),
                            child: const Text('Confirmer'),
                          ),
                        ),
                      if (isConfirmed)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _completeReservation(index),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                            child: const Text('Terminer'),
                          ),
                        ),
                    ],
                    if (isCompleted)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed(
                              AppRoutes.chat,
                              arguments: {
                                'contactId': reservation['clientName'] == 'Karim B.' ? 101 : 102,
                                'contactName': reservation['clientName'],
                                'appointmentId': int.parse(reservation['id']),
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.white),
                          child: const Text('Évaluer'),
                        ),
                      ),
                    if (isCancelled)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          child: const Text('Annulée', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      )),
    );
  }
}