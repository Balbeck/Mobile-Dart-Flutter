import 'package:flutter/material.dart';
import '../services/weather_service.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN CONSTANTS  (cohérentes avec today_screen_layout)
// ─────────────────────────────────────────────────────────────
class CurrentlyDesign {
  static const Color accent = Color(0xFFE8A045);       // orange ambre
  static const Color accentBlue = Color(0xFF5BC4D8);   // bleu ciel
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFBBBBBB);
  static const Color cardBg = Color(0x33000000);
  static const Color divider = Color(0x44FFFFFF);

  static const TextStyle cityName = TextStyle(
    color: accent,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
  static const TextStyle regionName = TextStyle(
    color: textSecondary,
    fontSize: 14,
    letterSpacing: 0.3,
  );
  static const TextStyle temperature = TextStyle(
    color: accent,
    fontSize: 64,
    fontWeight: FontWeight.w200,
    letterSpacing: -2,
  );
  static const TextStyle description = TextStyle(
    color: textPrimary,
    fontSize: 18,
    letterSpacing: 0.5,
  );
  static const TextStyle windSpeed = TextStyle(
    color: accentBlue,
    fontSize: 15,
  );
}

// ─────────────────────────────────────────────────────────────
//  WIDGET PRINCIPAL : CurrentlyScreenLayout
//  Reçoit les données de CurrentlyScreen — affichage uniquement.
//  Sujet : localisation, température, description, icône, vent
// ─────────────────────────────────────────────────────────────
class CurrentlyScreenLayout extends StatelessWidget {
  final String cityName;
  final String regionName;
  final String countryName;
  final CurrentWeather weather;

  const CurrentlyScreenLayout({
    super.key,
    required this.cityName,
    required this.regionName,
    required this.countryName,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Localisation ──
            Text(cityName, style: CurrentlyDesign.cityName),
            const SizedBox(height: 4),
            Text(
              '$regionName, $countryName',
              style: CurrentlyDesign.regionName,
            ),

            const SizedBox(height: 48),

            // ── Température grand format ──
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: CurrentlyDesign.temperature,
            ),

            const SizedBox(height: 12),

            // ── Description texte ──
            Text(weather.description, style: CurrentlyDesign.description),

            const SizedBox(height: 24),

            // ── Icône météo animée (large) ──
            _WeatherIcon(description: weather.description),

            const SizedBox(height: 32),

            // ── Vitesse du vent ──
            _WindCard(windSpeed: weather.windSpeed),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ICÔNE MÉTÉO  (grande, centrée, avec halo coloré)
// ─────────────────────────────────────────────────────────────
class _WeatherIcon extends StatelessWidget {
  final String description;
  const _WeatherIcon({required this.description});

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(description);
    final color = _colorFor(description);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 52),
    );
  }

  IconData _iconFor(String d) {
    final desc = d.toLowerCase();
    if (desc.contains('clear')) return Icons.wb_sunny_outlined;
    if (desc.contains('partly')) return Icons.wb_cloudy_outlined;
    if (desc.contains('cloud')) return Icons.cloud_outlined;
    if (desc.contains('fog')) return Icons.foggy;
    if (desc.contains('drizzle')) return Icons.grain;
    if (desc.contains('rain')) return Icons.umbrella_outlined;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('thunder')) return Icons.thunderstorm_outlined;
    return Icons.device_thermostat;
  }

  Color _colorFor(String d) {
    final desc = d.toLowerCase();
    if (desc.contains('clear')) return const Color(0xFFE8A045);
    if (desc.contains('rain') || desc.contains('drizzle')) {
      return const Color(0xFF5BC4D8);
    }
    if (desc.contains('snow')) return Colors.white70;
    if (desc.contains('thunder')) return const Color(0xFFFFD700);
    return Colors.white60;
  }
}

// ─────────────────────────────────────────────────────────────
//  CARTE VENT
// ─────────────────────────────────────────────────────────────
class _WindCard extends StatelessWidget {
  final double windSpeed;
  const _WindCard({required this.windSpeed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: CurrentlyDesign.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CurrentlyDesign.divider, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.air, color: CurrentlyDesign.accentBlue, size: 22),
          const SizedBox(width: 10),
          Text(
            '${windSpeed.toStringAsFixed(1)} km/h',
            style: CurrentlyDesign.windSpeed,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  WIDGETS D'ÉTAT  (loading / erreur / vide)
// ─────────────────────────────────────────────────────────────
class CurrentlyLoadingView extends StatelessWidget {
  const CurrentlyLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: CurrentlyDesign.accent),
    );
  }
}

class CurrentlyErrorView extends StatelessWidget {
  final String message;
  const CurrentlyErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent, fontSize: 15),
        ),
      ),
    );
  }
}

class CurrentlyEmptyView extends StatelessWidget {
  const CurrentlyEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No weather data available',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }
}
