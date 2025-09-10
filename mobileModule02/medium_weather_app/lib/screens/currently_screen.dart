import 'package:flutter/material.dart';
import 'package:weather_app/models/city.dart';
import 'package:weather_app/services/weather_service.dart';

class CurrentlyScreen extends StatefulWidget {
  final City city;

  const CurrentlyScreen({super.key, required this.city});

  @override
  State<CurrentlyScreen> createState() => _CurrentlyScreenState();
}

class _CurrentlyScreenState extends State<CurrentlyScreen> {
  CurrentWeather? _weather;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.city.name != 'No location') {
      _fetchWeather();
    }
  }

  @override
  void didUpdateWidget(CurrentlyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != oldWidget.city) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    if (widget.city.name == 'No Location') return;
    setState(() => _loading = true);
    try {
      final weather = await WeatherService.getCurrentWeather(widget.city);
      if (mounted) {
        setState(() {
          _weather = weather;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weather = null;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('CurrentlyScreen / City: [ ${widget.city} ]');

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
      child: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.city.name}, ${widget.city.region}, ${widget.city.country}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  if (_weather != null) ...[
                    Text(
                      'Temperature: ${_weather!.temperature.toStringAsFixed(1)}°C',
                    ),
                    const SizedBox(height: 10),
                    Text('Weather: ${_weather!.description}'),
                    const SizedBox(height: 10),
                    Text(
                      'Wind: ${_weather!.windSpeed.toStringAsFixed(1)} km/h',
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
