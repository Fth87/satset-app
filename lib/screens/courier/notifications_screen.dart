
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      bottomPadding: 96,
      header: AppHeader(
        title: 'System Logs',
        backTo: AppScreen.dashboard,
        controller: controller,
      ),
      child: Column(
        children: const [
          LogCard(
            icon: Icons.warning_amber_rounded,
            title: 'Topology Override',
            time: '10m ago',
            body:
                'Routing diubah akibat deteksi anomali banjir di Sektor Kenjeran.',
          ),
          LogCard(
            icon: Icons.check_circle_outline,
            title: 'AI Resolution Success',
            time: '1h ago',
            body: 'Data alamat PKG-002 berhasil dipulihkan. Node diperbarui.',
          ),
          LogCard(
            icon: Icons.person_outline,
            title: 'Session Initiated',
            time: '08:00',
            body: 'Otentikasi berhasil. Selamat bertugas.',
          ),
        ],
      ),
    );
  }
}
