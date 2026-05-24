import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/reservation_controller.dart';
import '../../models/appointment.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';

class ReservationScreen extends StatelessWidget {
   ReservationScreen({super.key});

  final ReservationController controller = Get.put(ReservationController());

  // Mock data for when backend is not available
  final List<Map<String, dynamic>> mockReservations = [
    {
      'id': '1',
      'artisan': 'Jean Dupont',
      'category': 'Plomberie',
      'date': '15 Mai 2026',
      'time': '14:00',
      'status': 'waiting',
    },
    {
      'id': '2',
      'artisan': 'Sophie Martin',
      'category': 'Électricité',
      'date': '18 Mai 2026',
      'time': '10:00',
      'status': 'confirmed',
    },

  ];

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

  @override
  Widget build(BuildContext context) {
    // Use mock data for now since backend might not have appointments
    final reservations = mockReservations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: reservations.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucune réservation',
                style: TextStyle(color: Colors.grey),
              ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isWaiting
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel(status),
                        style: TextStyle(
                          color: statusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      reservation['category']!,
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reservation['artisan']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                if (isWaiting) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'En attente de confirmation. Sera supprimée automatiquement si non confirmée.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Annuler la réservation'),
                              content: const Text(
                                'Êtes-vous sûr de vouloir annuler cette réservation ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Non'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Get.snackbar(
                                      'Succès',
                                      'Réservation annulée',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Oui'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Info',
                            'Message envoyé à l\'artisan',
                            backgroundColor: const Color(0xFF2563EB),
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Contacter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}