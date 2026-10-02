import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/analytical_time_series.dart';
import 'transformed_time_series_styles.dart';

Widget buildFlAnalyticalChart(String id) {
  final names = switch (id) {
    'indexed-line' => stableSeriesNames(
      indexedTimeSeriesFor(id).map((p) => p.series),
    ),
    'normalized-stacked-area' => stableSeriesNames(
      normalizedStackedAreaFor(id).map((p) => p.series),
    ),
    'streamgraph' => stableSeriesNames(streamgraphFor(id).map((p) => p.series)),
    _ => <String>[],
  };
  final labels = switch (id) {
    'indexed-line' => indexedTimeSeriesFor(
      id,
    ).where((p) => p.series == names.first).toList(),
    'normalized-stacked-area' => normalizedStackedAreaFor(
      id,
    ).where((p) => p.series == names.first).toList(),
    'streamgraph' => streamgraphFor(
      id,
    ).where((p) => p.series == names.first).toList(),
    'control-chart' => controlChartFor(id).points,
    _ => cumulativeTimeSeriesFor(id),
  };
  final lines = switch (id) {
    'cumulative-line' => [_cumulativeLine(id)],
    'indexed-line' => _indexedLines(id, names),
    'normalized-stacked-area' => _normalizedLines(id, names),
    'streamgraph' => _streamLines(id, names),
    'control-chart' => _controlLines(id),
    _ => throw ArgumentError.value(id, 'id'),
  };
  final range = _yRange(id);
  final hasLegend = names.isNotEmpty || id == 'control-chart';
  return Column(
    children: [
      if (hasLegend) _legendFor(id, names),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: fl.LineChart(
            fl.LineChartData(
              minX: labels.first.period.toDouble(),
              maxX: labels.last.period.toDouble(),
              minY: range.$1,
              maxY: range.$2,
              lineBarsData: lines,
              betweenBarsData: id == 'normalized-stacked-area'
                  ? [
                      for (var i = 1; i < lines.length; i++)
                        fl.BetweenBarsData(
                          fromIndex: i - 1,
                          toIndex: i,
                          color:
                              analyticalSeriesColors[i %
                                      analyticalSeriesColors.length]
                                  .withValues(alpha: 0.72),
                        ),
                    ]
                  : id == 'streamgraph'
                  ? [
                      for (var i = 0; i < names.length; i++)
                        fl.BetweenBarsData(
                          fromIndex: i * 2,
                          toIndex: i * 2 + 1,
                          color:
                              analyticalSeriesColors[i %
                                      analyticalSeriesColors.length]
                                  .withValues(alpha: 0.72),
                        ),
                    ]
                  : const [],
              titlesData: _titles(labels),
              lineTouchData: _touchData(id, names),
              gridData: const fl.FlGridData(show: true),
              borderData: fl.FlBorderData(show: true),
            ),
          ),
        ),
      ),
    ],
  );
}

fl.LineChartBarData _cumulativeLine(String id) {
  final points = cumulativeTimeSeriesFor(id);
  return fl.LineChartBarData(
    spots: [for (final p in points) fl.FlSpot(p.period.toDouble(), p.value)],
    color: analyticalSeriesColors.first,
    barWidth: 3,
    dotData: const fl.FlDotData(show: true),
  );
}

List<fl.LineChartBarData> _indexedLines(String id, List<String> names) {
  final points = indexedTimeSeriesFor(id);
  return [
    for (var i = 0; i < names.length; i++)
      fl.LineChartBarData(
        spots: [
          for (final p in points.where((p) => p.series == names[i]))
            fl.FlSpot(p.period.toDouble(), p.value),
        ],
        color: analyticalSeriesColors[i % analyticalSeriesColors.length],
        barWidth: 3,
        dotData: fl.FlDotData(
          show: true,
          getDotPainter: (spot, percent, bar, index) => i.isEven
              ? fl.FlDotCirclePainter(
                  radius: 3,
                  color: bar.color!,
                  strokeWidth: 1,
                )
              : fl.FlDotSquarePainter(
                  size: 7,
                  color: bar.color!,
                  strokeWidth: 1,
                ),
        ),
      ),
  ];
}

List<fl.LineChartBarData> _normalizedLines(String id, List<String> names) {
  final points = normalizedStackedAreaFor(id);
  var cumulativeByPeriod = <int, double>{};
  return [
    for (var i = 0; i < names.length; i++)
      () {
        final spots = <fl.FlSpot>[];
        for (final p in points.where((p) => p.series == names[i])) {
          final upper = (cumulativeByPeriod[p.period] ?? 0) + p.value;
          cumulativeByPeriod[p.period] = upper;
          spots.add(fl.FlSpot(p.period.toDouble(), upper));
        }
        return fl.LineChartBarData(
          spots: spots,
          color: analyticalSeriesColors[i % analyticalSeriesColors.length],
          barWidth: 1,
          dotData: const fl.FlDotData(show: false),
          belowBarData: i == 0
              ? fl.BarAreaData(
                  show: true,
                  color: analyticalSeriesColors.first.withValues(alpha: 0.72),
                  applyCutOffY: true,
                  cutOffY: 0,
                )
              : fl.BarAreaData(show: false),
        );
      }(),
  ];
}

List<fl.LineChartBarData> _streamLines(String id, List<String> names) {
  final points = streamgraphFor(id);
  return [
    for (final name in names) ...[
      for (final upper in [false, true])
        fl.LineChartBarData(
          spots: [
            for (final p in points.where((p) => p.series == name))
              fl.FlSpot(p.period.toDouble(), upper ? p.upper : p.lower),
          ],
          color:
              analyticalSeriesColors[names.indexOf(name) %
                  analyticalSeriesColors.length],
          barWidth: 1,
          dotData: const fl.FlDotData(show: false),
        ),
    ],
  ];
}

