
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.controller,
    required this.onToast,
  });

  final AppController controller;
  final void Function(String message, {bool isError}) onToast;

  @override
  State<ForgotPasswordScreen> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool submitted = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => widget.controller.go(AppScreen.login),
              icon: const Icon(Icons.arrow_back),
            ),
            const Spacer(),
            const Icon(Icons.key_outlined, size: 48),
            const SizedBox(height: 24),
            const Text(
              'Forgot Password',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              submitted
                  ? 'Instruksi reset kata sandi telah dikirim ke email Anda.'
                  : 'Masukkan email untuk menerima tautan pemulihan kata sandi.',
              style: const TextStyle(color: muted, height: 1.45),
            ),
            const SizedBox(height: 34),
            if (!submitted) ...[
              const FieldLabel('Email Address'),
              const TextField(
                decoration: InputDecoration(hintText: 'operator@smartlog.com'),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'Send Reset Link',
                onPressed: () {
                  setState(() => submitted = true);
                  widget.onToast('Reset link sent to your email');
                },
              ),
            ] else
              SecondaryButton(
                label: 'Back to Login',
                onPressed: () => widget.controller.go(AppScreen.login),
              ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
