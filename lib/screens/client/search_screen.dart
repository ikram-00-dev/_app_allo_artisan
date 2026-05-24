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

  String _selectedCategory = 'all';
  double _selectedDistance = 10;
  double _selectedRating = 0;
  bool _isFiltering = false;

  final List<Map<String, String>> categories = [
    {'id': 'all', 'name': '🔍 Toutes catégories', 'icon': '🔍'},
    {'id': 'plomberie', 'name': 'Plomberie', 'icon': '🔧'},
    {'id': 'electricite', 'name': 'Électricité', 'icon': '⚡'},
    {'id': 'menuisier', 'name': 'Menuiserie', 'icon': '🪚'},
    {'id': 'peinture', 'name': 'Peinture', 'icon': '🎨'},
    {'id': 'macconnerie', 'name': 'Maçonnerie', 'icon': '🧱'},
    {'id': 'jardinage', 'name': 'Jardinage', 'icon': '🌿'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAllArtisans();
    });
  }

  void _applyFilters() {
    setState(() => _isFiltering = true);
    // Apply filters based on selection
    controller.loadAllArtisans();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isFiltering = false);
    });
  }

  List<Artisan> get filteredArtisans {
    var result = controller.allArtisans.where((artisan) {
      // Category filter
      if (_selectedCategory != 'all' &&
          artisan.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      // Rating filter
      if (_selectedRating > 0 && (artisan.rating ?? 0) < _selectedRating) {
        return false;
      }
      // Search query
      if (searchController.text.isNotEmpty &&
          !artisan.fullName.toLowerCase().contains(searchController.text.toLowerCase()) &&
          !artisan.category.toLowerCase().contains(searchController.text.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    // Sort by rating
    result.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Rechercher un artisan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (_) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou catégorie...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filters Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // 1. Category Filter (Radio)
                Card(
                  child: ExpansionTile(
                    title: const Text('Catégorie * (obligatoire)'),
                    subtitle: Text(_selectedCategory == 'all' ? 'Toutes catégories' : _selectedCategory),
                    leading: const Icon(Icons.category, color: Color(0xFF3B82F6)),
                    children: categories.map((category) {
                      return RadioListTile<String>(
                        title: Text(category['name']!),
                        value: category['id']!,
                        groupValue: _selectedCategory,
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                          _applyFilters();
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Distance Filter (Slider)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on, color: Color(0xFF3B82F6)),
                            SizedBox(width: 8),
                            Text('Zone de recherche (optionnel)'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _selectedDistance,
                                min: 5,
                                max: 50,
                                divisions: 9,
                                label: '${_selectedDistance.toInt()} km',
                                onChanged: (value) {
                                  setState(() => _selectedDistance = value);
                                  _applyFilters();
                                },
                                activeColor: const Color(0xFF3B82F6),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${_selectedDistance.toInt()} km',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Rating Filter (Slider)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('Note minimum (optionnel)'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _selectedRating,
                                min: 0,
                                max: 5,
                                divisions: 10,
                                label: _selectedRating == 0 ? 'Toutes notes' : '${_selectedRating.toInt()} étoiles',
                                onChanged: (value) {
                                  setState(() => _selectedRating = value);
                                  _applyFilters();
                                },
                                activeColor: Colors.amber,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                _selectedRating == 0 ? 'Toutes' : '${_selectedRating.toInt()}★',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Results Count
                Text(
                  '${filteredArtisans.length} artisan(s) trouvé(s)',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Artisans List
                _isFiltering
                    ? const Center(child: CircularProgressIndicator())
                    : filteredArtisans.isEmpty
                    ? _buildEmptyState()
                    : Column(
                  children: filteredArtisans.map((artisan) => _buildArtisanCard(artisan)).toList(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun artisan trouvé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text('Essayez de modifier vos filtres', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildArtisanCard(Artisan artisan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: artisan.avatarUrl.isNotEmpty
                      ? NetworkImage(artisan.avatarUrl)
                      : null,
                  child: artisan.avatarUrl.isEmpty
                      ? Text(artisan.fullName.isNotEmpty ? artisan.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(artisan.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(artisan.category, style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text((artisan.rating ?? 0).toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(artisan.fullAddress, style: const TextStyle(color: Colors.grey, fontSize: 12))),
              ],
            ),
            const SizedBox(height: 12),
            Text(artisan.bio, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.artisanProfile, arguments: artisan.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Voir le profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}