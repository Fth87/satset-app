import 'package:flutter/material.dart';

import '../models/package.dart';
import 'package:latlong2/latlong.dart';
import 'supabase_service.dart';
import 'weather_service.dart';
import 'ai_parsing_service.dart';
import 'location_service.dart';

enum AppScreen {
  splash,
  onboarding,
  login,
  forgotPassword,
  dashboard,
  scanner,
  receiptResult,
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
  weather,
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
  OperatorProfile? profile;
  DeliveryPackage? selectedPackage;
  ParsedReceipt? currentReceipt;
  bool isDarkMode = false;
  String? errorMessage;

  // Persistent Map State
  List<LatLng> routePoints = []; // Compatibility
  List<LatLng> goingPoints = [];
  List<LatLng> returnPoints = [];
  Map<String, LatLng> packageCoordinates = {};
  bool isCalculatingRoute = false;

  void updateMapState({List<LatLng>? points, List<LatLng>? going, List<LatLng>? back, Map<String, LatLng>? coords}) {
    if (points != null) routePoints = points;
    if (going != null) goingPoints = going;
    if (back != null) returnPoints = back;
    if (coords != null) packageCoordinates.addAll(coords);
    notifyListeners();
  }

  bool isLoadingPackages = false;
  bool isFetchingMore = false;
  List<DeliveryPackage> packages = [];
  int _currentOffset = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  AppController() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = SupabaseService.currentUser;
    if (user != null) {
      await _fetchProfileAndRoute(user.id);
    } else {
      go(AppScreen.onboarding);
    }
    
    // Listen for auth changes (e.g. token refresh, logout from another tab)
    SupabaseService.authStateChanges.listen((data) {
      final session = data.session;
      if (session == null && screen != AppScreen.login) {
        profile = null;
        packages = [];
        go(AppScreen.onboarding);
      }
    });
  }

  Future<void> fetchPackages() async {
    try {
      isLoadingPackages = true;
      _currentOffset = 0;
      _hasMore = true;
      notifyListeners();
      packages = await SupabaseService.getPackages(limit: _pageSize, offset: _currentOffset);
      if (packages.length < _pageSize) {
        _hasMore = false;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoadingPackages = false;
      notifyListeners();
    }
  }

  Future<void> fetchMorePackages() async {
    if (isFetchingMore || !_hasMore) return;
    try {
      isFetchingMore = true;
      _currentOffset += _pageSize;
      notifyListeners();
      
      final morePackages = await SupabaseService.getPackages(limit: _pageSize, offset: _currentOffset);
      if (morePackages.isEmpty || morePackages.length < _pageSize) {
        _hasMore = false;
      }
      packages.addAll(morePackages);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      try {
        profile = await SupabaseService.getProfile(user.id);
        notifyListeners();
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  Map<String, dynamic>? weatherData;
  bool isLoadingWeather = false;
  String currentCity = 'Detecting...';

  Future<void> fetchWeather() async {
    try {
      isLoadingWeather = true;
      notifyListeners();
      
      final pos = await LocationService.getCurrentLocation();
      if (pos != null) {
        currentCity = await LocationService.getCityName(pos.latitude, pos.longitude);
        weatherData = await WeatherService.getWeather(pos.latitude, pos.longitude);
      } else {
        // Fallback to Surabaya
        currentCity = 'Surabaya';
        weatherData = await WeatherService.getWeather(-7.2575, 112.7521);
      }
      
      isLoadingWeather = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch weather: $e');
      isLoadingWeather = false;
      notifyListeners();
    }
  }

  Future<bool> deletePackage(String id) async {
    try {
      final success = await SupabaseService.deletePackage(id);
      if (success) {
        packages.removeWhere((p) => p.id == id);
        if (selectedPackage?.id == id) {
          selectedPackage = null;
        }
        notifyListeners();
        
        await fetchPackages();
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> addPackage(Map<String, dynamic> data) async {
    try {
      await SupabaseService.createPackage(data);
      await fetchPackages();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePackage(String id, Map<String, dynamic> data) async {
    try {
      await SupabaseService.updatePackage(id, data);
      // Optimistic update
      final index = packages.indexWhere((p) => p.id == id);
      if (index != -1) {
        final old = packages[index];
        packages[index] = DeliveryPackage(
          id: old.id,
          recipient: data['recipient'] ?? old.recipient,
          address: data['address'] ?? old.address,
          status: old.status, // Assuming status doesn't change here directly
          priority: data['priority'] ?? old.priority,
          eta: old.eta,
          confidence: old.confidence,
          cluster: old.cluster,
          phone: data['phone'] ?? old.phone,
        );
        if (selectedPackage?.id == id) {
          selectedPackage = packages[index];
        }
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchProfileAndRoute(String userId) async {
    try {
      profile = await SupabaseService.getProfile(userId);
      if (profile != null) {
        await fetchPackages();
        fetchWeather(); // Fetch weather in background
        if (profile!.role == UserRole.dispatcher) {
          go(AppScreen.dispatcherDashboard);
        } else {
          go(AppScreen.dashboard);
        }
      } else {
        errorMessage = 'Profile not found.';
        go(AppScreen.login);
      }
    } catch (e) {
      errorMessage = e.toString();
      go(AppScreen.login);
    }
  }

  void go(AppScreen next, {DeliveryPackage? package}) {
    screen = next;
    selectedPackage = package ?? selectedPackage;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      errorMessage = null;
      notifyListeners();
      final response = await SupabaseService.signIn(email, password);
      if (response.user != null) {
        await _fetchProfileAndRoute(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> addPackageFromScan({
    required String name,
    required String phone,
    required String address,
  }) async {
    // Generate a mock ID for now
    final newPackage = DeliveryPackage(
      id: 'PKG-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      recipient: name,
      address: address,
      status: PackageStatus.pending,
      priority: 'Standard',
      eta: 'TBD',
      confidence: 100,
      cluster: 'Custom',
      phone: phone,
    );
    
    // Optimistic UI update
    packages.insert(0, newPackage);
    notifyListeners();
    
    // TODO: Insert into Supabase when connected
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    profile = null;
    packages.clear();
    go(AppScreen.login);
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
