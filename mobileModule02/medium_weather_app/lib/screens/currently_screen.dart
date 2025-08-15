import 'package:flutter/material.dart';

class CurrentlyScreen extends StatelessWidget {
  final String city;

  const CurrentlyScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    print('CurrentlyScreen');
    final prefix = city.isEmpty ? '' : city;
    return Center(child: Text('${prefix}\nCurrently'));
  }
}
