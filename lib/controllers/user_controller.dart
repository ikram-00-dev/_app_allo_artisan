import 'package:get/get.dart';
import '../services/api_service.dart';

class UserController extends GetxController {
  final ApiService api;

  UserController(this.api);

  var isLoading = false.obs;
  var profile = Rxn<Map<String, dynamic>>();

  Future<void> loadMyProfile() async {
    try {
      isLoading.value = true;

      final res = await ApiService.get("/auth/me");

      profile.value = res;
    } finally {
      isLoading.value = false;
    }
  }
}