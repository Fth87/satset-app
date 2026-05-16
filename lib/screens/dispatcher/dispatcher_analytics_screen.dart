
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_shell_widgets.dart';

class DispatcherAnalyticsScreen extends StatelessWidget {
  const DispatcherAnalyticsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MetricsPage(
      controller: controller,
      title: 'Analytics & Reports',
      mainLabel: 'Delivery Success Rate',
      mainValue: '96.5%',
      progress: .965,
    );
  }
}
