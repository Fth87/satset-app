import 'package:flutter/material.dart';

import '../models/package.dart';

enum UserRole { courier, dispatcher }

enum AppScreen {
  splash,
  login,
  forgotPassword,
  dashboard,
  scanner,
  routeSummary,
  manifest,
  clarification,
  incidentReport,
  mapNav,
  deliveryDetail,
  pod,
  history,
  notifications,
  profile,
  help,
  settings,
  syncManager,
  dispatcherDashboard,
  dispatcherLiveMap,
  dispatcherAssignments,
  dispatcherCenter,
  dispatcherAnalytics,
  incidentDetail,
}

class AppController extends ChangeNotifier {
  AppScreen screen = AppScreen.splash;
  UserRole? role;
  DeliveryPackage? selectedPackage;
  bool isDarkMode = false;

  void go(AppScreen next, {DeliveryPackage? package}) {
    screen = next;
    selectedPackage = package ?? selectedPackage;
    notifyListeners();
  }

  void login(UserRole nextRole) {
    role = nextRole;
    screen = nextRole == UserRole.dispatcher
        ? AppScreen.dispatcherDashboard
        : AppScreen.dashboard;
    notifyListeners();
  }

  void logout() {
    role = null;
    selectedPackage = null;
    screen = AppScreen.login;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
