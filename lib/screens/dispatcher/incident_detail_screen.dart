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
        title: 'Incident Detail',
        backTo: AppScreen.dispatcherDashboard,
        controller: controller,
      ),
      child: const Center(
        child: Text('Incident detail view is coming soon.'),
      ),
    );
  }
}
