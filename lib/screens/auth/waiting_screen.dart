// lib/screens/auth/waiting_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WaitingScreen extends StatelessWidget {
  final Map<String, dynamic>? formData;

  const WaitingScreen({super.key, this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Clock icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule,
                      size: 48,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'En attente de validation',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Votre demande d\'inscription a été enregistrée avec succès.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Next steps information box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prochaines étapes :',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStepItem(
                          icon: Icons.check_circle,
                          text: 'Nos équipes vont vérifier vos documents sous 24 à 48 heures',
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(height: 8),
                        _buildStepItem(
                          icon: Icons.check_circle,
                          text: 'Vous recevrez un email de confirmation une fois votre compte approuvé',
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(height: 8),
                        _buildStepItem(
                          icon: Icons.check_circle,
                          text: 'Vous pourrez alors accéder à toutes les fonctionnalités de la plateforme',
                          color: Colors.blue.shade700,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Warning box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber, size: 20, color: Colors.amber.shade800),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Important : Assurez-vous que vos documents sont lisibles et valides. Tout document frauduleux entraînera le rejet automatique de votre demande.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Return to login button
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retour à la connexion',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildStepItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: color),
          ),
        ),
      ],
    );
  }
}