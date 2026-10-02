import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/analytical_structures_data.dart';
import 'analytical_structures_batch_demos.dart' show matrixGrid;

Widget buildFlAnalyticalStructures(String id) => switch (id) {
  'diverging-stacked-bar' => _diverging(),
  'scatterplot-matrix' => matrixGrid(_matrixCell),
  'ternary-plot' => _ternary(),
  'fan-chart' => _fan(),
  'calibration-plot' => _calibration(),
  _ => throw ArgumentError.value(id, 'id'),
};

const _colors = <String, Color>{
  'Muy insatisfecho': Color(0xffc62828),
  'Insatisfecho': Color(0xffef9a9a),
  'Neutral': Color(0xffb0bec5),
  'Satisfecho': Color(0xff81c784),
  'Muy satisfecho': Color(0xff2e7d32),
};

Widget _diverging() => Padding(
  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
  child: fl.BarChart(
    fl.BarChartData(
      rotationQuarterTurns: 1,
      minY: -55,
      maxY: 85,
      titlesData: fl.FlTitlesData(
        topTitles: const fl.AxisTitles(
          sideTitles: fl.SideTitles(showTitles: false),
        ),
        rightTitles: const fl.AxisTitles(
          sideTitles: fl.SideTitles(showTitles: false),
        ),
        leftTitles: const fl.AxisTitles(
          sideTitles: fl.SideTitles(showTitles: true, reservedSize: 28),
        ),
        bottomTitles: fl.AxisTitles(
          sideTitles: fl.SideTitles(
            showTitles: true,
            reservedSize: 78,
            getTitlesWidget: (v, meta) {
              final i = v.round();
              return v == i && i >= 0 && i < touristLikert.length
                  ? Text(
                      touristLikert[i].label,
                      style: const TextStyle(fontSize: 10),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < touristLikert.length; i++)
          () {
            final segments = divergingLikert(touristLikert[i]);
            final left = segments.where((s) => s.side == 'left').toList();
            final right = segments.where((s) => s.side == 'right').toList();
            return fl.BarChartGroupData(
              x: i,
              groupVertically: true,
              barRods: [
                fl.BarChartRodData(
                  toY: left.last.end,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                  rodStackItems: [
                    for (final s in left)
                      fl.BarChartRodStackItem(
                        math.min(s.start, s.end),
                        math.max(s.start, s.end),
                        _colors[s.response]!,
                      ),
                  ],
                  color: Colors.transparent,
                ),
                fl.BarChartRodData(
                  toY: right.last.end,
                  width: 20,
                  borderRadius: BorderRadius.zero,
                  rodStackItems: [
                    for (final s in right)
                      fl.BarChartRodStackItem(
                        s.start,
                        s.end,
                        _colors[s.response]!,
                      ),
                  ],
                  color: Colors.transparent,
                ),
              ],
            );
          }(),
      ],
      barTouchData: fl.BarTouchData(
        touchTooltipData: fl.BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final row = touristLikert[group.x];
            final segments = divergingLikert(row);
            final labels = <String, double>{
              for (final s in segments)
                if (s.response != 'Neutral') s.response: s.percentage,
              'Neutral': segments[0].percentage + segments[3].percentage,
            };
            return fl.BarTooltipItem(
              '${row.label}\n${labels.entries.map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}%').join('\n')}',
              const TextStyle(color: Colors.white, fontSize: 11),
            );
          },
        ),
      ),
    ),
  ),
);

