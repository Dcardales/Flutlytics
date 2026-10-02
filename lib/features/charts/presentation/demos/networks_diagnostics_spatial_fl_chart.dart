import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/networks_diagnostics_spatial_data.dart';
import 'networks_diagnostics_spatial_batch_demos.dart';

Widget buildFlNetworksDiagnosticsSpatial(String id) => switch (id) {
  'network-graph' => _network(),
  'qq-plot' => _qq(),
  'parallel-coordinates' => parallelFrame(_parallel()),
  'contour' => _contour(),
  'calendar-heatmap' => calendarFrame(_calendar()),
  _ => throw ArgumentError.value(id, 'id'),
};

fl.FlTitlesData _hiddenTitles() => const fl.FlTitlesData(show: false);

Widget _network() => Column(
  children: [
    const Text(
      'Red de destinos y servicios · disposición circular',
      style: TextStyle(fontSize: 11),
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: fl.LineChart(
          fl.LineChartData(
            minX: -1.25,
            maxX: 1.25,
            minY: -1.25,
            maxY: 1.25,
            titlesData: _hiddenTitles(),
            lineBarsData: [
              for (final edge in touristNetwork.edges)
                fl.LineChartBarData(
                  spots: [
                    fl.FlSpot(
                      touristNetwork.byId[edge.sourceId]!.x,
                      touristNetwork.byId[edge.sourceId]!.y,
                    ),
                    fl.FlSpot(
                      touristNetwork.byId[edge.targetId]!.x,
                      touristNetwork.byId[edge.targetId]!.y,
                    ),
                  ],
                  color: const Color(0xff90a4ae),
                  barWidth: 1 + edge.weight / 6,
                  dotData: const fl.FlDotData(show: false),
                ),
              for (final p in touristNetwork.positions)
                fl.LineChartBarData(
                  spots: [fl.FlSpot(p.x, p.y)],
                  barWidth: 0,
                  color: Colors.transparent,
                  dotData: fl.FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        fl.FlDotCirclePainter(
                          radius: 5 + p.node.weight / 3,
                          color: p.node.group == 'Destino'
                              ? const Color(0xff1565c0)
                              : p.node.group == 'Transporte'
                              ? const Color(0xffef6c00)
                              : const Color(0xff2e7d32),
                        ),
                  ),
                ),
            ],
            lineTouchData: fl.LineTouchData(
              touchTooltipData: fl.LineTouchTooltipData(
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    s.barIndex >= touristNetwork.edges.length
                        ? fl.LineTooltipItem(
                            networkTooltip(
                              touristNetwork.positions[s.barIndex -
                                  touristNetwork.edges.length],
                            ),
                            const TextStyle(color: Colors.white, fontSize: 10),
                          )
                        : null,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Wrap(
        spacing: 10,
        children: [
          for (final p in touristNetwork.positions)
            Text('● ${p.node.label}', style: const TextStyle(fontSize: 9)),
        ],
      ),
    ),
  ],
);

Widget _qq() => fl.LineChart(
  fl.LineChartData(
    minX: -3,
    maxX: 3,
    minY: -3,
    maxY: 3,
    lineBarsData: [
      fl.LineChartBarData(
        spots: const [fl.FlSpot(-3, -3), fl.FlSpot(3, 3)],
        color: const Color(0xff78909c),
        dashArray: [5, 4],
        barWidth: 1,
        dotData: const fl.FlDotData(show: false),
      ),
      fl.LineChartBarData(
        spots: [
          for (final p in serviceQq) fl.FlSpot(p.theoretical, p.observed),
        ],
        color: const Color(0xff1565c0),
        barWidth: 0,
        dotData: const fl.FlDotData(show: true),
      ),
    ],
    lineTouchData: fl.LineTouchData(
      touchTooltipData: fl.LineTouchTooltipData(
        getTooltipItems: (spots) => [
          for (final s in spots)
            s.barIndex == 1
                ? fl.LineTooltipItem(
                    'Normal ${s.x.toStringAsFixed(2)}\nObservado z=${s.y.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white, fontSize: 11),
                  )
                : null,
        ],
      ),
    ),
  ),
);

Widget _parallel() => fl.LineChart(
  fl.LineChartData(
    minX: 0,
    maxX: (touristParallel.variables.length - 1).toDouble(),
    minY: 0,
    maxY: 1,
    titlesData: fl.FlTitlesData(
      topTitles: const fl.AxisTitles(
        sideTitles: fl.SideTitles(showTitles: false),
      ),
      rightTitles: const fl.AxisTitles(
        sideTitles: fl.SideTitles(showTitles: false),
      ),
      bottomTitles: fl.AxisTitles(
        sideTitles: fl.SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (v, meta) =>
              v == v.round() && v >= 0 && v < touristParallel.variables.length
              ? Text(
                  touristParallel.variables[v.toInt()].label,
                  style: const TextStyle(fontSize: 9),
                )
              : const SizedBox.shrink(),
        ),
      ),
    ),
    extraLinesData: fl.ExtraLinesData(
      verticalLines: [
        for (var i = 0; i < touristParallel.variables.length; i++)
          fl.VerticalLine(
            x: i.toDouble(),
            color: const Color(0xffb0bec5),
            strokeWidth: 1,
          ),
      ],
    ),
    lineBarsData: [
      for (var i = 0; i < touristParallel.observations.length; i++)
        fl.LineChartBarData(
          spots: [
            for (final p in touristParallel.forObservation(
              touristParallel.observations[i],
            ))
              fl.FlSpot(p.axis.toDouble(), p.normalized),
          ],
          isCurved: false,
          color: Colors.primaries[i % Colors.primaries.length].withValues(
            alpha: .75,
          ),
          barWidth: 2,
          dotData: const fl.FlDotData(show: true),
        ),
    ],
    lineTouchData: fl.LineTouchData(
      touchTooltipData: fl.LineTouchTooltipData(
        getTooltipItems: (spots) => [
          for (final s in spots)
            fl.LineTooltipItem(() {
              final p = touristParallel.forObservation(
                touristParallel.observations[s.barIndex],
              )[s.x.round()];
              return '${p.observation.label}\n${p.variable.label}: ${p.raw.toStringAsFixed(1)} ${p.variable.unit}';
            }(), const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    ),
  ),
);

Widget _contour() => fl.LineChart(
  fl.LineChartData(
    minX: 0,
    maxX: 24,
    minY: 0,
    maxY: 19,
    lineBarsData: [
      for (final s in touristContour.segments)
        fl.LineChartBarData(
          spots: [fl.FlSpot(s.a.x, s.a.y), fl.FlSpot(s.b.x, s.b.y)],
          color:
              Colors.primaries[touristContour.levels.indexOf(s.level) %
                  Colors.primaries.length],
          barWidth: 1.7,
          dotData: const fl.FlDotData(show: false),
        ),
    ],
    lineTouchData: fl.LineTouchData(
      touchTooltipData: fl.LineTouchTooltipData(
        getTooltipItems: (spots) => [
          for (final touched in spots)
            fl.LineTooltipItem(
              'Intensidad ${touristContour.segments[touched.barIndex].level.toStringAsFixed(1)}',
              const TextStyle(color: Colors.white, fontSize: 10),
            ),
        ],
      ),
    ),
  ),
);

Widget _calendar() => fl.ScatterChart(
  fl.ScatterChartData(
    minX: -1,
    maxX: bookingCalendar.cells.last.week + 1.0,
    minY: -.6,
    maxY: 6.6,
    titlesData: fl.FlTitlesData(
      topTitles: const fl.AxisTitles(
        sideTitles: fl.SideTitles(showTitles: false),
      ),
      rightTitles: const fl.AxisTitles(
        sideTitles: fl.SideTitles(showTitles: false),
      ),
      leftTitles: fl.AxisTitles(
        sideTitles: fl.SideTitles(
          showTitles: true,
          reservedSize: 18,
          interval: 1,
          getTitlesWidget: (v, meta) => v == v.round() && v >= 0 && v < 7
              ? Text(
                  weekdayLabels[v.toInt()],
                  style: const TextStyle(fontSize: 10),
                )
              : const SizedBox.shrink(),
        ),
      ),
      bottomTitles: fl.AxisTitles(
        sideTitles: fl.SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 1,
          getTitlesWidget: (v, meta) => v == v.round() && v >= 0
              ? Text(monthLabel(v.toInt()), style: const TextStyle(fontSize: 9))
              : const SizedBox.shrink(),
        ),
      ),
    ),
    scatterSpots: [
      for (final c in bookingCalendar.cells)
        fl.ScatterSpot(
          c.week.toDouble(),
          c.weekday.toDouble(),
          dotPainter: fl.FlDotSquarePainter(
            size: 12,
            color: Color.lerp(
              const Color(0xffe3f2fd),
              const Color(0xff0d47a1),
              bookingCalendar.intensity(c.day),
            )!,
            strokeWidth: 0,
          ),
        ),
    ],
    scatterTouchData: fl.ScatterTouchData(
      touchTooltipData: fl.ScatterTouchTooltipData(
        getTooltipItems: (spot) {
          final c = bookingCalendar.cells.firstWhere(
            (v) => v.week == spot.x && v.weekday == spot.y,
          );
          return fl.ScatterTooltipItem(
            '${isoDay(c.day.date)}\n${c.day.value.toStringAsFixed(0)} reservas',
            textStyle: const TextStyle(color: Colors.white, fontSize: 10),
          );
        },
      ),
    ),
  ),
);
