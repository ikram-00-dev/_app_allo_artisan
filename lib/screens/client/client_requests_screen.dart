// client_requests_screen.dart - REDESIGNED VERSION (matching React design)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/request_controller.dart';
import '../../models/request_model.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({super.key});

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  final AuthController authController = Get.find<AuthController>();
  final RequestController requestController = Get.find<RequestController>();
  final TextEditingController _editDescriptionController = TextEditingController();

  bool _showEditModal = false;
  RequestModel? _editingRequest;
  String _editCategory = '';
  String _editDescription = '';
  bool _editIsUrgent = false;
  String _editZone = '';
  bool _isEditSubmitting = false;
  File? _editImage;
  bool _removeExistingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final user = authController.user.value;
    final clientId = user?['id'] ?? user?['clientId'] ?? user?['ID'];
    if (clientId != null && clientId is int) {
      await requestController.loadMyRequests(clientId);
    }
  }

  // Update the status methods - SIMPLIFIED
  String _getStatusLabel(String status, bool isActive) {
    if (isActive) {
      return 'ACTIVE';
    } else {
      return 'INACTIVE';
    }
  }

  Color _getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.red;
  }

  Future<void> _deleteRequest(int id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer la demande'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette demande ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Non')),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await requestController.deleteRequest(id);
      await _loadRequests();
    }
  }

  void _openEditModal(RequestModel request) {
    setState(() {
      _editingRequest = request;
      _editCategory = request.category;
      _editDescription = request.description;
      _editIsUrgent = request.isUrgent;
      _editZone = (request.zoneKm != null && request.zoneKm! > 0)
          ? request.zoneKm.toString()
          : '';
      _editImage = null;
      _removeExistingImage = false;
      _showEditModal = true;

      _editDescriptionController.text = request.description;
    });
  }

  Future<void> _pickEditImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _editImage = File(pickedFile.path);
          _removeExistingImage = false; // Don't remove existing when picking new
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _removeEditImage() {
    setState(() {
      _editImage = null;
      _removeExistingImage = true;
    });
  }

  Future<void> _handleEditSubmit() async {
    if (_editDescription.trim().isEmpty) {
      Get.snackbar('Erreur', 'Veuillez entrer une description',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (_editIsUrgent && _editZone.isEmpty) {
      Get.snackbar('Erreur', 'La zone est obligatoire pour une demande urgente',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isEditSubmitting = true);

    try {
      final success = await requestController.updateRequest(
        _editingRequest!.idRequest!,
        description: _editDescription,
        category: _editCategory,
        isUrgent: _editIsUrgent,
        zoneKm: _editIsUrgent ? int.tryParse(_editZone) : null,
        imagePath: _editImage?.path,
        removeImage: _removeExistingImage && _editImage == null,
      );

      if (success) {
        setState(() {
          _showEditModal = false;
          _editingRequest = null;
          _editImage = null;
          _removeExistingImage = false;
        });
        await _loadRequests();
      }
    } catch (e) {
      print('Error in edit submit: $e');
      Get.snackbar('Erreur', 'Impossible de modifier la demande',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _isEditSubmitting = false);
    }
  }

  String _formatDateSafe(DateTime? date) {
    if (date == null) {
      return 'Date inconnue';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    // Handle future dates (should not happen but safety)
    if (difference.inDays < 0) {
      return 'À l\'instant';
    }

    if (difference.inDays > 30) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Demandes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.offAllNamed(AppRoutes.clientHome),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Obx(() {
            if (requestController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (requestController.myRequests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, size: 32, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text('Aucune demande', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text(
                      'Cliquez sur "Partager une demande" pour commencer',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requestController.myRequests.length,
                itemBuilder: (context, index) {
                  final req = requestController.myRequests[index];
                  final isUrgent = req.isUrgent;
                  final status = req.status;
                  final borderColor = isUrgent ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with badges
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Urgency badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isUrgent ? 'URGENTE' : 'NORMALE',
                                  style: TextStyle(
                                    color: isUrgent ? Colors.red.shade600 : Colors.blue.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: req.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  req.displayStatus,
                                  style: TextStyle(
                                    color: req.displayStatusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Image - FIXED
                        // Image - IMPROVED VERSION
                        if (req.imageUrl != null && req.imageUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                ApiService.getFileUrl(req.imageUrl!),   // ← This is the fix
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey)
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade100,
                                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                },
                              ),
                            ),
                          ),

                        const Divider(height: 1, color: Color(0xFFF3F4F6)),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.category,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue.shade600),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                req.description,
                                style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF374151)),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),

                              // Zone + Time - FIXED
                              // Zone + Time - FIXED to only show zone if > 0
                              Row(
                                children: [
                                  if (req.zoneKm != null && req.zoneKm! > 0) ...[
                                    const Icon(Icons.location_on, size: 14,color: Color(0xFF9CA3AF)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${req.zoneKm} km',
                                      style: TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateSafe(req.createdAt),
                                    style: TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                ],
                              ),
                              // Accepted message
                              if (status == 'accepted')
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check, size: 10, color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Accepté par un artisan',
                                            style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Action buttons
                        // Action buttons (updated with reactivate button)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              // Edit button - only show if not expired OR if accepted
                              if (req.isActive)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openEditModal(req),
                                    icon: Icon(Icons.edit_outlined, size: 18, color: Colors.blue.shade600),
                                    label: Text('Modifier', style: TextStyle(color: Colors.blue.shade600)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: BorderSide(color: Colors.blue.shade600, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 12), // This creates space between buttons

                              // Reactivate button - show if expired and not accepted
                              if (req.canBeActivated)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _reactivateRequest(req.idRequest!),
                                    icon: Icon(Icons.refresh, size: 18, color: Colors.green.shade600),
                                    label: Text('Réactiver', style: TextStyle(color: Colors.green.shade600)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      side: BorderSide(color: Colors.green.shade600, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),

                              // Add spacing if both buttons are visible
                              if (req.canBeActivated)                                const SizedBox(width: 12),

                              // Delete button - always show
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: requestController.isDeleting.value
                                      ? null
                                      : () => _deleteRequest(req.idRequest!),
                                  icon: requestController.isDeleting.value
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      : Icon(Icons.delete_outline, size: 18, color: Colors.red.shade500),
                                  label: Text('Supprimer', style: TextStyle(color: Colors.red.shade500)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: Colors.red.shade500, width: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),

          // Edit Modal
          if (_showEditModal && _editingRequest != null) _buildEditModal(),
        ],
      ),
    );
  }

  // Replace the _buildEditModal method in client_requests_screen.dart
  Widget _buildEditModal() {
    if (!_showEditModal || _editingRequest == null) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header (unchanged)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.edit_note, color: Colors.blue.shade700, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Modifier la demande',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _editingRequest!.isUrgent ? 'Demande urgente' : 'Demande normale',
                              style: TextStyle(fontSize: 12, color: _editingRequest!.isUrgent ? Colors.red.shade600 : Colors.blue.shade600),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showEditModal = false),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),

                // Body
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      _buildImageSection(),
                      const SizedBox(height: 16),

                      // Category
                      _buildDropdownCategory(),
                      const SizedBox(height: 12),

                      // === FIXED ZONE DROPDOWN ===
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<int?>(
                          value: _getValidZoneValue(), // ← FIXED HERE
                          isExpanded: true,
                          hint: const Text('Sélectionner une zone (km)'),
                          decoration: const InputDecoration(
                            hintText: 'Zone de recherche (km)',
                            labelText: 'Zone (km)',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: InputBorder.none,
                          ),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Pas de zone spécifique')),
                            DropdownMenuItem(value: 5, child: Text('5 km')),
                            DropdownMenuItem(value: 10, child: Text('10 km')),
                            DropdownMenuItem(value: 20, child: Text('20 km')),
                            DropdownMenuItem(value: 30, child: Text('30 km')),
                            DropdownMenuItem(value: 40, child: Text('40 km')),
                            DropdownMenuItem(value: 50, child: Text('50 km')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _editZone = value?.toString() ?? '';
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _editDescriptionController,
                          onChanged: (value) => _editDescription = value,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Description de votre besoin...',
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() => _showEditModal = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey.shade400, width: 1),
                              ),
                              child: const Text('Annuler', style: TextStyle(color: Color(0xFF374151), fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isEditSubmitting ? null : _handleEditSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isEditSubmitting
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                          ),
                        ],
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
  int? _getValidZoneValue() {
    if (_editZone.isEmpty) return null;

    final parsed = int.tryParse(_editZone);
    if (parsed == null || parsed == 0) return null;

    // Only return value if it's in the allowed list
    const allowed = {5, 10, 20, 30, 40, 50};
    return allowed.contains(parsed) ? parsed : null;
  }

// Remove the _buildUrgencyAndZone method entirely since we're not using the type toggle

  Widget _buildImageSection() {
    final hasExistingImage = _editingRequest?.imageUrl != null &&
        _editingRequest!.imageUrl!.isNotEmpty &&
        !_removeExistingImage &&
        _editImage == null;

    final hasNewImage = _editImage != null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Show existing image
          if (hasExistingImage)
            Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        'http://192.168.1.36:8081${_editingRequest!.imageUrl!}',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeEditImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: const Center(
                    child: Text(
                      'Image actuelle',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ],
            ),

          // Show new image
          if (hasNewImage)
            Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.file(
                        _editImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeEditImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: const Center(
                    child: Text(
                      'Nouvelle image sélectionnée',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ],
            ),

          // Show add photo placeholder if no image
          if ((_editingRequest?.imageUrl == null ||
              _editingRequest!.imageUrl!.isEmpty ||
              _removeExistingImage) &&
              _editImage == null)
            GestureDetector(
              onTap: _pickEditImage,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 28, color: Color(0xFF6B7280)),
                      SizedBox(height: 4),
                      Text(
                        'Ajouter une photo',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Show change image button if image exists
          if ((hasExistingImage || hasNewImage))
            GestureDetector(
              onTap: _pickEditImage,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: const Center(
                  child: Text(
                    'Changer l\'image',
                    style: TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  Future<void> _reactivateRequest(int requestId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Réactiver la demande'),
        content: const Text('Cette demande sera à nouveau visible par les artisans comme une nouvelle demande. Voulez-vous continuer?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Non')),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await requestController.reactivateRequest(requestId);
      await _loadRequests();
    }
  }
  Widget _buildDropdownCategory() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: _editCategory,
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: InputBorder.none,
          ),
          items: requestController.categories.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (value) => setState(() => _editCategory = value!),
        ),
      ),
    );
  }


}