Widget _matrixCell(MatrixCell cell) {
  final xs = touristMatrix.scales[cell.x.id]!;
  final ys = touristMatrix.scales[cell.y.id]!;
  return Column(
    children: [
      Text(
        '${cell.y.label} × ${cell.x.label}',
        style: const TextStyle(fontSize: 9),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Expanded(
        child: fl.ScatterChart(
          fl.ScatterChartData(
            minX: xs.min,
            maxX: xs.max,
            minY: ys.min,
            maxY: ys.max,
            titlesData: const fl.FlTitlesData(show: false),
            scatterSpots: [
              for (final o in touristMatrix.observations)
                fl.ScatterSpot(
                  o.value(cell.x),
                  o.value(cell.y),
                  dotPainter: fl.FlDotCirclePainter(
                    radius: 2.3,
                    color: const Color(0xff1565c0),
                  ),
                ),
            ],
            scatterTouchData: fl.ScatterTouchData(
              touchTooltipData: fl.ScatterTouchTooltipData(
                getTooltipItems: (spot) {
                  final o = touristMatrix.observations.reduce(
                    (a, b) =>
                        (a.value(cell.x) - spot.x).abs() +
                                (a.value(cell.y) - spot.y).abs() <
                            (b.value(cell.x) - spot.x).abs() +
                                (b.value(cell.y) - spot.y).abs()
                        ? a
                        : b,
                  );
                  return fl.ScatterTooltipItem(
                    '${o.label}\n${cell.x.label}: ${o.value(cell.x).toStringAsFixed(1)} ${cell.x.unit}\n${cell.y.label}: ${o.value(cell.y).toStringAsFixed(1)} ${cell.y.unit}',
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _ternary() => Column(
  children: [
    const Text('Alojamiento', style: TextStyle(fontSize: 11)),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: fl.LineChart(
          fl.LineChartData(
            minX: 0,
            maxX: 1,
            minY: 0,
            maxY: ternaryHeight,
            titlesData: const fl.FlTitlesData(show: false),
            lineBarsData: [
              fl.LineChartBarData(
                spots: [
                  const fl.FlSpot(0, 0),
                  const fl.FlSpot(1, 0),
                  const fl.FlSpot(.5, ternaryHeight),
                  const fl.FlSpot(0, 0),
                ],
                color: const Color(0xff455a64),
                barWidth: 2,
                dotData: const fl.FlDotData(show: false),
              ),
              fl.LineChartBarData(
                spots: [for (final p in touristBudgetMix) fl.FlSpot(p.x, p.y)],
                color: const Color(0xff1565c0),
                barWidth: 0,
                dotData: const fl.FlDotData(show: true),
              ),
            ],
            lineTouchData: fl.LineTouchData(
              touchTooltipData: fl.LineTouchTooltipData(
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    if (s.barIndex == 1)
                      fl.LineTooltipItem(() {
                        final p = touristBudgetMix[s.spotIndex];
                        return '${p.label}\nAlojamiento ${p.a}% · Alimentación ${p.b}% · Transporte ${p.c}%';
                      }(), const TextStyle(color: Colors.white, fontSize: 10))
                    else
                      null,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Alimentación', style: TextStyle(fontSize: 11)),
        Text('Transporte', style: TextStyle(fontSize: 11)),
      ],
    ),
  ],
);

Widget _fan() {
  final getters = <double Function(ForecastPoint)>[
    (p) => p.lower95,
    (p) => p.upper95,
    (p) => p.lower80,
    (p) => p.upper80,
    (p) => p.lower50,
    (p) => p.upper50,
    (p) => p.median,
  ];
  return Column(
    children: [
      const Wrap(
        spacing: 12,
        children: [
          Text('░ 95%', style: TextStyle(fontSize: 11)),
          Text('▒ 80%', style: TextStyle(fontSize: 11)),
          Text('▓ 50%', style: TextStyle(fontSize: 11)),
          Text('— Mediana', style: TextStyle(fontSize: 11)),
        ],
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 8, 5),
          child: fl.LineChart(
            fl.LineChartData(
              minX: 0,
              maxX: 11,
              minY: 40,
              maxY: 100,
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
                    reservedSize: 22,
                    interval: 2,
                    getTitlesWidget: (v, meta) => Text(
                      '${v.toInt() + 1}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                leftTitles: const fl.AxisTitles(
                  sideTitles: fl.SideTitles(showTitles: true, reservedSize: 30),
                ),
              ),
              lineBarsData: [
                for (var g = 0; g < getters.length; g++)
                  fl.LineChartBarData(
                    spots: [
                      for (var i = 0; i < hotelForecastFan.length; i++)
                        fl.FlSpot(
                          i.toDouble(),
                          getters[g](hotelForecastFan[i]),
                        ),
                    ],
                    color: g == 6
                        ? const Color(0xff0d47a1)
                        : Colors.transparent,
                    barWidth: g == 6 ? 2 : 0,
                    dotData: fl.FlDotData(show: g == 6),
                  ),
              ],
              betweenBarsData: [
                fl.BetweenBarsData(
                  fromIndex: 0,
                  toIndex: 1,
                  color: const Color(0x558bb9ee),
                ),
                fl.BetweenBarsData(
                  fromIndex: 2,
                  toIndex: 3,
                  color: const Color(0x7788aef0),
                ),
                fl.BetweenBarsData(
                  fromIndex: 4,
                  toIndex: 5,
                  color: const Color(0x9964a4e8),
                ),
              ],
              lineTouchData: fl.LineTouchData(
                touchTooltipData: fl.LineTouchTooltipData(
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      fl.LineTooltipItem(() {
                        final p = hotelForecastFan[s.x.round().clamp(0, 11)];
                        return 'Mes ${p.period}: mediana ${p.median.toStringAsFixed(1)}%\n50% [${p.lower50.toStringAsFixed(1)}, ${p.upper50.toStringAsFixed(1)}]\n80% [${p.lower80.toStringAsFixed(1)}, ${p.upper80.toStringAsFixed(1)}]\n95% [${p.lower95.toStringAsFixed(1)}, ${p.upper95.toStringAsFixed(1)}]';
                      }(), const TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _calibration() => Padding(
  padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
  child: fl.LineChart(
    fl.LineChartData(
      minX: 0,
      maxX: 1,
      minY: 0,
      maxY: 1,
      lineBarsData: [
        fl.LineChartBarData(
          spots: [const fl.FlSpot(0, 0), const fl.FlSpot(1, 1)],
          color: const Color(0xff607d8b),
          barWidth: 1.5,
          dashArray: [5, 4],
          dotData: const fl.FlDotData(show: false),
        ),
        fl.LineChartBarData(
          spots: [
            for (final b in cancellationCalibration)
              fl.FlSpot(b.avgPredicted, b.observedRate),
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
              if (s.barIndex == 1)
                fl.LineTooltipItem(() {
                  final b = cancellationCalibration[s.spotIndex];
                  return 'Predicha ${b.avgPredicted.toStringAsFixed(2)}\nObservada ${b.observedRate.toStringAsFixed(2)}\nn=${b.count}';
                }(), const TextStyle(color: Colors.white, fontSize: 11))
              else
                null,
          ],
        ),
      ),
    ),
  ),
);
