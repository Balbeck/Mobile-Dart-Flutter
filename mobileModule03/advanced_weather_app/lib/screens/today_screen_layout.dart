import 'package:flutter/material.dart';
import '../services/weather_service.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN CONSTANTS  (palette inspirée du sujet Mobile 03)
// ─────────────────────────────────────────────────────────────
class TodayDesign {
  // Couleurs principales
  static const Color accent = Color(0xFFE8A045); // orange ambre
  static const Color accentBlue = Color(0xFF5BC4D8); // bleu ciel accent
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFBBBBBB);
  static const Color cardBg = Color(0x33000000); // noir semi-transparent
  static const Color divider = Color(0x44FFFFFF);

  // Typographie
  static const TextStyle cityName = TextStyle(
    color: accent,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
  static const TextStyle regionName = TextStyle(
    color: textSecondary,
    fontSize: 13,
    letterSpacing: 0.3,
  );
  static const TextStyle chartTitle = TextStyle(
    color: textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static const TextStyle hourLabel = TextStyle(
    color: textPrimary,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle tempLabel = TextStyle(
    color: accent,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle windLabel = TextStyle(
    color: accentBlue,
    fontSize: 11,
  );
  static const TextStyle condLabel = TextStyle(
    color: textSecondary,
    fontSize: 11,
  );
}

// ─────────────────────────────────────────────────────────────
//  WIDGET PRINCIPAL : TodayScreenLayout
//  Reçoit les données de TodayScreen et se charge uniquement
//  de l'affichage (pas de logique métier ici).
// ─────────────────────────────────────────────────────────────
class TodayScreenLayout extends StatelessWidget {
  final String cityName;
  final String regionName;
  final String countryName;
  final List<HourlyWeather> weatherList;

  const TodayScreenLayout({
    super.key,
    required this.cityName,
    required this.regionName,
    required this.countryName,
    required this.weatherList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        _CityHeader(
          cityName: cityName,
          regionName: regionName,
          countryName: countryName,
        ),
        const SizedBox(height: 16),
        _TemperatureChart(weatherList: weatherList),
        const SizedBox(height: 12),
        Expanded(
          child: _HourlyList(weatherList: weatherList),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EN-TÊTE : Ville / Région / Pays
// ─────────────────────────────────────────────────────────────
class _CityHeader extends StatelessWidget {
  final String cityName;
  final String regionName;
  final String countryName;

  const _CityHeader({
    required this.cityName,
    required this.regionName,
    required this.countryName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(cityName, style: TodayDesign.cityName),
        const SizedBox(height: 2),
        Text(
          '$regionName, $countryName',
          style: TodayDesign.regionName,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GRAPHIQUE DE TEMPÉRATURE  (CustomPaint, pas de lib externe)
// ─────────────────────────────────────────────────────────────
class _TemperatureChart extends StatelessWidget {
  final List<HourlyWeather> weatherList;

  const _TemperatureChart({required this.weatherList});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: TodayDesign.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TodayDesign.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Today temperatures', style: TodayDesign.chartTitle),
          ),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _ChartPainter(weatherList: weatherList),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PAINTER du graphique
// ─────────────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<HourlyWeather> weatherList;

  _ChartPainter({required this.weatherList});

  @override
  void paint(Canvas canvas, Size size) {
    if (weatherList.isEmpty) return;

    final temps = weatherList.map((w) => w.temperature).toList();
    final hours = weatherList.map((w) => w.time.hour).toList();

    final double minTemp = temps.reduce((a, b) => a < b ? a : b) - 2;
    final double maxTemp = temps.reduce((a, b) => a > b ? a : b) + 2;
    final double tempRange = maxTemp - minTemp;

    final int count = temps.length;
    final double xStep = size.width / (count - 1);

    // ── Grille horizontale ──
    final gridPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final double labelTemp = maxTemp - (tempRange * i / 4);
      final tp = TextPainter(
        text: TextSpan(
          text: '${labelTemp.toStringAsFixed(0)}°',
          style: const TextStyle(color: Color(0x88FFFFFF), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y + 2));
    }

    // ── Ligne de la courbe ──
    final linePaint = Paint()
      ..color = TodayDesign.accent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // ── Remplissage sous la courbe ──
    final fillPaint = Paint()
      ..color = TodayDesign.accent.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    double firstX = 0, firstY = 0;

    for (int i = 0; i < count; i++) {
      final double x = i * xStep;
      final double y =
          size.height - ((temps[i] - minTemp) / tempRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
        firstX = x;
        firstY = y;
      } else {
        // Courbe bezier smooth
        final double prevX = (i - 1) * xStep;
        final double prevY =
            size.height - ((temps[i - 1] - minTemp) / tempRange) * size.height;
        final double cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    // Fermer le fill
    fillPath.lineTo((count - 1) * xStep, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // ── Points et labels heure ──
    final dotPaint = Paint()
      ..color = TodayDesign.accent
      ..style = PaintingStyle.fill;

    // N'afficher qu'un label sur 3 pour éviter la surcharge
    for (int i = 0; i < count; i++) {
      final double x = i * xStep;
      final double y =
          size.height - ((temps[i] - minTemp) / tempRange) * size.height;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);

      if (i % 3 == 0) {
        final hourStr =
            '${hours[i].toString().padLeft(2, '0')}:00';
        final tp = TextPainter(
          text: TextSpan(
            text: hourStr,
            style: const TextStyle(
              color: Color(0xAAFFFFFF),
              fontSize: 8,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(x - tp.width / 2, size.height - tp.height - 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.weatherList != weatherList;
}

// ─────────────────────────────────────────────────────────────
//  LISTE SCROLLABLE DES HEURES
// ─────────────────────────────────────────────────────────────
class _HourlyList extends StatelessWidget {
  final List<HourlyWeather> weatherList;

  const _HourlyList({required this.weatherList});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: weatherList.length,
      separatorBuilder: (_, __) => Divider(
        color: TodayDesign.divider,
        height: 1,
        thickness: 0.5,
      ),
      itemBuilder: (context, index) {
        final w = weatherList[index];
        return _HourlyRow(weather: w);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LIGNE HORAIRE : heure | icône météo | température | vent
// ─────────────────────────────────────────────────────────────
class _HourlyRow extends StatelessWidget {
  final HourlyWeather weather;

  const _HourlyRow({required this.weather});

  @override
  Widget build(BuildContext context) {
    final String hourStr =
        '${weather.time.hour.toString().padLeft(2, '0')}:00';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: TodayDesign.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Heure
          SizedBox(
            width: 48,
            child: Text(hourStr, style: TodayDesign.hourLabel),
          ),

          // Icône météo
          SizedBox(
            width: 36,
            child: Center(
              child: Icon(
                _weatherIcon(weather.description),
                color: TodayDesign.accent,
                size: 22,
              ),
            ),
          ),

          // Condition (texte court)
          Expanded(
            child: Text(
              weather.description,
              style: TodayDesign.condLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Température
          SizedBox(
            width: 52,
            child: Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: TodayDesign.tempLabel,
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(width: 8),

          // Vent
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.air, color: TodayDesign.accentBlue, size: 14),
              const SizedBox(width: 3),
              Text(
                '${weather.windSpeed.toStringAsFixed(1)} km/h',
                style: TodayDesign.windLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Icône en fonction de la description météo
  IconData _weatherIcon(String description) {
    final d = description.toLowerCase();
    if (d.contains('clear')) return Icons.wb_sunny_outlined;
    if (d.contains('partly')) return Icons.wb_cloudy_outlined;
    if (d.contains('cloud')) return Icons.cloud_outlined;
    if (d.contains('fog')) return Icons.foggy;
    if (d.contains('drizzle')) return Icons.grain;
    if (d.contains('rain')) return Icons.umbrella_outlined;
    if (d.contains('snow')) return Icons.ac_unit;
    if (d.contains('thunder')) return Icons.thunderstorm_outlined;
    return Icons.device_thermostat;
  }
}

// ─────────────────────────────────────────────────────────────
//  WIDGETS D'ÉTAT  (erreur / chargement / pas de ville)
//  Réutilisables depuis today_screen.dart
// ─────────────────────────────────────────────────────────────
class TodayErrorView extends StatelessWidget {
  final String message;
  const TodayErrorView({super.key, required this.message});

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

class TodayLoadingView extends StatelessWidget {
  const TodayLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: TodayDesign.accent),
    );
  }
}

class TodayEmptyView extends StatelessWidget {
  const TodayEmptyView({super.key});

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
