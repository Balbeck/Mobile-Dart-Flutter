import 'package:flutter/material.dart';
import '../models/city.dart';
import '../services/weather_service.dart';

class WeekScreen extends StatefulWidget {
  final City city;

  const WeekScreen({super.key, required this.city});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  List<DailyWeather>? _weatherList;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.city.name != 'No location') {
      _fetchWeather();
    }
  }

  @override
  void didUpdateWidget(WeekScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != oldWidget.city) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    if (widget.city == 'No location') return;
    setState(() => _loading = true);
    final weather = await WeatherService.getWeeklyWeather(widget.city);
    setState(() {
      _weatherList = weather;
      _loading = false;
    });
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    print('Week_Screen / City: [ ${widget.city} ]');

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
                        _formatDate(weather.date),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Min: ${weather.tempMin}°C / Max: ${weather.tempMax}°C',
                          ),
                          Text('Weather: ${weather.description}'),
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
