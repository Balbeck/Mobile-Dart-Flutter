import 'package:flutter/material.dart';
import 'screens/currently_screen.dart';
import 'screens/today_screen.dart';
import 'screens/week_screen.dart';
import 'widgets/top_bar.dart';
import 'widgets/settings_drawer.dart';
import 'services/location_service.dart';
import 'package:weather_app/models/city.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late City currentCity;

  // Résultats de recherche exposés par TopBar → affichés en overlay
  List<City> _searchResults = [];
  String _searchQuery = '';

  // ── Background sélectionné (null = aucun) ──
  String? _selectedBackground = 'assets/background_assets/backgroud_image_weatherApp.jpg';

  // ── Contrôle du volet settings ──
  bool _settingsOpen = false;
  late AnimationController _drawerAnimController;
  late Animation<Offset> _drawerSlide;

  @override
  void initState() {
    super.initState();

    currentCity = City(
      name: 'No location',
      region: '',
      country: '',
      latitude: 0.0,
      longitude: 0.0,
    );
    _fetchLocationOnStart();

    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerSlide = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerAnimController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _drawerAnimController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationOnStart() async {
    City cityFromLocation = await LocationService.getCityByLocation(context);
    if (mounted) {
      setState(() => currentCity = cityFromLocation);
    }
  }

  void _onCitySelected(City city) {
    setState(() {
      currentCity = city;
      _searchResults = [];
      _searchQuery = '';
    });
    print('Selected City: $city');
  }

  void _openSettings() {
    setState(() => _settingsOpen = true);
    _drawerAnimController.forward();
  }

  void _closeSettings() {
    _drawerAnimController.reverse().then((_) {
      if (mounted) setState(() => _settingsOpen = false);
    });
  }

  void _onBackgroundSelected(String? path) {
    setState(() => _selectedBackground = path);
    _closeSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        image: _selectedBackground != null
            ? DecorationImage(
                image: AssetImage(_selectedBackground!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: TopBar(
            onCitySelected: _onCitySelected,
            onSettingsPressed: _openSettings,
            onGeo: () async {
              City cityFromLocation = await LocationService.getCityByLocation(
                context,
              );
              setState(() {
                currentCity = cityFromLocation;
                _searchResults = [];
              });
            },
            onResultsChanged: (results) {
              setState(() => _searchResults = results);
            },
            onQueryChanged: (query) {
              setState(() => _searchQuery = query);
            },
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // ── Contenu principal ──
                TabBarView(
                  children: [
                    CurrentlyScreen(city: currentCity),
                    TodayScreen(city: currentCity),
                    WeekScreen(city: currentCity),
                  ],
                ),

                // ── Overlay suggestions de recherche ──
                if (_searchResults.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 260),
                        decoration: BoxDecoration(
                          color: const Color(0xCC1A1A2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0x44FFFFFF),
                            width: 0.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            separatorBuilder: (_, __) => Divider(
                              color: const Color(0x33FFFFFF),
                              height: 1,
                              thickness: 0.5,
                            ),
                            itemBuilder: (context, index) {
                              final city = _searchResults[index];
                              final query = _searchQuery;
                              final nameMatch = query.isNotEmpty &&
                                  city.name.toLowerCase().startsWith(
                                        query.toLowerCase(),
                                      );
                              final splitAt = nameMatch
                                  ? query.length.clamp(0, city.name.length)
                                  : 0;

                              return ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFFE8A045),
                                  size: 20,
                                ),
                                title: RichText(
                                  text: TextSpan(
                                    children: [
                                      if (nameMatch) ...[
                                        TextSpan(
                                          text: city.name.substring(0, splitAt),
                                          style: const TextStyle(
                                            color: Color(0xFFE8A045),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: city.name.substring(splitAt),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ] else
                                        TextSpan(
                                          text: city.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      TextSpan(
                                        text:
                                            '  ${city.region}, ${city.country}',
                                        style: const TextStyle(
                                          color: Color(0xAAFFFFFF),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () => _onCitySelected(city),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Overlay settings drawer ──
                if (_settingsOpen)
                  Positioned.fill(
                    child: SlideTransition(
                      position: _drawerSlide,
                      child: SettingsDrawer(
                        selectedBackground: _selectedBackground,
                        onBackgroundSelected: _onBackgroundSelected,
                        onClose: _closeSettings,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            child: TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.access_time), text: 'Currently'),
                Tab(icon: Icon(Icons.today), text: 'Today'),
                Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
