
import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/weather_service.dart';
import '../../core/location_service.dart';
import '../../models/package.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    await LocationService.requestPermissions();
    if (mounted) {
       widget.controller.fetchWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      topPadding: 0,
      bottomPadding: 96,
      onRefresh: () => widget.controller.fetchPackages(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourierHomeTop(
            controller: widget.controller,
            onBell: () => widget.controller.go(AppScreen.notifications),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.controller.go(AppScreen.weather),
                  child: InsightCard(
                    label: 'Weather',
                    value: widget.controller.isLoadingWeather 
                        ? '...' 
                        : (widget.controller.weatherData != null 
                            ? '${widget.controller.weatherData!['current']['temperature_2m']}°' 
                            : 'N/A'),
                    body: widget.controller.weatherData != null 
                        ? WeatherService.getWeatherDescription(widget.controller.weatherData!['current']['weathercode'])
                        : 'Fetching...',
                    icon: Icons.wb_sunny_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InsightCard(
                  label: 'Traffic',
                  value: DateTime.now().hour >= 16 && DateTime.now().hour <= 19 ? 'Heavy' : 'Moderate',
                  body: DateTime.now().hour >= 16 && DateTime.now().hour <= 19 
                      ? 'Rush hour in ${widget.controller.currentCity}.' 
                      : 'Smooth flow in ${widget.controller.currentCity}.',
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(22),
            child: widget.controller.isLoadingPackages
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 30,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.controller.packages.length} Packages Total',
                        style: const TextStyle(
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Text('Route Progress'),
                          const Spacer(),
                          Text(
                            '${widget.controller.packages.where((p) => p.status == PackageStatus.delivered).length} / ${widget.controller.packages.length}', 
                            style: const TextStyle(color: muted)
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.controller.packages.isEmpty 
                  ? 0 
                  : widget.controller.packages.where((p) => p.status == PackageStatus.delivered).length / widget.controller.packages.length,
              minHeight: 8,
              backgroundColor: line,
              color: ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.controller.packages.isEmpty 
                ? 'NO PACKAGES' 
                : 'EST. COMPLETION ${(DateTime.now().add(Duration(minutes: widget.controller.packages.where((p) => p.status != PackageStatus.delivered).length * 10))).toString().substring(11, 16)}',
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Start Route',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => widget.controller.go(AppScreen.routeSummary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SecondaryButton(
                  label: 'Scan New Package',
                  icon: Icons.document_scanner_outlined,
                  onPressed: () => widget.controller.go(AppScreen.scanner),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionLabel('AI Agents Subsystem'),
          Row(
            children: [
              const Expanded(
                child: AgentTile(
                  icon: Icons.document_scanner,
                  title: 'OCR',
                  subtitle: 'Active',
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: AgentTile(
                  icon: Icons.map_outlined,
                  title: 'Route',
                  subtitle: 'Optimizing',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.controller.go(AppScreen.clarification),
                  child: const AgentTile(
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
