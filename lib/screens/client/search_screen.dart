// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/artisan_controller.dart';
import '../../models/artisan.dart';
import '../../routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ArtisanController controller = Get.find<ArtisanController>();
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    "Plomberie",
    "Électricité",
    "Menuiserie",
    "Peinture",
    "Maçonnerie",
    "Jardinage",
  ];

  final List<String> selectedCategories = [];
  double rating = 2;
  bool showFilters = false;
  bool showCategoryFilter = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAllArtisans();
    });
  }

  List<Artisan> get filteredArtisans {
    return controller.allArtisans.where((artisan) {
      final matchesCategory = selectedCategories.isEmpty ||
          selectedCategories.contains(artisan.category);
      final matchesRating = (artisan.rating ?? 0) >= rating;
      final matchesSearch = searchController.text.isEmpty ||
          artisan.fullName.toLowerCase().contains(searchController.text.toLowerCase()) ||
          artisan.category.toLowerCase().contains(searchController.text.toLowerCase());

      return matchesCategory && matchesRating && matchesSearch;
    }).toList();
  }

  void toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Rechercher un artisan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAllArtisans(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
              TextField(
                controller: searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Rechercher par nom...",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter Button
              GestureDetector(
                onTap: () => setState(() => showFilters = !showFilters),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.filter_list),
                          SizedBox(width: 8),
                          Text("Filtres", style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Icon(showFilters ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              ),

              // Filters Panel
              if (showFilters) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      GestureDetector(
                        onTap: () => setState(() => showCategoryFilter = !showCategoryFilter),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Catégories", style: TextStyle(fontWeight: FontWeight.bold)),
                            Icon(showCategoryFilter ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
                          ],
                        ),
                      ),
                      if (showCategoryFilter)
                        ...categories.map((category) => CheckboxListTile(
                          value: selectedCategories.contains(category),
                          onChanged: (_) => toggleCategory(category),
                          title: Text(category),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        )),
                      const SizedBox(height: 20),

                      // Rating
                      Text(
                        "Évaluation minimale: ${rating.toStringAsFixed(1)} ⭐",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        value: rating,
                        min: 2,
                        max: 5,
                        divisions: 6,
                        onChanged: (value) => setState(() => rating = value),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              selectedCategories.clear();
                              rating = 2;
                            });
                          },
                          child: const Text("Réinitialiser les filtres", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Results Count
              Obx(() => Text(
                "${filteredArtisans.length} artisan(s) trouvé(s)",
                style: const TextStyle(color: Colors.grey),
              )),

              const SizedBox(height: 16),

              // Artisans List
              Obx(() {
                if (controller.isLoading.value && controller.allArtisans.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filteredArtisans.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Aucun artisan trouvé", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 8),
                        Text("Essayez de modifier vos filtres", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return Column(
                  children: filteredArtisans.map((artisan) => _buildArtisanCard(artisan)).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtisanCard(Artisan artisan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    artisan.fullName.isNotEmpty ? artisan.fullName[0].toUpperCase() : "?",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artisan.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              artisan.category,
                              style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                          Expanded(
                            child: Text(
                              artisan.fullAddress,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            (artisan.rating ?? 0).toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(${artisan.reviewCount ?? 0})",
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              artisan.bio,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(artisan.phone, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    artisan.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Get.toNamed(AppRoutes.artisanProfile, arguments: artisan.id),
                child: const Text("Voir le profil"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}