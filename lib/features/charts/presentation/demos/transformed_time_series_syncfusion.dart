import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/analytical_time_series.dart';
import '../../data/sample_datasets.dart';
import '../../data/time_series_data.dart';
import 'transformed_time_series_styles.dart';

typedef _ControlReference = ({int period, double value});

Widget buildSyncfusionAnalyticalChart(String id) {
  final names = _seriesNames(id);
  final labels = _periodLabels(id);
  final maximum = id == 'normalized-stacked-area'
      ? 100.0
      : id == 'control-chart'
      ? controlChartFor(id).points
                .map((p) => p.value)
                .reduce((a, b) => a > b ? a : b) *
            1.12
      : _allYValues(id).reduce((a, b) => a > b ? a : b) * 1.12;
  return Column(
    children: [
      if (names.isNotEmpty || id == 'control-chart') _legend(id, names),
      Expanded(
        child: sf.SfCartesianChart(
          primaryXAxis: sf.NumericAxis(
            minimum: labels.keys.reduce((a, b) => a < b ? a : b).toDouble(),
            maximum: labels.keys.reduce((a, b) => a > b ? a : b).toDouble(),
            interval: labels.length > 6 ? 2 : 1,
            axisLabelFormatter: (details) => sf.ChartAxisLabel(
              labels[details.value.toInt()] ?? '',
              details.textStyle,
            ),
          ),
          primaryYAxis: sf.NumericAxis(
            minimum: id == 'streamgraph'
                ? streamgraphFor(id)
                          .map((p) => p.lower)
                          .reduce((a, b) => a < b ? a : b) *
                      1.08
                : 0,
            maximum: id == 'normalized-stacked-area' ? 100 : maximum,
          ),
          tooltipBehavior: sf.TooltipBehavior(
            enable: true,
            canShowMarker: true,
            builder: (data, point, series, pointIndex, seriesIndex) =>
                _tooltip(id, data, point),
          ),
          series: _series(id, names),
        ),
      ),
    ],
  );
}

List<sf.CartesianSeries<dynamic, int>> _series(String id, List<String> names) {
  switch (id) {
    case 'cumulative-line':
      final points = cumulativeTimeSeriesFor(id);
      return [
        sf.LineSeries<SingleTimeSeriesPoint, int>(
          name: 'Acumulado',
          dataSource: points,
          xValueMapper: (p, _) => p.period,
          yValueMapper: (p, _) => p.value,
          markerSettings: const sf.MarkerSettings(isVisible: true),
          animationDuration: 0,
        ),
      ];
    case 'indexed-line':
      final points = indexedTimeSeriesFor(id);
      return [
        for (var i = 0; i < names.length; i++)
          sf.LineSeries<IndexedSeriesPoint, int>(
            name: names[i],
            dataSource: points.where((p) => p.series == names[i]).toList(),
            xValueMapper: (p, _) => p.period,
            yValueMapper: (p, _) => p.value,
            color: analyticalSeriesColors[i % analyticalSeriesColors.length],
            markerSettings: sf.MarkerSettings(
              isVisible: true,
              shape: i.isEven
                  ? sf.DataMarkerType.circle
                  : sf.DataMarkerType.diamond,
            ),
            animationDuration: 0,
          ),
      ];
    case 'normalized-stacked-area':
      final points = normalizedStackedAreaFor(id);
      return [
        for (var i = 0; i < names.length; i++)
          sf.StackedArea100Series<MultiTimeSeriesPoint, int>(
            name: names[i],
            dataSource: points.where((p) => p.series == names[i]).toList(),
            xValueMapper: (p, _) => p.period,
            yValueMapper: (p, _) => p.value,
            color: analyticalSeriesColors[i % analyticalSeriesColors.length]
                .withValues(alpha: 0.78),
            animationDuration: 0,
          ),
      ];
    case 'streamgraph':
      final points = streamgraphFor(id);
      return [
        for (var i = 0; i < names.length; i++)
          sf.RangeAreaSeries<StreamgraphPoint, int>(
            name: names[i],
            dataSource: points.where((p) => p.series == names[i]).toList(),
            xValueMapper: (p, _) => p.period,
            lowValueMapper: (p, _) => p.lower,
            highValueMapper: (p, _) => p.upper,
            color: analyticalSeriesColors[i % analyticalSeriesColors.length]
                .withValues(alpha: 0.76),
            borderColor:
                analyticalSeriesColors[i % analyticalSeriesColors.length],
            borderWidth: 1,
            animationDuration: 0,
          ),
      ];
    case 'control-chart':
      final result = controlChartFor(id);
      final refs = [
        ('Media', result.stats.mean),
        ('UCL', result.stats.upperControlLimit),
        ('LCL', result.stats.lowerControlLimit),
      ];
      final points = result.points;
      final baseSeries = <sf.CartesianSeries<dynamic, int>>[
        sf.LineSeries<ControlChartPoint, int>(
          name: 'Observación',
          dataSource: points,
          xValueMapper: (p, _) => p.period,
          yValueMapper: (p, _) => p.value,
          markerSettings: const sf.MarkerSettings(
            isVisible: true,
            shape: sf.DataMarkerType.circle,
          ),
          animationDuration: 0,
        ),
        sf.ScatterSeries<ControlChartPoint, int>(
          name: 'Fuera de control',
          dataSource: points.where((p) => p.outOfControl).toList(),
          xValueMapper: (p, _) => p.period,
          yValueMapper: (p, _) => p.value,
          color: Colors.red.shade700,
          markerSettings: const sf.MarkerSettings(
            isVisible: true,
            shape: sf.DataMarkerType.diamond,
            width: 12,
            height: 12,
          ),
          animationDuration: 0,
        ),
      ];
      for (final (index, reference) in refs.indexed) {
        final data = <_ControlReference>[
          for (final p in points) (period: p.period, value: reference.$2),
        ];
        baseSeries.add(
          sf.LineSeries<_ControlReference, int>(
            name: reference.$1,
            dataSource: data,
            xValueMapper: (p, _) => p.period,
            yValueMapper: (p, _) => p.value,
            color: index == 0 ? Colors.black54 : Colors.red.shade700,
            dashArray: index == 0 ? null : const [6, 3],
            width: 1.5,
            animationDuration: 0,
          ),
        );
      }
      return baseSeries;
    default:
      throw ArgumentError.value(id, 'id');
  }
}

