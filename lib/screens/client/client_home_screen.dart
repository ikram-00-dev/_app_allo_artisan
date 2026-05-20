import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/app_wets.dart';
import '../../utils/utils.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final AuthController authController = Get.find<AuthController>();

  final List<Map<String, dynamic>> publications = [
    {
      "id": "1",
      "name": "Jean Dupont",
      "category": "Plomberie",
      "rating": 4.8,
      "verified": true,
      "time": "Il y a 2 heures",
      "likes": 45,
      "comments": 8,
      "description":
      "Installation d'une nouvelle salle de bain complète avec robinetterie moderne.",
      "image":
      "https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800",
      "avatar":
      "https://api.dicebear.com/7.x/avataaars/png?seed=jean",
    },
    {
      "id": "2",
      "name": "Sophie Martin",
      "category": "Électricité",
      "rating": 4.9,
      "verified": true,
      "time": "Il y a 5 heures",
      "likes": 67,
      "comments": 12,
      "description":
      "Rénovation complète de l'installation électrique.",
      "image":
      "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800",
      "avatar":
      "https://api.dicebear.com/7.x/avataaars/png?seed=sophie",
    },
  ];

  final Set<String> likedPosts = {};

  void toggleLike(String id) {
    setState(() {
      if (likedPosts.contains(id)) {
        likedPosts.remove(id);
      } else {
        likedPosts.add(id);
      }
    });
  }

  void showRequestDialog() {
    String category = "";
    String zone = "";
    String description = "";

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Partager une demande",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  CustomTextField(
                    hint: "Catégorie",
                    onChanged: (v) => category = v,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    hint: "Zone",
                    onChanged: (v) => zone = v,
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    maxLines: 5,
                    onChanged: (v) => description = v,
                    decoration: InputDecoration(
                      hintText: "Décrivez votre besoin...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  CustomButton(
                    text: "Envoyer",
                    onPressed: () {
                      if (category.isEmpty || description.isEmpty) {
                        Get.snackbar(
                          "Erreur",
                          "Veuillez remplir les champs",
                        );
                        return;
                      }

                      Get.back();

                      Get.snackbar(
                        "Succès",
                        "Demande envoyée avec succès",
                        backgroundColor: AppColors.primary,
                        colorText: Colors.white,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: showRequestDialog,
        icon: const Icon(Icons.add),
        label: const Text("Partager"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Publications récentes",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ...publications.map(
                  (post) => Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage:
                            NetworkImage(post["avatar"]),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      post["name"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(width: 6),

                                    if (post["verified"])
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    Text(
                                      post["category"],
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),

                                    Text(
                                      post["rating"].toString(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Text(
                            post["time"],
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.network(
                        post["image"],
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(post["description"]),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              InkWell(
                                onTap: () => toggleLike(post["id"]),
                                child: Row(
                                  children: [
                                    Icon(
                                      likedPosts.contains(post["id"])
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: likedPosts.contains(post["id"])
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${post["likes"]}",
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 24),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.mode_comment_outlined,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${post["comments"]}",
                                  ),
                                ],
                              ),

                              const SizedBox(width: 24),

                              const Icon(Icons.share_outlined),
                            ],
                          ),
                        ],
                      ),
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