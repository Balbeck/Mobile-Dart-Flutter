import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
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
}
