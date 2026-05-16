
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../models/package.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class ClarificationScreen extends StatelessWidget {
  const ClarificationScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final packages = controller.packages.where(
      (p) => p.status == PackageStatus.clarification,
    );
    return ScrollPage(
      header: AppHeader(
        title: 'Anomaly Handling',
        backTo: AppScreen.dashboard,
        controller: controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppCard(
            child: Text(
              '1 paket sedang diklarifikasi oleh Agent via protokol eksternal.',
              style: TextStyle(color: muted, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          ...packages.map(
            (pkg) => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pkg.id, style: const TextStyle(color: muted)),
                  const SizedBox(height: 4),
                  Text(
                    pkg.recipient,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pkg.address,
                    style: const TextStyle(
                      color: muted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: line),
                    ),
                    child: const Text(
                      'Status Log: Menunggu respons data spesifik nomor blok dari pelanggan.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Manual',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Inject Data',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
