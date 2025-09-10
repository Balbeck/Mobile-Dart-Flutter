import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/city.dart';

class CurrentWeather {
  final double temperature;
  final String description;
  final double windSpeed;

  CurrentWeather({
    required this.temperature,
    required this.description,
    required this.windSpeed,
  });
}

class HourlyWeather {
  final DateTime time;
  final double temperature;
  final String description;
  final double windSpeed;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.description,
    required this.windSpeed,
  });
}

class DailyWeather {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String description;

  DailyWeather({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.description,
  });
}

class WeatherService {
  static Future<CurrentWeather?> getCurrentWeather(City city) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${city.latitude}&longitude=${city.longitude}&current_weather=true',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final current = data['current_weather'];

      if (current != null) {
        return CurrentWeather(
          temperature: current['temperature']?.toDouble() ?? 0.0,
          description: _mapWeatherCodeToDescription(
            current['weathercode'] ?? 0,
          ),
          windSpeed: current['windspeed']?.toDouble() ?? 0.0,
        );
      }
    }
    return null;
  }

  static Future<List<HourlyWeather>> getTodayWeather(City city) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${city.latitude}&longitude=${city.longitude}'
      '&hourly=temperature_2m,windspeed_10m,weathercode&forecast_days=1&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final times = List<String>.from(data['hourly']['time']);
      final temps = List<dynamic>.from(data['hourly']['temperature_2m']);
      final winds = List<dynamic>.from(data['hourly']['windspeed_10m']);
      final codes = List<dynamic>.from(data['hourly']['weathercode']);

      List<HourlyWeather> list = [];
      for (int i = 0; i < times.length; i++) {
        list.add(
          HourlyWeather(
            time: DateTime.parse(times[i]),
            temperature: temps[i]?.toDouble() ?? 0.0,
            windSpeed: winds[i]?.toDouble() ?? 0.0,
            description: _mapWeatherCodeToDescription(codes[i] ?? 0),
          ),
        );
      }
      return list;
    }
    return [];
  }

  static Future<List<DailyWeather>> getWeeklyWeather(City city) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=${city.latitude}&longitude=${city.longitude}'
      '&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dates = List<String>.from(data['daily']['time']);
      final maxTemps = List<dynamic>.from(data['daily']['temperature_2m_max']);
      final minTemps = List<dynamic>.from(data['daily']['temperature_2m_min']);
      final codes = List<dynamic>.from(data['daily']['weathercode']);

      List<DailyWeather> list = [];
      for (int i = 0; i < dates.length; i++) {
        list.add(
          DailyWeather(
            date: DateTime.parse(dates[i]),
            tempMax: maxTemps[i]?.toDouble() ?? 0.0,
            tempMin: minTemps[i]?.toDouble() ?? 0.0,
            description: _mapWeatherCodeToDescription(codes[i] ?? 0),
          ),
        );
      }
      return list;
    }
    return [];
  }

  static String _mapWeatherCodeToDescription(int weatherCode) {
    if (weatherCode == 0) return "Clear sky";
    if ([1, 2, 3].contains(weatherCode)) return "Partly cloudy";
    if ([45, 48].contains(weatherCode)) return "Foggy";
    if ([51, 53, 55].contains(weatherCode)) return "Drizzle";
    if ([61, 63, 65].contains(weatherCode)) return "Rain";
    if ([71, 73, 75].contains(weatherCode)) return "Snow";
    if ([95, 96, 99].contains(weatherCode)) return "Thunderstorm";
    return "Unknown";
  }
}
