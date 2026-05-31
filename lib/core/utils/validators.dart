// lib/core/utils/validators.dart
import 'package:flutter/material.dart';

class AppValidators {
  // Common validators
  static String? requiredField(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional if phone is provided
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Veuillez entrer un email valide (exemple@domaine.com)';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional if email is provided
    }

    // Algerian phone number format
    final phoneRegex = RegExp(r'^(0[567][0-9]{8})$');

    String cleanedPhone = value.trim().replaceAll(RegExp(r'\s'), '');

    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Numéro invalide (ex: 0555123456 ou 0665123456)';
    }
    return null;
  }

  // Check if at least one contact method is provided
  static String? contactMethod(String? email, String? phone) {
    final hasEmail = email != null && email.trim().isNotEmpty;
    final hasPhone = phone != null && phone.trim().isNotEmpty;

    if (!hasEmail && !hasPhone) {
      return 'Veuillez fournir au moins un email ou un numéro de téléphone';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  static String? name(String? value, {String fieldName = 'Nom'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }

    if (value.trim().length < 2) {
      return '$fieldName doit contenir au moins 2 caractères';
    }

    if (value.trim().length > 50) {
      return '$fieldName ne peut pas dépasser 50 caractères';
    }

    // Simpler validation without complex regex
    final String trimmed = value.trim();
    for (int i = 0; i < trimmed.length; i++) {
      final int charCode = trimmed.codeUnitAt(i);
      final bool isLetter = (charCode >= 65 && charCode <= 90) || // A-Z
          (charCode >= 97 && charCode <= 122) || // a-z
          (charCode >= 192 && charCode <= 255) || // Accented characters
          charCode == 32 || // space
          charCode == 39 || // apostrophe
          charCode == 45;   // hyphen

      if (!isLetter) {
        return 'Format de $fieldName invalide (lettres seulement)';
      }
    }

    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom d\'utilisateur est requis';
    }

    if (value.trim().length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }

    if (value.trim().length > 30) {
      return 'Le nom d\'utilisateur ne peut pas dépasser 30 caractères';
    }

    // Letters, numbers, underscore, dot
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_.]+$');
    if (!usernameRegex.hasMatch(value.trim())) {
      return 'Utilisez seulement des lettres, chiffres, _ ou .';
    }

    return null;
  }

  static String? category(String? value) {
    if (value == null || value.isEmpty) {
      return 'La catégorie est requise';
    }
    return null;
  }

  static String? province(String? value) {
    if (value == null || value.isEmpty) {
      return 'La wilaya est requise';
    }
    return null;
  }

  static String? city(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La commune est requise';
    }

    if (value.trim().length < 2) {
      return 'Nom de commune invalide';
    }

    return null;
  }

  static String? district(String? value) {
    if (value == null || value.isEmpty) {
      return 'La zone/quartier est requis';
    }
    return null;
  }

  static String? experience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Les années d\'expérience sont requises';
    }

    final years = int.tryParse(value);
    if (years == null) {
      return 'Veuillez entrer un nombre valide';
    }

    if (years < 0) {
      return 'Les années d\'expérience ne peuvent pas être négatives';
    }

    if (years > 50) {
      return 'Expérience maximale de 50 ans';
    }

    return null;
  }

  static String? document(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le document officiel est requis';
    }
    return null;
  }

  static String? diploma(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le diplôme/certification est requis';
    }
    return null;
  }

  // Specific validators for Artisan registration
  static Map<String, String?> validateArtisanStep1(Map<String, dynamic> formData) {
    return {
      'firstName': name(formData['firstName'], fieldName: 'Prénom'),
      'lastName': name(formData['lastName'], fieldName: 'Nom'),
      'category': category(formData['category']),
      'province': province(formData['province']),
      'city': city(formData['city']),
      'district': district(formData['district']),
      'experience': experience(formData['experience']?.toString()),
    };
  }

  static Map<String, String?> validateArtisanStep2(Map<String, dynamic> formData) {
    return {
      'officialDoc': document(formData['officialDoc']),
      'diploma': diploma(formData['diploma']),
    };
  }

  static Map<String, String?> validateArtisanStep3(Map<String, dynamic> formData) {
    final emailError = email(formData['email']);
    final phoneError = phoneNumber(formData['phoneNumber']);
    final contactError = contactMethod(formData['email'], formData['phoneNumber']);

    return {
      'email': emailError,
      'phoneNumber': phoneError,
      'contactMethod': contactError,
      'password': password(formData['password']),
      'confirmPassword': confirmPassword(
        formData['confirmPassword'],
        formData['password'] ?? '',
      ),
    };
  }

  static bool isArtisanStep1Valid(Map<String, dynamic> formData) {
    final errors = validateArtisanStep1(formData);
    return errors.values.every((error) => error == null);
  }

  static bool isArtisanStep2Valid(Map<String, dynamic> formData) {
    final errors = validateArtisanStep2(formData);
    return errors.values.every((error) => error == null);
  }

  static bool isArtisanStep3Valid(Map<String, dynamic> formData) {
    final errors = validateArtisanStep3(formData);
    return errors['contactMethod'] == null &&
        errors['password'] == null &&
        errors['confirmPassword'] == null;
  }

  // Specific validators for Client registration
  static Map<String, String?> validateClientForm({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    final emailError = AppValidators.email(email);
    final phoneError = AppValidators.phoneNumber(phoneNumber);
    final contactError = AppValidators.contactMethod(email, phoneNumber);

    return {
      'username': AppValidators.username(username),
      'firstName': AppValidators.name(firstName, fieldName: 'Prénom'),
      'lastName': AppValidators.name(lastName, fieldName: 'Nom'),
      'email': emailError,
      'phoneNumber': phoneError,
      'contactMethod': contactError,
      'password': AppValidators.password(password),
      'confirmPassword': AppValidators.confirmPassword(confirmPassword, password),
    };
  }

  static bool isClientFormValid({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    final errors = validateClientForm(
      username: username,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
    );
    return errors['username'] == null &&
        errors['firstName'] == null &&
        errors['lastName'] == null &&
        errors['contactMethod'] == null &&
        errors['password'] == null &&
        errors['confirmPassword'] == null;
  }
}

// Extension for easy form validation in widgets
extension FormValidationExtension on GlobalKey<FormState> {
  bool isValid() {
    return currentState?.validate() ?? false;
  }

  void validateAndSave() {
    currentState?.validate();
    currentState?.save();
  }
}