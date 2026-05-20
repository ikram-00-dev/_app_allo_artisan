/// ============================================================
/// SEARCH CONTROLLER
/// CONNECTED DIRECTLY TO ApiService
/// lib/controllers/search_controller.dart
/// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/artisan.dart';
import '../services/api_service.dart';

class SearchController extends GetxController {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController searchController =
  TextEditingController();

  // ============================================================
  // OBSERVABLES
  // ============================================================

  RxBool isLoading = false.obs;

  RxList<Artisan> artisans =
      <Artisan>[].obs;

  RxList<String> selectedCategories =
      <String>[].obs;

  RxDouble rating = 2.0.obs;
  RxDouble distance = 50.0.obs;

  RxBool showFilters = false.obs;
  RxBool showCategoryFilter = false.obs;

  // ============================================================
  // CATEGORIES
  // ============================================================

  final List<String> categories = [
    "Plomberie",
    "Électricité",
    "Menuiserie",
    "Peinture",
    "Maçonnerie",
    "Jardinage",
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    fetchArtisans();
  }

  // ============================================================
  // FETCH ARTISANS FROM BACKEND
  // ============================================================

  Future<void> fetchArtisans() async {
    try {
      isLoading.value = true;

      String endpoint = "/artisans/search?";

      // ========================================================
      // SEARCH QUERY
      // ========================================================

      if (searchController.text.isNotEmpty) {
        endpoint +=
        "query=${searchController.text}&";
      }

      // ========================================================
      // CATEGORIES
      // ========================================================

      if (selectedCategories.isNotEmpty) {
        endpoint +=
        "categories=${selectedCategories.join(",")}&";
      }

      // ========================================================
      // RATING
      // ========================================================

      endpoint +=
      "rating=${rating.value}&";

      // ========================================================
      // DISTANCE
      // ========================================================

      endpoint +=
      "distance=${distance.value}";

      // ========================================================
      // API CALL
      // ========================================================

      final response =
      await ApiService.get(endpoint);

      // ========================================================
      // CONVERT JSON TO MODEL
      // ========================================================

      artisans.value = (response as List)
          .map(
            (json) => Artisan.fromJson(json),
      )
          .toList();

    } catch (e) {
      Get.snackbar(
        "Erreur",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // TOGGLE CATEGORY
  // ============================================================

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }

    fetchArtisans();
  }

  // ============================================================
  // RESET FILTERS
  // ============================================================

  void resetFilters() {
    selectedCategories.clear();

    rating.value = 2;

    distance.value = 50;

    fetchArtisans();
  }
}