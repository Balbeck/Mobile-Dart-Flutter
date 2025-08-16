import 'package:flutter/material.dart';

class WeekScreen extends StatelessWidget {
  final String city;

  const WeekScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    print('WeekScreen');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Weekly'), if (city.isNotEmpty) Text(city)],
      ),
    );
  }
}
