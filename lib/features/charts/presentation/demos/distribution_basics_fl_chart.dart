import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/distribution_basics_data.dart';

const _blue = Color(0xff1565c0);
const _bins = 6;
const _bandwidth = 2.4;

Widget buildFlDistributionChart(String id) {
  final sample = touristServiceSample;
  final bins = buildHistogramBins(sample.values, binCount: _bins);
  final values = switch (id) {
    'histogram' => <DistributionPoint>[],
    'frequency-polygon' => buildFrequencyPolygon(bins),
    'ogive' => [
      for (final p in buildOgive(bins))
        DistributionPoint(p.upperBound, p.cumulativePercentage),
    ],
    'density' => buildGaussianKde(sample.values, bandwidth: _bandwidth),
    _ => const <DistributionPoint>[],
  };
  final minX = sample.values.reduce((a, b) => a < b ? a : b);
  final maxX = sample.values.reduce((a, b) => a > b ? a : b);
  if (id == 'histogram') {
    final maxY = bins.fold<int>(0, (m, b) => b.frequency > m ? b.frequency : m);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
      child: fl.BarChart(
        fl.BarChartData(
          minY: 0,
          maxY: (maxY + 1).toDouble(),
          barGroups: [
            for (var i = 0; i < bins.length; i++)
              fl.BarChartGroupData(
                x: i,
                barRods: [
                  fl.BarChartRodData(
                    toY: bins[i].frequency.toDouble(),
                    width: 34,
                    color: _blue,
                  ),
                ],
              ),
          ],
          titlesData: _titles(
            bottom: (v) {
              final i = v.toInt();
              return i >= 0 && i < bins.length ? bins[i].label : '';
            },
            bottomSize: 34,
          ),
          gridData: const fl.FlGridData(drawVerticalLine: false),
          barTouchData: fl.BarTouchData(
            enabled: true,
            touchTooltipData: fl.BarTouchTooltipData(
              getTooltipItem: (group, index, rod, rodIndex) => fl.BarTooltipItem(
                'Intervalo ${bins[index].label}\nFrecuencia: ${rod.toY.toInt()}',
                const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ),
      ),
    );
  }
  final isStrip = id == 'strip-plot';
  final strip = buildStripPoints(sample.values);
  final isOgive = id == 'ogive';
  final minY = isStrip ? -0.16 : 0.0;
  final maxY = isStrip
      ? 0.16
      : isOgive
      ? 100.0
      : null;
  final lineSpots = [for (final p in values) fl.FlSpot(p.x, p.y)];
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 12, 12, 8),
    child: isStrip
        ? fl.ScatterChart(
            fl.ScatterChartData(
              minX: minX - 1,
              maxX: maxX + 1,
              minY: minY,
              maxY: maxY,
              scatterSpots: [
                for (final p in strip)
                  fl.ScatterSpot(
                    p.value,
                    p.jitter,
                    dotPainter: fl.FlDotCirclePainter(radius: 4, color: _blue),
                  ),
              ],
              titlesData: _titles(
                bottom: (v) => v.toInt().toString(),
                bottomSize: 24,
              ),
              scatterTouchData: fl.ScatterTouchData(
                enabled: true,
                touchTooltipData: fl.ScatterTouchTooltipData(
                  getTooltipItems: (spot) => fl.ScatterTooltipItem(
                    'Tiempo: ${spot.x.toStringAsFixed(1)} min',
                    textStyle: TextStyle(color: spot.dotPainter.mainColor),
                  ),
                ),
              ),
            ),
          )
        : fl.LineChart(
            fl.LineChartData(
              minX: id == 'density' ? values.first.x : minX,
              maxX: id == 'density' ? values.last.x : maxX,
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                fl.LineChartBarData(
                  spots: lineSpots,
                  color: _blue,
                  barWidth: 2.5,
                  isCurved: id == 'density',
                  dotData: fl.FlDotData(show: id != 'density'),
                  belowBarData: fl.BarAreaData(show: false),
                ),
              ],
              titlesData: _titles(
                bottom: (v) => v.toInt().toString(),
                bottomSize: 24,
              ),
              gridData: const fl.FlGridData(drawVerticalLine: false),
              lineTouchData: fl.LineTouchData(
                enabled: true,
                touchTooltipData: fl.LineTouchTooltipData(
                  getTooltipItems: (spots) => [
                    for (final touched in spots)
                      fl.LineTooltipItem(
                        _distributionTooltip(id, touched, bins),
                        const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                  ],
                ),
              ),
            ),
          ),
  );
}

fl.FlTitlesData _titles({
  required String Function(double) bottom,
  required double bottomSize,
}) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: bottomSize,
      interval: 1,
      getTitlesWidget: (v, _) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(bottom(v), style: const TextStyle(fontSize: 8)),
      ),
    ),
  ),
  leftTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: true, reservedSize: 30),
  ),
);

String _distributionTooltip(
  String id,
  fl.LineBarSpot spot,
  List<HistogramBin> bins,
) {
  if (id == 'frequency-polygon') {
    final bin = bins.firstWhere((b) => b.midpoint == spot.x);
    return 'Intervalo ${bin.label}\nFrecuencia: ${bin.frequency}';
  }
  if (id == 'ogive') {
    final point = buildOgive(bins).firstWhere((p) => p.upperBound == spot.x);
    return 'Hasta ${point.upperBound.toStringAsFixed(1)} min\n'
        'Acumulado: ${point.cumulativeFrequency} '
        '(${point.cumulativePercentage.toStringAsFixed(1)}%)';
  }
  return 'Tiempo: ${spot.x.toStringAsFixed(1)} min\n'
      'Densidad: ${spot.y.toStringAsFixed(4)}';
}
