// lib/screens/client/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/artisan_controller.dart';
import '../../models/artisan.dart';
import '../../routes/app_routes.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ArtisanController controller = Get.find<ArtisanController>();
  final TextEditingController searchController = TextEditingController();

  // Reactive variables using GetX
  final RxBool _showFilters = true.obs;
  final RxString _selectedCategory = 'all'.obs;
  final RxDouble _selectedDistance = 10.0.obs;
  final RxDouble _selectedRating = 0.0.obs;
  final RxBool _isCategoryExpanded = false.obs;

  // For debouncing search
  Timer? _debounceTimer;

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'Toutes catégories', 'icon': '🔍'},
    {'id': 'plomberie', 'name': 'Plomberie', 'icon': '🔧'},
    {'id': 'électricité', 'name': 'Électricité', 'icon': '⚡'},
    {'id': 'menuiserie', 'name': 'Menuiserie', 'icon': '🪚'},
    {'id': 'peinture', 'name': 'Peinture', 'icon': '🎨'},
    {'id': 'maçonnerie', 'name': 'Maçonnerie', 'icon': '🧱'},
    {'id': 'jardinage', 'name': 'Jardinage', 'icon': '🌿'},
    {'id': 'climatisation', 'name': 'Climatisation', 'icon': '❄️'},
    {'id': 'carrelage', 'name': 'Carrelage', 'icon': '📐'},
    {'id': 'plâtrerie', 'name': 'Plâtrerie', 'icon': '🏠'},
    {'id': 'soudure', 'name': 'Soudure', 'icon': '🔥'},
  ];

  // Computed observable for filtered artisans
  RxList<Artisan> get _filteredArtisans => RxList<Artisan>(
      controller.allArtisans.where((artisan) {
        // Filter ONLY active artisans (activesStatus == 'active')
        if (artisan.activesStatus != 'active') {
          return false;
        }

        if (_selectedCategory.value != 'all' &&
            artisan.category.toLowerCase() != _selectedCategory.value.toLowerCase()) {
          return false;
        }

        if (_selectedRating.value > 0 && (artisan.rating ?? 0) < _selectedRating.value) {
          return false;
        }

        final query = searchController.text.trim().toLowerCase();
        if (query.isNotEmpty) {
          return artisan.fullName.toLowerCase().contains(query) ||
              artisan.category.toLowerCase().contains(query);
        }
        return true;
      }).toList()
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory.value = widget.initialCategory!.toLowerCase();
    }

    // Load artisans when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAllArtisans();
    });

    // Add listener to search controller for debouncing
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    // Trigger rebuild by updating the filtered list
    _filteredArtisans.refresh();
  }

  void _navigateToArtisanProfile(Artisan artisan) {
    Get.toNamed(AppRoutes.artisanProfile, arguments: artisan.id);
  }

  void _selectCategory(String value) {
    _selectedCategory.value = value;
    _isCategoryExpanded.value = false;
    _applyFilters();
  }

  void _resetFilters() {
    _selectedCategory.value = 'all';
    _selectedDistance.value = 10.0;
    _selectedRating.value = 0.0;
    searchController.clear();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    // Get the selected category name for display
    String selectedCategoryName = 'Toutes catégories';
    for (var cat in _categories) {
      if (cat['id'] == _selectedCategory.value) {
        selectedCategoryName = cat['name']!;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Rechercher un artisan...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
            onChanged: (_) => _applyFilters(),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(_showFilters.value ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () => _showFilters.value = !_showFilters.value,
          )),
        ],
      ),
      body: Obx(() {
        // Show loading state
        if (controller.isLoading.value && controller.allArtisans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          );
        }

        return Column(
          children: [
            if (_showFilters.value) _buildFilters(selectedCategoryName),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                    '${_filteredArtisans.length} artisan(s) trouvé(s)',
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                  )),
                  Obx(() {
                    if (_selectedCategory.value != 'all' ||
                        _selectedRating.value > 0 ||
                        searchController.text.isNotEmpty) {
                      return TextButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Réinitialiser'),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_filteredArtisans.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredArtisans.length,
                  itemBuilder: (context, index) {
                    return _buildArtisanCard(_filteredArtisans[index]);
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilters(String selectedCategoryName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category ExpansionTile (Collapsible List)
          Obx(() => ExpansionTile(
            title: const Text(
              'Catégorie',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              selectedCategoryName,
              style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13),
            ),
            leading: const Icon(Icons.category, color: Color(0xFF2563EB)),
            initiallyExpanded: _isCategoryExpanded.value,
            onExpansionChanged: (expanded) {
              _isCategoryExpanded.value = expanded;
            },
            children: [
              SizedBox(
                height: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory.value == category['id'];
                    return ListTile(
                      leading: Text(
                        category['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      title: Text(
                        category['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF2563EB) : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 20)
                          : null,
                      onTap: () => _selectCategory(category['id']!),
                    );
                  },
                ),
              ),
            ],
          )),
          const Divider(height: 24),

          // Distance Slider
          const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 6),
              Text('Zone de recherche', style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: [
              Expanded(
                child: Slider(
                  value: _selectedDistance.value,
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: '${_selectedDistance.value.toInt()} km',
                  onChanged: (value) {
                    _selectedDistance.value = value;
                    _applyFilters();
                  },
                  activeColor: const Color(0xFF2563EB),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${_selectedDistance.value.toInt()} km',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          )),
          const SizedBox(height: 16),

          // Rating Slider
          const Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              SizedBox(width: 6),
              Text('Note minimum', style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
            children: [
              Expanded(
                child: Slider(
                  value: _selectedRating.value,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _selectedRating.value == 0 ? 'Toutes notes' : '${_selectedRating.value.toInt()}★',
                  onChanged: (value) {
                    _selectedRating.value = value;
                    _applyFilters();
                  },
                  activeColor: Colors.amber,
                ),
              ),
              SizedBox(
                width: 70,
                child: Text(
                  _selectedRating.value == 0 ? 'Toutes' : '${_selectedRating.value.toInt()}★',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun artisan trouvé', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Essayez de modifier vos filtres', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildArtisanCard(Artisan artisan) {
    return GestureDetector(
      onTap: () => _navigateToArtisanProfile(artisan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: artisan.avatarUrl.isNotEmpty ? NetworkImage(artisan.avatarUrl) : null,
                    child: artisan.avatarUrl.isEmpty
                        ? Text(
                      artisan.fullName.isNotEmpty ? artisan.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(artisan.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(artisan.category, style: const TextStyle(color: Colors.blue, fontSize: 13)),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${(artisan.rating ?? 0).toStringAsFixed(1)}'),
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
                  Expanded(child: Text(artisan.fullAddress, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                ],
              ),
              if (artisan.bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(artisan.bio, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToArtisanProfile(artisan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Voir le profil', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}