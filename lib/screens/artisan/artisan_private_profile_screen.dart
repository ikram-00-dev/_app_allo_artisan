// lib/screens/artisan/artisan_private_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_artisan_gpt/core/widgets/bottom_nav_bar.dart';

class ArtisanPrivateProfileScreen extends StatefulWidget {
  const ArtisanPrivateProfileScreen({super.key});

  @override
  State<ArtisanPrivateProfileScreen> createState() => _ArtisanPrivateProfileScreenState();
}

class _ArtisanPrivateProfileScreenState extends State<ArtisanPrivateProfileScreen> {
  bool _isVisible = true;
  bool _showAvailability = false;
  bool _showFollowers = false;

  // Calendar Data
  final Map<DateTime, Map<String, dynamic>> _dayStatus = {};

  void _toggleDay(DateTime date) {
    setState(() {
      if (!_dayStatus.containsKey(date)) {
        _dayStatus[date] = {'available': true, 'note': ''};
      } else {
        _dayStatus[date]!['available'] = !_dayStatus[date]!['available'];
      }
    });
  }

  void _openNoteDialog(DateTime date) {
    final TextEditingController noteController = TextEditingController(
      text: _dayStatus[date]?['note'] ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: Text("Note pour le ${date.day}/${date.month}/${date.year}"),
        content: TextField(
          controller: noteController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Ajouter des détails (ex: rendez-vous, congé, etc.)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (!_dayStatus.containsKey(date)) {
                  _dayStatus[date] = {'available': true, 'note': ''};
                }
                _dayStatus[date]!['note'] = noteController.text.trim();
              });
              Get.back();
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Allo Artisan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () => setState(() => _showAvailability = !_showAvailability),
              child: _buildMenuCard(Icons.calendar_today, Colors.green, "Gérer mes disponibilités", "Modifier mon calendrier"),
            ),
            if (_showAvailability) _buildCalendar(),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => setState(() => _showFollowers = !_showFollowers),
              child: _buildMenuCard(Icons.people, Colors.purple, "Mes abonnés", "2 abonnés"),
            ),
            if (_showFollowers) _buildFollowersList(),

            const SizedBox(height: 20),

            _buildCreatePostSection(),

            const SizedBox(height: 24),

            // ==================== MES PUBLICATIONS ====================
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Mes publications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            _buildPublicationCard(),
          ],
        ),
      ),
    );
  }

  // ==================== PROFILE HEADER ====================
  Widget _buildProfileHeader() {
    return Container(
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
                child: const Text("JY", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("Jawad Ben Yahya", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Color(0xFF2563EB), size: 20),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                          child: const Text("Plomberie", style: TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        const Row(children: [Icon(Icons.star, color: Colors.amber, size: 18), Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold))]),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.email, size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text("jawadbenyahya@GMAIL.COM", style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                  onPressed: () => Get.dialog(_buildQrDialog()),
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
                    Text(
                      _isVisible ? "Vous êtes visible pour les clients" : "Vous êtes invisible",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                Switch(
                  value: _isVisible,
                  onChanged: (val) => setState(() => _isVisible = val),
                  activeColor: const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ],
      ),
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
  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Calendrier - Mai 2026", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildCalendarGrid(),
          const SizedBox(height: 12),
          const Text("• Appuyez une fois = Vert / Rouge", style: TextStyle(fontSize: 12, color: Colors.grey)),
          const Text("• Appuyez deux fois = Ajouter une note", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        final day = index + 1;
        if (day > 31) return const SizedBox.shrink();

        final date = DateTime(2026, 5, day);
        final status = _dayStatus[date];
        final isAvailable = status?['available'] ?? true;
        final hasNote = status?['note']?.isNotEmpty ?? false;

        return GestureDetector(
          onTap: () => _toggleDay(date),
          onDoubleTap: () => _openNoteDialog(date),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isAvailable ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
                if (hasNote)
                  const Positioned(bottom: 4, right: 6, child: Text("📝", style: TextStyle(fontSize: 14))),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== FOLLOWERS ====================
  Widget _buildFollowersList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildFollowerItem("Marie Dubois"),
          const Divider(height: 24),
          _buildFollowerItem("Pierre Leroy"),
        ],
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

  // ==================== CREATE POST ====================
  Widget _buildCreatePostSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Créer une publication", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Partagez votre dernier projet...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text("Ajouter une photo"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.snackbar("Succès", "Publication publiée !"),
                  child: const Text("Publier", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  // ==================== MES PUBLICATIONS ====================
  Widget _buildPublicationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              "https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Installation d'une nouvelle salle de bain complète avec robinetterie moderne et carrelage italien. Projet réalisé en 5 jours.",
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Il y a 2 heures", style: TextStyle(color: Colors.grey)),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 18),
                        const SizedBox(width: 4),
                        Text("45", style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, color: Colors.grey, size: 18),
                        const SizedBox(width: 4),
                        const Text("8"),
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
}

  Widget _buildQrDialog() {
    return AlertDialog(
      title: const Text("QR Code"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code, size: 180, color: Color(0xFF2563EB)),
          SizedBox(height: 10),
          Text("Partagez ce code avec vos clients", textAlign: TextAlign.center),
        ],
      ),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text("Fermer"))],
    );
  }
