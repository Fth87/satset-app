
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class SyncManagerScreen extends StatelessWidget {
  const SyncManagerScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      header: AppHeader(
        title: 'Sync Subsystem',
        backTo: AppScreen.profile,
        controller: controller,
      ),
      child: Column(
        children: [
          const AppCard(
            child: Column(
              children: [
                Icon(Icons.wifi_off_outlined, size: 48),
                SizedBox(height: 16),
                Text(
                  '3 Payloads Pending',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'Data operasional tersimpan lokal dan dikirim otomatis saat koneksi optimal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 3; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PoD Payload: PKG-00$i',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Icon(Icons.schedule),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Force Synchronization',
            icon: Icons.sync,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
