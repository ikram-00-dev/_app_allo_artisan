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

      debugPrint('Splash: Token found = ${token != null}');

      if (token == null || token.isEmpty) {
        debugPrint('Splash: No token, going to login');
        _goToLogin();
        return;
      }

      // Try to verify token by getting current user
      try {
        final user = await ApiService.getCurrentUser();
        debugPrint('Splash: User verified = $user');

        if (user != null) {
          // Store user and role
          await StorageService.saveUser(user);
          final role = user['Role'] ?? user['role'] ?? '';
          await StorageService.saveRole(role.toString().toLowerCase());

          if (!mounted) return;
          _goToHomeByRole(role.toString().toLowerCase());
        } else {
          // Invalid user data, clear and go to login
          await StorageService.clearToken();
          _goToLogin();
        }
      } catch (e) {
        // Token is invalid or expired
        debugPrint('Splash: Token validation failed: $e');
        await StorageService.clearToken();
        _goToLogin();
      }
    } catch (e) {
      debugPrint('Splash: Error: $e');
      _goToLogin();
    }
  }

  void _goToHomeByRole(String role) {
    debugPrint('Splash: Navigating to home for role: $role');
    if (role == 'artisan') {
      Get.offAllNamed(AppRoutes.artisanHome);
    } else {
      Get.offAllNamed(AppRoutes.clientHome);
    }
  }

  void _goToLogin() {
    debugPrint('Splash: Navigating to login');
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