import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weather_app/models/city.dart';

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
        const SnackBar(
          content: Text('Permission denied. Use \'Search location\' instead.'),
        ),
      );
      return 'No location';
    }
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    print('Position: ${position.latitude}, ${position.longitude}');
    return '${position.latitude}, ${position.longitude}';
  }

  // Fct get City by coordonnees (latitude, longitude)
  static Future<City> getCityByCoordonates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$latitude&longitude=$longitude&localityLanguage=en',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print(data);

        final cityName = data['city'] ?? 'Unknown';
        final region = data['principalSubdivision'] ?? 'Unknown';
        final country = data['countryName'] ?? 'Unknown';

        print('Geoloc result: [ $cityName, $region, $country ]');

        return City(
          name: cityName,
          region: region,
          country: country,
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (e) {
      print('Error fetching city: $e');
    }

    return City(
      name: 'Unknown',
      region: 'Unknown',
      country: 'Unknown',
      latitude: latitude,
      longitude: longitude,
    );
  }

  // Fct get City by location (latitude, longitude)
  static Future<City> getCityByLocation(BuildContext context) async {
    String coords = await getLocation(context);
    if (coords == 'No location') {
      return City(
        name: 'No location',
        region: '',
        country: '',
        latitude: 0.0,
        longitude: 0.0,
      );
    }
    List<String> parts = coords.split(',');
    if (parts.length != 2) {
      return City(
        name: 'Unknown location',
        region: '',
        country: '',
        latitude: 0.0,
        longitude: 0.0,
      );
    }
    double? latitude = double.tryParse(parts[0].trim());
    double? longitude = double.tryParse(parts[1].trim());
    if (latitude == null || longitude == null) {
      return City(
        name: 'Unknown location',
        region: '',
        country: '',
        latitude: 0.0,
        longitude: 0.0,
      );
    }
    return await getCityByCoordonates(latitude, longitude);
  }
}
