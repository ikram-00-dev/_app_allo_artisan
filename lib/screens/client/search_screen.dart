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

  // Store all artisans locally for filtering
  List<Artisan> _allArtisans = [];

  // ONLY TWO FAKE/STATIC ARTISANS
  final List<Map<String, dynamic>> _fakeArtisansData = [
    {
      'id': 9991,
      'firstName': 'Aymen',
      'lastName': 'Aymen',
      'fullName': 'Aymen Aymen',
      'category': 'Plomberie',
      'province': 'Alger',
      'city': 'Alger Centre',
      'district': '10km',
      'rating': 4.9,
      'bio': 'Plombier professionnel avec 12 ans d\'expérience. Intervention rapide et travail soigné. Disponible 7j/7.',
      'phoneNumber': '+213 551 23 45 67',
      'email': 'aymen.aymen@example.com',
      'avatarUrl': '',
      'activesStatus': 'active',
      'isAvailable': true,
      'experience': 12,
      'diploma': 'Certification professionnelle Plomberie',
    },
    {
      'id': 9992,
      'firstName': 'Yasser',
      'lastName': 'Yasser',
      'fullName': 'Yasser Yasser',
      'category': 'Électricité',
      'province': 'Alger',
      'city': 'Alger Centre',
      'district': '15km',
      'rating': 4.8,
      'bio': 'Électricien certifié, spécialiste en installation et dépannage électrique. Travail de qualité garanti.',
      'phoneNumber': '+213 552 34 56 78',
      'email': 'yasser.yasser@example.com',
      'avatarUrl': '',
      'activesStatus': 'active',
      'isAvailable': true,
      'experience': 10,
      'diploma': 'Bac Technicien Électrique',
    },
  ];

  // Fake artisans as Artisan objects (created from maps)
  List<Artisan> get _fakeArtisans {
    return _fakeArtisansData.map((data) => Artisan.fromJson(data)).toList();
  }

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'Toutes catégories', 'icon': '🔍'},
    {'id': 'plomberie', 'name': 'Plomberie', 'icon': '🔧'},
    {'id': 'electricite', 'name': 'Électricité', 'icon': '⚡'},
    {'id': 'menuiserie', 'name': 'Menuiserie', 'icon': '🪚'},
    {'id': 'peinture', 'name': 'Peinture', 'icon': '🎨'},
    {'id': 'maconnerie', 'name': 'Maçonnerie', 'icon': '🧱'},
    {'id': 'jardinage', 'name': 'Jardinage', 'icon': '🌿'},
    {'id': 'climatisation', 'name': 'Climatisation', 'icon': '❄️'},
    {'id': 'carrelage', 'name': 'Carrelage', 'icon': '📐'},
    {'id': 'plâtrerie', 'name': 'Plâtrerie', 'icon': '🏠'},
    {'id': 'soudure', 'name': 'Soudure', 'icon': '🔥'},
    {'id': 'electronique', 'name': 'Électronique', 'icon': '💻'},
    {'id': 'informatique', 'name': 'Informatique', 'icon': '🖥️'},
    {'id': 'cuisine', 'name': 'Cuisine', 'icon': '🍳'},
  ];

  // Computed filtered artisans (combines real + fake)
  List<Artisan> get _filteredArtisans {
    // Only show fake artisans (Aymen and Yasser) - no real artisans
    final allArtisansToShow = [..._fakeArtisans];

    return allArtisansToShow.where((artisan) {
      // Filter ONLY active artisans (activesStatus == 'active')
      if (artisan.activesStatus != 'active') {
        return false;
      }

      // Category filter
      if (_selectedCategory.value != 'all') {
        final artisanCategory = artisan.category.toLowerCase();
        final selectedCat = _selectedCategory.value.toLowerCase();
        if (!artisanCategory.contains(selectedCat) &&
            artisanCategory != selectedCat) {
          return false;
        }
      }

      // Rating filter
      if (_selectedRating.value > 0 && (artisan.rating ?? 0) < _selectedRating.value) {
        return false;
      }

      // Search query filter
      final query = searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        return artisan.fullName.toLowerCase().contains(query) ||
            artisan.category.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory.value = widget.initialCategory!.toLowerCase();
    }

    // Load all artisans when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllArtisans();
    });

    // Add listener to search controller for debouncing
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadAllArtisans() async {
    // No need to load real artisans - we only show fake ones
    setState(() {});
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {}); // Trigger rebuild
    });
  }

  void _navigateToArtisanProfile(Artisan artisan) {
    Get.toNamed(AppRoutes.artisanProfile, arguments: artisan.id);
  }

  void _selectCategory(String value) {
    _selectedCategory.value = value;
    _isCategoryExpanded.value = false;
    setState(() {});
  }

  void _resetFilters() {
    _selectedCategory.value = 'all';
    _selectedDistance.value = 10.0;
    _selectedRating.value = 0.0;
    searchController.clear();
    setState(() {});
  }

  String _getInitials(String firstName, String lastName) {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    if (firstInitial.isNotEmpty && lastInitial.isNotEmpty) {
      return '$firstInitial$lastInitial';
    }
    return firstInitial.isNotEmpty ? firstInitial : '?';
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
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(_showFilters.value ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () => _showFilters.value = !_showFilters.value,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters.value) _buildFilters(selectedCategoryName),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredArtisans.length} artisan(s) trouvé(s)',
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                ),
                if (_selectedCategory.value != 'all' ||
                    _selectedRating.value > 0 ||
                    searchController.text.isNotEmpty)
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
      ),
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
          ExpansionTile(
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
          ),
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
          Row(
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
          ),
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
          Row(
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
                    setState(() {});
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
          ),
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
    String initials = _getInitials(artisan.user.firstName, artisan.user.lastName);

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
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(
                      initials,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
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