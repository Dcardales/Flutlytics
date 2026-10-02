import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/relationships_intervals_data.dart';

const _colors = [
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
  Color(0xff00838f),
];

Widget buildFlRelationshipsIntervals(String id) => switch (id) {
  'scatter' => _scatter(),
  'bubble' => _bubble(),
  'connected-scatter' => _connected(),
  'error-bar' => _errorBar(),
  _ => _rangeColumn(),
};

Widget _scatter() => Padding(
  padding: const EdgeInsets.fromLTRB(28, 8, 8, 8),
  child: fl.ScatterChart(
    fl.ScatterChartData(
      minX: 0,
      maxX: 8,
      minY: 0,
      maxY: 6000,
      scatterSpots: [
        for (final point in scatterObservations)
          fl.ScatterSpot(point.nights, point.spendThousands),
      ],
      titlesData: _titles(
        bottomName: 'Noches',
        leftName: 'Gasto (mil COP)',
        bottomCount: 5,
        bottom: (v) => v.toStringAsFixed(0),
        leftCount: 4,
        left: (v) => v.toInt().toString(),
      ),
      scatterTouchData: fl.ScatterTouchData(
        enabled: true,
        touchTooltipData: fl.ScatterTouchTooltipData(
          getTooltipItems: (spot) {
            final point = scatterObservations.reduce(
              (a, b) =>
                  ((a.nights - spot.x).abs() +
                          (a.spendThousands - spot.y).abs()) <
                      ((b.nights - spot.x).abs() +
                          (b.spendThousands - spot.y).abs())
                  ? a
                  : b,
            );
            return fl.ScatterTooltipItem(
              '${point.label}\n${point.nights.toStringAsFixed(1)} noches · ${point.spendThousands.toStringAsFixed(0)} mil COP',
              textStyle: TextStyle(color: spot.dotPainter.mainColor),
            );
          },
        ),
      ),
    ),
  ),
);

Widget _bubble() {
  final radii = bubbleDestinationRadii;
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
    child: fl.ScatterChart(
      fl.ScatterChartData(
        minX: 0,
        maxX: 1000,
        minY: 300,
        maxY: 1400,
        scatterSpots: [
          for (var i = 0; i < bubbleDestinations.length; i++)
            fl.ScatterSpot(
              bubbleDestinations[i].visitorsThousands,
              bubbleDestinations[i].spendPerVisitorThousands,
              dotPainter: fl.FlDotCirclePainter(
                radius: radii[i],
                color: _colors[0].withValues(alpha: .65),
              ),
            ),
        ],
        titlesData: _titles(
          bottomName: 'Visitantes (miles)',
          leftName: 'Gasto/turista (mil COP)',
          bottomCount: 5,
          bottom: (v) => v.toInt().toString(),
          leftCount: 4,
          left: (v) => v.toInt().toString(),
        ),
        scatterTouchData: fl.ScatterTouchData(
          enabled: true,
          touchTooltipData: fl.ScatterTouchTooltipData(
            getTooltipItems: (spot) {
              final index = bubbleDestinations.indexWhere(
                (p) =>
                    p.visitorsThousands == spot.x &&
                    p.spendPerVisitorThousands == spot.y,
              );
              final point = bubbleDestinations[index];
              return fl.ScatterTooltipItem(
                '${point.label}\n${point.visitorsThousands}k visitors · ${point.spendPerVisitorThousands}k COP\nEstablishments: ${point.establishments.toInt()}',
                textStyle: TextStyle(color: spot.dotPainter.mainColor),
              );
            },
          ),
        ),
      ),
    ),
  );
}

