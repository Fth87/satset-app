import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/weather_service.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/app_shell_widgets.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final weather = controller.weatherData;

    return ScrollPage(
      bottomPadding: 96,
      onRefresh: () => controller.fetchWeather(),
      header: AppHeader(
        title: 'Weather Forecast',
        backTo: AppScreen.dashboard,
        controller: controller,
      ),
      child: weather == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Loading weather data...'),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('Current Conditions in ${controller.currentCity}'),
                AppCard(
                  child: Column(
                    children: [
                      const Icon(Icons.wb_sunny, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      Text(
                        '${weather['current']['temperature_2m']}°C',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        WeatherService.getWeatherDescription(weather['current']['weathercode']),
                        style: const TextStyle(
                          fontSize: 20,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionLabel('7-Day Forecast'),
                ...List.generate(7, (index) {
                  final date = weather['daily']['time'][index];
                  final maxTemp = weather['daily']['temperature_2m_max'][index];
                  final minTemp = weather['daily']['temperature_2m_min'][index];
                  final code = weather['daily']['weathercode'][index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_outlined),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  WeatherService.getWeatherDescription(code),
                                  style: const TextStyle(color: muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$maxTemp° / $minTemp°',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
