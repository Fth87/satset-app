
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class DispatcherDashboardScreen extends StatelessWidget {
  const DispatcherDashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      bottomPadding: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeHeader(
            title: 'Dispatcher Dashboard',
            subtitle: 'Fleet Overview',
            roleLabel: 'Dispatcher',
            statusLabel: '2 zones need attention',
            onBell: () => controller.go(AppScreen.notifications),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: StatTile(value: '12', label: 'Active Couriers'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: StatTile(value: '245', label: 'Total Packages'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: StatTile(
                  value: '120',
                  label: 'Delivered',
                  icon: Icons.check,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: '118',
                  label: 'Pending',
                  icon: Icons.schedule,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: '7',
                  label: 'Failed',
                  icon: Icons.close,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sector B mengalami delay berat. Re-routing disarankan.',
                    style: TextStyle(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Open Live Fleet Map',
            icon: Icons.map_outlined,
            onPressed: () => controller.go(AppScreen.dispatcherLiveMap),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Manage Assignments',
            icon: Icons.groups_outlined,
            onPressed: () => controller.go(AppScreen.dispatcherAssignments),
          ),
        ],
      ),
    );
  }
}
