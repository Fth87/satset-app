
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class DispatcherCenterScreen extends StatelessWidget {
  const DispatcherCenterScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      bottomPadding: 96,
      header: AppHeader(title: 'Incident & SOS Center', controller: controller),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Active Incidents'),
          const IncidentCard(
            title: 'Route Blocked',
            body:
                'Courier C-88291 reported route blockage due to construction.',
          ),
          const SizedBox(height: 20),
          const SectionLabel('SOS Alerts'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'CRITICAL EMERGENCY',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10),
                Text('Courier C-88293 triggered SOS. Vehicle breakdown.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
