import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/artisan_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class CreatePostScreen extends StatefulWidget {
  final bool isUrgent;

  const CreatePostScreen({
    super.key,
    this.isUrgent = false,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ArtisanController artisanController = Get.find<ArtisanController>();
  final AuthController authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();

  String _selectedCategory = 'Plomberie';
  bool _isLoading = false;

  final List<Map<String, String>> categories = [
    {'name': 'Plomberie', 'icon': '🔧'},
    {'name': 'Électricité', 'icon': '⚡'},
    {'name': 'Menuiserie', 'icon': '🪚'},
    {'name': 'Peinture', 'icon': '🎨'},
    {'name': 'Maçonnerie', 'icon': '🧱'},
    {'name': 'Jardinage', 'icon': '🌿'},
    {'name': 'Climatisation', 'icon': '❄️'},
    {'name': 'Carrelage', 'icon': '📐'},
    {'name': 'Plâtrerie', 'icon': '🏠'},
    {'name': 'Soudure', 'icon': '🔥'},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String content;

        if (widget.isUrgent) {
          // Format urgent demand with all details
          content = '''
🔴 DEMANDE URGENTE 🔴

📂 Catégorie: $_selectedCategory
📝 Titre: ${_titleController.text}
📋 Description: ${_contentController.text}
💰 Budget: ${_minBudgetController.text} DA - ${_maxBudgetController.text} DA

⚠️ Tous les artisans actifs de cette catégorie seront notifiés immédiatement.
''';
        } else {
          // Normal post content
          content = _contentController.text;
        }

        // Create post using your existing ArtisanController
        final success = await artisanController.createPost(content, null);

        if (success && mounted) {
          Get.snackbar(
            'Succès',
            widget.isUrgent
                ? '✅ Demande urgente publiée! Les artisans seront notifiés.'
                : '✅ Publication publiée avec succès!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // Navigate back and refresh
          Get.back();
          Get.back(); // Close both dialogs if needed
        }
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de publier: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClient = authController.isClient;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isUrgent
              ? 'Demande urgente'
              : (isClient ? 'Créer une demande' : 'Partager votre travail'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============================================================
              // URGENT DEMAND FIELDS
              // ============================================================
              if (widget.isUrgent) ...[
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Catégorie *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category['name'],
                      child: Text('${category['icon']} ${category['name']}'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                  validator: (value) =>
                  value == null ? 'Veuillez sélectionner une catégorie' : null,
                ),
                const SizedBox(height: 16),

                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre du problème *',
                    hintText: 'Ex: Fuite d\'eau urgente',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // ============================================================
              // DESCRIPTION FIELD (for both types)
              // ============================================================
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: widget.isUrgent ? 'Description *' : 'Votre message *',
                  hintText: widget.isUrgent
                      ? 'Décrivez votre problème en détail...'
                      : (isClient
                      ? 'Décrivez votre besoin...'
                      : 'Partagez vos réalisations, conseils...'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return widget.isUrgent
                        ? 'Veuillez décrire votre problème'
                        : 'Veuillez entrer votre message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ============================================================
              // BUDGET FIELDS (only for urgent)
              // ============================================================
              if (widget.isUrgent) ...[
                const Text(
                  'Budget estimé',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minBudgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Min (DA)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Budget min requis';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxBudgetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Max (DA)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Budget max requis';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // ============================================================
              // PHOTO UPLOAD SECTION (optional for both)
              // ============================================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Photos (optionnel)'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement image picker
                        Get.snackbar(
                          'Info',
                          'Fonctionnalité à venir: Ajout de photos',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      },
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, color: Colors.grey),
                              SizedBox(height: 4),
                              Text('Ajouter des photos', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.isUrgent) const SizedBox(height: 16),

              // ============================================================
              // WARNING MESSAGE (only for urgent)
              // ============================================================
              if (widget.isUrgent)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Information importante',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Tous les artisans actifs de cette catégorie seront notifiés immédiatement',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Votre demande apparaîtra dans la section "Demandes urgentes"',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Les artisans pourront vous contacter directement',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // ============================================================
              // SUBMIT BUTTON
              // ============================================================
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isUrgent
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  widget.isUrgent
                      ? '📢 Publier ma demande urgente'
                      : (isClient ? '📝 Publier ma demande' : '📷 Partager mon travail'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}