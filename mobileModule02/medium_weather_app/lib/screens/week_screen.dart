import 'package:flutter/material.dart';

class WeekScreen extends StatelessWidget {
  final String city;

  const WeekScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    print('WeekScreen');
    final prefix = city.isEmpty ? '' : city;
    return Center(child: Text('${prefix}\nWeek'));
  }
}
