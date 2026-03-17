import 'package:flutter/material.dart';
import '../services/weather_service.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN CONSTANTS  (cohérentes avec today / currently)
// ─────────────────────────────────────────────────────────────
class WeekDesign {
  static const Color accent = Color(0xFFE8A045);       // orange ambre
  static const Color accentBlue = Color(0xFF5BC4D8);   // bleu ciel (min temp)
  static const Color accentRed = Color(0xFFE85C45);    // rouge (max temp)
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFBBBBBB);
  static const Color cardBg = Color(0x33000000);
  static const Color divider = Color(0x44FFFFFF);

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
  static const TextStyle dayLabel = TextStyle(
    color: textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle maxTemp = TextStyle(
    color: accentRed,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle minTemp = TextStyle(
    color: accentBlue,
    fontSize: 12,
  );
  static const TextStyle condLabel = TextStyle(
    color: textSecondary,
    fontSize: 11,
  );
}

// ─────────────────────────────────────────────────────────────
//  WIDGET PRINCIPAL : WeekScreenLayout
//  Reçoit les données de WeekScreen — affichage uniquement.
//  Sujet : localisation, graphique 2 courbes min/max, liste 7 jours
// ─────────────────────────────────────────────────────────────
class WeekScreenLayout extends StatelessWidget {
  final String cityName;
  final String regionName;
  final String countryName;
  final List<DailyWeather> weatherList;

  const WeekScreenLayout({
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
        _WeeklyChart(weatherList: weatherList),
        const SizedBox(height: 12),
        Expanded(
          child: _DailyList(weatherList: weatherList),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EN-TÊTE
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
        Text(cityName, style: WeekDesign.cityName),
        const SizedBox(height: 2),
        Text('$regionName, $countryName', style: WeekDesign.regionName),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GRAPHIQUE 2 COURBES  min (bleu) + max (rouge)
// ─────────────────────────────────────────────────────────────
class _WeeklyChart extends StatelessWidget {
  final List<DailyWeather> weatherList;

  const _WeeklyChart({required this.weatherList});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: WeekDesign.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WeekDesign.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('Weekly temperatures', style: WeekDesign.chartTitle),
          ),
          // Légende
          Row(
            children: [
              _LegendDot(color: WeekDesign.accentRed, label: 'Max temperature'),
              const SizedBox(width: 16),
              _LegendDot(color: WeekDesign.accentBlue, label: 'Min temperature'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _WeekChartPainter(weatherList: weatherList),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 9)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PAINTER  — 2 courbes bezier smooth
// ─────────────────────────────────────────────────────────────
class _WeekChartPainter extends CustomPainter {
  final List<DailyWeather> weatherList;
  _WeekChartPainter({required this.weatherList});

  @override
  void paint(Canvas canvas, Size size) {
    if (weatherList.isEmpty) return;

    final maxTemps = weatherList.map((w) => w.tempMax).toList();
    final minTemps = weatherList.map((w) => w.tempMin).toList();
    final allTemps = [...maxTemps, ...minTemps];

    final double globalMin = allTemps.reduce((a, b) => a < b ? a : b) - 2;
    final double globalMax = allTemps.reduce((a, b) => a > b ? a : b) + 2;
    final double range = globalMax - globalMin;

    final int count = weatherList.length;
    final double xStep = size.width / (count - 1);

    double toY(double temp) =>
        size.height - ((temp - globalMin) / range) * size.height;

    // ── Grille horizontale ──
    final gridPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final double y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      final double labelTemp = globalMax - (range * i / 4);
      final tp = TextPainter(
        text: TextSpan(
          text: '${labelTemp.toStringAsFixed(0)}°',
          style: const TextStyle(color: Color(0x88FFFFFF), fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y + 2));
    }

    // ── Labels jours (axe X) ──
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 0; i < count; i++) {
      final double x = i * xStep;
      final dayStr = days[(weatherList[i].date.weekday - 1) % 7];
      final tp = TextPainter(
        text: TextSpan(
          text: dayStr,
          style: const TextStyle(color: Color(0x88FFFFFF), fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Positionné sous la courbe, aligné sur le point
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - tp.height));
    }

    // ── Dessine une courbe smooth ──
    void drawCurve(List<double> temps, Color color) {
      final fillPaint = Paint()
        ..color = color.withOpacity(0.10)
        ..style = PaintingStyle.fill;
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final path = Path();
      final fillPath = Path();

      for (int i = 0; i < count; i++) {
        final double x = i * xStep;
        final double y = toY(temps[i]);

        if (i == 0) {
          path.moveTo(x, y);
          fillPath.moveTo(x, size.height);
          fillPath.lineTo(x, y);
        } else {
          final double prevX = (i - 1) * xStep;
          final double prevY = toY(temps[i - 1]);
          final double cpX = (prevX + x) / 2;
          path.cubicTo(cpX, prevY, cpX, y, x, y);
          fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
        }
      }

      fillPath.lineTo((count - 1) * xStep, size.height);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, linePaint);

      // Points
      for (int i = 0; i < count; i++) {
        canvas.drawCircle(Offset(i * xStep, toY(temps[i])), 3.5, dotPaint);
      }
    }

    // Courbe min (bleu) puis max (rouge) par-dessus
    drawCurve(minTemps, WeekDesign.accentBlue);
    drawCurve(maxTemps, WeekDesign.accentRed);
  }

  @override
  bool shouldRepaint(covariant _WeekChartPainter oldDelegate) =>
      oldDelegate.weatherList != weatherList;
}

// ─────────────────────────────────────────────────────────────
//  LISTE SCROLLABLE DES JOURS
// ─────────────────────────────────────────────────────────────
class _DailyList extends StatelessWidget {
  final List<DailyWeather> weatherList;
  const _DailyList({required this.weatherList});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: weatherList.length,
      separatorBuilder: (_, __) => Divider(
        color: WeekDesign.divider,
        height: 1,
        thickness: 0.5,
      ),
      itemBuilder: (context, index) {
        return _DailyRow(weather: weatherList[index]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LIGNE JOURNALIÈRE : date | icône | condition | min | max
// ─────────────────────────────────────────────────────────────
class _DailyRow extends StatelessWidget {
  final DailyWeather weather;
  const _DailyRow({required this.weather});

  static const List<String> _days = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  String _formatDate(DateTime d) {
    final day = _days[(d.weekday - 1) % 7];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$day  $dd/$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: WeekDesign.cardBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 72,
            child: Text(_formatDate(weather.date), style: WeekDesign.dayLabel),
          ),

          // Icône
          SizedBox(
            width: 32,
            child: Icon(
              _weatherIcon(weather.description),
              color: WeekDesign.accent,
              size: 20,
            ),
          ),

          // Condition
          Expanded(
            child: Text(
              weather.description,
              style: WeekDesign.condLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Min temperature
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_downward,
                  color: WeekDesign.accentBlue, size: 12),
              const SizedBox(width: 2),
              Text(
                '${weather.tempMin.toStringAsFixed(1)}°C',
                style: WeekDesign.minTemp,
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Max temperature
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_upward,
                  color: WeekDesign.accentRed, size: 12),
              const SizedBox(width: 2),
              Text(
                '${weather.tempMax.toStringAsFixed(1)}°C',
                style: WeekDesign.maxTemp,
              ),
            ],
          ),
        ],
      ),
    );
  }

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
//  WIDGETS D'ÉTAT
// ─────────────────────────────────────────────────────────────
class WeekLoadingView extends StatelessWidget {
  const WeekLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: WeekDesign.accent),
    );
  }
}

class WeekErrorView extends StatelessWidget {
  final String message;
  const WeekErrorView({super.key, required this.message});

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

class WeekEmptyView extends StatelessWidget {
  const WeekEmptyView({super.key});

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
