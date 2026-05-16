
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class DispatcherAssignmentsScreen extends StatelessWidget {
  const DispatcherAssignmentsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      bottomPadding: 96,
      header: AppHeader(
        title: 'Package Assignment',
        backTo: AppScreen.dispatcherDashboard,
        controller: controller,
      ),
      child: Column(
        children: [
          for (var i = 1; i <= 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PKG-00${i + 4}',
                          style: const TextStyle(
                            color: muted,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Chip(label: Text('Courier C-8829$i')),
                      ],
                    ),
                    Text(
                      'Jl. Sudirman No. ${i * 10}',
                      style: const TextStyle(color: muted),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: 'Reassign',
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 56,
                          width: 56,
                          child: IconButton.filledTonal(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.close,
                              color: Colors.redAccent,
                            ),
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
