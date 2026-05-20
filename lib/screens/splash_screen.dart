import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final token = await StorageService.getToken();

      if (token == null || token.isEmpty) {
        _goToLogin();
        return;
      }

      // ✅ CALL BACKEND to get current user
      final user = await ApiService.get("/auth/me");

      // Store user locally and get role
      await StorageService.saveUser(user);

      // Extract role from user object
      final role = user['Role'] ?? user['role'] ?? '';
      await StorageService.saveRole(role.toString().toLowerCase());

      if (!mounted) return;

      // Navigate based on user role (client or artisan only)
      _goToHomeByRole(role.toString().toLowerCase());

    } catch (e) {
      // ❌ token invalid or backend error
      await StorageService.clearToken();

      if (!mounted) return;
      _goToLogin();
    }
  }

  void _goToHomeByRole(String role) {
    if (role == 'artisan') {
      Get.offAllNamed(AppRoutes.artisanHome);
    } else {
      // Default to client home for client, or any other role
      Get.offAllNamed(AppRoutes.clientHome);
    }
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.handyman,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Artisan Connect",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}