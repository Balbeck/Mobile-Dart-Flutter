import 'package:flutter/material.dart';

class CurrentlyScreen extends StatelessWidget {
  final String city;

  const CurrentlyScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    print('CurrentlyScreen');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Currently'), if (city.isNotEmpty) Text(city)],
      ),
    );
  }
}
