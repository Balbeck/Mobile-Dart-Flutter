import 'package:flutter/material.dart';
import '../services/search_service.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String> onCitySelected;
  final VoidCallback onGeo;

  const TopBar({super.key, required this.onCitySelected, required this.onGeo});

  @override
  _TopBarState createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 200);
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
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
              if (value.trim().isNotEmpty) {
                widget.onCitySelected(value.trim());
              }
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
                final result = _searchResults[index];
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${result['name']},",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: "  "),
                        TextSpan(
                          text: "${result['admin1'] ?? ''}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const TextSpan(text: ", "),
                        TextSpan(
                          text: "${result['country']}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    widget.onCitySelected("${result['name']}");
                    _searchController.text = result['name'];
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
