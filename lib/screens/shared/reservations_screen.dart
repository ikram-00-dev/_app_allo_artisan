import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/reservation_controller.dart';
import '../models/appointment.dart';

class ReservationScreen extends StatelessWidget {
  ReservationScreen({super.key});

  final ReservationController controller =
  Get.put(ReservationController());

  Color statusColor(Appointment a) {
    if (a.isConfirmed) return Colors.green;
    if (a.isPending) return Colors.orange;
    if (a.isCancelled) return Colors.red;
    if (a.isCompleted) return Colors.grey;
    return Colors.black;
  }

  String statusLabel(Appointment a) {
    if (a.isConfirmed) return "Confirmé";
    if (a.isPending) return "En attente";
    if (a.isCancelled) return "Annulé";
    if (a.isCompleted) return "Terminé";
    return a.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        title: const Text("Réservations"),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.appointments.isEmpty) {
          return const Center(
            child: Text("Aucune réservation"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.appointments.length,
          itemBuilder: (context, index) {
            final a = controller.appointments[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: statusColor(a),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        statusLabel(a),
                        style: TextStyle(
                          color: statusColor(a),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// DATE / TIME
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "${a.scheduledTime.day}/${a.scheduledTime.month}/${a.scheduledTime.year}",
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        "${a.scheduledTime.hour.toString().padLeft(2, '0')}:${a.scheduledTime.minute.toString().padLeft(2, '0')}",
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ID
                  Text(
                    "ID: ${a.idAppointment}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ACTIONS
                  if (a.isPending)
                    Row(
                      children: [

                        /// CONFIRM
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () =>
                                controller.confirm(a.idAppointment),
                            child: const Text("Confirmer"),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// CANCEL
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () =>
                                controller.cancel(a.idAppointment),
                            child: const Text("Annuler"),
                          ),
                        ),
                      ],
                    ),

                  if (a.isConfirmed)
                    const Text(
                      "✔ Rendez-vous confirmé",
                      style: TextStyle(color: Colors.green),
                    ),

                  if (a.isCancelled)
                    const Text(
                      "✖ Rendez-vous annulé",
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}