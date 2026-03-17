import 'package:flutter/material.dart';
import 'package:weather_app/models/city.dart';
import 'package:weather_app/services/weather_service.dart';
import 'currently_screen_layout.dart';

class CurrentlyScreen extends StatefulWidget {
  final City city;

  const CurrentlyScreen({super.key, required this.city});

  @override
  State<CurrentlyScreen> createState() => _CurrentlyScreenState();
}

class _CurrentlyScreenState extends State<CurrentlyScreen> {
  CurrentWeather? _weather;
  bool _loading = false;
  String? _errorMessage;

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
    setState(() {
      _loading = true;
      _errorMessage = null; // Reset error message on new fetch
    });

    try {
      final weather = await WeatherService.getCurrentWeather(widget.city);
      if (mounted) {
        setState(() {
          _weather = weather;
          _loading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weather = null;
          _loading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('CurrentlyScreen / City: [ ${widget.city} ]');

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

    // Cas aucune ville
    if (widget.city.name == 'No location' || widget.city.name == 'Unknown') {
      return const Center(
        child: Text(
          'No city selected, Select a city to view weather.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_loading) return const CurrentlyLoadingView();

    if (_errorMessage != null) {
      return CurrentlyErrorView(message: _errorMessage!);
    }

    if (_weather == null) return const CurrentlyEmptyView();

    return CurrentlyScreenLayout(
      cityName: widget.city.name,
      regionName: widget.city.region,
      countryName: widget.city.country,
      weather: _weather!,
    );
  }
}
