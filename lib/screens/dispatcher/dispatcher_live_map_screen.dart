
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/app_controller.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

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
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(-6.2088, 106.8456),
                  initialZoom: 12.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.satset',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: const LatLng(-6.2088, 106.8456),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.local_shipping, color: ink, size: 30),
                      ),
                      Marker(
                        point: const LatLng(-6.2200, 106.8500),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.local_shipping, color: ink, size: 30),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                  MiniAction(icon: Icons.center_focus_strong, label: 'Focus'),
                  MiniAction(icon: Icons.call_outlined, label: 'Contact'),
                  MiniAction(icon: Icons.person_outline, label: 'Details'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
