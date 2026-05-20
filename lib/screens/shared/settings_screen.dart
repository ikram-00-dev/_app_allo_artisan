import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final controller = Get.put(SettingsController(Get.find()));

  String openSection = "";

  @override
  void initState() {
    super.initState();
    controller.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text("Settings")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ================= PROFILE =================
            _section(
              title: "Profile",
              isOpen: openSection == "profile",
              onTap: () => setState(() {
                openSection = openSection == "profile" ? "" : "profile";
              }),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => controller.name.value = v,
                    controller: TextEditingController(text: controller.name.value),
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    onChanged: (v) => controller.phone.value = v,
                    decoration: const InputDecoration(labelText: "Phone"),
                  ),
                  TextField(
                    onChanged: (v) => controller.location.value = v,
                    decoration: const InputDecoration(labelText: "Location"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: controller.updateProfile,
                    child: const Text("Save Profile"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= LANGUAGE =================
            _section(
              title: "Language",
              isOpen: openSection == "lang",
              onTap: () => setState(() {
                openSection = openSection == "lang" ? "" : "lang";
              }),
              child: Column(
                children: [
                  RadioListTile(
                    value: "fr",
                    groupValue: controller.selectedLanguage.value,
                    onChanged: (v) => controller.selectedLanguage.value = v!,
                    title: const Text("Français"),
                  ),
                  RadioListTile(
                    value: "en",
                    groupValue: controller.selectedLanguage.value,
                    onChanged: (v) => controller.selectedLanguage.value = v!,
                    title: const Text("English"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ================= SECURITY =================
            _section(
              title: "Security",
              isOpen: openSection == "security",
              onTap: () => setState(() {
                openSection = openSection == "security" ? "" : "security";
              }),
              child: Column(
                children: [
                  TextField(
                    obscureText: true,
                    onChanged: (v) => controller.currentPassword = v,
                    decoration: const InputDecoration(labelText: "Current password"),
                  ),
                  TextField(
                    obscureText: true,
                    onChanged: (v) => controller.newPassword = v,
                    decoration: const InputDecoration(labelText: "New password"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: controller.changePassword,
                    child: const Text("Change Password"),
                  ),

                  const Divider(),

                  TextField(
                    onChanged: (v) => controller.newEmail = v,
                    decoration: const InputDecoration(labelText: "New Email"),
                  ),
                  TextField(
                    obscureText: true,
                    onChanged: (v) => controller.emailPassword = v,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  ElevatedButton(
                    onPressed: controller.changeEmail,
                    child: const Text("Change Email"),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _section({
    required String title,
    required bool isOpen,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(title),
            trailing: Icon(isOpen ? Icons.expand_less : Icons.expand_more),
            onTap: onTap,
          ),
          if (isOpen) Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}