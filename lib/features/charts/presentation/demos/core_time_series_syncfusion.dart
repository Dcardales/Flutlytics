import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/time_series_data.dart';
import 'core_time_series_fl_chart.dart';

Widget buildSyncfusionTimeSeriesChart(String id) {
  final stacked = id == 'stacked-area';
  final multi = id == 'multi-line';
  final labels = stacked || multi
      ? multiTimeSeriesFor(id)
            .where((p) => p.series == multiTimeSeriesFor(id).first.series)
            .toList()
      : singleTimeSeriesFor(id);
  final maximum = stacked
      ? stackedAreaFor(id).map((p) => p.total).reduce((a, b) => a > b ? a : b) *
            1.12
      : (multi
                ? multiTimeSeriesFor(id)
                      .map((p) => p.value)
                      .reduce((a, b) => a > b ? a : b)
                : singleTimeSeriesFor(id)
                      .map((p) => p.value)
                      .reduce((a, b) => a > b ? a : b)) *
            1.2;
  final series = switch (id) {
    'multi-line' => _multiSeries(id),
    'stacked-area' => _stackedSeries(id),
    'area' => <sf.CartesianSeries<SingleTimeSeriesPoint, int>>[
      sf.AreaSeries<SingleTimeSeriesPoint, int>(
        dataSource: singleTimeSeriesFor(id),
        xValueMapper: (p, _) => p.period,
        yValueMapper: (p, _) => p.value,
        borderColor: timeSeriesColors.first,
        borderWidth: 2,
        color: timeSeriesColors.first.withValues(alpha: 0.35),
        animationDuration: 0,
      ),
    ],
    'step-line' => <sf.CartesianSeries<SingleTimeSeriesPoint, int>>[
      sf.StepLineSeries<SingleTimeSeriesPoint, int>(
        dataSource: singleTimeSeriesFor(id),
        xValueMapper: (p, _) => p.period,
        yValueMapper: (p, _) => p.value,
        animationDuration: 0,
        markerSettings: const sf.MarkerSettings(isVisible: true),
      ),
    ],
    _ => throw ArgumentError.value(id, 'id'),
  };
  return Column(
    children: [
      if (stacked || multi) _sfLegend(id),
      Expanded(
        child: sf.SfCartesianChart(
          primaryXAxis: sf.NumericAxis(
            minimum: labels.first.period.toDouble(),
            maximum: labels.last.period.toDouble(),
            interval: labels.length > 5 ? 2 : 1,
            axisLabelFormatter: (details) {
              final point = labels
                  .where((p) => p.period == details.value.toInt())
                  .firstOrNull;
              return sf.ChartAxisLabel(point?.label ?? '', details.textStyle);
            },
          ),
          primaryYAxis: sf.NumericAxis(minimum: 0, maximum: maximum),
          tooltipBehavior: sf.TooltipBehavior(enable: true),
          series: series,
        ),
      ),
    ],
  );
}

List<sf.CartesianSeries<MultiTimeSeriesPoint, int>> _multiSeries(String id) {
  final points = multiTimeSeriesFor(id);
  final names = points.map((p) => p.series).toSet().toList()..sort();
  return [
    for (var i = 0; i < names.length; i++)
      sf.LineSeries<MultiTimeSeriesPoint, int>(
        name: names[i],
        dataSource: points.where((p) => p.series == names[i]).toList(),
        xValueMapper: (p, _) => p.period,
        yValueMapper: (p, _) => p.value,
        color: timeSeriesColors[i % timeSeriesColors.length],
        markerSettings: const sf.MarkerSettings(isVisible: true),
        animationDuration: 0,
      ),
  ];
}

List<sf.CartesianSeries<StackedAreaPoint, int>> _stackedSeries(String id) {
  final points = stackedAreaFor(id);
  final names = points.map((p) => p.series).toSet().toList()..sort();
  return [
    for (var i = 0; i < names.length; i++)
      sf.StackedAreaSeries<StackedAreaPoint, int>(
        name: names[i],
        dataSource: points.where((p) => p.series == names[i]).toList(),
        xValueMapper: (p, _) => p.period,
        yValueMapper: (p, _) => p.value,
        color: timeSeriesColors[i % timeSeriesColors.length].withValues(
          alpha: 0.75,
        ),
        borderColor: timeSeriesColors[i % timeSeriesColors.length],
        borderWidth: 1,
        animationDuration: 0,
      ),
  ];
}

Widget _sfLegend(String id) {
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
            Icon(Icons.circle, size: 9, color: timeSeriesColors[i]),
            const SizedBox(width: 4),
            Text(names[i], style: const TextStyle(fontSize: 11)),
          ],
        ),
    ],
  );
}
