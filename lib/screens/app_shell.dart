import 'dart:async';

import 'package:flutter/material.dart';

import '../core/app_controller.dart';
import '../widgets/app_widgets.dart';
import '../widgets/app_shell_widgets.dart';

import 'auth/splash_screen.dart';
import 'auth/login_screen.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/onboarding_screen.dart';

import 'courier/dashboard_screen.dart';
import 'courier/scanner_screen.dart';
import 'courier/receipt_result_screen.dart';
import 'courier/route_summary_screen.dart';
import 'courier/manifest_screen.dart';
import 'courier/clarification_screen.dart';
import 'courier/incident_report_screen.dart';
import 'courier/map_nav_screen.dart';
import 'courier/delivery_detail_screen.dart';
import 'courier/pod_screen.dart';
import 'courier/history_screen.dart';
import 'courier/notifications_screen.dart';

import 'dispatcher/dispatcher_dashboard_screen.dart';
import 'dispatcher/dispatcher_live_map_screen.dart';
import 'dispatcher/dispatcher_assignments_screen.dart';
import 'dispatcher/dispatcher_center_screen.dart';
import 'dispatcher/dispatcher_analytics_screen.dart';
import 'dispatcher/incident_detail_screen.dart';

import 'common/profile_screen.dart';
import 'common/help_screen.dart';
import 'common/settings_screen.dart';
import 'common/weather_screen.dart';
import 'common/sync_manager_screen.dart';

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
              if (_showBottomNav) BottomNav(controller: widget.controller),
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
      AppScreen.onboarding => OnboardingScreen(controller: c),
      AppScreen.login => LoginScreen(controller: c),
      AppScreen.forgotPassword => ForgotPasswordScreen(
        controller: c,
        onToast: _showToast,
      ),
      AppScreen.dashboard => DashboardScreen(controller: c),
      AppScreen.scanner => ScannerScreen(controller: c, onToast: _showToast),
      AppScreen.receiptResult => ReceiptResultScreen(
        controller: c,
        receipt: c.currentReceipt!,
      ),
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
      AppScreen.weather => WeatherScreen(controller: c),
      AppScreen.syncManager => SyncManagerScreen(
        controller: c,
      ),
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
