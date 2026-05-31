// lib/screens/admin/admin_panel_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isAdmin = authController.role.value == 'admin';
    final userEmail = authController.user.value?['email'] ?? 'ikram2005@gmail.com';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? "Panneau d'Administration" : "Panneau Modérateur"),
        backgroundColor: Colors.blue.shade900,
        centerTitle: true,
        elevation: 0,
        // Add back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _showLogoutConfirmationDialog(context),
          tooltip: 'Se déconnecter',
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdmin ? "Bienvenue, Administrateur" : "Bienvenue, Modérateur",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),

              const Text(
                "Gestion Principale",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueGrey),
              ),
              const SizedBox(height: 16),

              // Artisans en Attente - with approve/reject buttons
              _buildDashboardCardWithActions(
                title: "Artisans en Attente",
                subtitle: "Vérifier et approuver les nouveaux artisans",
                icon: Icons.pending_actions,
                color: Colors.orange,
                onTap: () => _showPendingArtisansDialog(context),
              ),
              const SizedBox(height: 12),

              // Rapports & Signalements - with validate/reject buttons
              _buildDashboardCardWithActions(
                title: "Rapports & Signalements",
                subtitle: "Voir et gérer les signalements",
                icon: Icons.report_problem,
                color: Colors.red,
                onTap: () => _showReportsDialog(context),
              ),
              const SizedBox(height: 12),

              // Admin only: Add Moderator button
              if (isAdmin)
                _buildDashboardCard(
                  title: "Ajouter Modérateur",
                  subtitle: "Créer un nouveau compte modérateur",
                  icon: Icons.person_add_alt_1,
                  color: Colors.green,
                  onTap: () => Get.toNamed(AppRoutes.addModerator),
                ),

              if (isAdmin) const SizedBox(height: 12),

              // Tous les Artisans
              _buildDashboardCard(
                title: "Tous les Artisans",
                subtitle: "Gérer tous les artisans vérifiés",
                icon: Icons.groups_2,
                color: Colors.blue,
                onTap: () => _showAllArtisansDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Déconnexion"),
          content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final authController = Get.find<AuthController>();
                await authController.logout();
                Get.offAllNamed(AppRoutes.login);
                Get.snackbar(
                  "Déconnexion",
                  "Vous avez été déconnecté",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Se déconnecter"),
            ),
          ],
        );
      },
    );
  }

  // Method to show pending artisans dialog with approve/reject buttons
  void _showPendingArtisansDialog(BuildContext context) {
    // Mock data for pending artisans
    final List<Map<String, dynamic>> pendingArtisans = [
      {
        'id': 1,
        'name': 'Ahmed Benali',
        'category': 'Plomberie',
        'email': 'ahmed@email.com',
        'experience': '5 ans',
        'avatar': null,
      },
      {
        'id': 2,
        'name': 'Fatima Zahra',
        'category': 'Électricité',
        'email': 'fatima@email.com',
        'experience': '3 ans',
        'avatar': null,
      },
      {
        'id': 3,
        'name': 'Karim Mansouri',
        'category': 'Menuiserie',
        'email': 'karim@email.com',
        'experience': '7 ans',
        'avatar': null,
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Artisans en Attente",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: pendingArtisans.length,
                    itemBuilder: (context, index) {
                      final artisan = pendingArtisans[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.orange.shade100,
                                    child: Text(
                                      artisan['name'][0],
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          artisan['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          artisan['category'],
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          artisan['email'],
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showConfirmationDialog(
                                          context,
                                          "Approuver ${artisan['name']}",
                                          "Êtes-vous sûr de vouloir approuver cet artisan ?",
                                              () {
                                            Get.snackbar(
                                              "Succès",
                                              "${artisan['name']} a été approuvé",
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text("Approuver"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showConfirmationDialog(
                                          context,
                                          "Refuser ${artisan['name']}",
                                          "Êtes-vous sûr de vouloir refuser cet artisan ?",
                                              () {
                                            Get.snackbar(
                                              "Refusé",
                                              "${artisan['name']} a été refusé",
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.close, size: 18),
                                      label: const Text("Refuser"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to show reports dialog with validate/reject buttons
  void _showReportsDialog(BuildContext context) {
    // Mock data for reports
    final List<Map<String, dynamic>> reports = [
      {
        'id': 1,
        'title': 'Comportement inapproprié',
        'reportedUser': 'Jean Dupont',
        'reportedBy': 'Marie Curie',
        'date': '2024-01-15',
        'description': 'L\'artisan a tenu des propos inappropriés lors du rendez-vous.',
        'status': 'pending',
      },
      {
        'id': 2,
        'title': 'Travail non conforme',
        'reportedUser': 'Pierre Martin',
        'reportedBy': 'Sophie Bernard',
        'date': '2024-01-14',
        'description': 'Les travaux réalisés ne correspondent pas à ce qui était convenu.',
        'status': 'pending',
      },
      {
        'id': 3,
        'title': 'Retard important',
        'reportedUser': 'Lucas Robert',
        'reportedBy': 'Emma Petit',
        'date': '2024-01-13',
        'description': 'L\'artisan est arrivé avec 2 heures de retard sans prévenir.',
        'status': 'pending',
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Signalements en Attente",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report['title'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Signalé par: ${report['reportedBy']}",
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Utilisateur signalé: ${report['reportedUser']}",
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "Date: ${report['date']}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                report['description'],
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showConfirmationDialog(
                                          context,
                                          "Valider le signalement",
                                          "Êtes-vous sûr de vouloir valider ce signalement ?",
                                              () {
                                            Get.snackbar(
                                              "Signalement validé",
                                              "Le signalement a été validé. L'utilisateur sera notifié.",
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                              snackPosition: SnackPosition.TOP,
                                              duration: const Duration(seconds: 3),
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.verified, size: 18),
                                      label: const Text("Valider"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _showConfirmationDialog(
                                          context,
                                          "Rejeter le signalement",
                                          "Êtes-vous sûr de vouloir rejeter ce signalement ?",
                                              () {
                                            Get.snackbar(
                                              "Signalement rejeté",
                                              "Le signalement a été rejeté car jugé non valide.",
                                              backgroundColor: Colors.orange,
                                              colorText: Colors.white,
                                              snackPosition: SnackPosition.TOP,
                                              duration: const Duration(seconds: 3),
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text("Rejeter"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Get.snackbar(
                                      "Notification envoyée",
                                      "L'utilisateur ${report['reportedUser']} a été notifié",
                                      backgroundColor: Colors.blue,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.TOP,
                                      duration: const Duration(seconds: 3),
                                    );
                                  },
                                  icon: const Icon(Icons.notifications_active, size: 18),
                                  label: const Text("Notifier l'utilisateur signalé"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.deepPurple,
                                    side: const BorderSide(color: Colors.deepPurple),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show all artisans dialog
  void _showAllArtisansDialog(BuildContext context) {
    // Mock data for all artisans
    final List<Map<String, dynamic>> allArtisans = [
      {
        'id': 1,
        'name': 'Mohammed Ali',
        'category': 'Plomberie',
        'email': 'mohammed@email.com',
        'status': 'approved',
        'rating': 4.5,
      },
      {
        'id': 2,
        'name': 'Sara Benali',
        'category': 'Électricité',
        'email': 'sara@email.com',
        'status': 'approved',
        'rating': 4.8,
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tous les Artisans",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: allArtisans.length,
                    itemBuilder: (context, index) {
                      final artisan = allArtisans[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(artisan['name'][0]),
                          ),
                          title: Text(artisan['name']),
                          subtitle: Text("${artisan['category']} • ${artisan['email']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              Text(" ${artisan['rating']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Confirmation dialog helper
  void _showConfirmationDialog(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }

  // Original dashboard card without actions (for simple navigation)
  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Dashboard card with actions indicator
  Widget _buildDashboardCardWithActions({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_note, size: 20),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}