// lib/screens/artisan/artisan_private_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';
import '../../controllers/artisan_controller.dart';
import '../../controllers/artisan_private_profile_controller.dart';
import 'package:allo_artisan_gpt/controllers/post_controller.dart';
import 'package:allo_artisan_gpt/models/post.dart';

class ArtisanPrivateProfileScreen extends StatelessWidget {
  const ArtisanPrivateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get controllers
    final controller = Get.find<ArtisanPrivateProfileController>();
    final artisanController = Get.find<ArtisanController>();
    final postController = Get.find<PostController>();

    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (artisanController.isLoading.value)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      body: RefreshIndicator(
        onRefresh: () async {
          await artisanController.loadDashboard();
          await postController.fetchAllPosts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildProfileHeader(controller, artisanController),
              const SizedBox(height: 16),

              // Informations professionnelles section
              _buildProfessionalInfoCard(controller),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => controller.showAvailability.toggle(),
                child: _buildMenuCard(Icons.calendar_today, Colors.green, "Gérer mes disponibilités", "Modifier mon calendrier"),
              ),
              if (controller.showAvailability.value) _buildCalendar(controller),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => controller.showFollowers.toggle(),
                child: _buildMenuCard(Icons.people, Colors.purple, "Mes abonnés", "${controller.getFollowersCount()} abonnés"),
              ),
              if (controller.showFollowers.value) _buildFollowersList(controller),

              const SizedBox(height: 20),

              // ==================== CREATE POST SECTION - DYNAMIC ====================
              _buildCreatePostSection(controller, postController, artisanController),

              const SizedBox(height: 24),

              // ==================== MES PUBLICATIONS - DYNAMIC ====================
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Mes publications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final currentArtisanId = artisanController.artisan.value?.id;

