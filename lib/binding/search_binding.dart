import 'package:get/get.dart';
import '../controllers/artisan_search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArtisanSearchController>(() => ArtisanSearchController());
  }
}