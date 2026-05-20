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
  // Add these missing properties:
  var availability = <Map<String, dynamic>>[].obs;
  var followers = <Map<String, dynamic>>[].obs;



  // ============================================================
  // INIT
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    loadDashboard();
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
    } finally {
      isLoading.value = false;
    }
  }
  void toggleActive() async {
    if (artisan.value == null) return;

    final newStatus = artisan.value!.isActive ? 'inactive' : 'active';

    // Update local state
    final updated = artisan.value!.copyWith(
      activesStatus: newStatus,
    );

    artisan.value = updated;

    // Optional: Sync with backend
    try {
      await ApiService.updateArtisan(artisan.value!.id, {
        'actives_status': newStatus,
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
      if (response['user_id'] != null) {
        final artisanId = int.parse(response['user_id'].toString());
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
        wilaya: selectedWilaya.value.isEmpty ? null : selectedWilaya.value,
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
      final response = await ApiService.getPosts(limit: 20, sort: '-created_at');
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
      await loadPosts(); // Refresh list

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