import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/city.dart';

class SearchService {
  static Future<List<City>> searchCities(String query) async {
    var listLength = 7;
    if (query.length <= 1) return []; // Min 2 char pour avoid spam API
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
        throw 'could not find any result for the supplied address ($query) or coordinates';
        // return [];
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

      return results.map((result) {
        return City(
          name: result['name'],
          region: result['admin1'],
          country: result['country'],
          latitude: result['latitude'],
          longitude: result['longitude'],
        );
      }).toList();
    }

    print('Error: ${response.statusCode}');
    return [];
  }
}
