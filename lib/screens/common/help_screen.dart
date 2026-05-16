
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({
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
        title: 'Emergency Protocols',
        backTo: AppScreen.profile,
        controller: controller,
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              onToast('CRITICAL: SOS signal broadcasted.', isError: true);
              controller.go(AppScreen.dashboard);
            },
            child: Container(
              width: 184,
              height: 184,
              decoration: const BoxDecoration(
                color: ink,
                shape: BoxShape.circle,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.health_and_safety_outlined,
                    size: 54,
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Tombol darurat akan membekukan aktivitas dan memindahkan pengiriman ke unit cadangan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, height: 1.45),
          ),
          const SizedBox(height: 26),
          const MetricList(
            rows: [
              ('SOP', 'Benda Pecah Belah'),
              ('COD', 'Penolakan Transaksi'),
              ('Comm', 'Live Channel'),
            ],
          ),
        ],
      ),
    );
  }
}
