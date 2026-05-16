
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_shell_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MetricsPage(
      controller: controller,
      title: 'Telemetry & Metrics',
      mainLabel: 'Punctuality Index',
      mainValue: '94%',
      progress: .94,
    );
  }
}
