import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city.dart';

class SearchService {
  static Future<List<City>> searchCities(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en&format=json',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);
    final results = List<Map<String, dynamic>>.from(data['results'] ?? []);
    if (results.isEmpty) return [];

    return results.map((r) {
      return City(
        name: r['name'],
        region: r['admin1'],
        country: r['country'],
        latitude: r['latitude'],
        longitude: r['longitude'],
      );
    }).toList();
  }
}
