
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class RouteSummaryScreen extends StatelessWidget {
  const RouteSummaryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      header: AppHeader(
        title: 'Routing Protocol',
        backTo: AppScreen.dashboard,
        controller: controller,
      ),
      child: Column(
        children: [
          const AppCard(
            child: Column(
              children: [
                Icon(Icons.route_outlined, size: 38),
                SizedBox(height: 14),
                Text(
                  'ALGORITHM FINALIZED',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Observe -> Think -> Decide -> Act',
                  style: TextStyle(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const MetricList(
            rows: [
              ('Waypoints', '28 Nodes'),
              ('Est. Duration', '4h 15m'),
              ('Risk Factor', 'Medium'),
            ],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Accept & Initialize',
            onPressed: () => controller.go(AppScreen.manifest),
          ),
          const SizedBox(height: 10),
          SecondaryButton(label: 'Force Recalculate', onPressed: () {}),
        ],
      ),
    );
  }
}
