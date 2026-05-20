// lib/screens/auth/register_artisan_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterArtisanScreen extends StatefulWidget {
  const RegisterArtisanScreen({super.key});

  @override
  State<RegisterArtisanScreen> createState() => _RegisterArtisanScreenState();
}

class _RegisterArtisanScreenState extends State<RegisterArtisanScreen> {
  final auth = Get.find<AuthController>();
  int step = 1;

  // Form controllers - Updated to match backend fields
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  final province = TextEditingController();  // Wilaya
  final city = TextEditingController();      // Baladeya
  final district = TextEditingController();  // Zone
  final category = TextEditingController();
  final diploma = TextEditingController();
  final experience = TextEditingController(); // Optional

  void next() {
    if (step < 3) {
      setState(() => step++);
    } else {
      submit();
    }
  }

  void back() {
    if (step > 1) {
      setState(() => step--);
    }
  }

  void submit() async {
    // Generate username from first and last name if not provided
    final String finalUsername = username.text.isNotEmpty
        ? username.text
        : '${firstName.text.toLowerCase()}_${lastName.text.toLowerCase()}';

    final success = await auth.registerArtisan(
      firstName: firstName.text,
      lastName: lastName.text,
      username: finalUsername,
      email: email.text,
      password: password.text,
      phoneNumber: phoneNumber.text,
      category: category.text,
      province: province.text,
      city: city.text,
      district: district.text,
      diploma: diploma.text.isNotEmpty ? diploma.text : null,
      experience: experience.text.isNotEmpty ? int.tryParse(experience.text) : null,
    );

    if (success) {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription Artisan")),
      body: Obx(() {
        if (auth.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: step == 1
                    ? step1()
                    : step == 2
                    ? step2()
                    : step3(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (step > 1)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: back,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text("Retour"),
                      ),
                    ),
                  if (step > 1) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: next,
                      child: Text(step == 3 ? "S'inscrire" : "Suivant"),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      }),
    );
  }

  Widget step1() {
    return ListView(
      children: [
        _buildTextField(firstName, "Prénom", Icons.person),
        const SizedBox(height: 12),
        _buildTextField(lastName, "Nom", Icons.person_outline),
        const SizedBox(height: 12),
        _buildTextField(username, "Nom d'utilisateur (optionnel)", Icons.account_circle),
        const SizedBox(height: 12),
        _buildTextField(category, "Catégorie (ex: Plomberie)", Icons.work),
        const SizedBox(height: 12),
        _buildTextField(province, "Wilaya", Icons.location_city),
        const SizedBox(height: 12),
        _buildTextField(city, "Baladeya (Commune)", Icons.location_on),
        const SizedBox(height: 12),
        _buildTextField(district, "Zone", Icons.map),
      ],
    );
  }

  Widget step2() {
    return ListView(
      children: [
        _buildTextField(diploma, "Diplôme / Certification (optionnel)", Icons.school, maxLines: 2),
        const SizedBox(height: 12),
        _buildTextField(experience, "Années d'expérience (optionnel)", Icons.work_history, keyboardType: TextInputType.number),
      ],
    );
  }

  Widget step3() {
    return ListView(
      children: [
        _buildTextField(email, "Email", Icons.email, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildTextField(phoneNumber, "Numéro de téléphone", Icons.phone, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildTextField(password, "Mot de passe", Icons.lock, obscure: true),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscure = false,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}