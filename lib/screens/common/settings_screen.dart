import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      header: AppHeader(
        title: 'System Prefs',
        backTo: AppScreen.profile,
        controller: controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Display & Audio'),
          AppCard(
            child: Column(
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Nav Audio Output'),
                  trailing: Chip(label: Text('ID_LANG')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Local Data Management'),
          const MetricList(
            rows: [
              ('Offline Map Sector', 'Surabaya 120MB'),
              ('Cache', 'Purge Cache'),
            ],
          ),
          const SizedBox(height: 22),
          const SectionLabel('Account'),
          AppCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              onTap: () => controller.logout(),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
