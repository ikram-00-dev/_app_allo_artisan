import 'package:flutter/material.dart';
import 'package:allo_artisan_gpt/core/theme/app_colors.dart';

class Utils {
  static void showSnackBar(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(message),
      ),
    );
  }

  static String formatRole(String role) {
    switch (role) {
      case "client":
        return "Client";

      case "artisan":
        return "Artisan";

      case "visitor":
        return "Visitor";

      default:
        return role;
    }
  }
}