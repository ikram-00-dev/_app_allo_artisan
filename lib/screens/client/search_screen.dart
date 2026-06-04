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

  final RxBool _showFilters = true.obs;
  final RxString _selectedCategory = 'all'.obs;
  final RxDouble _selectedRating = 0.0.obs;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory.value = widget.initialCategory!.toLowerCase();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadAllArtisans();
    });

    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _filteredArtisans.refresh();
    });
  }

  // Improved filtered list
  RxList<Artisan> get _filteredArtisans => RxList<Artisan>(
      controller.allArtisans.where((artisan) {
        // Only show active artisans
        if (!artisan.isActive) return false;

        final query = searchController.text.trim().toLowerCase();

        final matchesSearch = query.isEmpty ||
            artisan.fullName.toLowerCase().contains(query) ||
            artisan.category.toLowerCase().contains(query) ||
            artisan.fullAddress.toLowerCase().contains(query);

        final matchesCategory = _selectedCategory.value == 'all' ||
            artisan.category.toLowerCase() == _selectedCategory.value.toLowerCase();

        final matchesRating = _selectedRating.value == 0 ||
            (artisan.rating ?? 0) >= _selectedRating.value;

        return matchesSearch && matchesCategory && matchesRating;
      }).toList()
  );

  void _resetFilters() {
    _selectedCategory.value = 'all';
    _selectedRating.value = 0.0;
    searchController.clear();
    _filteredArtisans.refresh();
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allArtisans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildFilters(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredArtisans.length} artisan(s) trouvé(s)',
                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                  if (_selectedCategory.value != 'all' || _selectedRating.value > 0 || searchController.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Réinitialiser'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _filteredArtisans.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredArtisans.length,
                itemBuilder: (context, index) {
                  return _buildArtisanCard(_filteredArtisans[index]);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Toutes'),
                selected: _selectedCategory.value == 'all',
                onSelected: (_) => _selectedCategory.value = 'all',
              ),
              ...['Plombier', 'Électricien', 'Menuisier', 'Maçon', 'Peintre en bâtiment'].map((cat) => FilterChip(
                label: Text(cat),
                selected: _selectedCategory.value == cat.toLowerCase(),
                onSelected: (_) => _selectedCategory.value = cat.toLowerCase(),
              )),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Note minimum', style: TextStyle(fontWeight: FontWeight.bold)),
          Obx(() => Slider(
            value: _selectedRating.value,
            min: 0,
            max: 5,
            divisions: 5,
            label: _selectedRating.value == 0 ? 'Toutes' : '${_selectedRating.value.toInt()}★',
            onChanged: (value) => _selectedRating.value = value,
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
        ],
      ),
    );
  }

  Widget _buildArtisanCard(Artisan artisan) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.artisanProfile, arguments: artisan.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: artisan.avatarUrl.isNotEmpty ? NetworkImage(artisan.avatarUrl) : null,
                    child: artisan.avatarUrl.isEmpty ? Text(artisan.fullName.isNotEmpty ? artisan.fullName[0] : '?') : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(artisan.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(artisan.category, style: const TextStyle(color: Colors.blue)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(' ${(artisan.rating ?? 0).toStringAsFixed(1)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(artisan.fullAddress, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }
}