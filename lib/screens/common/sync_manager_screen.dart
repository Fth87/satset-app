import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class SyncManagerScreen extends StatelessWidget {
  const SyncManagerScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      header: AppHeader(
        title: 'Sync Manager',
        backTo: AppScreen.dashboard,
        controller: controller,
      ),
      child: const Center(
        child: Text('Offline synchronization manager is coming soon.'),
      ),
    );
  }
}
