// lib/screens/auth/register_artisan_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';

enum RegistrationStep { form, waiting }

class RegisterArtisanScreen extends StatefulWidget {
  const RegisterArtisanScreen({super.key});

  @override
  State<RegisterArtisanScreen> createState() => _RegisterArtisanScreenState();
}

class _RegisterArtisanScreenState extends State<RegisterArtisanScreen> {
  final auth = Get.find<AuthController>();

  RegistrationStep _registrationStep = RegistrationStep.form;
  int _formStep = 1;

  // Form data
  final Map<String, dynamic> _formData = {
    'firstName': '',
    'lastName': '',
    'category': '',
    'province': '',
    'city': '',
    'district': '5km',
    'email': '',
    'phoneNumber': '',
    'password': '',
    'confirmPassword': '',
    'diplomaUrl': '',
    'officialDocUrl': '',
    'avatarUrl': '',
  };

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  // Track if files are "uploaded" (simulated)
  bool _hasProfileImage = false;
  bool _hasDiploma = false;
  bool _hasOfficialDoc = false;

  // Simulated upload states
  bool _isUploadingProfileImage = false;
  bool _isUploadingDiploma = false;
  bool _isUploadingOfficialDoc = false;

  // Store simulated file paths (just for display)
  File? _profileImageFile;
  File? _diplomaFile;
  File? _officialDocFile;

  // Complete list of wilayas
  final List<String> _wilayas = [
    'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa', 'Biskra',
    'Béchar', 'Blida', 'Bouira', 'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret',
    'Tizi Ouzou', 'Alger', 'Djelfa', 'Jijel', 'Sétif', 'Saïda', 'Skikda',
    'Sidi Bel Abbès', 'Annaba', 'Guelma', 'Constantine', 'Médéa', 'Mostaganem',
    'M’Sila', 'Mascara', 'Ouargla', 'Oran', 'El Bayadh', 'Illizi',
    'Bordj Bou Arréridj', 'Boumerdès', 'El Tarf', 'Tindouf', 'Tissemsilt',
    'El Oued', 'Khenchela', 'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla',
    'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane', 'Timimoun',
    'Bordj Badji Mokhtar', 'Ouled Djellal', 'Béni Abbès', 'In Salah',
    'In Guezzam', 'Touggourt', 'Djanet', 'El M’Ghair', 'El Meniaa'
  ];

  // Zone radius options
  final List<String> _zoneRadii = [
    '5km', '10km', '15km', '20km', '25km', '30km', '35km', '40km', '45km', '50km'
  ];

  final List<String> _categories = [
    'Plomberie', 'Électricité', 'Menuiserie', 'Peinture', 'Maçonnerie',
    'Jardinage', 'Climatisation', 'Carrelage', 'Plâtrerie', 'Soudure',
    'Électronique', 'Informatique', 'Cuisine',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfileImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() {
        _profileImageFile = File(file.path);
        _isUploadingProfileImage = true;
      });

      final uploadedUrl = await ApiService.uploadImage(file.path);

      setState(() {
        _hasProfileImage = true;
        _isUploadingProfileImage = false;
        _formData['avatarUrl'] = uploadedUrl;
      });