List<String> _seriesNames(String id) {
  final Iterable<String> names = switch (id) {
    'indexed-line' => indexedTimeSeriesFor(id).map((p) => p.series),
    'normalized-stacked-area' => normalizedStackedAreaFor(
      id,
    ).map((p) => p.series),
    'streamgraph' => streamgraphFor(id).map((p) => p.series),
    _ => const <String>[],
  };
  return stableSeriesNames(names);
}

Map<int, String> _periodLabels(String id) {
  final Iterable<SingleTimeSeriesPoint> points = switch (id) {
    'indexed-line' => indexedTimeSeriesFor(id),
    'normalized-stacked-area' => normalizedStackedAreaFor(id),
    'streamgraph' => streamgraphFor(id),
    'control-chart' => controlChartFor(id).points,
    _ => cumulativeTimeSeriesFor(id),
  };
  return {for (final p in points) p.period: p.label};
}

List<double> _allYValues(String id) => switch (id) {
  'cumulative-line' => cumulativeTimeSeriesFor(id).map((p) => p.value).toList(),
  'indexed-line' => indexedTimeSeriesFor(id).map((p) => p.value).toList(),
  'streamgraph' => streamgraphFor(id).map((p) => p.upper).toList(),
  _ => [100],
};

Widget _legend(String id, List<String> names) => id == 'control-chart'
    ? analyticalLegend(const [
        'Observación',
        'Fuera de control (◆)',
        'Media',
        'UCL / LCL',
      ])
    : analyticalLegend(names);

Widget _tooltip(String id, dynamic data, dynamic point) {
  final text = switch (data) {
    IndexedSeriesPoint p =>
      '${p.series} ${p.label}: index ${p.value.toStringAsFixed(1)} (original ${p.originalValue.toStringAsFixed(1)})',
    MultiTimeSeriesPoint p when id == 'normalized-stacked-area' =>
      '${p.series} ${p.label}: ${p.value.toStringAsFixed(1)} %',
    StreamgraphPoint p =>
      '${p.series} ${p.label}: ${p.value.toStringAsFixed(0)} conversations',
    ControlChartPoint p =>
      '${p.label}: ${p.value.toStringAsFixed(1)} ms - ${p.outOfControl ? 'OUT OF CONTROL' : 'within limits'}',
    SingleTimeSeriesPoint p =>
      '${p.label}: ${p.value.toStringAsFixed(1)} ${ChartDatasetRegistry.forConcept(id)!.unit}',
    _ => '$point',
  };
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: TextStyle(color: Colors.white, fontSize: 11)),
  );
}
