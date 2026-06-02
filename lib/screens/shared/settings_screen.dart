// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_artisan_gpt/controllers/auth_controller.dart';
import 'package:allo_artisan_gpt/controllers/settings_controller.dart';
import 'package:allo_artisan_gpt/services/api_service.dart';
import 'package:allo_artisan_gpt/routes/app_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:allo_artisan_gpt/controllers/switch_account_controller.dart';
// ============================================================
// TYPES
// ============================================================
enum Section { profile, language, security, documents }
enum SecuritySection { password, email, delete }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController authController = Get.find<AuthController>();
  final SettingsController settingsController = Get.put(SettingsController(ApiService()));

  // Section states
  Section? _openSection;
  SecuritySection? _openSecurity;

  // Profile data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Visibility settings
  bool _showBirthdate = false;
  bool _showLocation = false;
  bool _showZone = false;

  // Language
  String _selectedLanguage = 'fr';

  // Password
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Email
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _emailPasswordController = TextEditingController();

  // Name change modal
  bool _showNameChangeModal = false;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  File? _selectedDocument;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profile = await ApiService.getCurrentUserProfile();

      setState(() {
        _nameController.text = "${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}".trim();
        _phoneController.text = profile['phoneNumber'] ?? '';
        _zoneController.text = profile['district'] ?? profile['zone'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _locationController.text = "${profile['city'] ?? ''}, ${profile['province'] ?? ''}".trim();
        // Add more fields as needed
      });
    } catch (e) {
      print('Error loading profile: $e');
      Get.snackbar("Erreur", "Impossible de charger le profil");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _zoneController.dispose();
    _bioController.dispose();
    _birthdateController.dispose();
    _locationController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newEmailController.dispose();
    _emailPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  @override
  @override
  Widget build(BuildContext context) {
    final user = authController.user.value;
    final isArtisan = authController.isArtisan;
    final canSwitchRole = authController.isClient || authController.isArtisan;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                // ============================================================
                // PROFILE SECTION (No more role switcher at top)
                // ============================================================
                _buildProfileSection(isArtisan),

                const SizedBox(height: 12),

                // ============================================================
                // LANGUAGE SECTION
                // ============================================================
                _buildLanguageSection(),

                const SizedBox(height: 12),

                // ============================================================
                // SECURITY SECTION
                // ============================================================
                _buildSecuritySection(),

                const SizedBox(height: 12),

                // ============================================================
                // DOCUMENTS SECTION (Artisan only)
                // ============================================================
                if (isArtisan) _buildDocumentsSection(),

                const SizedBox(height: 12),

                // ============================================================
                // SWITCH ACCOUNT & LOGOUT (Only this remains for role switching)
                // ============================================================
                _buildBottomActions(canSwitchRole),

                const SizedBox(height: 24),
              ],
            ),
          ),
          // Modal overlay
          if (_showNameChangeModal) _buildNameChangeModal(isArtisan),
        ],
      ),
    );
  }



  // ============================================================
  // PROFILE SECTION
  // ============================================================
  Widget _buildProfileSection(bool isArtisan) {
    final isExpanded = _openSection == Section.profile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() {
              _openSection = isExpanded ? null : Section.profile;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.person_outline, size: 20, color: Color(0xFF2563EB)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Modifier le profil",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF171717),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Photo, nom, téléphone, bio",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              child: Column(
                children: [
                  // Avatar section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFE5E7EB),
                        backgroundImage: NetworkImage(
                          authController.user.value?['avatarUrl'] ?? '',
                        ),
                        child: authController.user.value?['avatarUrl'] == null ||
                            authController.user.value?['avatarUrl'].isEmpty
                            ? Text(
                          _getInitials(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _pickAndUploadAvatar,
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text("Changer la photo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name
                  _buildTextField(
                    label: "Nom complet",
                    controller: _nameController,
                    hint: "Votre nom complet",
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  _buildTextField(
                    label: "Numéro de téléphone",
                    controller: _phoneController,
                    hint: "+33 6 12 34 56 78",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Birthdate with visibility
                  _buildFieldWithVisibility(
                    label: "Date de naissance",
                    child: TextField(
                      controller: _birthdateController,
                      decoration: InputDecoration(
                        hintText: "YYYY-MM-DD",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    visibilityValue: _showBirthdate,
                    onVisibilityChanged: (val) => setState(() => _showBirthdate = val),
                  ),
                  const SizedBox(height: 16),

                  // Location with visibility
                  _buildFieldWithVisibility(
                    label: "Localisation",
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: "Ex: Paris, France",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    visibilityValue: _showLocation,
                    onVisibilityChanged: (val) => setState(() => _showLocation = val),
                  ),
                  const SizedBox(height: 16),

                  // Artisan specific fields
                  if (authController.isArtisan) ...[
                    _buildFieldWithVisibility(
                      label: "Zone d'intervention",
                      child: TextField(
                        controller: _zoneController,
                        decoration: InputDecoration(
                          hintText: "Ex: Paris et banlieue",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      visibilityValue: _showZone,
                      onVisibilityChanged: (val) => setState(() => _showZone = val),
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bio / Description",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF404040),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _bioController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Décrivez votre activité...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Change name button
                  GestureDetector(
                    onTap: () => setState(() => _showNameChangeModal = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.description, size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Modifier nom et prénom",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF404040),
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
                        ],
                      ),
                    ),
                  ),
                  if (authController.isArtisan)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: Text(
                        "Nécessite un document officiel pour vérification",
                        style: TextStyle(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 18),
                          SizedBox(width: 8),
                          Text("Enregistrer les modifications"),
                        ],
                      ),
                    ),
                  ),

                  // Manage posts (Artisan only)
                  if (authController.isArtisan) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      "Gérer les publications",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _buildPostCard(
                      title: "Installation salle de bain",
                      date: "Publié il y a 2 jours",
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // LANGUAGE SECTION
  // ============================================================
  Widget _buildLanguageSection() {
    final languages = [
      {'code': 'fr', 'label': 'Français', 'sublabel': 'French', 'flag': '🇫🇷'},
      {'code': 'ar', 'label': 'العربية', 'sublabel': 'Arabic', 'flag': '🇸🇦'},
      {'code': 'en', 'label': 'English', 'sublabel': 'Anglais', 'flag': '🇬🇧'},
    ];
    final isExpanded = _openSection == Section.language;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _openSection = isExpanded ? null : Section.language;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.language, size: 20, color: Color(0xFF059669)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Langue",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          languages.firstWhere((l) => l['code'] == _selectedLanguage)['label'] as String,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              child: Column(
                children: languages.map((lang) {
                  final isSelected = _selectedLanguage == lang['code'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLanguage = lang['code'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF5F5F5),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(lang['flag'] as String, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['label'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  lang['sublabel'] as String,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 12, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SECURITY SECTION
  // ============================================================
  Widget _buildSecuritySection() {
    final isExpanded = _openSection == Section.security;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _openSection = isExpanded ? null : Section.security;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_outline, size: 20, color: Color(0xFF9333EA)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sécurité",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Mot de passe, email, informations",
                          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              child: Column(
                children: [
                  // Change password
                  _buildSecuritySubsection(
                    title: "Modifier le mot de passe",
                    icon: Icons.lock_outline,
                    isExpanded: _openSecurity == SecuritySection.password,
                    onTap: () => setState(() {
                      _openSecurity = _openSecurity == SecuritySection.password ? null : SecuritySection.password;
                    }),
                    child: Column(
                      children: [
                        _buildPasswordField(
                          label: "Mot de passe actuel",
                          controller: _currentPasswordController,
                          obscure: !_showCurrentPassword,
                          onToggle: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          label: "Nouveau mot de passe",
                          controller: _newPasswordController,
                          obscure: !_showNewPassword,
                          onToggle: () => setState(() => _showNewPassword = !_showNewPassword),
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          label: "Confirmer le nouveau mot de passe",
                          controller: _confirmPasswordController,
                          obscure: !_showConfirmPassword,
                          onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9333EA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Mettre à jour"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Change email
                  _buildSecuritySubsection(
                    title: "Modifier l'adresse email",
                    icon: Icons.email_outlined,
                    isExpanded: _openSecurity == SecuritySection.email,
                    onTap: () => setState(() {
                      _openSecurity = _openSecurity == SecuritySection.email ? null : SecuritySection.email;
                    }),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email actuel",
                                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                authController.user.value?['email'] ?? '',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "Nouvel email",
                          controller: _newEmailController,
                          hint: "nouveau@email.com",
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          label: "Mot de passe de confirmation",
                          controller: _emailPasswordController,
                          hint: "••••••••",
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _changeEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9333EA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Mettre à jour"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete account
                  _buildSecuritySubsection(
                    title: "Supprimer mon compte",
                    icon: Icons.warning_amber_rounded,
                    isExpanded: _openSecurity == SecuritySection.delete,
                    onTap: () => setState(() {
                      _openSecurity = _openSecurity == SecuritySection.delete ? null : SecuritySection.delete;
                    }),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            border: Border.all(color: const Color(0xFFFEE2E2)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "⚠️ Cette action est irréversible. Toutes vos données seront définitivement supprimées.",
                            style: TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirmDeleteAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Confirmer la suppression"),
                          ),
                        ),
                      ],
                    ),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // DOCUMENTS SECTION (Artisan only)
  // ============================================================
  Widget _buildDocumentsSection() {
    final isExpanded = _openSection == Section.documents;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() {
              _openSection = isExpanded ? null : Section.documents;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.description_outlined, size: 20, color: Color(0xFFD97706)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Documents officiels",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Documents de vérification",
                          style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      border: Border.all(color: const Color(0xFFD1FAE5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.description, color: Color(0xFF047857)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Document d'identité",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF064E3B)),
                              ),
                              const Text(
                                "Vérifié le 15 avril 2026",
                                style: TextStyle(fontSize: 11, color: Color(0xFF047857)),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "✓ Carte d'identité validée",
                                style: TextStyle(fontSize: 12, color: Color(0xFF059669)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Color(0xFF1E40AF)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "ℹ️ Vos documents ne peuvent pas être modifiés ou supprimés pour des raisons de sécurité. Pour toute modification, contactez le support.",
                            style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTIONS
  // ============================================================
  // ============================================================
// BOTTOM ACTIONS
// ============================================================
  // ============================================================
// BOTTOM ACTIONS - UPDATED with dynamic switch account
// ============================================================
  Widget _buildBottomActions(bool canSwitchRole) {
    // Initialize the switch controller (GetX will manage it)
    final SwitchAccountController switchController = Get.put(SwitchAccountController());

    return Obx(() {
      // Show loading state while checking artisan account
      if (switchController.checkingAccount.value && authController.isClient) {
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Vérification en cours...",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF171717),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Vérification de votre compte artisan",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, size: 20),
                label: const Text("Se déconnecter"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFFEE2E2)),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          if (canSwitchRole)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: InkWell(
                onTap: switchController.isLoading.value ? null : () => _switchAccountWithLogic(switchController),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: switchController.isLoading.value
                            ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                            : const Center(
                          child: Icon(Icons.swap_horiz, size: 22, color: Color(0xFF2563EB)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              switchController.isLoading.value
                                  ? "Changement en cours..."
                                  : "Basculer en ${authController.isArtisan ? "Client" : "Artisan"}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF171717),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authController.isArtisan
                                  ? "Mode actuel: Artisan"
                                  : (switchController.hasArtisanAccount.value
                                  ? "Mode actuel: Client (Compte Artisan trouvé)"
                                  : "Mode actuel: Client (Créez un compte Artisan)"),
                              style: TextStyle(
                                fontSize: 12,
                                color: authController.isArtisan
                                    ? const Color(0xFF9CA3AF)
                                    : (switchController.hasArtisanAccount.value
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFD97706)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        switchController.isLoading.value ? Icons.hourglass_empty : Icons.chevron_right,
                        size: 20,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, size: 20),
              label: const Text("Se déconnecter"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFEE2E2)),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

// Add this new method to handle the switch logic
  Future<void> _switchAccountWithLogic(SwitchAccountController switchController) async {
    if (authController.isClient) {
      // Client wants to switch to artisan
      if (switchController.hasArtisanAccount.value) {
        // Direct switch - artisan account exists
        await authController.switchRole('artisan');
        Get.snackbar(
          "Mode changé",
          "Vous êtes maintenant en mode Artisan",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Show dialog to create artisan account (preserve your design)
        _showCreateArtisanAccountDialog();
      }
    } else if (authController.isArtisan) {
      // Artisan wants to switch to client - direct switch allowed
      await authController.switchRole('client');
      Get.snackbar(
        "Mode changé",
        "Vous êtes maintenant en mode Client",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

// Add dialog method with your app's design language
  void _showCreateArtisanAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.construction, color: Color(0xFF2563EB), size: 20),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Devenir Artisan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Vous n'avez pas encore de compte artisan. "
              "Souhaitez-vous créer un compte artisan maintenant pour "
              "pouvoir basculer entre les deux modes ?",
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to artisan registration
              Get.toNamed('/artisan-register', arguments: {
                'fromSwitch': true,
                'clientEmail': authController.user.value?['email'],
                'clientPhone': authController.user.value?['phoneNumber'],
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Créer un compte"),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NAME CHANGE MODAL
  // ============================================================
  Widget _buildNameChangeModal(bool isArtisan) {
    if (!_showNameChangeModal) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          color: Colors.black54,
          child: GestureDetector(
            onTap: () => setState(() => _showNameChangeModal = false),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Modifier nom et prénom",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isArtisan
                            ? "Pour des raisons de sécurité, vous devez fournir un document officiel (carte d'identité, passeport, etc.) pour modifier votre nom."
                            : "Modifiez votre nom et prénom. Ces informations seront visibles sur votre profil.",
                        style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: "Prénom",
                        controller: _firstNameController,
                        hint: "Nouveau prénom",
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: "Nom de famille",
                        controller: _lastNameController,
                        hint: "Nouveau nom de famille",
                      ),
                      if (isArtisan) ...[
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Document officiel *",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _pickDocument,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFD1D5DB), width: 2, style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      _selectedDocument != null ? Icons.check_circle : Icons.cloud_upload,
                                      size: 32,
                                      color: _selectedDocument != null ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedDocument != null
                                          ? _selectedDocument!.path.split('/').last
                                          : "Télécharger un document",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _selectedDocument != null ? const Color(0xFF059669) : const Color(0xFF404040),
                                      ),
                                    ),
                                    if (_selectedDocument == null)
                                      const Text(
                                        "PNG, JPG ou PDF - Max 10MB",
                                        style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Le document sera vérifié par notre équipe avant validation",
                              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _showNameChangeModal = false;
                                  _firstNameController.clear();
                                  _lastNameController.clear();
                                  _selectedDocument = null;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF404040),
                                side: const BorderSide(color: Color(0xFFD1D5DB)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Annuler"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _submitNameChange,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Soumettre"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HELPER WIDGETS
  // ============================================================
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String hint = '',
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF404040)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 18),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithVisibility({
    required String label,
    required Widget child,
    required bool visibilityValue,
    required Function(bool) onVisibilityChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF404040)),
            ),
            Row(
              children: [
                Checkbox(
                  value: visibilityValue,
                  onChanged: (val) => onVisibilityChanged(val ?? false),
                  activeColor: const Color(0xFF2563EB),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text("Visible", style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ],
        ),
        child,
      ],
    );
  }

  Widget _buildSecuritySubsection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
    bool isDestructive = false,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: isDestructive ? const Color(0xFFDC2626) : const Color(0xFF9CA3AF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? const Color(0xFFDC2626) : const Color(0xFF404040),
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                  size: 18,
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: child,
          ),
      ],
    );
  }

  Widget _buildPostCard({required String title, required String date}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _showDeletePostDialog(),
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text("Supprimer"),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              backgroundColor: const Color(0xFFFEF2F2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================
  void _switchRole(String newRole) async {
    await authController.switchRole(newRole);
    setState(() {});
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // TODO: Implement avatar upload
      Get.snackbar("Info", "Fonctionnalité à implémenter");
    }
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedDocument = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    await settingsController.updateProfile();
    Get.snackbar("Succès", "Profil mis à jour avec succès !");
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      Get.snackbar("Erreur", "Les mots de passe ne correspondent pas");
      return;
    }
    await settingsController.changePassword();
    Get.snackbar("Succès", "Mot de passe mis à jour !");
  }

  Future<void> _changeEmail() async {
    await settingsController.changeEmail();
    Get.snackbar("Succès", "Email mis à jour !");
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le compte"),
        content: const Text(
          "Êtes-vous absolument sûr de vouloir supprimer votre compte ? Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authController.logout();
              Get.snackbar("Succès", "Compte supprimé");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  void _showDeletePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la publication"),
        content: const Text("Voulez-vous vraiment supprimer cette publication ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar("Succès", "Publication supprimée !");
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  void _submitNameChange() {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      Get.snackbar("Erreur", "Veuillez remplir tous les champs");
      return;
    }
    if (authController.isArtisan && _selectedDocument == null) {
      Get.snackbar("Erreur", "Le document officiel est obligatoire pour les artisans");
      return;
    }
    Get.snackbar(
      "Succès",
      authController.isArtisan
          ? "Demande de modification envoyée pour vérification"
          : "Nom et prénom modifiés avec succès",
    );
    setState(() {
      _showNameChangeModal = false;
      _firstNameController.clear();
      _lastNameController.clear();
      _selectedDocument = null;
    });
  }

  Future<void> _logout() async {
    await authController.logout();
  }

  String _getInitials() {
    final user = authController.user.value;
    if (user != null) {
      final firstName = user['firstName'] ?? '';
      final lastName = user['lastName'] ?? '';
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        return "${firstName[0]}${lastName[0]}".toUpperCase();
      }
    }
    return "U";
  }
}