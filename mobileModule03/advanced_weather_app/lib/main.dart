import 'package:flutter/material.dart';
import 'screens/currently_screen.dart';
import 'screens/today_screen.dart';
import 'screens/week_screen.dart';
import 'widgets/top_bar.dart';
import 'services/location_service.dart';
import 'package:weather_app/models/city.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late City currentCity;

  @override
  void initState() {
    super.initState();
    currentCity = City(
      name: 'No location',
      region: '',
      country: '',
      latitude: 0.0,
      longitude: 0.0,
    );
    _fetchLocationOnStart();
  }

  Future<void> _fetchLocationOnStart() async {
    City cityFromLocation = await LocationService.getCityByLocation(context);
    if (mounted) {
      setState(() => currentCity = cityFromLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("backgroud_image_weatherApp.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: TopBar(
            onCitySelected: (selectedCity) {
              setState(() => currentCity = selectedCity);
              print('Selected City: $selectedCity');
            },
            onGeo: () async {
              City cityFromLocation = await LocationService.getCityByLocation(
                context,
              );
              setState(() => currentCity = cityFromLocation);
            },
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                CurrentlyScreen(city: currentCity),
                TodayScreen(city: currentCity),
                WeekScreen(city: currentCity),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            child: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.access_time), text: 'Currently'),
                Tab(icon: Icon(Icons.today), text: 'Today'),
                Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
