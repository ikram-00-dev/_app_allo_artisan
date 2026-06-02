// switch_account_button.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/switch_account_controller.dart';
import '/controllers/auth_controller.dart';

class SwitchAccountButton extends StatelessWidget {
  final bool showIcon;
  final bool showLabel;
  final double? width;
  final double? height;

  const SwitchAccountButton({
    Key? key,
    this.showIcon = true,
    this.showLabel = true,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final SwitchAccountController switchController = Get.put(SwitchAccountController());

    return Obx(() {
      if (switchController.checkingAccount.value) {
        return Container(
          width: width ?? 40,
          height: height ?? 40,
          padding: const EdgeInsets.all(8),
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      }

      return ElevatedButton(
        onPressed: switchController.isLoading.value
            ? null
            : () => switchController.switchAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[800],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          minimumSize: width != null && height != null
              ? Size(width!, height!)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: switchController.isLoading.value
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                authController.isClient ? Icons.construction : Icons.person,
                size: 20,
              ),
              if (showLabel) const SizedBox(width: 8),
            ],
            if (showLabel)
              Text(
                authController.isClient
                    ? 'Passer en mode Artisan'
                    : 'Passer en mode Client',
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
      );
    });
  }
}