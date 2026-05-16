import 'package:flutter/material.dart';

import 'core/app_controller.dart';
import 'core/app_theme.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(const SmartLogisticsApp());
}

class SmartLogisticsApp extends StatefulWidget {
  const SmartLogisticsApp({super.key});

  @override
  State<SmartLogisticsApp> createState() => _SmartLogisticsAppState();
}

class _SmartLogisticsAppState extends State<SmartLogisticsApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Logistics',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: AppShell(controller: _controller),
        );
      },
    );
  }
}
