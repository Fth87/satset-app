import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_controller.dart';
import '../../core/location_service.dart';
import '../../core/route_optimization_service.dart';
import '../../models/package.dart';
import '../../widgets/app_widgets.dart';

class MapNavScreen extends StatefulWidget {
  const MapNavScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<MapNavScreen> createState() => _MapNavScreenState();
}

class _MapNavScreenState extends State<MapNavScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStream;
  LatLng? _currentLocation;
  bool _isLoadingRoute = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  LatLng? _customStartLocation;
  bool _useCustomStart = false;

  @override
  void initState() {
    super.initState();
    _loadCustomStartLocation();
    _initLocationAndRoute();
  }

  Future<void> _loadCustomStartLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('custom_start_lat');
    final lng = prefs.getDouble('custom_start_lng');
    if (lat != null && lng != null && mounted) {
      setState(() {
        _customStartLocation = LatLng(lat, lng);
      });
    }
  }

  Future<void> _saveCustomStartLocation(LatLng pos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('custom_start_lat', pos.latitude);
    await prefs.setDouble('custom_start_lng', pos.longitude);
  }

  Future<void> _initLocationAndRoute() async {
    setState(() => _isCheckingPermission = true);
    final granted = await LocationService.requestPermissions();
    if (mounted) {
      setState(() {
        _hasPermission = granted;
        _isCheckingPermission = false;
      });
    }

    if (granted) {
      final initialPos = await LocationService.getCurrentLocation();
      if (initialPos != null && mounted) {
        setState(() {
          _currentLocation = LatLng(initialPos.latitude, initialPos.longitude);
        });
        _mapController.move(_currentLocation!, 15.0);
        
        // Initial load of markers
        await _geocodeMissingPackages();
      }

      _positionStream = LocationService.getPositionStream().listen((Position pos) {
        if (!mounted) return;
        setState(() {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
        });
      });
    }
  }

  Future<void> _geocodeMissingPackages() async {
    final pending = widget.controller.packages
        .where((p) => p.status == PackageStatus.pending)
        .toList();
    
    Map<String, LatLng> newCoords = {};
    for (var pkg in pending) {
      if (!widget.controller.packageCoordinates.containsKey(pkg.id)) {
        final coords = await RouteOptimizationService.geocodeAddress(pkg.address);
        if (coords != null) {
          newCoords[pkg.id] = coords;
        }
      }
    }
    
    if (newCoords.isNotEmpty && mounted) {
      widget.controller.updateMapState(coords: newCoords);
    }
  }

  List<Marker> _buildMarkers() {
    final List<Marker> markers = [];
    final pending = widget.controller.packages
        .where((p) => p.status == PackageStatus.pending)
        .toList();

    for (var pkg in pending) {
      final coords = widget.controller.packageCoordinates[pkg.id];
      if (coords != null) {
        markers.add(
          Marker(
            point: coords,
            width: 60,
            height: 60,
            alignment: Alignment.bottomCenter,
            child: Tooltip(
              message: pkg.recipient,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                    ),
                    child: Text(
                      pkg.recipient.split(' ')[0],
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 32),
                ],
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }

  Future<void> _calculateOptimizationRoute() async {
    final pendingPackages = widget.controller.packages
        .where((p) => p.status == PackageStatus.pending)
        .toList();
        
    if (pendingPackages.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Manifest Kosong'),
            content: const Text('Silahkan masukkan alamat paket dengan status "Akan Dikirim" terlebih dahulu.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      }
      return;
    }

    final start = (_useCustomStart && _customStartLocation != null) ? _customStartLocation : _currentLocation;
    if (start == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi tidak tersedia. Pastikan GPS aktif.')),
      );
      return;
    }

    setState(() => _isLoadingRoute = true);

    try {
      await _geocodeMissingPackages();
      
      List<LatLng> deliveryCoords = [];
      for (var pkg in pendingPackages) {
        final coords = widget.controller.packageCoordinates[pkg.id];
        if (coords != null) {
          deliveryCoords.add(coords);
        }
      }

      if (deliveryCoords.isNotEmpty) {
        final res = await RouteOptimizationService.optimizeRoute(
            start, deliveryCoords);
        if (res != null && mounted) {
          widget.controller.updateMapState(
            going: res['going'],
            back: res['return'],
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rute optimal ditemukan!')),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sistem gagal menghitung jalur rute.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Routing error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghitung rute: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  final TextEditingController _searchController = TextEditingController();

  void _showStartPointDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mulai Rute Dari:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location, color: Colors.blue),
              title: const Text('Lokasi Saya (GPS)'),
              trailing: !_useCustomStart ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                setState(() => _useCustomStart = false);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.stars, color: Colors.orange),
              title: const Text('Titik Tandai (Bintang)'),
              subtitle: _customStartLocation == null ? const Text('Belum ada titik ditandai', style: TextStyle(fontSize: 10, color: Colors.red)) : null,
              trailing: _useCustomStart ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                if (_customStartLocation == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tandai lokasi dulu di peta!')));
                  return;
                }
                setState(() => _useCustomStart = true);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text;
    if (query.isEmpty) return;
    
    final coords = await RouteOptimizationService.geocodeAddress(query);
    if (coords != null) {
      if (!mounted) return;
      _mapController.move(coords, 15.0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moved to: $query')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found')),
      );
    }
  }

  void _centerOnLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    }
  }

  void _handleMapLongPress(LatLng point) {
    setState(() {
      _customStartLocation = point;
    });
    _saveCustomStartLocation(point);
    _calculateOptimizationRoute();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Titik mulai diatur ke lokasi yang dipilih')),
    );
  }

  void _goToCustomMark() {
    if (_customStartLocation != null) {
      _mapController.move(_customStartLocation!, 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada lokasi yang ditandai (tekan lama di peta)')),
      );
    }
  }

  void _showDeliverySelectionDialog() async {
    final pending = widget.controller.packages
        .where((p) => p.status == PackageStatus.pending)
        .toList();

    if (pending.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada paket "Akan Dikirim"')),
      );
      return;
    }

    if (pending.length == 1) {
      _goToPackage(pending.first);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pilih Lokasi Paket:'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pending.length,
            itemBuilder: (ctx, i) {
              final pkg = pending[i];
              return ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: Text(pkg.recipient),
                subtitle: Text(pkg.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.pop(ctx);
                  _goToPackage(pkg);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _goToPackage(DeliveryPackage pkg) async {
    final coords = await RouteOptimizationService.geocodeAddress(pkg.address);
    if (coords != null && mounted) {
      _mapController.move(coords, 16.0);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menemukan lokasi paket')),
        );
      }
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermission) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: surface,
        appBar: AppBar(title: const Text('Rute Pengiriman')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off_outlined, size: 64, color: muted),
                const SizedBox(height: 16),
                const Text('Akses Lokasi Diperlukan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Berikan Akses', onPressed: _initLocationAndRoute),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) => FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation ?? const LatLng(-6.2088, 106.8456),
                  initialZoom: 15.0,
                  onLongPress: (tapPos, point) => _handleMapLongPress(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.ngetestaja',
                  ),
                  if (widget.controller.goingPoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: widget.controller.goingPoints,
                          color: Colors.white,
                          strokeWidth: 8.0,
                        ),
                        Polyline(
                          points: widget.controller.goingPoints,
                          color: Colors.blue.withValues(alpha: 0.8),
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  if (widget.controller.returnPoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        // Outline for return path
                        Polyline(
                          points: widget.controller.returnPoints,
                          color: Colors.white.withValues(alpha: 0.7),
                          strokeWidth: 6.0,
                        ),
                        // Vivid dashed return path
                        Polyline(
                          points: widget.controller.returnPoints,
                          color: Colors.deepPurple,
                          strokeWidth: 3.0,
                          pattern: StrokePattern.dashed(segments: [12, 8]),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (_currentLocation != null)
                        Marker(
                          point: _currentLocation!,
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.navigation, color: Colors.blue, size: 20),
                          ),
                        ),
                      if (_customStartLocation != null)
                        Marker(
                          point: _customStartLocation!,
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(Icons.stars, color: Colors.orange, size: 40),
                        ),
                      ..._buildMarkers(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Search Bar
          Positioned(
            top: 60,
            left: 70,
            right: 16,
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari lokasi...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _searchLocation(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: muted),
                    onPressed: _searchLocation,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Left Actions (Optimization & Start Point)
          Positioned(
            bottom: 120,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingActionButton.small(
                  heroTag: 'go_to_delivery',
                  onPressed: _showDeliverySelectionDialog,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.inventory_2_outlined, color: Colors.red),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'start_point_toggle',
                  onPressed: _showStartPointDialog,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _useCustomStart ? Icons.stars : Icons.my_location,
                    color: _useCustomStart ? Colors.orange : Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'optimize_route',
                  onPressed: _calculateOptimizationRoute,
                  backgroundColor: ink,
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
              ],
            ),
          ),

          if (_isLoadingRoute)
            Positioned(
              top: 140, // Moved up from 180
              left: 0,
              right: 0,
              child: Center(
                child: IntrinsicWidth(
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 12),
                        const Text('Menghitung rute tercepat...', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            
          Positioned(
            top: 66,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close, color: ink),
                onPressed: () => widget.controller.go(AppScreen.manifest),
              ),
            ),
          ),

          // Legend
          if (widget.controller.goingPoints.isNotEmpty)
            Positioned(
              top: 130,
              right: 16,
              child: IntrinsicWidth(
                child: AppCard(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 20, height: 3, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text('Jalur Pergi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            child: Row(
                              children: [
                                Container(width: 8, height: 2, color: Colors.deepPurple),
                                const SizedBox(width: 4),
                                Container(width: 8, height: 2, color: Colors.deepPurple),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Jalur Pulang', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Map Action Buttons (Move up to avoid navbar)
          Positioned(
            bottom: 120,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'go_custom',
                  onPressed: _goToCustomMark,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.stars, color: Colors.orange),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'center_me',
                  onPressed: _centerOnLocation,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
