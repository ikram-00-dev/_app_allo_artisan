// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import '../admin/admin_panel_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController controller = Get.find<AuthController>();

  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String selectedRole = "client"; // Default role
  bool obscurePassword = true;
  bool isLoading = false;

  String? _redirectRoute;

  final List<Map<String, dynamic>> roles = [
    {'value': 'client', 'label': 'Client', 'icon': Icons.person},
    {'value': 'artisan', 'label': 'Artisan', 'icon': Icons.handyman},
  ];

  @override
  void initState() {
    super.initState();
    // Get redirect route from query parameters
    _redirectRoute = Get.parameters['redirect'];
    debugPrint('Redirect route: $_redirectRoute');
  }

  Future<void> handleLogin() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final email = identifierController.text.trim();
        final password = passwordController.text.trim();

        // Debug prints
        debugPrint('Attempting login with: email="$email", password="$password"');

        // === SPECIAL ADMIN LOGIN ===
        if (email == 'ikram2005@gmail.com' && password == 'ikram2005') {
          debugPrint('✅ Admin login detected');
          await controller.setAdminMode();

          // Check if there's a redirect route
          if (_redirectRoute != null && _redirectRoute!.isNotEmpty) {
            Get.offAllNamed(_redirectRoute!);
          } else {
            Get.offAll(() => const AdminPanelScreen());
          }

          Get.snackbar(
            "Admin",
            "Bienvenue Administrateur",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        // === SPECIAL MODERATOR LOGIN ===
        if (email == 'amiraamira@gmail.com' && password == 'amiraamira') {
          debugPrint('✅ Moderator login detected');
          await controller.setModeratorMode();

          // Check if there's a redirect route
          if (_redirectRoute != null && _redirectRoute!.isNotEmpty) {
            Get.offAllNamed(_redirectRoute!);
          } else {
            Get.offAll(() => const AdminPanelScreen());
          }

          Get.snackbar(
            "Modérateur",
            "Bienvenue Modérateur",
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        // Normal user login
        await controller.login(
          email: email,
          password: password,
          userRole: selectedRole,
        );

        // After successful login, redirect if needed
        // Note: The controller.login already handles navigation,
        // but we check for redirect route to override if necessary
        if (_redirectRoute != null && _redirectRoute!.isNotEmpty) {
          // Small delay to ensure login is fully processed
          Future.delayed(const Duration(milliseconds: 100), () {
            Get.offAllNamed(_redirectRoute!);
          });
        }

      } catch (e) {
        if (mounted) {
          Get.snackbar(
            "Erreur",
            e.toString().replaceFirst('Exception: ', ''),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Reduced vertical padding
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ============================================================
                    // LOGO IMAGE (INSERTED DIRECTLY)
                    // ============================================================
                    Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    // Role Selection (Client & Artisan only - Admin removed)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: roles.map((role) {
                          final isSelected = selectedRole == role['value'];
                          return Expanded(
                            child: InkWell(
                              onTap: () => setState(() => selectedRole = role['value']),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ] : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(role['icon'], size: 18),
                                    const SizedBox(width: 8),
                                    Text(role['label']),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email/Username Field (Blue border)
                    TextFormField(
                      controller: identifierController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Email ou nom d\'utilisateur',

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email ou nom d\'utilisateur';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field (Blue border)
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      onPressed: isLoading ? null : handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Visitor Button
                    OutlinedButton(
                      onPressed: () async {
                        // If there's a redirect route, go there as visitor
                        if (_redirectRoute != null && _redirectRoute!.isNotEmpty) {
                          Get.offAllNamed(_redirectRoute!);
                        } else {
                          Get.offAllNamed(AppRoutes.clientHome);
                        }

                        Get.snackbar(
                          "Mode Visiteur",
                          "Vous naviguez en tant que visiteur",
                          snackPosition: SnackPosition.TOP,
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.grey,
                          colorText: Colors.white,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      ),
                      child: const Text(
                        'Continuer comme visiteur',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Registration Links (Blue color)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Pas de compte ? ',
                          style: TextStyle(color: Color(0xFF737373)),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.registerClient),
                          child: const Text(
                            'Inscription Client',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.registerArtisan),
                        child: const Text(
                          'Inscription Artisan',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}