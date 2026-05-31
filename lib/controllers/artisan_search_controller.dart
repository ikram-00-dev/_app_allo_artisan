// lib/controllers/artisan_search_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/artisan.dart';
import '../services/api_service.dart';

class ArtisanSearchController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  RxBool isLoading = false.obs;
  RxList<Artisan> artisans = <Artisan>[].obs;

  RxString selectedCategory = 'all'.obs;
  RxDouble minRating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchArtisans();
  }

  Future<void> fetchArtisans() async {
    try {
      isLoading.value = true;

      final response = await ApiService.getArtisans(
        category: selectedCategory.value == 'all' ? null : selectedCategory.value,
        search: searchController.text.isEmpty ? null : searchController.text,
        rating: minRating.value > 0 ? minRating.value : null,
      );

      artisans.value = (response as List)
          .map((json) => Artisan.fromJson(json))
          .toList();
    } catch (e) {
      Get.snackbar(
        "Erreur",
        "Impossible de charger les artisans: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    fetchArtisans();
  }

  void updateMinRating(double rating) {
    minRating.value = rating;
    fetchArtisans();
  }

  void resetFilters() {
    selectedCategory.value = 'all';
    minRating.value = 0.0;
    searchController.clear();
    fetchArtisans();
  }
}