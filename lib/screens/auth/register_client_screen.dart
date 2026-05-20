import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final AuthController authController = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final RxBool loading = false.obs;

  Future<void> handleRegister() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    loading.value = true;

    await authController.registerClient(
      username: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phone: phoneController.text,
    );

    loading.value = false;

    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Créer un compte client",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Rejoignez Allo Artisan pour trouver les meilleurs artisans",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // NAME
                _input("Nom complet", nameController, "Marie Martin"),

                const SizedBox(height: 16),

                // EMAIL
                _input("Email", emailController, "marie@email.com"),

                const SizedBox(height: 16),

                // PASSWORD
                _input("Mot de passe", passwordController, "••••••••",
                    obscure: true),

                const SizedBox(height: 16),

                // PHONE
                _input("Téléphone", phoneController, "+213..."),

                const SizedBox(height: 24),

                // BUTTON
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                      loading.value ? null : () => handleRegister(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        loading.value ? "Inscription..." : "Créer mon compte",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 10),

                Center(
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () => Get.toNamed('/login'),
                        child: const Text("Déjà un compte ? Se connecter"),
                      ),
                      TextButton(
                        onPressed: () =>
                            Get.toNamed('/register/artisan'),
                        child: const Text("Vous êtes artisan ? Inscription artisan"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
      String label,
      TextEditingController controller,
      String hint, {
        bool obscure = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}