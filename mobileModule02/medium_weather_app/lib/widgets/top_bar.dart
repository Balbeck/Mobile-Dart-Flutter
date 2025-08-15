import 'package:flutter/material.dart';

class TopBar extends AppBar {
  TopBar({
    super.key,
    required ValueChanged<String> onSearch,
    required VoidCallback onGeo,
  }) : super(
         title: TextField(
           onChanged: onSearch,
           decoration: InputDecoration(hintText: 'Search location...'),
           textInputAction: TextInputAction.search,
         ),
         actions: [
           IconButton(
             icon: Icon(Icons.location_on),
             onPressed: () {
               print('Location Icon pressed');
               onGeo();
             }, // Geo button - ajoute logique plus tard
           ),
         ],
       );
}
