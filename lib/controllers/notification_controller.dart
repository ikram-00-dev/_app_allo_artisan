import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/notification.dart';

class NotificationController extends GetxController {
  final ApiService api;

  NotificationController({ApiService? api})
      : api = api ?? ApiService();

  // ======================
  // STATE
  // ======================
  var isLoading = false.obs;
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  // ======================
  // GET ALL NOTIFICATIONS
  // ======================
  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;

      final res = await ApiService.get("/notifications");

      notifications.value = (res as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de charger les notifications");
    } finally {
      isLoading.value = false;
    }
  }

  // ======================
  // MARK AS READ
  // ======================
  Future<void> markAsRead(int id) async {
    try {
      await ApiService.put("/notifications/$id/read", {});

      notifications.value = notifications.map((n) {
        if (n.idNotif == id) {
          return NotificationModel(
            idNotif: n.idNotif,
            content: n.content,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de marquer comme lu");
    }
  }

  // ======================
  // MARK ALL AS READ
  // ======================
  Future<void> markAllAsRead() async {
    try {
      await ApiService.put("/notifications/read-all", {});

      notifications.value = notifications
          .map((n) => NotificationModel(
        idNotif: n.idNotif,
        content: n.content,
        isRead: true,
        createdAt: n.createdAt,
      ))
          .toList();
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de tout marquer comme lu");
    }
  }
}