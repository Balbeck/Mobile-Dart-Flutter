import 'dart:async';
import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../models/city.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<City> onCitySelected;
  final VoidCallback onGeo;
  final VoidCallback onSettingsPressed;
  final ValueChanged<List<City>> onResultsChanged;
  final ValueChanged<String> onQueryChanged;

  const TopBar({
    super.key,
    required this.onCitySelected,
    required this.onGeo,
    required this.onSettingsPressed,
    required this.onResultsChanged,
    required this.onQueryChanged,
  });

  @override
  TopBarState createState() => TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void clearSearch() {
    _searchController.clear();
    _closeResults();
  }

  void _onSearchChanged(String query) {
    widget.onQueryChanged(query);
    _debounce?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      widget.onResultsChanged([]);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 200), () {
      _doSearch(trimmed);
    });
  }

  Future<void> _doSearch(String query) async {
    final id = ++_requestId;
    try {
      final results = await SearchService.searchCities(query);
      // Ignore si une recherche plus récente a été lancée
      if (id != _requestId) return;
      widget.onResultsChanged(results);
    } catch (_) {
      if (id == _requestId) widget.onResultsChanged([]);
    }
  }

  void _closeResults() {
    _debounce?.cancel();
    _requestId++;
    widget.onResultsChanged([]);
    widget.onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.menu, color: Colors.white, size: 22),
            onPressed: widget.onSettingsPressed,
          ),
        ),
      ),
      title: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onSubmitted: (value) async {
          _debounce?.cancel();
          if (value.trim().isNotEmpty) {
            try {
              final results = await SearchService.searchCities(value.trim());
              if (results.isNotEmpty) {
                widget.onCitySelected(results[0]);
              }
            } catch (e) {
              widget.onCitySelected(City(
                name: 'Exception_Error',
                region: e.toString(),
                country: '',
                latitude: 0,
                longitude: 0,
              ));
            }
          }
          _searchController.clear();
          _closeResults();
        },
        decoration: InputDecoration(
          hintText: 'Search Location...',
          hintStyle: const TextStyle(color: Colors.white70),
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
          onPressed: () {
            _searchController.clear();
            _closeResults();
            widget.onGeo();
          },
        ),
      ],
    );
  }
}
