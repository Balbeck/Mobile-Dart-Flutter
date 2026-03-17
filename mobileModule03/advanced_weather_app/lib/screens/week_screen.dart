import 'package:flutter/material.dart';
import '../models/city.dart';
import '../services/weather_service.dart';
import 'week_screen_layout.dart';

class WeekScreen extends StatefulWidget {
  final City city;
  final List<DailyWeather>? cachedWeather;

  const WeekScreen({super.key, required this.city, this.cachedWeather});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  List<DailyWeather>? _weatherList;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _weatherList = widget.cachedWeather;
    if (widget.city.name != 'No location') {
      _fetchWeather();
    }
  }

  @override
  void didUpdateWidget(WeekScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cachedWeather != oldWidget.cachedWeather && widget.cachedWeather != null) {
      _weatherList = widget.cachedWeather;
    }
    if (widget.city != oldWidget.city) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    if (widget.city.name == 'No location') return;
    setState(() {
      _loading = _weatherList == null;
      _errorMessage = null;
    });

    try {
      final weather = await WeatherService.getWeeklyWeather(widget.city);
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
          if (_weatherList == null) _errorMessage = e.toString();
          _loading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    print('Week_Screen / City: [ ${widget.city} ]');

    // Error Search de la city
    if (widget.city.name == 'Exception_Error') {
      return Center(
        child: Text(
          widget.city.region, // Error msg region
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    // Cas aucune ville n'est selectionnee
    if (widget.city.name == 'No location' || widget.city.name == 'Unknown') {
      return const Center(
        child: Text(
          'No city selected, Select a city to view weather.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_loading) return const WeekLoadingView();

    if (_errorMessage != null) return WeekErrorView(message: _errorMessage!);

    if (_weatherList == null || _weatherList!.isEmpty) {
      return const WeekEmptyView();
    }

    return WeekScreenLayout(
      cityName: widget.city.name,
      regionName: widget.city.region,
      countryName: widget.city.country,
      weatherList: _weatherList!,
    );
  }
}
