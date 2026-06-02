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

  final Map<String, String> _verificationCodes = {
    'email': '',
    'phone': '',
  };

  bool _isLoading = false;
  bool _isResending = false;
  bool _requiresEmailVerification = false;
  bool _requiresPhoneVerification = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationRequirements();
  }

  void _checkVerificationRequirements() {
    // Check what needs verification
    if (widget.formData['email'] != null && widget.formData['email'].toString().isNotEmpty) {
      _requiresEmailVerification = true;
    }

    if (widget.formData['phoneNumber'] != null && widget.formData['phoneNumber'].toString().isNotEmpty) {
      _requiresPhoneVerification = true;
    }
  }

  Future<void> _verifyAndRegister() async {
    setState(() => _isLoading = true);

    try {
      if (widget.isArtisan) {
        // For artisan, the account is already created via the registration
        // Just navigate to waiting screen
        Get.off(() => const WaitingScreen(isArtisan: true));
      } else {
        // Proceed with client registration
        final success = await authController.registerClient(
          firstName: widget.formData['firstName'],
          lastName: widget.formData['lastName'],
          username: widget.formData['username'],
          email: widget.formData['email'],
          phoneNumber: widget.formData['phoneNumber'],
          password: widget.formData['password'],
          avatarUrl: widget.formData['avatarUrl'],
        );

        if (success) {
          // Registration and auto-login successful
          Get.offAllNamed('/client-home');
        }
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      _showError('Erreur lors de l\'inscription: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    Get.snackbar("Erreur", message,
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _showSuccess(String message) {
    Get.snackbar("Succès", message,
        backgroundColor: Colors.green, colorText: Colors.white);
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
                      widget.isArtisan ? Icons.assignment_turned_in : Icons.info_outline,
                      size: 48,
                      color: widget.isArtisan ? Colors.amber : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.isArtisan ? 'Demande envoyée' : 'Vérification simplifiée',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isArtisan
                        ? 'Votre demande d\'inscription a été enregistrée avec succès.'
                        : 'Votre compte va être créé avec:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),

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
                        ListTile(
                          leading: const Icon(Icons.person, color: Color(0xFF2563EB)),
                          title: const Text('Nom complet'),
                          subtitle: Text('${widget.formData['firstName']} ${widget.formData['lastName']}'),
                        ),
                        if (widget.isArtisan)
                          ListTile(
                            leading: const Icon(Icons.work, color: Color(0xFF2563EB)),
                            title: const Text('Rôle'),
                            subtitle: const Text('Artisan'),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (!widget.isArtisan)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Note: La vérification par code sera disponible prochainement. Pour l\'instant, votre compte sera créé immédiatement.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!widget.isArtisan) const SizedBox(height: 24),

                  // Create account button for client or Continue button for artisan
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
                      widget.isArtisan ? 'Continuer' : 'Créer mon compte',
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