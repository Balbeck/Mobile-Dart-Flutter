import 'package:flutter/material.dart';
import 'package:weather_app/models/city.dart';
import '../services/weather_service.dart';

class TodayScreen extends StatefulWidget {
  final City city;

  const TodayScreen({super.key, required this.city});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<HourlyWeather>? _weatherList;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.city.name != 'No location') {
      _fetchWeather();
    }
  }

  @override
  void didUpdateWidget(TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != oldWidget.city) {
      _fetchWeather();
    }
  }

  String? _errorMessage;

  Future<void> _fetchWeather() async {
    if (widget.city.name == 'No location') return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final weather = await WeatherService.getTodayWeather(widget.city);
      if (mounted) {
        setState(() {
          _weatherList = weather;
          _loading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherList = null;
          _loading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Today_Screen / City: [ ${widget.city} ]');

    // Error Search de la city
    if (widget.city.name == 'Exception_Error') {
      return Center(
        child: Text(
          widget.city.region, // Error msg dans region
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    // Cas ou aucune ville n'est selectionnee
    if (widget.city.name == 'No location' || widget.city.name == 'Unknown') {
      return const Center(
        child: Text(
          'No city selected, Select a city to view weather.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '${widget.city.name}, ${widget.city.region}, ${widget.city.country}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: 16),
            )
          else if (_weatherList == null || _weatherList!.isEmpty)
            const Text('No weather data available')
          else
            Expanded(
              child: ListView.builder(
                itemCount: _weatherList!.length,
                itemBuilder: (context, index) {
                  final weather = _weatherList![index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${weather.time.hour}:00',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Temperature: ${weather.temperature}°C'),
                          Text('Weather: ${weather.description}'),
                          Text('Wind: ${weather.windSpeed} km/h'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
