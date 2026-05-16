import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'env.dart';

class RouteOptimizationService {
  static final Dio _dio = Dio();
  static const String _geocodeUrl = 'https://api.openrouteservice.org/geocode/search';
  static const String _optimizationUrl = 'https://api.openrouteservice.org/optimization';

  /// Convert address to LatLng using OpenRouteService Geocoding API
  static Future<LatLng?> geocodeAddress(String address) async {
    final apiKey = Env.orsApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_OPENROUTESERVICE_API_KEY') {
      debugPrint('ORS API Key is not set.');
      return null;
    }

    try {
      final response = await _dio.get(
        _geocodeUrl,
        queryParameters: {
          'api_key': apiKey,
          'text': address,
          'size': 1,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'];
          // ORS returns [longitude, latitude]
          return LatLng(coordinates[1], coordinates[0]);
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
    return null;
  }

  /// Optimizes route and returns split paths: 'going' and 'return'
  static Future<Map<String, List<LatLng>>?> optimizeRoute(LatLng startLocation, List<LatLng> deliveries) async {
    final apiKey = Env.orsApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_OPENROUTESERVICE_API_KEY') {
      debugPrint('ORS API Key is not set.');
      return null;
    }

    final List<Map<String, dynamic>> jobs = [];
    for (int i = 0; i < deliveries.length; i++) {
      jobs.add({
        'id': i + 1,
        'location': [deliveries[i].longitude, deliveries[i].latitude],
      });
    }

    final Map<String, dynamic> vehicle = {
      'id': 1,
      'profile': 'driving-car',
      'start': [startLocation.longitude, startLocation.latitude],
      'end': [startLocation.longitude, startLocation.latitude],
    };

    final payload = {
      'jobs': jobs,
      'vehicles': [vehicle],
      'geometry': true,
    };

    try {
      final response = await _dio.post(
        _optimizationUrl,
        data: jsonEncode(payload),
        options: Options(
          headers: {
            'Authorization': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List<dynamic> steps = data['routes'][0]['steps'];
          List<LatLng> orderedPoints = [];
          
          for (var step in steps) {
            if (step['location'] != null) {
              orderedPoints.add(LatLng(step['location'][1], step['location'][0]));
            }
          }

          if (orderedPoints.length >= 2) {
            debugPrint('Optimization success. Splitting paths...');
            // Going: start -> last delivery
            final goingPoints = orderedPoints.sublist(0, orderedPoints.length - 1);
            // Return: last delivery -> start
            final returnPoints = [orderedPoints[orderedPoints.length - 2], orderedPoints.last];

            final detailedGoing = await getDetailedRoute(goingPoints);
            final detailedReturn = await getDetailedRoute(returnPoints);

            return {
              'going': detailedGoing ?? goingPoints,
              'return': detailedReturn ?? returnPoints,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Optimization error: $e');
      return {
        'going': [startLocation, ...deliveries],
        'return': [deliveries.last, startLocation],
      };
    }
    return null;
  }

  /// Fetches actual road-following path between multiple points
  static Future<List<LatLng>?> getDetailedRoute(List<LatLng> points) async {
    final apiKey = Env.orsApiKey;
    const String directionsUrl = 'https://api.openrouteservice.org/v2/directions/driving-car/geojson';

    try {
      final response = await _dio.post(
        directionsUrl,
        data: jsonEncode({
          'coordinates': points.map((p) => [p.longitude, p.latitude]).toList(),
        }),
        options: Options(
          headers: {
            'Authorization': apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['features'] != null && data['features'].isNotEmpty) {
          final List<dynamic> coords = data['features'][0]['geometry']['coordinates'];
          return coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
      return points; // Fallback to optimized sequence points
    }
    return points;
  }

  /// Decodes an encoded polyline string to a List of LatLng
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}
