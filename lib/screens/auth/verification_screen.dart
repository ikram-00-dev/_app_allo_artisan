// lib/screens/auth/verification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'waiting_screen.dart';

class VerificationScreen extends StatefulWidget {
  final Map<String, dynamic> formData;
  final bool isArtisan;

  const VerificationScreen({
    super.key,
    required this.formData,
    this.isArtisan = false,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final authController = Get.find<AuthController>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _debugPrintFormData();
  }

  void _debugPrintFormData() {
    debugPrint('========== VERIFICATION SCREEN DATA ==========');
    debugPrint('isArtisan: ${widget.isArtisan}');
    debugPrint('formData keys: ${widget.formData.keys}');
    debugPrint('formData: ${widget.formData}');

    debugPrint('firstName: ${widget.formData['firstName']}');
    debugPrint('lastName: ${widget.formData['lastName']}');
    debugPrint('email: ${widget.formData['email']}');
    debugPrint('phoneNumber: ${widget.formData['phoneNumber']}');
  }

  Future<void> _verifyAndRegister() async {
    setState(() => _isLoading = true);

    try {
      if (widget.isArtisan) {
        debugPrint('📝 Registering artisan...');

        final success = await authController.registerArtisan(
          firstName: widget.formData['firstName']?.toString() ?? '',
          middleName: widget.formData['middleName']?.toString(),
          lastName: widget.formData['lastName']?.toString() ?? '',
          username: widget.formData['username']?.toString() ?? '',
          email: widget.formData['email']?.toString() ?? '',
          phoneNumber: widget.formData['phoneNumber']?.toString() ?? '',
          password: widget.formData['password']?.toString() ?? '',
          category: widget.formData['category']?.toString() ?? '',
          province: widget.formData['province']?.toString() ?? '',
          city: widget.formData['city']?.toString() ?? '',
          district: widget.formData['district']?.toString() ?? '',
          avatarUrl: widget.formData['avatarUrl']?.toString(),
          diplomaUrl: widget.formData['diplomaUrl']?.toString(),
          officialDocUrl: widget.formData['officialDocUrl']?.toString(),
          experience: widget.formData['experience'] != null
              ? int.tryParse(widget.formData['experience'].toString())
              : null,
        );

        if (success) {
          debugPrint('✅ Artisan registration successful, navigating to waiting screen');
          // The AuthController already navigates to waiting screen
          // So we don't need to do anything here
        } else {
          _showError('Échec de l\'inscription. Veuillez réessayer.');
        }
      } else {
        debugPrint('📝 Registering client...');

        final email = widget.formData['email']?.toString() ?? '';
        final phoneNumber = widget.formData['phoneNumber']?.toString() ?? '';

        if (email.isEmpty && phoneNumber.isEmpty) {
          _showError('Veuillez fournir un email ou un numéro de téléphone');
          setState(() => _isLoading = false);
          return;
        }

        final success = await authController.registerClient(
          firstName: widget.formData['firstName']?.toString() ?? '',
          middleName: widget.formData['middleName']?.toString(),
          lastName: widget.formData['lastName']?.toString() ?? '',
          username: widget.formData['username']?.toString() ?? '',
          email: email.isNotEmpty ? email : null,
          phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
          password: widget.formData['password']?.toString() ?? '',
          avatarUrl: widget.formData['avatarUrl']?.toString(),
        );

        if (success) {
          debugPrint('✅ Client registration successful');
          // AuthController will handle navigation to client home
        } else {
          _showError('Échec de l\'inscription. Veuillez réessayer.');
        }
      }
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      _showError('Erreur lors de l\'inscription: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Erreur",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(widget.isArtisan ? 'Inscription Artisan' : 'Confirmation'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: widget.isArtisan ? Colors.amber.shade100 : Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isArtisan ? Icons.assignment_turned_in : Icons.check_circle,
                      size: 48,
                      color: widget.isArtisan ? Colors.amber : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.isArtisan ? 'Vérification des informations' : 'Confirmation',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isArtisan
                        ? 'Vérifiez vos informations avant de soumettre votre demande:'
                        : 'Vérifiez vos informations avant validation:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Display info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person, color: Color(0xFF2563EB)),
                          title: const Text('Nom complet'),
                          subtitle: Text('${widget.formData['firstName']} ${widget.formData['lastName']}'),
                        ),
                        if (widget.formData['email'] != null && widget.formData['email'].toString().isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.email, color: Color(0xFF2563EB)),
                            title: const Text('Email'),
                            subtitle: Text(widget.formData['email']),
                          ),
                        if (widget.formData['phoneNumber'] != null && widget.formData['phoneNumber'].toString().isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.phone, color: Color(0xFF2563EB)),
                            title: const Text('Téléphone'),
                            subtitle: Text(widget.formData['phoneNumber']),
                          ),
                        if (widget.isArtisan)
                          ListTile(
                            leading: const Icon(Icons.work, color: Color(0xFF2563EB)),
                            title: const Text('Catégorie'),
                            subtitle: Text(widget.formData['category'] ?? ''),
                          ),
                        if (widget.isArtisan)
                          ListTile(
                            leading: const Icon(Icons.location_on, color: Color(0xFF2563EB)),
                            title: const Text('Localisation'),
                            subtitle: Text('${widget.formData['city']}, ${widget.formData['province']}'),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info message for artisans
                  if (widget.isArtisan)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Votre demande sera examinée par un administrateur. Vous recevrez une notification par email une fois votre compte approuvé.',
                              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Create account button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyAndRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isArtisan ? Colors.amber : const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
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
                      widget.isArtisan ? 'Envoyer la demande' : 'Créer mon compte',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}