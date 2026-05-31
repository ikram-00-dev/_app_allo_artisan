// lib/widgets/client_tile.dart
import 'package:allo_artisan_gpt/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/screens/artisan/client_public_profile_screen.dart';
import '/models/client.dart';

class ClientTile extends StatelessWidget {
  final int? clientId;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final Widget? child;
  final bool showAsAvatar;
  final double avatarRadius;

  const ClientTile({
    super.key,
    this.clientId,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    this.child,
    this.showAsAvatar = false,
    this.avatarRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToClientProfile(),
      child: child ?? _buildDefaultWidget(),
    );
  }

  Widget _buildDefaultWidget() {
    if (showAsAvatar) {
      return CircleAvatar(
        radius: avatarRadius,
        backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
            ? NetworkImage(avatarUrl!)
            : null,
        child: avatarUrl == null || avatarUrl!.isEmpty
            ? Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
            : null,
      );
    }

    return Text(
      name,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  void _navigateToClientProfile() {
    if (clientId == null || clientId == 0) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger le profil du client. ID manquant.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Make sure we have a valid Client object
    Get.to(() => ClientPublicProfileScreen(
      client: Client(
        user: User(
          idUser: clientId!,
          firstName: name.split(' ').first,
          middleName: '',
          lastName: name.split(' ').length > 1 ? name.split(' ').last : '',
          username: name,
          email: email ?? '',
          phoneNumber: phone ?? '',
          password: '',
          creationDate: DateTime.now(),
          avatarUrl: avatarUrl ?? '',
          role: 'client',
        ),
      ),
    ));
  }
}