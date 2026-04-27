import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final List<double>? history;

  const SensorCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B29),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Mini chart en fond
          if (history != null && history!.length > 2)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Opacity(
                  opacity: 0.35,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: const LineTouchData(enabled: false),
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: history!
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList(),
                          isCurved: true,
                          color: color,
                          barWidth: 1.8,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withOpacity(0.25),
                                color.withOpacity(0.02),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(value,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  )),
              const SizedBox(height: 2),
              Text(unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                  )),
              const SizedBox(height: 6),
              Text(label.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
