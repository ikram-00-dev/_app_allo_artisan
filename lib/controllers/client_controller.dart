import 'package:get/get.dart';
import '../services/api_service.dart';

class ClientController extends GetxController {
  final ApiService api;

  ClientController(this.api);

  var isLoading = false.obs;
  var clients = <dynamic>[].obs;

  Future<void> fetchClients() async {
    try {
      isLoading.value = true;

      final res = await ApiService.get("/clients");

      clients.value = res;
    } finally {
      isLoading.value = false;
    }
  }
}