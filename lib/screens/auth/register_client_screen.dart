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

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  final RxBool loading = false.obs;

  Future<void> handleRegister() async {
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneNumberController.text.isEmpty) {
      Get.snackbar("Erreur", "Veuillez remplir tous les champs");
      return;
    }

    // Generate username from first and last name if not provided
    final String finalUsername = usernameController.text.isNotEmpty
        ? usernameController.text
        : '${firstNameController.text.toLowerCase()}_${lastNameController.text.toLowerCase()}';

    loading.value = true;

    final success = await authController.registerClient(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      username: finalUsername,
      email: emailController.text,
      password: passwordController.text,
      phoneNumber: phoneNumberController.text,
    );

    loading.value = false;

    if (success) {
      // Show success message and navigate to login
      Get.snackbar(
        "Succès",
        "Compte créé avec succès! Veuillez vous connecter.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      // Navigate to login screen
      Get.offAllNamed('/login');
    }
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

                // FIRST NAME
                _input("Prénom", firstNameController, "Marie"),
                const SizedBox(height: 16),

                // LAST NAME
                _input("Nom", lastNameController, "Martin"),
                const SizedBox(height: 16),

                // USERNAME (OPTIONAL)
                _input("Nom d'utilisateur (optionnel)", usernameController, "marie.martin"),
                const SizedBox(height: 16),

                // EMAIL
                _input("Email", emailController, "marie@email.com",
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                // PASSWORD
                _input("Mot de passe", passwordController, "••••••••", obscure: true),
                const SizedBox(height: 16),

                // PHONE
                _input("Téléphone", phoneNumberController, "+213...",
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 24),

                // BUTTON
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading.value ? null : () => handleRegister(),
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
                        onPressed: () => Get.toNamed('/register-artisan'),
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
        TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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