      Get.snackbar(
        'Succès',
        'Photo de profil téléchargée avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      setState(() => _isUploadingProfileImage = false);
      debugPrint('Error uploading artisan profile image: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de télécharger la photo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // SIMULATED document picker
  Future<void> _pickDiploma() async {
    try {
      final XFile? file = await _picker.pickMedia();

      if (file == null) return;

      setState(() {
        _diplomaFile = File(file.path);
        _isUploadingDiploma = true;
      });

      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _hasDiploma = true;
        _isUploadingDiploma = false;
        _formData['diplomaUrl'] = 'simulated_diploma_${DateTime.now().millisecondsSinceEpoch}.pdf';
      });

      Get.snackbar(
        'Succès',
        'Diplôme téléchargé avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      setState(() => _isUploadingDiploma = false);
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sélection',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // SIMULATED official document picker
  Future<void> _pickOfficialDoc() async {
    try {
      final XFile? file = await _picker.pickMedia();

      if (file == null) return;

      setState(() {
        _officialDocFile = File(file.path);
        _isUploadingOfficialDoc = true;
      });

      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _hasOfficialDoc = true;
        _isUploadingOfficialDoc = false;
        _formData['officialDocUrl'] = 'simulated_official_${DateTime.now().millisecondsSinceEpoch}.pdf';
      });

      Get.snackbar(
        'Succès',
        'Document officiel téléchargé avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      setState(() => _isUploadingOfficialDoc = false);
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sélection',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _nextStep() {
    if (_formStep == 1) {
      if (_formData['firstName'].isEmpty ||
          _formData['lastName'].isEmpty ||
          _formData['category'].isEmpty ||
          _formData['province'].isEmpty ||
          _formData['city'].isEmpty) {
        _showError('Veuillez remplir tous les champs obligatoires');
        return;
      }
    } else if (_formStep == 2) {
      if (!_hasDiploma) {
        _showError('Veuillez télécharger votre diplôme/certification');
        return;
      }
      if (!_hasOfficialDoc) {
        _showError('Veuillez télécharger votre document officiel');
        return;
      }
    } else if (_formStep == 3) {
      if (_formData['email'].isEmpty && _formData['phoneNumber'].isEmpty) {
        _showError('Veuillez fournir au moins un email ou un numéro de téléphone');
        return;
      }
      if (_formData['password'].isEmpty || _formData['confirmPassword'].isEmpty) {
        _showError('Veuillez remplir tous les champs');
        return;
      }
      if (_formData['password'] != _formData['confirmPassword']) {
        _showError('Les mots de passe ne correspondent pas');
        return;
      }
      _submitRegistration();
      return;
    }

    setState(() => _formStep++);
  }

  void _previousStep() {
    if (_formStep > 1) {
      setState(() => _formStep--);
    }
  }

  void _showError(String message) {
    Get.snackbar(
      "Erreur",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);

    final String finalUsername = '${_formData['firstName'].toLowerCase()}_${_formData['lastName'].toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';

    // Build email from phone if email not provided
    String email = _formData['email'].toString().trim();
    if (email.isEmpty && _formData['phoneNumber'].toString().isNotEmpty) {
      email = "${_formData['phoneNumber']}@temp.com";
    }

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    final success = await auth.registerArtisan(
      firstName: _formData['firstName'],
      lastName: _formData['lastName'],
      username: finalUsername,
      email: email,
      phoneNumber: _formData['phoneNumber'].toString(),
      password: _formData['password'],
      category: _formData['category'],
      province: _formData['province'],
      city: _formData['city'],
      district: _formData['district'],
      diplomaUrl: _formData['diplomaUrl'].toString(),
      officialDocUrl: _formData['officialDocUrl'].toString(),
      avatarUrl: _hasProfileImage ? _formData['avatarUrl'].toString() : null,
      experience: null,
    );

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _registrationStep = RegistrationStep.waiting);
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              const Text(
                'Photo de profil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajoutez une photo pour personnaliser votre profil',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _isUploadingProfileImage ? null : _pickProfileImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: const Color(0xFF2563EB), width: 2),
                  ),
                  child: _isUploadingProfileImage
                      ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                    ),
                  )
                      : _hasProfileImage
                      ? ClipOval(
                    child: Container(
                      color: Colors.green.shade100,
                      child: const Icon(Icons.check_circle, size: 48, color: Colors.green),
                    ),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 32, color: Color(0xFF2563EB)),
                      SizedBox(height: 8),
                      Text(
                        'Ajouter',
                        style: TextStyle(color: Color(0xFF2563EB), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _formData['firstName'],
                decoration: InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => _formData['firstName'] = value,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: _formData['lastName'],
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => _formData['lastName'] = value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _formData['category'].toString().isEmpty ? null : _formData['category'],
          decoration: InputDecoration(
            labelText: 'Catégorie *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _categories.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat));
          }).toList(),
          onChanged: (value) {
            setState(() => _formData['category'] = value ?? '');
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                child: DropdownButtonFormField<String>(
                  value: _formData['province'].toString().isEmpty ? null : _formData['province'],
                  decoration: InputDecoration(
                    labelText: 'Wilaya *',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  isExpanded: true,
                  items: _wilayas.map((wilaya) {
                    return DropdownMenuItem(value: wilaya, child: Text(wilaya));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _formData['province'] = value ?? '');
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: _formData['city'],
                decoration: InputDecoration(
                  labelText: 'Baladeya (Commune) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => _formData['city'] = value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _formData['district'].toString(),
          decoration: InputDecoration(
            labelText: 'Zone de service *',
            hintText: 'Rayon d\'intervention',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _zoneRadii.map((radius) {
            return DropdownMenuItem(value: radius, child: Text(radius));
          }).toList(),
          onChanged: (value) {
            setState(() => _formData['district'] = value ?? '5km');
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200, width: 2),
            borderRadius: BorderRadius.circular(16),
            color: Colors.blue.shade50,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.description, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text(
                      'Document officiel *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Pièce d\'identité, extrait de casier judiciaire, etc.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _isUploadingOfficialDoc ? null : _pickOfficialDoc,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: _isUploadingOfficialDoc
                            ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Téléchargement...',
                                style: TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                        )
                            : _hasOfficialDoc
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 40, color: Colors.green),
                            const SizedBox(height: 8),
                            Text(
                              'Document sélectionné',
                              style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cliquez pour changer',
                              style: TextStyle(color: Colors.blue.shade700, fontSize: 11),
                            ),
                          ],
                        )
                            : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 40, color: Color(0xFF2563EB)),
                            SizedBox(height: 12),
                            Text(
                              'Cliquez pour télécharger',
                              style: TextStyle(color: Color(0xFF2563EB), fontSize: 14),
                            ),
                            Text(
                              'PDF, PNG, JPG, etc.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade200, width: 2),
            borderRadius: BorderRadius.circular(16),
            color: Colors.blue.shade50,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.school, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text(
                      'Diplôme / Certification *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Téléchargez votre diplôme ou certification professionnelle',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _isUploadingDiploma ? null : _pickDiploma,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: _isUploadingDiploma
                            ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Téléchargement...',
                                style: TextStyle(fontSize: 12, color: Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                        )
                            : _hasDiploma
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 40, color: Colors.green),
                            const SizedBox(height: 8),
                            Text(
                              'Diplôme sélectionné',
                              style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cliquez pour changer',
                              style: TextStyle(color: Colors.blue.shade700, fontSize: 11),
                            ),
                          ],
                        )
                            : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 40, color: Color(0xFF2563EB)),
                            SizedBox(height: 12),
                            Text(
                              'Cliquez pour télécharger',
                              style: TextStyle(color: Color(0xFF2563EB), fontSize: 14),
                            ),
                            Text(
                              'PDF, PNG, JPG, etc.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: _formData['email'],
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Optionnel si téléphone fourni',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) => _formData['email'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['phoneNumber'],
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Numéro de téléphone',
            hintText: 'Optionnel si email fourni',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) => _formData['phoneNumber'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Mot de passe *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          onChanged: (value) => _formData['password'] = value,
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: !_showConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirmer mot de passe *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: IconButton(
              icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
          onChanged: (value) => _formData['confirmPassword'] = value,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_registrationStep == RegistrationStep.waiting) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.schedule, size: 32, color: Colors.amber),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Demande envoyée',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Votre demande d\'inscription a été envoyée avec succès!',
                      style: TextStyle(color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prochaines étapes :',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12),
                          Row(children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(child: Text('Votre dossier est en cours de vérification', style: TextStyle(fontSize: 13))),
                          ]),
                          SizedBox(height: 8),
                          Row(children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(child: Text('Vous recevrez une notification une fois approuvé', style: TextStyle(fontSize: 13))),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Get.offAllNamed('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Retour à la connexion'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Inscription Artisan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.toNamed('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress indicator
                  Row(
                    children: [
                      Expanded(child: Column(children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: _formStep >= 1 ? const Color(0xFF2563EB) : Colors.grey.shade200, shape: BoxShape.circle),
                            child: Center(child: Text('1', style: TextStyle(color: _formStep >= 1 ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)))),
                        const SizedBox(height: 4), const Text('Info perso', style: TextStyle(fontSize: 11)),
                      ])),
                      Expanded(child: Container(height: 2, color: _formStep > 1 ? const Color(0xFF2563EB) : Colors.grey.shade200)),
                      Expanded(child: Column(children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: _formStep >= 2 ? const Color(0xFF2563EB) : Colors.grey.shade200, shape: BoxShape.circle),
                            child: Center(child: Text('2', style: TextStyle(color: _formStep >= 2 ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)))),
                        const SizedBox(height: 4), const Text('Documents', style: TextStyle(fontSize: 11)),
                      ])),
                      Expanded(child: Container(height: 2, color: _formStep > 2 ? const Color(0xFF2563EB) : Colors.grey.shade200)),
                      Expanded(child: Column(children: [
                        Container(width: 36, height: 36, decoration: BoxDecoration(color: _formStep >= 3 ? const Color(0xFF2563EB) : Colors.grey.shade200, shape: BoxShape.circle),
                            child: Center(child: Text('3', style: TextStyle(color: _formStep >= 3 ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)))),
                        const SizedBox(height: 4), const Text('Compte', style: TextStyle(fontSize: 11)),
                      ])),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (_formStep == 1) _buildStep1(),
                  if (_formStep == 2) _buildStep2(),
                  if (_formStep == 3) _buildStep3(),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_formStep > 1) Expanded(child: OutlinedButton(onPressed: _previousStep, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: Color(0xFF2563EB))), child: const Text('Précédent'))),
                      if (_formStep > 1) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _nextStep,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          child: _isLoading && _formStep == 3
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                              : Text(_formStep == 3 ? "S'inscrire" : 'Suivant'),
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
    );
  }
}