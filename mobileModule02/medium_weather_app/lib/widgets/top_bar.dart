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
    if (query.trim().length >= 3) {
      final results = await SearchService.searchCities(query.trim());
      setState(() {
        _searchResults = results;
        _showResults = true;
      });
    } else {
      setState(() => _showResults = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onSubmitted: (value) {
              setState(() => _showResults = false);
            },
            decoration: const InputDecoration(
              hintText: 'Search Location...',
              border: InputBorder.none,
            ),
            textInputAction: TextInputAction.search,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: widget.onGeo,
            ),
          ],
        ),
        if (_showResults)
          Container(
            color: Colors.grey[100],
            height: 200,
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final city = _searchResults[index];
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${city.name},",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: "  "),
                        TextSpan(
                          text: city.region,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const TextSpan(text: ", "),
                        TextSpan(
                          text: city.country,
                          style: const TextStyle(color: Colors.grey),
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
