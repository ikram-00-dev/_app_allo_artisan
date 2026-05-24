// lib/screens/auth/register_artisan_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

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
    'district': '',
    'email': '',
    'phoneNumber': '',
    'password': '',
    'confirmPassword': '',
    'diploma': '',
    'officialDoc': '',
    'profileImage': '',
  };

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  final List<String> _wilayas = [
    'Alger', 'Oran', 'Constantine', 'Annaba', 'Blida', 'Batna', 'Djelfa',
    'Sétif', 'Sidi Bel Abbès', 'Biskra', 'Tébessa', 'El Oued', 'Skikda',
    'Tizi Ouzou', 'Béjaïa', 'Tlemcen', 'Mostaganem',
  ];

  final List<String> _categories = [
    'Plomberie', 'Électricité', 'Menuiserie', 'Peinture', 'Maçonnerie',
    'Jardinage', 'Climatisation', 'Carrelage', 'Plâtrerie', 'Soudure',
    'Électronique', 'Informatique', 'Cuisine',
  ];

  void _nextStep() {
    if (_formStep == 1) {
      if (_formData['firstName'].isEmpty ||
          _formData['lastName'].isEmpty ||
          _formData['category'].isEmpty ||
          _formData['province'].isEmpty ||
          _formData['city'].isEmpty ||
          _formData['district'].isEmpty) {
        _showError('Veuillez remplir tous les champs');
        return;
      }
    } else if (_formStep == 2) {
      // Documents are optional - no validation
    } else if (_formStep == 3) {
      if (_formData['email'].isEmpty ||
          _formData['phoneNumber'].isEmpty ||
          _formData['password'].isEmpty ||
          _formData['confirmPassword'].isEmpty) {
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

    final String finalUsername = '${_formData['firstName'].toLowerCase()}_${_formData['lastName'].toLowerCase()}';

    final success = await auth.registerArtisan(
      firstName: _formData['firstName'],
      lastName: _formData['lastName'],
      username: finalUsername,
      email: _formData['email'],
      password: _formData['password'],
      phoneNumber: _formData['phoneNumber'],
      category: _formData['category'],
      province: _formData['province'],
      city: _formData['city'],
      district: _formData['district'],
      diplomaUrl: _formData['diploma'].toString().isNotEmpty ? _formData['diploma'] : null,
      officialDocUrl: _formData['officialDoc'].toString().isNotEmpty ? _formData['officialDoc'] : null,
      avatarUrl: _formData['profileImage'].toString().isNotEmpty ? _formData['profileImage'] : null,
      experience: null,
    );

    setState(() => _isLoading = false);

    if (success) {
      setState(() => _registrationStep = RegistrationStep.waiting);
    }
  }

  // ============================================================
  // STEP 1: Informations personnelles + Profile Image
  // ============================================================
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              const Text(
                'Photo de profil *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajoutez une photo pour personnaliser votre profil',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Get.snackbar('Info', 'Fonctionnalité à venir');
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(color: const Color(0xFF2563EB), width: 2),
                  ),
                  child: _formData['profileImage'].toString().isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      _formData['profileImage'],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _formData['province'].toString().isEmpty ? null : _formData['province'],
                decoration: InputDecoration(
                  labelText: 'Wilaya *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _wilayas.map((wilaya) {
                  return DropdownMenuItem(value: wilaya, child: Text(wilaya));
                }).toList(),
                onChanged: (value) {
                  setState(() => _formData['province'] = value ?? '');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: _formData['city'],
                decoration: InputDecoration(
                  labelText: 'Baladeya (Commune) *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => _formData['city'] = value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _formData['district'],
          decoration: InputDecoration(
            labelText: 'Zone *',
            hintText: 'Ex: Centre-ville, Quartier résidentiel...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) => _formData['district'] = value,
        ),
      ],
    );
  }

  // ============================================================
  // STEP 2: Upload documents (Optional)
  // ============================================================
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2563EB),
                      ),
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
                      onTap: () {
                        Get.snackbar('Info', 'Fonctionnalité à venir');
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 40, color: Color(0xFF2563EB)),
                            SizedBox(height: 12),
                            Text(
                              'Cliquez pour télécharger',
                              style: TextStyle(color: Color(0xFF2563EB), fontSize: 14),
                            ),
                            Text(
                              'PDF, PNG, JPG (Max 5MB)',
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2563EB),
                      ),
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
                      onTap: () {
                        Get.snackbar('Info', 'Fonctionnalité à venir');
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 40, color: Color(0xFF2563EB)),
                            SizedBox(height: 12),
                            Text(
                              'Cliquez pour télécharger',
                              style: TextStyle(color: Color(0xFF2563EB), fontSize: 14),
                            ),
                            Text(
                              'PDF, PNG, JPG (Max 5MB)',
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

  // ============================================================
  // STEP 3: Compte
  // ============================================================
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: _formData['email'],
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            labelText: 'Numéro de téléphone *',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                      'Inscription en cours',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      const Text(
                        'Votre compte a été créé avec succès!',
                        style: TextStyle(color: Colors.green),
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
                          Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Votre compte est actif',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Vous pouvez maintenant vous connecter',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Aller à la connexion'),
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
                  // ============================================================
                  // PROGRESS INDICATOR - EQUAL SPACING WITH LABELS UNDER BUBBLES
                  // ============================================================
                  Column(
                    children: [
                      // Row for bubbles and lines
                      Row(
                        children: [
                          // Step 1 bubble
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _formStep >= 1 ? const Color(0xFF2563EB) : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        color: _formStep >= 1 ? Colors.white : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Info perso',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          // Line between 1 and 2
                          Expanded(
                            child: Container(
                              height: 2,
                              color: _formStep > 1 ? const Color(0xFF2563EB) : Colors.grey.shade200,
                            ),
                          ),
                          // Step 2 bubble
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _formStep >= 2 ? const Color(0xFF2563EB) : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
                                      style: TextStyle(
                                        color: _formStep >= 2 ? Colors.white : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Documents',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          // Line between 2 and 3
                          Expanded(
                            child: Container(
                              height: 2,
                              color: _formStep > 2 ? const Color(0xFF2563EB) : Colors.grey.shade200,
                            ),
                          ),
                          // Step 3 bubble
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _formStep >= 3 ? const Color(0xFF2563EB) : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '3',
                                      style: TextStyle(
                                        color: _formStep >= 3 ? Colors.white : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Compte',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Form steps
                  if (_formStep == 1) _buildStep1(),
                  if (_formStep == 2) _buildStep2(),
                  if (_formStep == 3) _buildStep3(),

                  const SizedBox(height: 24),

                  // Navigation buttons
                  Row(
                    children: [
                      if (_formStep > 1)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                            ),
                            child: const Text('Précédent'),
                          ),
                        ),
                      if (_formStep > 1) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading && _formStep == 3
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
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