List<fl.LineChartBarData> _controlLines(String id) {
  final result = controlChartFor(id);
  final points = result.points;
  fl.LineChartBarData horizontal(double y, Color color, {List<int>? dash}) =>
      fl.LineChartBarData(
        spots: [for (final p in points) fl.FlSpot(p.period.toDouble(), y)],
        color: color,
        barWidth: 2,
        dashArray: dash,
        dotData: const fl.FlDotData(show: false),
      );
  return [
    fl.LineChartBarData(
      spots: [for (final p in points) fl.FlSpot(p.period.toDouble(), p.value)],
      color: analyticalSeriesColors.first,
      barWidth: 2,
      dotData: fl.FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => points[index].outOfControl
            ? fl.FlDotSquarePainter(
                size: 10,
                color: Colors.red.shade700,
                strokeWidth: 1,
              )
            : fl.FlDotCirclePainter(
                radius: 3,
                color: analyticalSeriesColors.first,
                strokeWidth: 1,
              ),
      ),
    ),
    horizontal(result.stats.mean, Colors.black54),
    horizontal(
      result.stats.upperControlLimit,
      Colors.red.shade700,
      dash: [6, 3],
    ),
    horizontal(
      result.stats.lowerControlLimit,
      Colors.red.shade700,
      dash: [6, 3],
    ),
  ];
}

(double, double) _yRange(String id) {
  switch (id) {
    case 'cumulative-line':
      final max = cumulativeTimeSeriesFor(id).last.value;
      return (0, max * 1.12);
    case 'indexed-line':
      final values = indexedTimeSeriesFor(id).map((p) => p.value).toList();
      return (0, values.reduce((a, b) => a > b ? a : b) * 1.12);
    case 'normalized-stacked-area':
      return (0, 100);
    case 'streamgraph':
      final values = streamgraphFor(id);
      return (
        values.map((p) => p.lower).reduce((a, b) => a < b ? a : b) * 1.08,
        values.map((p) => p.upper).reduce((a, b) => a > b ? a : b) * 1.08,
      );
    case 'control-chart':
      final result = controlChartFor(id);
      final minimum = result.points
          .map((p) => p.value)
          .reduce((a, b) => a < b ? a : b);
      final maximum = result.points
          .map((p) => p.value)
          .reduce((a, b) => a > b ? a : b);
      return (minimum * 0.94, maximum * 1.04);
    default:
      throw ArgumentError.value(id, 'id');
  }
}

fl.FlTitlesData _titles(List<dynamic> points) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      interval: points.length > 6 ? 2 : 1,
      reservedSize: 28,
      getTitlesWidget: (value, meta) {
        for (final point in points) {
          if (value == point.period) {
            return Text(point.label, style: const TextStyle(fontSize: 9));
          }
        }
        return const SizedBox.shrink();
      },
    ),
  ),
);

fl.LineTouchData _touchData(String id, List<String> names) => fl.LineTouchData(
  enabled: true,
  touchTooltipData: fl.LineTouchTooltipData(
    fitInsideHorizontally: true,
    fitInsideVertically: true,
    getTooltipItems: (spots) => [
      for (final spot in spots)
        fl.LineTooltipItem(
          _tooltipText(id, names, spot),
          const TextStyle(color: Colors.white, fontSize: 10),
        ),
    ],
  ),
);

String _tooltipText(String id, List<String> names, fl.LineBarSpot spot) {
  final period = spot.x.toInt();
  switch (id) {
    case 'cumulative-line':
      final point = cumulativeTimeSeriesFor(id)
          .singleWhere((p) => p.period == period);
      return '${point.label}: ${point.value.toStringAsFixed(1)} acumulado';
    case 'indexed-line':
      final point = indexedTimeSeriesFor(id).singleWhere(
        (p) => p.period == period && p.series == names[spot.barIndex],
      );
      return '${point.series} ${point.label}: índice ${point.value.toStringAsFixed(1)} (base 100)';
    case 'normalized-stacked-area':
      final point = normalizedStackedAreaFor(id).singleWhere(
        (p) => p.period == period && p.series == names[spot.barIndex],
      );
      return '${point.series} ${point.label}: ${point.value.toStringAsFixed(1)} %';
    case 'streamgraph':
      final point = streamgraphFor(id).singleWhere(
        (p) => p.period == period && p.series == names[spot.barIndex ~/ 2],
      );
      return '${point.series} ${point.label}: ${point.value.toStringAsFixed(0)} conversaciones';
    case 'control-chart':
      final result = controlChartFor(id);
      final point = result.points.singleWhere((p) => p.period == period);
      final seriesName = [
        'Observación',
        'Media',
        'Límite superior',
        'Límite inferior',
      ][spot.barIndex];
      final value = switch (spot.barIndex) {
        1 => result.stats.mean,
        2 => result.stats.upperControlLimit,
        3 => result.stats.lowerControlLimit,
        _ => point.value,
      };
      return '${point.label} $seriesName: ${value.toStringAsFixed(1)} ms${point.outOfControl ? ' · FUERA DE CONTROL' : ''}';
    default:
      return spot.y.toStringAsFixed(1);
  }
}

Widget _legendFor(String id, List<String> names) {
  if (id != 'control-chart') return analyticalLegend(names);
  return analyticalLegend(const [
    'Observación',
    'Media',
    'UCL/LCL; □ fuera de control',
  ]);
}
