import 'package:flutter/material.dart';
import 'screens/currently_screen.dart';
import 'screens/today_screen.dart';
import 'screens/week_screen.dart';
import 'widgets/top_bar.dart';
import 'services/location_service.dart';
import 'package:weather_app/models/city.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: Home());
//   }
// }

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   late City = currentCity;

//   @override
//   void initState() {
//     super.initState();
//     _fetchLocationOnStart();
//   }

//   Future<void> _fetchLocationOnStart() async {
//     String coords = await LocationService.getLocation(context);
//     if (mounted) {
//       setState(() => city = coords);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3, // 3 tabs
//       child: Scaffold(
//         appBar: TopBar(
//           onCitySelected: (selectedCity) {
//             setState(() => currentCity = selectedCity);
//             print('Selected City: $selectedCity');
//           },
//           onGeo: () async {
//             String location = await LocationService.getLocation(context);
//             // String location = await LocationService.getCityByLocation(context);
//             setState(() => city = location);
//           },
//         ),

//         body: TabBarView(
//           children: [
//             CurrentlyScreen(city: currentCity),
//             TodayScreen(city: currentCity),
//             WeekScreen(city: currentCity),
//           ],
//         ),
//         bottomNavigationBar: BottomAppBar(
//           child: TabBar(
//             tabs: [
//               Tab(icon: Icon(Icons.access_time), text: 'Currently'),
//               Tab(icon: Icon(Icons.today), text: 'Today'),
//               Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
        body: TabBarView(
          children: [
            CurrentlyScreen(city: currentCity),
            TodayScreen(city: currentCity),
            WeekScreen(city: currentCity),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.access_time), text: 'Currently'),
              Tab(icon: Icon(Icons.today), text: 'Today'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
            ],
          ),
        ),
      ),
    );
  }
}
