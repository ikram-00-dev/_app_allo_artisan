import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/artisan.dart';
import '../models/post.dart';
import '../services/storage_service.dart';

class ArtisanController extends GetxController {
  // ============================================================
  // STATE
  // ============================================================
  var isLoading = false.obs;
  var artisan = Rxn<Artisan>();
  var posts = <PostModel>[].obs;
  var allArtisans = <Artisan>[].obs;
  var isFollowing = false.obs;
  var isVisible = true.obs; // For private profile visibility toggle

  // Selected filters
  var selectedCategory = ''.obs;
  var selectedWilaya = ''.obs;
  var searchQuery = ''.obs;

  // ============================================================
  // AVAILABILITY CALENDAR (Dynamic from backend)
  // ============================================================
  var availability = <Map<String, dynamic>>[].obs;

  // ============================================================
  // FOLLOWERS (Dynamic from backend)
  // ============================================================
  var followers = <Map<String, dynamic>>[].obs;
  var followingCount = 0.obs;

  // ============================================================
  // INIT
  // ============================================================
  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  // ============================================================
  // DASHBOARD LOAD
  // ============================================================
  Future<void> loadDashboard() async {
    isLoading.value = true;
    try {
      await loadCurrentUser();
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD CURRENT USER (Detects role automatically)
  // ============================================================
  Future<void> loadCurrentUser() async {
    try {
      final response = await ApiService.getCurrentUser();
      print('Current user response: $response');

      if (response['user'] != null) {
        final userData = response['user'];
        final role = userData['Role'] ?? userData['role'];

        if (role == 'artisan' || userData['category'] != null) {
          artisan.value = Artisan.fromJson(userData);
          await loadArtisanPosts(artisan.value!.id);
          await loadAvailabilityFromBackend();
          await loadFollowers();
          isVisible.value = artisan.value?.isAvailable ?? true;
        } else if (role == 'client') {
          // FIXED: Convert to int properly
          final userId = userData['ID'] ?? userData['id'];
          if (userId != null) {
            final int clientId = userId is int ? userId : int.tryParse(userId.toString()) ?? 0;
            await loadClientProfile(clientId);
          }
        }
      } else if (response['ID'] != null || response['id'] != null) {
        // FIXED: Convert to int properly
        final userIdDynamic = response['ID'] ?? response['id'];
        final int userId = userIdDynamic is int
            ? userIdDynamic
            : int.tryParse(userIdDynamic.toString()) ?? 0;
        final role = response['Role'] ?? response['role'];

        if (role == 'artisan' || response['category'] != null) {
          await loadArtisanById(userId);
          await loadArtisanPosts(userId);
        }
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  // ============================================================
  // LOAD CLIENT PROFILE (For client viewing their own profile)
  // ============================================================
  Future<void> loadClientProfile(int id) async {
    try {
      final response = await ApiService.getClientProfile(id);
      print('Client profile loaded: $response');
    } catch (e) {
      print('Error loading client profile: $e');
    }
  }

  // ============================================================
  // LOAD ARTISAN BY ID (Public profile view)
  // ============================================================
  Future<void> loadArtisanById(int id) async {
    try {
      isLoading.value = true;
      final response = await ApiService.getArtisanById(id);
      artisan.value = Artisan.fromJson(response);

      await checkFollowingStatus(id);
      await loadArtisanPosts(id);

      if (artisan.value?.availability != null && artisan.value!.availability!.isNotEmpty) {
        availability.value = artisan.value!.availability!;
      } else {
        await loadAvailabilityFromBackend();
      }
    } catch (e) {
      print('Error loading artisan by id: $e');
      Get.snackbar('Erreur', 'Impossible de charger le profil');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD ARTISAN POSTS
  // ============================================================
  Future<void> loadArtisanPosts(int artisanId) async {
    try {
      final allPostsResponse = await ApiService.getPosts();
      final allPosts = (allPostsResponse as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      posts.value = allPosts.where((post) => post.artisanId == artisanId).toList();
    } catch (e) {
      print('Error loading artisan posts: $e');
      posts.value = [];
    }
  }

  // ============================================================
  // LOAD ALL ARTISANS (For search screen)
  // ============================================================
  // ============================================================
// LOAD ALL ARTISANS (For search screen)
// ============================================================
  // ============================================================
// LOAD ALL ARTISANS (For search screen)
// ============================================================
  Future<void> loadAllArtisans() async {
    try {
      isLoading.value = true;
      final List<dynamic> response = await ApiService.getAllArtisans();

      print('Loaded ${response.length} artisans from API');

      // response is already a List from ApiService
      allArtisans.value = response.map((json) => Artisan.fromJson(json)).toList();

      print('Parsed ${allArtisans.length} artisans');
    } catch (e) {
      print('Error loading all artisans: $e');
      allArtisans.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // LOAD AVAILABILITY FROM BACKEND
  // ============================================================
  Future<void> loadAvailabilityFromBackend() async {
    if (artisan.value == null) return;

    try {
      if (artisan.value!.availability != null && artisan.value!.availability!.isNotEmpty) {
        availability.value = artisan.value!.availability!;
      } else {
        _initDefaultAvailability();
      }
    } catch (e) {
      print('Error loading availability: $e');
      _initDefaultAvailability();
    }
  }

  // ============================================================
  // INIT DEFAULT AVAILABILITY
  // ============================================================
  void _initDefaultAvailability() {
    final List<Map<String, dynamic>> weekSchedule = [];
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

      weekSchedule.add({
        'date': date,
        'day': day,
        'month': now.month,
        'year': now.year,
        'available': !isWeekend,
        'note': '',
      });
    }
    availability.value = weekSchedule;
  }

  // ============================================================
  // TOGGLE DAY AVAILABILITY
  // ============================================================
  void toggleDayAvailability(DateTime date) {
    final index = availability.value.indexWhere((day) {
      final dayDate = day['date'] as DateTime;
      return dayDate.year == date.year &&
          dayDate.month == date.month &&
          dayDate.day == date.day;
    });

    if (index != -1) {
      final updatedAvailability = List<Map<String, dynamic>>.from(availability.value);
      updatedAvailability[index]['available'] = !(updatedAvailability[index]['available'] as bool);
      availability.value = updatedAvailability;
      _syncAvailabilityWithBackend();
    }
  }

  // ============================================================
  // UPDATE DAY NOTE
  // ============================================================
  void updateDayNote(DateTime date, String note) {
    final index = availability.value.indexWhere((day) {
      final dayDate = day['date'] as DateTime;
      return dayDate.year == date.year &&
          dayDate.month == date.month &&
          dayDate.day == date.day;
    });

    if (index != -1) {
      final updatedAvailability = List<Map<String, dynamic>>.from(availability.value);
      updatedAvailability[index]['note'] = note;
      availability.value = updatedAvailability;
      _syncAvailabilityWithBackend();
    }
  }

  // ============================================================
  // SYNC AVAILABILITY WITH BACKEND
  // ============================================================
  Future<void> _syncAvailabilityWithBackend() async {
    if (artisan.value == null) return;
    try {
      final availabilityData = availability.value.map((day) {
        return {
          'date': (day['date'] as DateTime).toIso8601String(),
          'available': day['available'],
          'note': day['note'] ?? '',
        };
      }).toList();

      await ApiService.updateArtisan(artisan.value!.id, {
        'availability': availabilityData,
      });
    } catch (e) {
      print('Error syncing availability: $e');
    }
  }

  // ============================================================
  // LOAD FOLLOWERS
  // ============================================================
  Future<void> loadFollowers() async {
    if (artisan.value == null) return;
    try {
      final response = await ApiService.get('/artisans/${artisan.value!.id}/followers');
      if (response is List) {
        followers.value = response.map((f) => {
          'name': f['name'] ?? f['fullName'] ?? 'Client',
          'id': f['id'],
          'avatar': f['avatarUrl'] ?? '',
        }).toList();
      } else {
        _loadMockFollowers();
      }
    } catch (e) {
      print('Error loading followers: $e');
      _loadMockFollowers();
    }
  }

  void _loadMockFollowers() {
    followers.value = [
      {'name': 'Marie Dubois', 'id': 1, 'avatar': ''},
      {'name': 'Pierre Leroy', 'id': 2, 'avatar': ''},
      {'name': 'Sophie Martin', 'id': 3, 'avatar': ''},
    ];
  }

  // ============================================================
  // FOLLOW/UNFOLLOW ARTISAN
  // ============================================================
  Future<void> toggleFollow(int artisanId) async {
    try {
      if (isFollowing.value) {
        await ApiService.delete('/artisans/$artisanId/follow');
        isFollowing.value = false;
        followingCount.value--;
        Get.snackbar('Succès', 'Vous ne suivez plus cet artisan');
      } else {
        await ApiService.post('/artisans/$artisanId/follow', {});
        isFollowing.value = true;
        followingCount.value++;
        Get.snackbar('Succès', 'Vous suivez maintenant cet artisan');
      }
    } catch (e) {
      print('Error toggling follow: $e');
      Get.snackbar('Erreur', 'Impossible de modifier le suivi');
    }
  }

  // ============================================================
  // CHECK FOLLOWING STATUS
  // ============================================================
  Future<void> checkFollowingStatus(int artisanId) async {
    try {
      final response = await ApiService.get('/artisans/$artisanId/is-following');
      isFollowing.value = response['isFollowing'] ?? false;
      followingCount.value = response['followersCount'] ?? 0;
    } catch (e) {
      print('Error checking follow status: $e');
      isFollowing.value = false;
    }
  }

  // ============================================================
  // TOGGLE VISIBILITY
  // ============================================================
  Future<void> toggleVisibility() async {
    if (artisan.value == null) return;

    isVisible.value = !isVisible.value;

    try {
      await ApiService.updateArtisan(artisan.value!.id, {
        'isAvailable': isVisible.value,
        'activesStatus': isVisible.value ? 'active' : 'inactive',
      });

      artisan.value = artisan.value!.copyWith(
        isAvailable: isVisible.value,
        activesStatus: isVisible.value ? 'active' : 'inactive',
      );

      Get.snackbar(
        'Succès',
        isVisible.value ? 'Vous êtes maintenant visible' : 'Vous êtes maintenant invisible',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Error toggling visibility: $e');
      isVisible.value = !isVisible.value;
    }
  }

  // ============================================================
  // CREATE POST
  // ============================================================
  Future<bool> createPost(String content, String? imageUrl) async {
    try {
      isLoading.value = true;

      final artisanId = artisan.value?.id;
      if (artisanId == null) {
        Get.snackbar("Erreur", "Impossible de créer la publication: artisan non trouvé");
        return false;
      }

      final data = {
        'content': content,
        'image': imageUrl ?? '',
        'artisanId': artisanId,
      };

      await ApiService.createPost(data);
      await loadArtisanPosts(artisanId);

      Get.snackbar("Succès", "Publication créée avec succès");
      return true;
    } catch (e) {
      print('Error creating post: $e');
      Get.snackbar("Erreur", "Impossible de créer la publication");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // DELETE POST
  // ============================================================
  Future<bool> deletePost(int postId) async {
    try {
      await ApiService.deletePost(postId);
      posts.removeWhere((p) => p.idPost == postId);
      Get.snackbar("Succès", "Publication supprimée");
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      Get.snackbar("Erreur", "Impossible de supprimer la publication");
      return false;
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    try {
      isLoading.value = true;
      final response = await ApiService.updateArtisan(artisan.value!.id, updates);
      artisan.value = Artisan.fromJson(response);
      Get.snackbar("Succès", "Profil mis à jour");
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      Get.snackbar("Erreur", "Impossible de mettre à jour le profil");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GET QR CODE DATA
  // ============================================================
  String getQrCodeData() {
    if (artisan.value == null) return '';
    return 'artisan:${artisan.value!.id}:${artisan.value!.fullName}';
  }

  // ============================================================
  // CLEAR DATA (On logout)
  // ============================================================
  void clearData() {
    artisan.value = null;
    posts.clear();
    allArtisans.clear();
    availability.clear();
    followers.clear();
    isFollowing.value = false;
    isVisible.value = true;
    selectedCategory.value = '';
    selectedWilaya.value = '';
    searchQuery.value = '';
  }
}