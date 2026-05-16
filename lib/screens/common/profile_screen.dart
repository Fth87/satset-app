
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      bottomPadding: 96,
      onRefresh: () => controller.fetchProfile(),
      header: AppHeader(title: 'Operator & Settings', controller: controller),
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: surface,
                  child: Icon(Icons.person_outline, size: 44, color: ink),
                ),
                const SizedBox(height: 16),
                Text(
                  controller.profile?.name ?? 'Unknown',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Chip(label: Text('ID: ${controller.profile?.id.substring(0, 8) ?? 'N/A'}')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (controller.profile != null) ProfileInfo(profile: controller.profile!),
          const SizedBox(height: 16),
          MenuButton(
            label: 'Storage & Sync',
            icon: Icons.sync,
            onTap: () => controller.go(AppScreen.syncManager),
          ),
          MenuButton(
            label: 'System Preferences',
            icon: Icons.settings_outlined,
            onTap: () => controller.go(AppScreen.settings),
          ),
          MenuButton(
            label: 'Protocols & SOS',
            icon: Icons.help_outline,
            onTap: () => controller.go(AppScreen.help),
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Terminate Session',
            icon: Icons.logout,
            onPressed: controller.logout,
          ),
        ],
      ),
    );
  }
}
