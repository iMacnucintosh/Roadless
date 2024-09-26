import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:roadless/src/models/location.dart';

class AltitudeChart extends StatelessWidget {
  final List<Location> locations;
  final Color trackColor;

  const AltitudeChart({super.key, required this.locations, required this.trackColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface,
      ),
      constraints: BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(
              show: false,
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surfaceContainerHighest,
                tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((LineBarSpot touchedSpot) {
                    return LineTooltipItem(
                      '${touchedSpot.y}m', // El texto que se mostrará
                      Theme.of(context).textTheme.bodyMedium!,
                    );
                  }).toList();
                },
              ),
              handleBuiltInTouches: true,
            ),
            lineBarsData: [
              LineChartBarData(
                color: trackColor,
                spots: locations.asMap().entries.map((entry) {
                  int index = entry.key;
                  double elevation = entry.value.elevation;
                  return FlSpot(index.toDouble(), elevation);
                }).toList(),
                isCurved: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
