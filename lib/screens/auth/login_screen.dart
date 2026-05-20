// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController controller = Get.find<AuthController>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String role = "client";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1E40AF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    // =========================
                    // LOGO + TITLE
                    // =========================
                    Column(
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.handyman_rounded,
                            size: 45,
                            color: Color(0xFF2563EB),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          "Welcome to Allo Artisan",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Trouvez l'artisan qu'il vous faut",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // =========================
                    // CARD
                    // =========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),

                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Connexion",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Connectez-vous à votre compte",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B7280),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // =========================
                            // EMAIL
                            // =========================
                            const Text(
                              "Email",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter your email";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "votre@email.com",
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // =========================
                            // PASSWORD
                            // =========================
                            const Text(
                              "Mot de passe",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Enter your password";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "••••••••",
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // =========================
                            // ROLE
                            // =========================
                            const Text(
                              "Type de compte",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF374151),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        role = "client";
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: role == "client"
                                            ? const Color(0xFFEFF6FF)
                                            : Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(14),
                                        border: Border.all(
                                          color: role == "client"
                                              ? const Color(0xFF2563EB)
                                              : const Color(0xFFD1D5DB),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Client",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: role == "client"
                                                ? const Color(0xFF2563EB)
                                                : const Color(0xFF374151),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        role = "artisan";
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: role == "artisan"
                                            ? const Color(0xFFEFF6FF)
                                            : Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(14),
                                        border: Border.all(
                                          color: role == "artisan"
                                              ? const Color(0xFF2563EB)
                                              : const Color(0xFFD1D5DB),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Artisan",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: role == "artisan"
                                                ? const Color(0xFF2563EB)
                                                : const Color(0xFF374151),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // =========================
                            // LOGIN BUTTON
                            // =========================
                            Obx(
                                  () => SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () async {
                                    if (!formKey.currentState!
                                        .validate()) {
                                      return;
                                    }

                                    await controller.login(
                                      email:
                                      emailController.text.trim(),
                                      password:
                                      passwordController.text.trim(),
                                      userRole: role,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    const Color(0xFF2563EB),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                      : const Text(
                                    "Se connecter",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // =========================
                            // VISITOR BUTTON
                            // =========================
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await controller.login(
                                    email: "visitor@app.com",
                                    password: "visitor",
                                    userRole: "visitor",
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                  const Color(0xFFF3F4F6),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Continuer comme visiteur",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // =========================
                            // FOOTER
                            // =========================
                            Container(
                              padding: const EdgeInsets.only(top: 22),
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: [
                                    const Text(
                                      "Pas encore de compte ? ",
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.registerClient,
                                        );
                                      },
                                      child: const Text(
                                        "Inscription client",
                                        style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const Text(
                                      " ou ",
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.registerArtisan,
                                        );
                                      },
                                      child: const Text(
                                        "Devenir artisan",
                                        style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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