                if (postController.isLoading.value && postController.posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter posts for current artisan only
                final myPosts = postController.posts
                    .where((post) => post.artisanId == currentArtisanId)
                    .toList();

                if (myPosts.isEmpty && !postController.isLoading.value) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.post_add, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text(
                            "Aucune publication pour le moment",
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Créez votre première publication ci-dessus",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: myPosts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPublicationCard(myPosts[index], artisanController, postController),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    ));
  }

  // ==================== PROFILE HEADER ====================
  Widget _buildProfileHeader(ArtisanPrivateProfileController controller, ArtisanController artisanController) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF2563EB),
                backgroundImage: controller.getAvatarUrl().isNotEmpty
                    ? NetworkImage(controller.getAvatarUrl())
                    : null,
                child: controller.getAvatarUrl().isEmpty
                    ? Text(
                    controller.getInitials(),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.getFullName(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Color(0xFF2563EB), size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Text(controller.getCategory(), style: const TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        Row(children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(" ${controller.getRating().toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold))
                        ]),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            controller.getEmail(),
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            controller.getPhoneNumber(),
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.dialog(_buildQrDialog(artisanController.getQrCodeData())),
                  icon: const Icon(Icons.qr_code, color: Colors.black),
                  label: const Text("QR Code", style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/settings'),
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: const Text("Paramètres", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Statut", style: TextStyle(fontWeight: FontWeight.w600)),
                    Obx(() => Text(
                      artisanController.isVisible.value ? "Vous êtes visible pour les clients" : "Vous êtes invisible",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    )),
                  ],
                ),
                Obx(() => Switch(
                  value: artisanController.isVisible.value,
                  onChanged: (val) => artisanController.toggleVisibility(),
                  activeColor: const Color(0xFF2563EB),
                )),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  // ==================== CREATE POST SECTION - DYNAMIC ====================
  Widget _buildCreatePostSection(ArtisanPrivateProfileController controller, PostController postController, ArtisanController artisanController) {
    final TextEditingController contentController = TextEditingController();
    final RxBool isPosting = false.obs;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Créer une publication", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: contentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Partagez votre dernier projet...",
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // TODO: Implement image picker
                    Get.snackbar("Info", "Fonctionnalité à venir",
                        backgroundColor: Colors.orange,
                        colorText: Colors.white
                    );
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text("Ajouter une photo"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => ElevatedButton(
                  onPressed: isPosting.value || contentController.text.trim().isEmpty
                      ? null
                      : () async {
                    isPosting.value = true;

                    final success = await postController.createPost(
                      contentController.text.trim(),
                      null, // Add image URL when implemented
                    );

                    isPosting.value = false;

                    if (success) {
                      contentController.clear();
                      Get.snackbar(
                        "Succès",
                        "Publication créée avec succès!",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    } else {
                      Get.snackbar(
                        "Erreur",
                        "Impossible de créer la publication",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isPosting.value
                      ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  )
                      : const Text("Publier", style: TextStyle(color: Colors.white)),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== PROFESSIONAL INFO CARD ====================
  Widget _buildProfessionalInfoCard(ArtisanPrivateProfileController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.work, size: 20, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text("Informations professionnelles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, "Localisation", controller.getLocation()),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.flag, "Zone de service", controller.getServiceZone()),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.school, "Diplôme", controller.getDiploma()),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.timer, "Expérience", controller.getExperience()),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.description, "Bio", controller.getBio()),
        ],
      ),
    ));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? "Non renseigné" : value,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // ==================== MENU CARD ====================
  Widget _buildMenuCard(IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  // ==================== CALENDAR ====================
  Widget _buildCalendar(ArtisanPrivateProfileController controller) {
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Calendrier - ${_getMonthName(now.month)} ${now.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildCalendarGrid(controller),
          const SizedBox(height: 12),
          const Text("• Appuyez une fois = Vert / Rouge", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const Text("• Appuyez deux fois = Ajouter une note", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ArtisanPrivateProfileController controller) {
    final weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final calendarDays = controller.getCurrentMonthDays();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays.map((day) => Expanded(
            child: Center(
              child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
          ),
          itemCount: calendarDays.length,
          itemBuilder: (context, index) {
            final day = calendarDays[index];
            if (day['isEmpty'] == true) {
              return const SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () => controller.toggleDay(day['date']),
              onDoubleTap: () => controller.openNoteDialog(day['date'], context),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: day['available'] ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      day['day'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: day['available'] ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                    if (day['hasNote'])
                      const Positioned(bottom: 4, right: 6, child: Text("📝", style: TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return months[month - 1];
  }

  // ==================== FOLLOWERS ====================
  Widget _buildFollowersList(ArtisanPrivateProfileController controller) {
    final followers = controller.getFollowers();

    if (followers.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Center(
          child: Text("Aucun abonné pour le moment"),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: followers.map((follower) => Column(
          children: [
            _buildFollowerItem(follower['name'] ?? 'Client'),
            const Divider(height: 24),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildFollowerItem(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = names.length >= 2 ? "${names[0][0]}${names[1][0]}" : names[0].substring(0, 2).toUpperCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2563EB),
          child: Text(initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(fullName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15))),
        ElevatedButton(
          onPressed: () => Get.snackbar("Profil", "Profil de $fullName ouvert"),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
          child: const Text("Voir profil", style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }

  // ==================== MES PUBLICATIONS ====================
  Widget _buildPublicationCard(PostModel post, ArtisanController artisanController, PostController postController) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.image != null && post.image!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                post.image!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDate(post.createdAt), style: const TextStyle(color: Colors.grey)),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showEditDeleteDialog(post, artisanController, postController),
                          child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red, size: 18),
                            const SizedBox(width: 4),
                            Text("${post.likesCount ?? 0}", style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        Text("${post.commentsCount ?? 0}"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDeleteDialog(PostModel post, ArtisanController artisanController, PostController postController) {
    final TextEditingController editController = TextEditingController(text: post.content);

    Get.dialog(
      AlertDialog(
        title: const Text('Modifier la publication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Modifiez votre description...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (post.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.image!, height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await postController.updatePost(
                post.idPost,
                editController.text.trim(),
                post.image,
              );
              if (success) {
                Get.snackbar('Succès', 'Publication modifiée');
                await artisanController.loadDashboard();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Enregistrer'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              Get.back();
              final confirm = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('Supprimer'),
                  content: const Text('Voulez-vous vraiment supprimer cette publication ?'),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
                    TextButton(onPressed: () => Get.back(result: true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                final success = await postController.deletePost(post.idPost);
                if (success) {
                  Get.snackbar('Succès', 'Publication supprimée');
                  await artisanController.loadDashboard();
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Récemment";
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return "${date.day}/${date.month}/${date.year}";
    } else if (difference.inDays > 0) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inHours > 0) {
      return "Il y a ${difference.inHours} heures";
    } else if (difference.inMinutes > 0) {
      return "Il y a ${difference.inMinutes} minutes";
    } else {
      return "À l'instant";
    }
  }

  Widget _buildQrDialog(String qrData) {
    return AlertDialog(
      title: const Text("QR Code"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 180,
            height: 180,
            color: const Color(0xFF2563EB),
            child: const Center(
              child: Icon(Icons.qr_code, size: 160, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text("Partagez ce code avec vos clients\n$qrData", textAlign: TextAlign.center),
        ],
      ),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text("Fermer"))],
    );
  }
}