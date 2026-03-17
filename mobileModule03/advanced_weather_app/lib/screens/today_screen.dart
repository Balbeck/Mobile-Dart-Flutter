import 'package:flutter/material.dart';
import 'package:weather_app/models/city.dart';
import '../services/weather_service.dart';
import 'today_screen_layout.dart';

class TodayScreen extends StatefulWidget {
  final City city;
  final List<HourlyWeather>? cachedWeather;

  const TodayScreen({super.key, required this.city, this.cachedWeather});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  List<HourlyWeather>? _weatherList;
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
  void didUpdateWidget(TodayScreen oldWidget) {
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
          if (_weatherList == null) _errorMessage = e.toString();
          _loading = false;
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

    if (_loading) return const TodayLoadingView();

    if (_errorMessage != null) return TodayErrorView(message: _errorMessage!);

    if (_weatherList == null || _weatherList!.isEmpty) {
      return const TodayEmptyView();
    }

    return TodayScreenLayout(
      cityName: widget.city.name,
      regionName: widget.city.region,
      countryName: widget.city.country,
      weatherList: _weatherList!,
    );
  }
}
