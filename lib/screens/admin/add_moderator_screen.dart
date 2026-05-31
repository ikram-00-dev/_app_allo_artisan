// lib/screens/admin/add_moderator_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';

class AddModeratorScreen extends StatefulWidget {
  const AddModeratorScreen({super.key});

  @override
  State<AddModeratorScreen> createState() => _AddModeratorScreenState();
}

class _AddModeratorScreenState extends State<AddModeratorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final Map<String, TextEditingController> controllers = {
    'firstName': TextEditingController(),
    'middleName': TextEditingController(),
    'lastName': TextEditingController(),
    'username': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'phoneNumber': TextEditingController(),
    'avatarUrl': TextEditingController(),
  };

  Future<void> createModerator() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await ApiService.post('/auth/register/moderator', {
        'firstName': controllers['firstName']!.text.trim(),
        'middleName': controllers['middleName']!.text.trim(),
        'lastName': controllers['lastName']!.text.trim(),
        'username': controllers['username']!.text.trim(),
        'email': controllers['email']!.text.trim(),
        'password': controllers['password']!.text,
        'phoneNumber': controllers['phoneNumber']!.text.trim(),
        'avatarUrl': controllers['avatarUrl']!.text.trim(),
      });

      Get.snackbar(
        "Succès",
        "Modérateur créé avec succès !",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      Get.back();
    } catch (e) {
      Get.snackbar("Erreur", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un Modérateur"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.person_add_alt_1, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Création de Compte Modérateur",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              _buildTextField("Prénom", controllers['firstName']!, isRequired: true),
              _buildTextField("Deuxième Prénom", controllers['middleName']!),
              _buildTextField("Nom de Famille", controllers['lastName']!, isRequired: true),
              _buildTextField("Nom d'utilisateur", controllers['username']!, isRequired: true),
              _buildTextField("Email", controllers['email']!, isRequired: true, keyboardType: TextInputType.emailAddress),
              _buildTextField("Mot de passe", controllers['password']!, isRequired: true, obscureText: true),
              _buildTextField("Numéro de Téléphone", controllers['phoneNumber']!),
              _buildTextField("URL de l'Avatar (optionnel)", controllers['avatarUrl']!),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : createModerator,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Créer le Modérateur",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        bool isRequired = false,
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: isRequired
            ? (value) => value == null || value.trim().isEmpty ? '$label est requis' : null
            : null,
      ),
    );
  }
}