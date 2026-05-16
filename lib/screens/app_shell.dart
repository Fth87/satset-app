import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../data/mock_logistics_data.dart';
import '../models/package.dart';
import '../widgets/app_widgets.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String? _toast;
  bool _toastIsError = false;
  Timer? _toastTimer;

  void _showToast(String message, {bool isError = false}) {
    _toastTimer?.cancel();
    setState(() {
      _toast = message;
      _toastIsError = isError;
    });
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _buildScreen();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: current,
                ),
              ),
              if (_showBottomNav) _BottomNav(controller: widget.controller),
              if (_toast != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AppToast(message: _toast!, isError: _toastIsError),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _showBottomNav {
    return {
      AppScreen.dashboard,
      AppScreen.manifest,
      AppScreen.mapNav,
      AppScreen.notifications,
      AppScreen.profile,
      AppScreen.dispatcherDashboard,
      AppScreen.dispatcherLiveMap,
      AppScreen.dispatcherAssignments,
      AppScreen.dispatcherCenter,
      AppScreen.dispatcherAnalytics,
    }.contains(widget.controller.screen);
  }

  Widget _buildScreen() {
    final c = widget.controller;
    return switch (c.screen) {
      AppScreen.splash => SplashScreen(controller: c),
      AppScreen.login => LoginScreen(controller: c),
      AppScreen.forgotPassword => ForgotPasswordScreen(
        controller: c,
        onToast: _showToast,
      ),
      AppScreen.dashboard => DashboardScreen(controller: c),
      AppScreen.scanner => ScannerScreen(controller: c, onToast: _showToast),
      AppScreen.routeSummary => RouteSummaryScreen(controller: c),
      AppScreen.manifest => ManifestScreen(controller: c),
      AppScreen.clarification => ClarificationScreen(controller: c),
      AppScreen.incidentReport => IncidentReportScreen(
        controller: c,
        onToast: _showToast,
      ),
      AppScreen.mapNav => MapNavScreen(controller: c),
      AppScreen.deliveryDetail => DeliveryDetailScreen(controller: c),
      AppScreen.pod => PodScreen(controller: c, onToast: _showToast),
      AppScreen.history => HistoryScreen(controller: c),
      AppScreen.notifications => NotificationsScreen(controller: c),
      AppScreen.profile => ProfileScreen(controller: c),
      AppScreen.help => HelpScreen(controller: c, onToast: _showToast),
      AppScreen.settings => SettingsScreen(controller: c),
      AppScreen.syncManager => SyncManagerScreen(controller: c),
      AppScreen.dispatcherDashboard => DispatcherDashboardScreen(controller: c),
      AppScreen.dispatcherLiveMap => DispatcherLiveMapScreen(controller: c),
      AppScreen.dispatcherAssignments => DispatcherAssignmentsScreen(
        controller: c,
      ),
      AppScreen.dispatcherCenter => DispatcherCenterScreen(controller: c),
      AppScreen.dispatcherAnalytics => DispatcherAnalyticsScreen(controller: c),
      AppScreen.incidentDetail => IncidentDetailScreen(controller: c),
    };
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int step = 0;

  static const slides = [
    (
      Icons.navigation_outlined,
      'Neo-Industrial Routing',
      'Routing presisi tinggi didukung AI Agentic.',
    ),
    (
      Icons.document_scanner_outlined,
      'Scan & Extract',
      'Otomatisasi pembacaan resi dan ekstraksi data lokasi.',
    ),
    (
      Icons.sync_outlined,
      'Self-Healing Logistics',
      'Sistem cerdas memulihkan kendala alamat secara independen.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final slide = slides[step];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Icon(slide.$1, size: 64, color: ink),
            const SizedBox(height: 28),
            Text(
              slide.$2,
              style: const TextStyle(
                fontSize: 28,
                height: 1.05,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              slide.$3,
              style: const TextStyle(color: muted, fontSize: 16, height: 1.45),
            ),
            const Spacer(),
            Row(
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: 34,
                  height: 4,
                  margin: const EdgeInsets.only(right: 8),
                  color: i == step ? ink : line,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: SecondaryButton(
                      label: 'Back',
                      onPressed: () => setState(() => step--),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: step < 2 ? 'Next' : 'Get Started',
                    onPressed: () {
                      if (step < 2) {
                        setState(() => step++);
                      } else {
                        widget.controller.go(AppScreen.login);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const _FieldLabel('Email Address'),
            const TextField(
              keyboardType: TextInputType.emailAddress,
              controller: null,
              decoration: InputDecoration(hintText: 'budi@smartlog.com'),
            ),
            const SizedBox(height: 22),
            const _FieldLabel('Access Key'),
            TextField(
              obscureText: !showPassword,
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
                Checkbox(value: true, onChanged: (_) {}),
                const Text('Remember Me'),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      widget.controller.go(AppScreen.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Courier',
                    onPressed: () => widget.controller.login(UserRole.courier),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Dispatch',
                    onPressed: () =>
                        widget.controller.login(UserRole.dispatcher),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _MiniAction(icon: Icons.help_outline, label: 'Help'),
                SizedBox(width: 44),
                _MiniAction(icon: Icons.headset_mic_outlined, label: 'Desk'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.controller,
    required this.onToast,
  });

  final AppController controller;
  final void Function(String message, {bool isError}) onToast;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
              const _FieldLabel('Email Address'),
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      bottomPadding: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHeader(
            title: 'Overview',
            subtitle: 'Sat, 16 May',
            onBell: () => controller.go(AppScreen.notifications),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: .78,
            children: const [
              StatTile(value: '42', label: 'Total'),
              StatTile(value: '12', label: 'Done', icon: Icons.check),
              StatTile(value: '28', label: 'Pend', icon: Icons.schedule),
              StatTile(value: '2', label: 'Fail', icon: Icons.close),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _InsightCard(
                  label: 'Weather',
                  value: '32 deg',
                  body: 'Clear conditions expected.',
                  icon: Icons.wb_sunny_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InsightCard(
                  label: 'Traffic',
                  value: 'Moderate',
                  body: '+12m delay on route.',
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '42 Packages Total',
                  style: TextStyle(
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: const [
                    Text('Route Progress'),
                    Spacer(),
                    Text('12 / 42', style: TextStyle(color: muted)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: .28,
                    minHeight: 8,
                    backgroundColor: line,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'EST. COMPLETION 16:30',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Start Route',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => controller.go(AppScreen.routeSummary),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: 'Scan New Package',
                  icon: Icons.document_scanner_outlined,
                  onPressed: () => controller.go(AppScreen.scanner),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel('AI Agents Subsystem'),
          Row(
            children: [
              const Expanded(
                child: _AgentTile(
                  icon: Icons.document_scanner,
                  title: 'OCR',
                  subtitle: 'Active',
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _AgentTile(
                  icon: Icons.map_outlined,
                  title: 'Route',
                  subtitle: 'Optimizing',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.go(AppScreen.clarification),
                  child: const _AgentTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Comm AI',
                    subtitle: '1 Action',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.controller,
    required this.onToast,
  });

  final AppController controller;
  final void Function(String message, {bool isError}) onToast;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ink,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            widget.controller.go(AppScreen.dashboard),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          'DATA EXTRACTION',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Icon(Icons.image_outlined, color: Colors.white),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Stack(
                        children: const [
                          Positioned.fill(child: _ScanGrid()),
                          Center(
                            child: Icon(
                              Icons.document_scanner_outlined,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!scanned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: GestureDetector(
                      onTap: () => setState(() => scanned = true),
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 4),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 260),
              ],
            ),
            if (scanned)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Chip(label: Text('MATCH: 98%')),
                          Spacer(),
                          Text('VALID SYNTAX', style: TextStyle(color: muted)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _FieldLabel('Recipient'),
                      const Text('Joko Anwar', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const _FieldLabel('Extracted Address'),
                      const Text(
                        'Jl. Darmo Permai II No. 14, Pradahkalikendal, Dukuhpakis, Surabaya 60226',
                        style: TextStyle(height: 1.4),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: SecondaryButton(
                              label: 'Retake',
                              onPressed: () => setState(() => scanned = false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Commit',
                              onPressed: () {
                                widget.onToast('Payload injected to Manifest');
                                widget.controller.go(AppScreen.dashboard);
                              },
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
      ),
    );
  }
}

class RouteSummaryScreen extends StatelessWidget {
  const RouteSummaryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
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
          const _MetricList(
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

class ManifestScreen extends StatelessWidget {
  const ManifestScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      bottomPadding: 96,
      header: AppHeader(
        title: 'Active Manifest',
        backTo: AppScreen.dashboard,
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
        ),
        controller: controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _FilterChip(label: 'Global (42)', active: true),
                _FilterChip(label: 'Pending (28)'),
                _FilterChip(label: 'Anomaly (1)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...mockPackages.map(
            (pkg) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PackageCard(package: pkg, controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}

class ClarificationScreen extends StatelessWidget {
  const ClarificationScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final packages = mockPackages.where(
      (p) => p.status == PackageStatus.clarification,
    );
    return _ScrollPage(
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

class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({
    super.key,
    required this.controller,
    required this.onToast,
  });

  final AppController controller;
  final void Function(String message, {bool isError}) onToast;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      header: AppHeader(
        title: 'Incident Report',
        backTo: AppScreen.dashboard,
        trailing: IconButton(
          onPressed: () => controller.go(AppScreen.incidentDetail),
          icon: const Icon(Icons.list_alt),
        ),
        controller: controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppCard(
            child: Text(
              'Gunakan form ini untuk mencatat gangguan, kecelakaan, atau kejadian lain selama pengiriman.',
              style: TextStyle(color: muted, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Jenis Insiden'),
                DropdownButtonFormField<String>(
                  initialValue: 'Delay',
                  items: const [
                    DropdownMenuItem(value: 'Delay', child: Text('Delay')),
                    DropdownMenuItem(
                      value: 'Vehicle Issue',
                      child: Text('Vehicle Issue'),
                    ),
                    DropdownMenuItem(
                      value: 'Package Damage',
                      child: Text('Package Damage'),
                    ),
                    DropdownMenuItem(
                      value: 'Route Blocked',
                      child: Text('Route Blocked'),
                    ),
                  ],
                  onChanged: (_) {},
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Detail'),
                const TextField(
                  minLines: 4,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan apa yang terjadi...',
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Submit Report',
                  onPressed: () {
                    onToast('Incident report submitted');
                    controller.go(AppScreen.dashboard);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MapNavScreen extends StatelessWidget {
  const MapNavScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _MapMock()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AppCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: const [
                  Icon(Icons.navigation, size: 34),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '250m',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Turn Left - Jl. Margorejo Indah',
                          style: TextStyle(color: muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ink, width: 4),
            ),
            child: const Icon(Icons.navigation, color: ink),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '10:30 ETA',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '1.2 km - 5 min remaining',
                            style: TextStyle(color: muted),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => controller.go(AppScreen.incidentReport),
                      icon: const Icon(Icons.warning_amber_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 58,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => controller.go(AppScreen.manifest),
                        child: const Icon(Icons.close),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Confirm Arrival',
                        onPressed: () => controller.go(
                          AppScreen.deliveryDetail,
                          package: mockPackages.first,
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
    );
  }
}

class DeliveryDetailScreen extends StatelessWidget {
  const DeliveryDetailScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final pkg = controller.selectedPackage ?? mockPackages.first;
    return _ScrollPage(
      bottomPadding: 92,
      header: AppHeader(
        title: 'Payload Data',
        backTo: AppScreen.manifest,
        controller: controller,
      ),
      child: Column(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      pkg.id,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    Chip(label: Text('Class: ${pkg.priority}')),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  pkg.recipient,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pkg.address,
                        style: const TextStyle(color: muted, height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Call',
                        icon: Icons.call,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Comm',
                        icon: Icons.chat,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ChatLog(),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Execute Handover',
            onPressed: () => controller.go(AppScreen.pod),
          ),
        ],
      ),
    );
  }
}

class PodScreen extends StatelessWidget {
  const PodScreen({super.key, required this.controller, required this.onToast});

  final AppController controller;
  final void Function(String message, {bool isError}) onToast;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      header: AppHeader(
        title: 'Handover Protocol',
        backTo: AppScreen.deliveryDetail,
        controller: controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Final State'),
          DropdownButtonFormField<String>(
            initialValue: 'Success - Direct Handover',
            items: const [
              DropdownMenuItem(
                value: 'Success - Direct Handover',
                child: Text('Success - Direct Handover'),
              ),
              DropdownMenuItem(
                value: 'Success - Security',
                child: Text('Success - Security/Reception'),
              ),
              DropdownMenuItem(
                value: 'Abort - Empty',
                child: Text('Abort - Location Empty'),
              ),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 20),
          const _EvidenceBox(
            label: 'Capture Media',
            icon: Icons.camera_alt_outlined,
            height: 190,
          ),
          const SizedBox(height: 20),
          const _EvidenceBox(
            label: 'Draw Input',
            icon: Icons.draw_outlined,
            height: 130,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Finalize Entry',
            onPressed: () {
              onToast('Transaction committed');
              controller.go(AppScreen.dashboard);
            },
          ),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _MetricsPage(
      controller: controller,
      title: 'Telemetry & Metrics',
      mainLabel: 'Punctuality Index',
      mainValue: '94%',
      progress: .94,
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      bottomPadding: 96,
      header: AppHeader(
        title: 'System Logs',
        backTo: AppScreen.dashboard,
        controller: controller,
      ),
      child: Column(
        children: const [
          _LogCard(
            icon: Icons.warning_amber_rounded,
            title: 'Topology Override',
            time: '10m ago',
            body:
                'Routing diubah akibat deteksi anomali banjir di Sektor Kenjeran.',
          ),
          _LogCard(
            icon: Icons.check_circle_outline,
            title: 'AI Resolution Success',
            time: '1h ago',
            body: 'Data alamat PKG-002 berhasil dipulihkan. Node diperbarui.',
          ),
          _LogCard(
            icon: Icons.person_outline,
            title: 'Session Initiated',
            time: '08:00',
            body: 'Otentikasi berhasil. Selamat bertugas.',
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      bottomPadding: 96,
      header: AppHeader(title: 'Operator & Settings', controller: controller),
      child: Column(
        children: [
          const AppCard(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: surface,
                  child: Icon(Icons.person_outline, size: 44, color: ink),
                ),
                SizedBox(height: 16),
                Text(
                  'Budi Santoso',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Chip(label: Text('ID: C-88291')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ProfileInfo(),
          const SizedBox(height: 16),
          _MenuButton(
            label: 'Storage & Sync',
            icon: Icons.sync,
            onTap: () => controller.go(AppScreen.syncManager),
          ),
          _MenuButton(
            label: 'System Preferences',
            icon: Icons.settings_outlined,
            onTap: () => controller.go(AppScreen.settings),
          ),
          _MenuButton(
            label: 'Protocols & SOS',
            icon: Icons.help_outline,
            onTap: () => controller.go(AppScreen.help),
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Terminate Session',
            icon: Icons.logout,
            onPressed: controller.logout,
          ),
        ],
      ),
    );
  }
}

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
    return _ScrollPage(
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
          const _MetricList(
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      header: AppHeader(
        title: 'System Prefs',
        backTo: AppScreen.profile,
        controller: controller,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Display & Audio'),
          AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Color Mode'),
                  value: controller.isDarkMode,
                  onChanged: (_) => controller.toggleTheme(),
                ),
                const Divider(),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Nav Audio Output'),
                  trailing: Chip(label: Text('ID_LANG')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Local Data Management'),
          const _MetricList(
            rows: [
              ('Offline Map Sector', 'Surabaya 120MB'),
              ('Cache', 'Purge Cache'),
            ],
          ),
        ],
      ),
    );
  }
}

class SyncManagerScreen extends StatelessWidget {
  const SyncManagerScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      header: AppHeader(
        title: 'Sync Subsystem',
        backTo: AppScreen.profile,
        controller: controller,
      ),
      child: Column(
        children: [
          const AppCard(
            child: Column(
              children: [
                Icon(Icons.wifi_off_outlined, size: 48),
                SizedBox(height: 16),
                Text(
                  '3 Payloads Pending',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'Data operasional tersimpan lokal dan dikirim otomatis saat koneksi optimal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 3; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PoD Payload: PKG-00$i',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Icon(Icons.schedule),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Force Synchronization',
            icon: Icons.sync,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class DispatcherDashboardScreen extends StatelessWidget {
  const DispatcherDashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      bottomPadding: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHeader(
            title: 'Dispatcher Dashboard',
            subtitle: 'Fleet Overview',
            onBell: () => controller.go(AppScreen.notifications),
          ),
          const SizedBox(height: 16),
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

class DispatcherLiveMapScreen extends StatelessWidget {
  const DispatcherLiveMapScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            AppHeader(
              title: 'Live Fleet Map',
              backTo: AppScreen.dispatcherDashboard,
              controller: controller,
            ),
            const Expanded(child: _MapMock(fleet: true)),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 92),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _MiniAction(icon: Icons.center_focus_strong, label: 'Focus'),
                  _MiniAction(icon: Icons.call_outlined, label: 'Contact'),
                  _MiniAction(icon: Icons.person_outline, label: 'Details'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DispatcherAssignmentsScreen extends StatelessWidget {
  const DispatcherAssignmentsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
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

class DispatcherCenterScreen extends StatelessWidget {
  const DispatcherCenterScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      bottomPadding: 96,
      header: AppHeader(title: 'Incident & SOS Center', controller: controller),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Active Incidents'),
          const _IncidentCard(
            title: 'Route Blocked',
            body:
                'Courier C-88291 reported route blockage due to construction.',
          ),
          const SizedBox(height: 20),
          const SectionLabel('SOS Alerts'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'CRITICAL EMERGENCY',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 10),
                Text('Courier C-88293 triggered SOS. Vehicle breakdown.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DispatcherAnalyticsScreen extends StatelessWidget {
  const DispatcherAnalyticsScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _MetricsPage(
      controller: controller,
      title: 'Analytics & Reports',
      mainLabel: 'Delivery Success Rate',
      mainValue: '96.5%',
      progress: .965,
    );
  }
}

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      header: AppHeader(
        title: 'Fleet Incidents',
        backTo: AppScreen.dashboard,
        controller: controller,
      ),
      child: Column(
        children: const [
          _IncidentCard(
            title: 'Route Blocked',
            body:
                'Jalan Margorejo Indah ditutup sementara karena perbaikan aspal.',
          ),
          SizedBox(height: 12),
          _IncidentCard(
            title: 'Heavy Traffic',
            body:
                'Macet panjang di area Jemursari. Estimasi delay 15-20 menit.',
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isDispatcher = controller.role == UserRole.dispatcher;
    final items = isDispatcher
        ? const [
            (AppScreen.dispatcherDashboard, Icons.inventory_2_outlined, 'Home'),
            (AppScreen.dispatcherLiveMap, Icons.map_outlined, 'Map'),
            (AppScreen.dispatcherAssignments, Icons.list_alt, 'Assign'),
            (AppScreen.dispatcherCenter, Icons.shield_outlined, 'Center'),
            (AppScreen.dispatcherAnalytics, Icons.bar_chart, 'Reports'),
          ]
        : const [
            (AppScreen.dashboard, Icons.inventory_2_outlined, 'Home'),
            (AppScreen.manifest, Icons.inventory_outlined, 'Manifest'),
            (AppScreen.mapNav, Icons.map_outlined, 'Map'),
            (AppScreen.profile, Icons.person_outline, 'Profile'),
          ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: line)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (!isDispatcher && i == 2)
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: SizedBox(
                      width: 62,
                      child: IconButton.filled(
                        onPressed: () => controller.go(AppScreen.scanner),
                        icon: const Icon(Icons.document_scanner_outlined),
                      ),
                    ),
                  ),
                Expanded(
                  child: _NavItem(
                    active: controller.screen == items[i].$1,
                    icon: items[i].$2,
                    label: items[i].$3,
                    onTap: () => controller.go(items[i].$1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? ink : muted, size: 22),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? ink : muted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollPage extends StatelessWidget {
  const _ScrollPage({
    required this.child,
    this.header,
    this.bottomPadding = 24,
  });

  final Widget child;
  final Widget? header;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ?header,
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
            children: [child],
          ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.title,
    required this.subtitle,
    required this.onBell,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle.toUpperCase(),
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton.outlined(
            onPressed: onBell,
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.controller});

  final DeliveryPackage package;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.go(AppScreen.deliveryDetail, package: package),
      borderRadius: BorderRadius.circular(24),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.id,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.recipient,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(package: package),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              package.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: muted),
            ),
            if (package.status == PackageStatus.pending) ...[
              const SizedBox(height: 16),
              SecondaryButton(
                label: 'Navigate Vector',
                icon: Icons.navigation_outlined,
                onPressed: () =>
                    controller.go(AppScreen.mapNav, package: package),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.package});

  final DeliveryPackage package;

  @override
  Widget build(BuildContext context) {
    final text = switch (package.status) {
      PackageStatus.pending => package.eta,
      PackageStatus.clarification => 'Comm AI',
      PackageStatus.delivered => 'Done',
    };
    return Chip(label: Text(text));
  }
}

class _ChatLog extends StatelessWidget {
  const _ChatLog();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMMUNICATION LOG',
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          for (final msg in mockChat)
            Align(
              alignment: msg.sender == 'ai'
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  color: msg.sender == 'ai' ? surface : ink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.sender == 'ai' ? ink : Colors.white,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      msg.time,
                      style: const TextStyle(color: muted, fontSize: 10),
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

class _MetricsPage extends StatelessWidget {
  const _MetricsPage({
    required this.controller,
    required this.title,
    required this.mainLabel,
    required this.mainValue,
    required this.progress,
  });

  final AppController controller;
  final String title;
  final String mainLabel;
  final String mainValue;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return _ScrollPage(
      bottomPadding: 96,
      header: AppHeader(title: title, controller: controller),
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                Text(
                  mainLabel.toUpperCase(),
                  style: const TextStyle(
                    color: muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mainValue,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: ink,
                  backgroundColor: line,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _InsightCard(
                  label: 'Avg Time',
                  value: '4.5 min',
                  body: 'Per drop',
                  icon: Icons.schedule,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InsightCard(
                  label: 'AI Resolve',
                  value: '88%',
                  body: 'Autonomous',
                  icon: Icons.auto_awesome,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapMock extends StatelessWidget {
  const _MapMock({this.fleet = false});

  final bool fleet;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPainter(fleet: fleet),
      child: const SizedBox.expand(),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.fleet});

  final bool fleet;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFEFF1F3), BlendMode.src);
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final route = Paint()
      ..color = ink
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 7; i++) {
      final y = size.height * (i + 1) / 8;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + (i.isEven ? 28 : -28)),
        road,
      );
    }
    for (var i = 0; i < 5; i++) {
      final x = size.width * (i + 1) / 6;
      canvas.drawLine(Offset(x, 0), Offset(x + 30, size.height), road);
    }

    final path = Path()
      ..moveTo(size.width * .22, size.height * .78)
      ..quadraticBezierTo(
        size.width * .38,
        size.height * .54,
        size.width * .52,
        size.height * .48,
      )
      ..quadraticBezierTo(
        size.width * .70,
        size.height * .40,
        size.width * .78,
        size.height * .25,
      );
    canvas.drawPath(path, route);

    final points = fleet
        ? [
            Offset(size.width * .35, size.height * .58),
            Offset(size.width * .68, size.height * .34),
          ]
        : [
            Offset(size.width * .22, size.height * .78),
            Offset(size.width * .52, size.height * .48),
            Offset(size.width * .78, size.height * .25),
          ];
    for (final p in points) {
      canvas.drawCircle(p, 10, Paint()..color = Colors.white);
      canvas.drawCircle(p, 7, Paint()..color = ink);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.fleet != fleet;
  }
}

class _ScanGrid extends StatelessWidget {
  const _ScanGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScanGridPainter());
  }
}

class _ScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .08)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetricList extends StatelessWidget {
  const _MetricList({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            ListTile(
              title: Text(rows[i].$1, style: const TextStyle(color: muted)),
              trailing: Text(
                rows[i].$2,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              shape: i == rows.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: line)),
            ),
        ],
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo();

  @override
  Widget build(BuildContext context) {
    return const _MetricList(
      rows: [
        ('Vehicle', mockUserVehicle),
        ('Zone', mockUserZone),
        ('Phone', '+62 812 3456 7890'),
      ],
    );
  }
}

const mockUserVehicle = 'Van - L 1234 XY';
const mockUserZone = 'Surabaya Selatan';

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(icon),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.value,
    required this.body,
    required this.icon,
  });

  final String label;
  final String value;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: muted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: muted, height: 1.25)),
        ],
      ),
    );
  }
}

class _AgentTile extends StatelessWidget {
  const _AgentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 14),
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
          Text(subtitle, style: const TextStyle(color: muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: active ? ink : Colors.white,
        labelStyle: TextStyle(color: active ? Colors.white : muted),
        side: const BorderSide(color: line),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({
    required this.icon,
    required this.title,
    required this.time,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String time;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Text(time, style: const TextStyle(color: muted, fontSize: 11)),
              ],
            ),
            const Divider(height: 20),
            Text(body, style: const TextStyle(color: muted, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const Text(
                '10 min ago',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(color: muted, height: 1.35)),
          const SizedBox(height: 10),
          const Text(
            'Reported by C-88291',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceBox extends StatelessWidget {
  const _EvidenceBox({
    required this.label,
    required this.icon,
    required this.height,
  });

  final String label;
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: line),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: muted,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: ink),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
