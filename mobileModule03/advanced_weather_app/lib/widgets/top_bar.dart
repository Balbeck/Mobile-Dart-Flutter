import 'package:flutter/material.dart';
import '../services/search_service.dart';
import '../models/city.dart';

// ─────────────────────────────────────────────────────────────
//  TopBar  — barre de recherche avec bouton hamburger (settings)
//  La liste de suggestions est exposée via [onResultsChanged]
//  et affichée en overlay dans main.dart via un Stack.
// ─────────────────────────────────────────────────────────────
class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<City> onCitySelected;
  final VoidCallback onGeo;
  final VoidCallback onSettingsPressed;

  /// Appelé à chaque changement de résultats :
  /// transmet la liste (vide = fermer l'overlay).
  final ValueChanged<List<City>> onResultsChanged;

  /// Texte courant dans le champ (pour le highlight en gras).
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
  _TopBarState createState() => _TopBarState();

  @override
  // preferredSize = hauteur de l'AppBar uniquement, sans la liste
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _onSearchChanged(String query) async {
    widget.onQueryChanged(query);
    if (query.trim().length >= 1) {
      try {
        final results = await SearchService.searchCities(query.trim());
        widget.onResultsChanged(results);
      } catch (_) {
        widget.onResultsChanged([]);
      }
    } else {
      widget.onResultsChanged([]);
    }
  }

  void _closeResults() {
    widget.onResultsChanged([]);
    widget.onQueryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // ── Bouton hamburger à gauche ──
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
          if (value.trim().length >= 3) {
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
            _closeResults();
            widget.onGeo();
          },
        ),
      ],
    );
  }
}
