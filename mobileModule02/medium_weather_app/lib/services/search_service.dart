import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  static Future<List<Map<String, dynamic>>> searchCities(String query) async {
    var listLength = 7;
    if (query.length < 3) return []; // Min 3 char pour avoid spam API
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=$listLength&language=en&format=json',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var results = List<Map<String, dynamic>>.from(data['results'] ?? []);

      ///////////////////////////////////////////////////////////////////////////
      // Debug
      if (results.isEmpty) {
        print('Status Code: ${response.statusCode}');
        print('No results found for query: $query');
        return [];
      }
      print("\n\n ***[ Query = $query ]*** ");
      print('Status Code: ${response.statusCode}');
      for (var city in results) {
        print(
          "${city['name']}, ${city['admin1'] ?? 'N/A'}, ${city['country']}, Lat: ${city['latitude']}, Lon: ${city['longitude']}",
        );
      }
      print('- - - - - -\n');
      ///////////////////////////////////////////////////////////////////////////

      return results;
    }

    print('Error: ${response.statusCode}');
    return [];
  }
}
