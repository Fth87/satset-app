
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;
  bool _isLoading = false;
  String? _localError;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _localError = 'Harap isi email dan password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _localError = null;
    });

    final success = await widget.controller.login(email, password);

    if (!mounted) return;

    if (!success) {
      setState(() {
        _isLoading = false;
        final error = widget.controller.errorMessage?.toLowerCase() ?? '';
        if (error.contains('invalid login credentials')) {
          _localError = 'Email atau password salah.';
        } else if (error.contains('network') || error.contains('socket')) {
          _localError = 'Masalah jaringan. Periksa koneksi internet Anda.';
        } else {
          _localError = 'Terjadi kesalahan. Silakan coba lagi.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayError = _localError ?? widget.controller.errorMessage;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _isLoading ? null : () => widget.controller.go(AppScreen.onboarding),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            const Icon(Icons.inventory_2_outlined, size: 48),
            const SizedBox(height: 28),
            const Text(
              'Operator Login',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Akses terminal pengiriman Anda.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 36),
            const FieldLabel('Email Address'),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              decoration: const InputDecoration(hintText: 'email@test.com'),
            ),
            const SizedBox(height: 22),
            const FieldLabel('Access Key'),
            TextField(
              controller: _passwordController,
              obscureText: !showPassword,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'password123',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => showPassword = !showPassword),
                  icon: Icon(
                    showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Checkbox(value: true, onChanged: _isLoading ? null : (_) {}),
                const Text('Remember Me'),
                const Spacer(),
                TextButton(
                  onPressed: _isLoading ? null : () =>
                      widget.controller.go(AppScreen.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            if (displayError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        displayError,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: _isLoading ? 'Authenticating...' : 'Login',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                MiniAction(icon: Icons.help_outline, label: 'Help'),
                SizedBox(width: 44),
                MiniAction(icon: Icons.headset_mic_outlined, label: 'Desk'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
