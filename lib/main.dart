import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'binding/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlloArtisanApp());
}

class AlloArtisanApp extends StatelessWidget {
  const AlloArtisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Allo Artisan",
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash, // ← MUST be splash, not login or home
      getPages: AppPages.pages,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}