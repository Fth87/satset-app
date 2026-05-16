
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({
    super.key,
    required this.controller,
    required this.onToast,
  });

  final AppController controller;
  final void Function(String message, {bool isError}) onToast;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      header: AppHeader(
        title: 'Incident Report',
        backTo: AppScreen.dashboard,
        trailing: IconButton(
          onPressed: () => controller.go(AppScreen.incidentDetail),
          icon: const Icon(Icons.list_alt),
        ),
        controller: controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppCard(
            child: Text(
              'Gunakan form ini untuk mencatat gangguan, kecelakaan, atau kejadian lain selama pengiriman.',
              style: TextStyle(color: muted, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('Jenis Insiden'),
                DropdownButtonFormField<String>(
                  initialValue: 'Delay',
                  items: const [
                    DropdownMenuItem(value: 'Delay', child: Text('Delay')),
                    DropdownMenuItem(
                      value: 'Vehicle Issue',
                      child: Text('Vehicle Issue'),
                    ),
                    DropdownMenuItem(
                      value: 'Package Damage',
                      child: Text('Package Damage'),
                    ),
                    DropdownMenuItem(
                      value: 'Route Blocked',
                      child: Text('Route Blocked'),
                    ),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: 18),
                const FieldLabel('Detail'),
                const TextField(
                  minLines: 4,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan apa yang terjadi...',
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Submit Report',
                  onPressed: () {
                    onToast('Incident report submitted');
                    controller.go(AppScreen.dashboard);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
