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

  // Form controllers
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  final wilaya = TextEditingController();
  final baladya = TextEditingController();
  final category = TextEditingController();
  final diploma = TextEditingController();
  final bio = TextEditingController();
  final zone = TextEditingController();

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
    final success = await auth.registerArtisan(
      firstName: firstName.text,
      lastName: lastName.text,
      email: email.text,
      password: password.text,
      phone: phone.text,
      category: category.text,
      wilaya: wilaya.text,
      baladeya: baladya.text,
      zone: zone.text,
      diploma: diploma.text,
      bio: bio.text,
    );

    if (success) {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Artisan")),
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
                        child: const Text("Back"),
                      ),
                    ),
                  if (step > 1) const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: next,
                      child: Text(step == 3 ? "Submit" : "Next"),
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
        _buildTextField(firstName, "First Name", Icons.person),
        const SizedBox(height: 12),
        _buildTextField(lastName, "Last Name", Icons.person_outline),
        const SizedBox(height: 12),
        _buildTextField(category, "Category (e.g., Plomberie)", Icons.work),
        const SizedBox(height: 12),
        _buildTextField(wilaya, "Wilaya (City)", Icons.location_city),
        const SizedBox(height: 12),
        _buildTextField(baladya, "Baladeya (District)", Icons.location_on),
        const SizedBox(height: 12),
        _buildTextField(zone, "Zone", Icons.map),
      ],
    );
  }

  Widget step2() {
    return ListView(
      children: [
        _buildTextField(diploma, "Diploma / Certification", Icons.school, maxLines: 2),
        const SizedBox(height: 12),
        _buildTextField(bio, "Bio / Description", Icons.description, maxLines: 4),
      ],
    );
  }

  Widget step3() {
    return ListView(
      children: [
        _buildTextField(email, "Email", Icons.email, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildTextField(phone, "Phone Number", Icons.phone, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildTextField(password, "Password", Icons.lock, obscure: true),
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