import 'package:flutter/material.dart';
import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // The AppController already handles the initial auth check and routing.
    // We just show a loading state here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 120),
            const SizedBox(height: 24),
            const Text(
              'SatSet',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: ink,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ink),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
