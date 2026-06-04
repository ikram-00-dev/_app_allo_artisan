// lib/core/widgets/share_post_modal.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/post_controller.dart';
import '../../controllers/auth_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class SharePostModal extends StatefulWidget {
  final VoidCallback? onPostCreated;

  const SharePostModal({super.key, this.onPostCreated});

  @override
  State<SharePostModal> createState() => _SharePostModalState();
}

class _SharePostModalState extends State<SharePostModal> {
  final PostController postController = Get.find<PostController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isUploadingImage = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Upload image to get URL
        setState(() => _isUploadingImage = true);
        try {
          final imageUrl = await ApiService.uploadImage(pickedFile.path);
          postController.setPostImage(imageUrl);
        } catch (e) {
          debugPrint('Error uploading image: $e');
          Get.snackbar('Erreur', 'Impossible de télécharger l\'image');
        } finally {
          setState(() => _isUploadingImage = false);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
    postController.setPostImage(null);
  }

  @override
  void dispose() {
    descriptionController.dispose();
    postController.clearNewPost();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.add_photo_alternate, size: 28, color: Color(0xFF2563EB)),
                const SizedBox(width: 12),
                const Text(
                  'Partager votre travail',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Artisan Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF2563EB),
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getFullName(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Artisan',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Actif', style: TextStyle(fontSize: 10, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description Field
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre projet...',
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Image Upload Section
            Obx(() => Container(
              height: postController.postImage.value != null ? 200 : 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: _isUploadingImage
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text("Téléchargement..."),
                  ],
                ),
              )
                  : postController.postImage.value != null
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      postController.postImage.value!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
                  : Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      const Text(
                        "Ajouter une photo",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const Text(
                        "JPG, PNG - Max 5MB",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            )),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: postController.isCreating.value || descriptionController.text.trim().isEmpty
                        ? null
                        : () => _handleCreatePost(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: postController.isCreating.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Partager', style: TextStyle(color: Colors.white)),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final user = authController.user.value;
    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    final username = user?['username'] ?? user?['Username'] ?? 'Artisan';
    if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'A';
  }

  String _getFullName() {
    final user = authController.user.value;
    final firstName = user?['firstName'] ?? '';
    final lastName = user?['lastName'] ?? '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    return user?['username'] ?? user?['Username'] ?? 'Artisan';
  }

  Future<void> _handleCreatePost() async {
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez ajouter une description',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await postController.createPost(
      descriptionController.text.trim(),
      postController.postImage.value,
    );

    if (success) {
      descriptionController.clear();
      Get.back();

      Get.snackbar(
        'Succès',
        'Votre publication a été partagée !',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to private profile
      widget.onPostCreated?.call();
    }
  }
}

