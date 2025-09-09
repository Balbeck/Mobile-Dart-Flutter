import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  // Fct Geolocalisation -> coordonnees (latitude, longitude)
  static Future<String> getLocation(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!context.mounted) {
        return 'No location';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission denied. Use \'Search location\' instead.'),
        ),
      );
      return 'No location';
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    print('position: ${position.latitude}, ${position.longitude}');
    return '${position.latitude}, ${position.longitude}';
  }

  // Fct get CityName by coordonnees (latitude, longitude)
  static Future<String> getCityByCoordonates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/reverse?latitude=$latitude&longitude=$longitude&language=en&format=json',
        // 'https://geocoding-api.open-meteo.com/v1/search?name=&latitude=$latitude&longitude=$longitude&count=1&language=en&format=json',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final city = data['results'][0]['name'];
          final region = city['results'][0]['admin1'] ?? 'N/A';
          final country = data['results'][0]['country'];

          // Debug
          print(
            'With coordonate($latitude, $longitude) \n-> City: $city, Region: $region, Country: $country',
          );
          return '$city, $region, $country';
        }
      }
    } catch (e) {
      print('Error fetching city: $e');
    }
    return 'Unknown location';
  }

  // static Future<String> getCityByLocation(BuildContext context) async {
  //   String coords = await getLocation(context);
  //   if (coords == 'No location') return coords;

  //   List<String> parts = coords.split(',');
  //   if (parts.length != 2) return 'Unknown location';

  //   double? latitude = double.tryParse(parts[0].trim());
  //   double? longitude = double.tryParse(parts[1].trim());
  //   if (latitude == null || longitude == null) return 'Unknown location';

  //   String city = await getCityByCoordonates(latitude, longitude);
  //   return city;
  // }
}
