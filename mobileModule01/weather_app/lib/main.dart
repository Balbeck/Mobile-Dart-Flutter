// ... existing code ...
import 'package:flutter/material.dart';
import 'screens/currently_screen.dart'; // Ajoute ces imports
import 'screens/today_screen.dart';
import 'screens/week_screen.dart';
import 'widgets/top_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String city = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 tabs
      child: Scaffold(
        appBar: TopBar(
          onSearch: (value) => setState(() => city = value.trim()),
          onGeo: () => setState(() => city = '42_Paris'),
        ),

        body: TabBarView(
          children: [
            CurrentlyScreen(city: city),
            TodayScreen(city: city),
            WeekScreen(city: city),
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
