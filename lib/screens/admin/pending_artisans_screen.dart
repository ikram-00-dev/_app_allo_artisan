// lib/screens/admin/pending_artisans_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';

class PendingArtisansScreen extends StatefulWidget {
  const PendingArtisansScreen({super.key});

  @override
  State<PendingArtisansScreen> createState() => _PendingArtisansScreenState();
}

class _PendingArtisansScreenState extends State<PendingArtisansScreen> {
  List<dynamic> artisans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPendingArtisans();
  }

  Future<void> fetchPendingArtisans() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiService.get('/admin/artisans/pending');
      setState(() {
        artisans = res is List ? res : [];
      });
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de charger les artisans", backgroundColor: Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> approveArtisan(int id) async {
    try {
      await ApiService.put('/admin/artisans/$id/approve', {});
      Get.snackbar("Succès", "Artisan approuvé ✓", backgroundColor: Colors.green);
      fetchPendingArtisans();
    } catch (e) {
      Get.snackbar("Erreur", "Échec de l'approbation");
    }
  }

  Future<void> rejectArtisan(int id) async {
    try {
      await ApiService.put('/admin/artisans/$id/reject', {});
      Get.snackbar("Succès", "Artisan refusé ✕", backgroundColor: Colors.red);
      fetchPendingArtisans();
    } catch (e) {
      Get.snackbar("Erreur", "Échec du refus");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Artisans en Attente"),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchPendingArtisans,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchPendingArtisans,
        color: Colors.blue.shade700,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : artisans.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Aucun artisan en attente",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: artisans.length,
          itemBuilder: (context, index) {
            final artisan = artisans[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: artisan['avatarUrl'] != null
                              ? NetworkImage(artisan['avatarUrl'])
                              : null,
                          child: artisan['avatarUrl'] == null
                              ? const Icon(Icons.person, size: 32)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${artisan['firstName']} ${artisan['middleName'] ?? ''} ${artisan['lastName']}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                artisan['category'] ?? '',
                                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _infoRow("Ville", "${artisan['city']}, ${artisan['province']}"),
                    _infoRow("Expérience", "${artisan['experience']} ans"),
                    _infoRow("Email", artisan['email'] ?? 'Non renseigné'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => approveArtisan(artisan['id'] ?? artisan['ID']),
                            label: const Text("Approuver"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.close),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => rejectArtisan(artisan['id'] ?? artisan['ID']),
                            label: const Text("Refuser"),
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
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}