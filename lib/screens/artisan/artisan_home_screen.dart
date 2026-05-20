import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/app_widgets.dart';
import '../../utils/utils.dart';

class ArtisanHomeScreen extends StatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  State<ArtisanHomeScreen> createState() =>
      _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState
    extends State<ArtisanHomeScreen> {
  final List<Map<String, dynamic>> requests = [
    {
      "id": "1",
      "urgent": true,
      "client": "Sophie Martin",
      "category": "Plomberie",
      "zone": "Paris 15ème",
      "description":
      "Fuite d'eau importante dans la salle de bain.",
      "time": "10 min",
    },
    {
      "id": "2",
      "urgent": false,
      "client": "Marc Dubois",
      "category": "Plomberie",
      "zone": "Paris 12ème",
      "description":
      "Recherche plombier pour rénover une salle de bain.",
      "time": "2 heures",
    },
  ];

  void acceptRequest(Map<String, dynamic> request) {
    Get.snackbar(
      "Accepté",
      "Demande acceptée",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void refuseRequest() {
    Get.snackbar(
      "Refusé",
      "Demande refusée",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Demandes clients",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ...requests.map(
                  (request) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: request["urgent"]
                      ? Colors.red.shade50
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: request["urgent"]
                        ? Colors.red.shade200
                        : Colors.grey.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    if (request["urgent"])
                      Row(
                        children: const [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Demande urgente",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                    if (request["urgent"])
                      const SizedBox(height: 14),

                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(
                            request["client"][0],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                request["client"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withOpacity(.1),
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      request["category"],
                                      style: const TextStyle(
                                        color:
                                        AppColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    request["zone"],
                                    style: TextStyle(
                                      color:
                                      Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Text(
                          request["time"],
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      request["description"],
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                acceptRequest(request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              request["urgent"]
                                  ? Colors.green
                                  : AppColors.primary,
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              request["urgent"]
                                  ? "Accepter"
                                  : "Envoyer message",
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: OutlinedButton(
                            onPressed: refuseRequest,
                            style: OutlinedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              request["urgent"]
                                  ? "Refuser"
                                  : "Pas intéressé",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}