Widget _connected() {
  final points = connectedScatterPoints;
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
    child: fl.LineChart(
      fl.LineChartData(
        minX: 50,
        maxX: 86,
        minY: 290,
        maxY: 460,
        lineBarsData: [
          fl.LineChartBarData(
            spots: [for (final p in points) fl.FlSpot(p.x, p.y)],
            color: _colors[0],
            barWidth: 2.5,
            dotData: fl.FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  fl.FlDotCirclePainter(
                    radius: index == 0 || index == points.length - 1 ? 6 : 3.5,
                    color: index == 0
                        ? Colors.green
                        : index == points.length - 1
                        ? Colors.red
                        : _colors[0],
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  ),
            ),
          ),
        ],
        titlesData: _titles(
          bottomName: 'Ocupacion (%)',
          leftName: 'Tarifa (mil COP)',
          bottomCount: 5,
          bottom: (v) => v.toInt().toString(),
          leftCount: 4,
          left: (v) => v.toInt().toString(),
        ),
        lineTouchData: fl.LineTouchData(
          enabled: true,
          touchTooltipData: fl.LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final spot in spots)
                fl.LineTooltipItem(
                  '${points[spot.spotIndex].label}\nOcupacion ${spot.x}% · tarifa ${spot.y} mil COP',
                  TextStyle(color: spot.bar.color ?? _colors[0]),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _errorBar() {
  final lines = <fl.LineChartBarData>[];
  for (var i = 0; i < errorBarEstimates.length; i++) {
    final estimate = errorBarEstimates[i];
    final x = i.toDouble();
    final color = _colors[i];
    lines.addAll([
      _line(
        [fl.FlSpot(x, estimate.lower), fl.FlSpot(x, estimate.upper)],
        color,
        2,
      ),
      _line(
        [
          fl.FlSpot(x - .13, estimate.lower),
          fl.FlSpot(x + .13, estimate.lower),
        ],
        color,
        2,
      ),
      _line(
        [
          fl.FlSpot(x - .13, estimate.upper),
          fl.FlSpot(x + .13, estimate.upper),
        ],
        color,
        2,
      ),
      fl.LineChartBarData(
        spots: [fl.FlSpot(x, estimate.estimate)],
        color: Colors.black,
        barWidth: 0,
        dotData: fl.FlDotData(
          show: true,
          getDotPainter: (_, _, _, _) =>
              fl.FlDotCirclePainter(radius: 4, color: Colors.black),
        ),
      ),
    ]);
  }
  return Padding(
    padding: const EdgeInsets.fromLTRB(28, 8, 8, 8),
    child: fl.LineChart(
      fl.LineChartData(
        minX: -.5,
        maxX: errorBarEstimates.length - .5,
        minY: 0,
        lineBarsData: lines,
        titlesData: _titles(
          bottomName: 'Servicio',
          leftName: 'Espera (min)',
          bottomCount: errorBarEstimates.length,
          bottom: (v) {
            final i = v.round();
            return i >= 0 && i < errorBarEstimates.length
                ? errorBarEstimates[i].label
                : '';
          },
          leftCount: 4,
          left: (v) => v.toInt().toString(),
        ),
        lineTouchData: fl.LineTouchData(
          enabled: true,
          touchTooltipData: fl.LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final spot in spots)
                () {
                  final i = (spot.x.round()).clamp(
                    0,
                    errorBarEstimates.length - 1,
                  );
                  final p = errorBarEstimates[i];
                  return fl.LineTooltipItem(
                    '${p.label}\nEstimate ${p.estimate.toStringAsFixed(2)} min\n[${p.lower.toStringAsFixed(2)}, ${p.upper.toStringAsFixed(2)}]',
                    TextStyle(color: spot.bar.color ?? _colors[i]),
                  );
                }(),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _rangeColumn() => Padding(
  padding: const EdgeInsets.fromLTRB(28, 8, 8, 8),
  child: fl.BarChart(
    fl.BarChartData(
      minY: 14,
      maxY: 31,
      barGroups: [
        for (var i = 0; i < dailyTemperatureRanges.length; i++)
          fl.BarChartGroupData(
            x: i,
            barRods: [
              fl.BarChartRodData(
                fromY: dailyTemperatureRanges[i].low,
                toY: dailyTemperatureRanges[i].high,
                width: 22,
                color: _colors[0],
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
      ],
      titlesData: _titles(
        bottomName: 'Dia',
        leftName: 'Temperatura (C)',
        bottomCount: dailyTemperatureRanges.length,
        bottom: (v) {
          final i = v.round();
          return i >= 0 && i < dailyTemperatureRanges.length
              ? dailyTemperatureRanges[i].label
              : '';
        },
        leftCount: 4,
        left: (v) => v.toStringAsFixed(0),
      ),
      barTouchData: fl.BarTouchData(
        enabled: true,
        touchTooltipData: fl.BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final range = dailyTemperatureRanges[group.x];
            return fl.BarTooltipItem(
              '${range.label}\nLow ${range.low}°C · High ${range.high}°C\nSpan ${range.span.toStringAsFixed(1)}°C',
              const TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    ),
  ),
);

fl.LineChartBarData _line(List<fl.FlSpot> spots, Color color, double width) =>
    fl.LineChartBarData(
      spots: spots,
      color: color,
      barWidth: width,
      dotData: const fl.FlDotData(show: false),
    );

fl.FlTitlesData _titles({
  required String bottomName,
  required String leftName,
  required int bottomCount,
  required String Function(double) bottom,
  int leftCount = 0,
  String Function(double)? left,
}) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    axisNameWidget: Text(bottomName),
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: 36,
      interval: bottomCount <= 7 ? 1 : null,
      getTitlesWidget: (value, meta) => fl.SideTitleWidget(
        meta: meta,
        child: Text(bottom(value), style: const TextStyle(fontSize: 9)),
      ),
    ),
  ),
  leftTitles: fl.AxisTitles(
    axisNameWidget: Text(leftName),
    sideTitles: fl.SideTitles(
      showTitles: leftCount > 0,
      reservedSize: 42,
      interval: leftCount > 0 ? (leftCount == 4 ? null : 1) : null,
      getTitlesWidget: (value, meta) => fl.SideTitleWidget(
        meta: meta,
        child: Text(
          left?.call(value) ?? '',
          style: const TextStyle(fontSize: 9),
        ),
      ),
    ),
  ),
);
