import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/time_series_data.dart';

const timeSeriesColors = <Color>[
  Color(0xff1976d2),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
];

Widget buildFlTimeSeriesChart(String id) {
  final isMulti = id == 'multi-line';
  final isStacked = id == 'stacked-area';
  final labels = isMulti || isStacked
      ? multiTimeSeriesFor(id)
            .where((p) => p.series == multiTimeSeriesFor(id).first.series)
            .toList()
      : singleTimeSeriesFor(id);
  final series = isStacked
      ? _stackedFlSeries(id)
      : isMulti
      ? _multiFlSeries(id)
      : [_singleFlSeries(id)];
  return Column(
    children: [
      if (isMulti || isStacked) _timeSeriesLegend(id),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: fl.LineChart(
            fl.LineChartData(
              minX: labels.first.period.toDouble(),
              maxX: labels.last.period.toDouble(),
              minY: 0,
              maxY: _maxY(id),
              lineBarsData: series,
              betweenBarsData: isStacked
                  ? [
                      for (var i = 1; i < series.length; i++)
                        fl.BetweenBarsData(
                          fromIndex: i - 1,
                          toIndex: i,
                          color: timeSeriesColors[i % timeSeriesColors.length]
                              .withValues(alpha: 0.7),
                        ),
                    ]
                  : const [],
              titlesData: _flTitles(labels),
              lineTouchData: _flTouchData(id),
              gridData: const fl.FlGridData(show: true),
              borderData: fl.FlBorderData(show: true),
            ),
          ),
        ),
      ),
    ],
  );
}

fl.LineTouchData _flTouchData(String id) => fl.LineTouchData(
  enabled: true,
  touchTooltipData: fl.LineTouchTooltipData(
    fitInsideHorizontally: true,
    fitInsideVertically: true,
    getTooltipItems: (spots) {
      final multi = id == 'multi-line';
      final stacked = id == 'stacked-area';
      final names =
          (multi
                  ? multiTimeSeriesFor(id).map((p) => p.series)
                  : stacked
                  ? stackedAreaFor(id).map((p) => p.series)
                  : const <String>[])
              .toSet()
              .toList()
            ..sort();
      return [
        for (final spot in spots)
          fl.LineTooltipItem(
            stacked
                ? '${names[spot.barIndex]}: ${stackedAreaFor(id).singleWhere((p) => p.series == names[spot.barIndex] && p.period == spot.x.toInt()).value.toStringAsFixed(0)}'
                : multi
                ? '${names[spot.barIndex]}: ${spot.y.toStringAsFixed(0)}'
                : '${singleTimeSeriesFor(id).singleWhere((p) => p.period == spot.x.toInt()).label}: ${spot.y.toStringAsFixed(0)}',
            const TextStyle(color: Colors.white, fontSize: 11),
          ),
      ];
    },
  ),
);

fl.LineChartBarData _singleFlSeries(String id) {
  final points = singleTimeSeriesFor(id);
  final isStep = id == 'step-line';
  return fl.LineChartBarData(
    spots: [for (final p in points) fl.FlSpot(p.period.toDouble(), p.value)],
    color: timeSeriesColors.first,
    barWidth: 3,
    isCurved: false,
    isStepLineChart: isStep,
    lineChartStepData: fl.LineChartStepData(
      stepDirection: fl.LineChartStepData.stepDirectionForward,
    ),
    dotData: fl.FlDotData(show: !isStep),
    belowBarData: id == 'area'
        ? fl.BarAreaData(
            show: true,
            color: timeSeriesColors.first.withValues(alpha: 0.28),
            applyCutOffY: true,
            cutOffY: 0,
          )
        : fl.BarAreaData(show: false),
  );
}

List<fl.LineChartBarData> _multiFlSeries(String id) {
  final points = multiTimeSeriesFor(id);
  final names = points.map((p) => p.series).toSet().toList()..sort();
  return [
    for (var i = 0; i < names.length; i++)
      fl.LineChartBarData(
        spots: [
          for (final p in points.where((p) => p.series == names[i]))
            fl.FlSpot(p.period.toDouble(), p.value),
        ],
        color: timeSeriesColors[i % timeSeriesColors.length],
        barWidth: 3,
        dotData: const fl.FlDotData(show: true),
      ),
  ];
}

List<fl.LineChartBarData> _stackedFlSeries(String id) {
  final points = stackedAreaFor(id);
  final names = points.map((p) => p.series).toSet().toList()..sort();
  return [
    for (var i = 0; i < names.length; i++)
      fl.LineChartBarData(
        spots: [
          for (final p in points.where((p) => p.series == names[i]))
            fl.FlSpot(p.period.toDouble(), p.upper),
        ],
        color: timeSeriesColors[i % timeSeriesColors.length],
        barWidth: 2,
        dotData: const fl.FlDotData(show: false),
        belowBarData: i == 0
            ? fl.BarAreaData(
                show: true,
                color: timeSeriesColors[i].withValues(alpha: 0.72),
                applyCutOffY: true,
                cutOffY: 0,
              )
            : fl.BarAreaData(show: false),
      ),
  ];
}

double _maxY(String id) {
  if (id == 'stacked-area') {
    return stackedAreaFor(id)
            .map((p) => p.total)
            .reduce((a, b) => a > b ? a : b) *
        1.12;
  }
  final values = id == 'multi-line'
      ? multiTimeSeriesFor(id).map((p) => p.value)
      : singleTimeSeriesFor(id).map((p) => p.value);
  return values.reduce((a, b) => a > b ? a : b) * 1.2;
}

fl.FlTitlesData _flTitles(List<dynamic> points) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      interval: points.length > 5 ? 2 : 1,
      reservedSize: 30,
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

Widget _timeSeriesLegend(String id) {
  final names =
      (id == 'multi-line'
              ? multiTimeSeriesFor(id).map((p) => p.series)
              : stackedAreaFor(id).map((p) => p.series))
          .toSet()
          .toList()
        ..sort();
  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    children: [
      for (var i = 0; i < names.length; i++)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              size: 9,
              color: timeSeriesColors[i % timeSeriesColors.length],
            ),
            const SizedBox(width: 4),
            Text(names[i], style: const TextStyle(fontSize: 11)),
          ],
        ),
    ],
  );
}
