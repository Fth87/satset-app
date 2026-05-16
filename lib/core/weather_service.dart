import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<Map<String, dynamic>?> getWeather(double lat, double lng) async {
    final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,weathercode&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Weather API error: $e');
    }
    return null;
  }
  
  static String getWeatherDescription(int code) {
    if (code == 0) return 'Cerah';
    if (code >= 1 && code <= 3) return 'Berawan';
    if (code >= 45 && code <= 48) return 'Berkabut';
    if (code >= 51 && code <= 67) return 'Hujan Gerimis';
    if (code >= 71 && code <= 77) return 'Bersalju';
    if (code >= 80 && code <= 82) return 'Hujan Deras';
    if (code >= 85 && code <= 86) return 'Hujan Salju';
    if (code >= 95 && code <= 99) return 'Badai Petir';
    return 'Cerah';
  }
}
