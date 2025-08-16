import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  final String city;

  const TodayScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    print('TodayScreen');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Today'), if (city.isNotEmpty) Text(city)],
      ),
    );
  }
}
