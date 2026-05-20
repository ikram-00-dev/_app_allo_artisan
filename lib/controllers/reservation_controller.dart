import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';

class ReservationController extends GetxController {
  var isLoading = false.obs;
  var appointments = <Appointment>[].obs;

  @override
  void onInit() {
    fetchAppointments();
    super.onInit();
  }

  Future<void> fetchAppointments() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getAppointments();
      appointments.value = (response as List)
          .map((e) => Appointment.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> confirm(int id) async {
    try {
      await ApiService.updateAppointmentStatus(id, "confirmed");
      await fetchAppointments();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> cancel(int id) async {
    try {
      await ApiService.updateAppointmentStatus(id, "cancelled");
      await fetchAppointments();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}