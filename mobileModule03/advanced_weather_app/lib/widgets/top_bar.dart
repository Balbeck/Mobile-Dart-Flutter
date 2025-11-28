import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../models/city.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<City> onCitySelected;
  final VoidCallback onGeo;

  const TopBar({super.key, required this.onCitySelected, required this.onGeo});

  @override
  _TopBarState createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 200);
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();
  List<City> _searchResults = [];
  bool _showResults = false;

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().length >= 1) {
      try {
        final results = await SearchService.searchCities(query.trim());
        setState(() {
          _searchResults = results;
          _showResults = true;
        });
      } catch (e) {
        setState(() {
          _searchResults = [];
          _showResults = false;
        });
      }
    } else {
      setState(() => _showResults = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          title: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (value) async {
              if (value.trim().length >= 3) {
                try {
                  final results = await SearchService.searchCities(
                    value.trim(),
                  );
                  //si Enter on garde le premier result !
                  if (results.isNotEmpty) {
                    widget.onCitySelected(results[0]);
                  }
                } catch (e) {
                  // ErrorCity pour throw l'error
                  final errorCity = City(
                    name: 'Exception_Error',
                    region: e.toString(),
                    country: '',
                    latitude: 0,
                    longitude: 0,
                  );
                  widget.onCitySelected(errorCity);
                }
              }
              _searchController.clear();
              setState(() => _showResults = false);
            },
            decoration: InputDecoration(
              hintText: 'Search Location...',
              hintStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(color: Colors.white, width: 2.0),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 16.0,
              ),
            ),
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.white),
              onPressed: widget.onGeo,
            ),
          ],
        ),

        if (_showResults)
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(200, 200, 200, 0.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            height: 200,
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final city = _searchResults[index];
                return ListTile(
                  // leading: const Icon(Icons.location_city, color: Colors.blue),
                  leading: const Icon(Icons.location_city, color: Colors.white),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        // Partie en gras du nom de la ville deja tapee
                        if (_searchController.text.isNotEmpty)
                          TextSpan(
                            text: city.name.substring(
                              0,
                              _searchController.text.length.clamp(
                                0,
                                city.name.length,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        // Partie restante du nom de la ville en gris
                        if (_searchController.text.isNotEmpty)
                          TextSpan(
                            text: city.name.substring(
                              _searchController.text.length.clamp(
                                0,
                                city.name.length,
                              ),
                            ),
                            style: const TextStyle(
                              // color: Colors.grey,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),

                        const TextSpan(
                          text: ", ",
                          // style: TextStyle(color: Colors.grey),
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: city.region,
                          // style: const TextStyle(color: Colors.grey),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const TextSpan(
                          text: ", ",
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: city.country,
                          // style: const TextStyle(color: Colors.grey),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    widget.onCitySelected(city);
                    _searchController.text = city.name;
                    setState(() => _showResults = false);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
