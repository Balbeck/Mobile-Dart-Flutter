import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.length < 3) return []; // Minimal pour éviter spam
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en&format=json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    }
    return [];
  }
}
