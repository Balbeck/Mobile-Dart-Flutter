import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  final String city;

  const TodayScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    print('TodayScreen');
    final prefix = city.isEmpty ? '' : city;
    return Center(child: Text('${prefix}\nToday'));
  }
}
