
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      header: AppHeader(
        title: 'Fleet Incidents',
        backTo: AppScreen.dashboard,
        controller: controller,
      ),
      child: Column(
        children: const [
          IncidentCard(
            title: 'Route Blocked',
            body:
                'Jalan Margorejo Indah ditutup sementara karena perbaikan aspal.',
          ),
          SizedBox(height: 12),
          IncidentCard(
            title: 'Heavy Traffic',
            body:
                'Macet panjang di area Jemursari. Estimasi delay 15-20 menit.',
          ),
        ],
      ),
    );
  }
}
