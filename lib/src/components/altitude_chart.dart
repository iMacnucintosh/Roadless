import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:roadless/src/models/location.dart';

class AltitudeChart extends StatefulWidget {
  final List<Location> locations;
  final Color trackColor;

  const AltitudeChart({
    super.key,
    required this.locations,
    required this.trackColor,
  });

  @override
  AltitudeChartState createState() => AltitudeChartState();
}

class AltitudeChartState extends State<AltitudeChart> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.show_chart),
                        const SizedBox(width: 10),
                        Text("Elevación", style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: _isExpanded ? 150 : 0,
              padding: const EdgeInsets.only(top: 16.0),
              child: _isExpanded
                  ? LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipColor: (touchedSpot) => Theme.of(context).colorScheme.surfaceContainerHighest,
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((LineBarSpot touchedSpot) {
                                return LineTooltipItem(
                                  '${touchedSpot.y.toInt()}m',
                                  Theme.of(context).textTheme.bodyMedium!,
                                );
                              }).toList();
                            },
                          ),
                          handleBuiltInTouches: true,
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            color: widget.trackColor,
                            spots: widget.locations.asMap().entries.map((entry) {
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
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
