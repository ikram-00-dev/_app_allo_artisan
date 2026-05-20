import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/artisan.dart';
import '../models/post.dart';

class ArtisanController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================
  var isLoading = false.obs;
  var artisan = Rxn<Artisan>();
  var posts = <PostModel>[].obs;
  var allArtisans = <Artisan>[].obs;

  var selectedCategory = ''.obs;
  var selectedWilaya = ''.obs;

  // ============================================================
  // ADDED: Availability and Followers for Dashboard
  // ============================================================
  var availability = <Map<String, dynamic>>[].obs;
  var followers = <Map<String, dynamic>>[].obs;

  // ============================================================
  // INIT
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    loadDashboard();
    _initAvailability();
    _loadFollowers();
  }

  // ============================================================
  // ADDED: Initialize availability slots (7 days, 24 hours)
  // ============================================================
  void _initAvailability() {
    final List<Map<String, dynamic>> weekSchedule = [];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (int i = 0; i < 7; i++) {
      final List<Map<String, dynamic>> slots = [];
      for (int hour = 0; hour < 24; hour++) {
        slots.add({
          'hour': hour,
          'available': hour >= 8 && hour <= 18, // Default: 8 AM to 6 PM available
        });
      }
      weekSchedule.add({
        'day': i,
        'dayName': days[i],
        'slots': slots,
      });
    }
    availability.value = weekSchedule;
  }

  // ============================================================
  // ADDED: Toggle slot availability
  // ============================================================
  void toggleSlot(int dayIndex, int hour) {
    final updatedAvailability = List<Map<String, dynamic>>.from(availability.value);
    final day = Map<String, dynamic>.from(updatedAvailability[dayIndex]);
    final slots = List<Map<String, dynamic>>.from(day['slots']);

    slots[hour] = {
      'hour': hour,
      'available': !(slots[hour]['available'] as bool),
    };

    day['slots'] = slots;
    updatedAvailability[dayIndex] = day;
    availability.value = updatedAvailability;

    // Optional: Sync with backend
    _syncAvailabilityWithBackend();
  }

  // ============================================================
  // ADDED: Sync availability with backend
  // ============================================================
  Future<void> _syncAvailabilityWithBackend() async {
    if (artisan.value == null) return;
    try {
      await ApiService.updateArtisan(artisan.value!.id, {
        'availability': availability.value,
      });
    } catch (e) {
      print('Error syncing availability: $e');
    }
  }

  // ============================================================
  // ADDED: Load followers from backend
  // ============================================================
  Future<void> _loadFollowers() async {
    if (artisan.value == null) return;
    try {
      // Get followers from the artisan model
      final artisanData = artisan.value;
      if (artisanData?.followers != null && artisanData!.followers!.isNotEmpty) {
        final List<Map<String, dynamic>> followerList = [];
        for (var f in artisanData.followers!) {
          followerList.add({
            'name': f['Client']?['Username'] ?? f['username'] ?? 'Client',
            'id': f['ClientID'] ?? f['clientId'],
          });
        }
        followers.value = followerList;
      } else {
        // Mock data for demo
        followers.value = [
          {'name': 'Jean Dupont', 'id': 1},
          {'name': 'Marie Martin', 'id': 2},
          {'name': 'Pierre Durand', 'id': 3},
        ];
      }
    } catch (e) {
      print('Error loading followers: $e');
      // Fallback mock data
      followers.value = [
        {'name': 'Jean Dupont', 'id': 1},
        {'name': 'Marie Martin', 'id': 2},
      ];
    }
  }

  // ============================================================
  // DASHBOARD
  // ============================================================
  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      await loadCurrentArtisan();
      await loadPosts();
      await loadAllArtisans();
      await _loadFollowers();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleActive() async {
    if (artisan.value == null) return;

    final newStatus = artisan.value!.isActive ? 'inactive' : 'active';

    final updated = artisan.value!.copyWith(
      activesStatus: newStatus,
      isAvailable: !artisan.value!.isAvailable,
    );

    artisan.value = updated;

    try {
      await ApiService.updateArtisan(artisan.value!.id, {
        'activesStatus': newStatus,
        'isAvailable': updated.isAvailable,
      });
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  // ============================================================
  // CURRENT ARTISAN PROFILE
  // ============================================================
  Future<void> loadCurrentArtisan() async {
    try {
      final response = await ApiService.getCurrentUser();
      if (response['ID'] != null || response['id'] != null) {
        final artisanId = (response['ID'] ?? response['id']) as int;
        await loadArtisanById(artisanId);
      }
    } catch (e) {
      print('Error loading artisan: $e');
    }
  }

  Future<void> loadArtisanById(int id) async {
    try {
      final response = await ApiService.getArtisanById(id);
      artisan.value = Artisan.fromJson(response);
    } catch (e) {
      print('Error loading artisan by id: $e');
    }
  }

  // ============================================================
  // ALL ARTISANS (for search/browse)
  // ============================================================
  Future<void> loadAllArtisans() async {
    try {
      final response = await ApiService.getArtisans(
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        province: selectedWilaya.value.isEmpty ? null : selectedWilaya.value,
      );
      allArtisans.value = (response as List)
          .map((json) => Artisan.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading artisans: $e');
    }
  }

  // ============================================================
  // POSTS
  // ============================================================
  Future<void> loadPosts() async {
    try {
      final response = await ApiService.getPosts(limit: 20, sort: '-createdAt');
      posts.value = (response as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  Future<bool> createPost(String content, String? imageUrl) async {
    try {
      isLoading.value = true;

      final data = {
        'content': content,
        'image': imageUrl ?? '',
      };

      await ApiService.createPost(data);
      await loadPosts();

      Get.snackbar("Succès", "Post créé avec succès");
      return true;
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de créer le post");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deletePost(int id) async {
    try {
      await ApiService.deletePost(id);
      posts.removeWhere((p) => p.idPost == id);

      Get.snackbar("Succès", "Post supprimé");
      return true;
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de supprimer");
      return false;
    }
  }

  // ============================================================
  // FILTERS
  // ============================================================
  void filterByCategory(String category) {
    selectedCategory.value = category;
    loadAllArtisans();
  }

  void filterByWilaya(String wilaya) {
    selectedWilaya.value = wilaya;
    loadAllArtisans();
  }

  void clearFilters() {
    selectedCategory.value = '';
    selectedWilaya.value = '';
    loadAllArtisans();
  }

  // ============================================================
  // AVAILABLE CATEGORIES (for filters)
  // ============================================================
  final List<String> categories = [
    "Plomberie",
    "Électricité",
    "Menuiserie",
    "Peinture",
    "Maçonnerie",
    "Jardinage",
    "Électronique",
    "Informatique",
    "Cuisine",
  ];

  final List<String> wilayas = [
    "Alger", "Oran", "Constantine", "Annaba", "Blida", "Sétif",
    "Tizi Ouzou", "Béjaïa", "Tlemcen", "Mostaganem",
  ];
}