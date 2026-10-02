import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/analytical_time_series.dart';
import '../../data/sample_datasets.dart';
import '../../data/time_series_data.dart';
import 'transformed_time_series_styles.dart';

Map<String, dynamic> graphifyAnalyticalOptions(String id) {
  final names = _seriesNames(id);
  final labels = _periodLabels(id);
  final dataSeries = switch (id) {
    'cumulative-line' => _cumulativeSeries(id),
    'indexed-line' => _indexedSeries(id, names),
    'normalized-stacked-area' => _normalizedSeries(id, names),
    'streamgraph' => _streamgraphSeries(id, names),
    'control-chart' => _controlSeries(id),
    _ => throw ArgumentError.value(id, 'id'),
  };
  final normalized = id == 'normalized-stacked-area';
  final control = id == 'control-chart';
  return {
    'animation': false,
    'color': [
      for (final color in analyticalSeriesColors)
        '#${color.toARGB32().toRadixString(16).substring(2)}',
    ],
    'tooltip': {
      'trigger': 'axis',
      'axisPointer': {'type': 'line'},
    },
    'legend': {
      'show': names.isNotEmpty && !control,
      'data': control
          ? ['Observación', 'Fuera de control', 'Media', 'UCL', 'LCL']
          : names,
      'bottom': 0,
    },
    'grid': {
      'left': 54,
      'right': 18,
      'top': 20,
      'bottom': names.isNotEmpty || control ? 56 : 38,
    },
    'xAxis': {
      'type': 'category',
      'data': labels,
      'boundaryGap': false,
      'axisLabel': {'interval': labels.length > 6 ? 1 : 0},
    },
    'yAxis': {
      'type': 'value',
      'name': ChartDatasetRegistry.forConcept(id)!.unit,
      if (normalized) 'min': 0,
      if (normalized) 'max': 100,
    },
    'series': dataSeries,
  };
}

String encodeGraphifyAnalyticalOptions(String id) =>
    jsonEncode(graphifyAnalyticalOptions(id));

List<Map<String, dynamic>> _cumulativeSeries(String id) {
  final points = cumulativeTimeSeriesFor(id);
  return [
    {
      'name': 'Acumulado',
      'type': 'line',
      'data': [for (final p in points) p.value],
      'showSymbol': true,
      'smooth': false,
    },
  ];
}

List<Map<String, dynamic>> _indexedSeries(String id, List<String> names) {
  final points = indexedTimeSeriesFor(id);
  return [
    for (var i = 0; i < names.length; i++)
      {
        'name': names[i],
        'type': 'line',
        'data': [
          for (final p in points.where((p) => p.series == names[i])) p.value,
        ],
        'showSymbol': true,
        'symbol': i.isEven ? 'circle' : 'diamond',
        'smooth': false,
      },
  ];
}

List<Map<String, dynamic>> _normalizedSeries(String id, List<String> names) {
  final points = normalizedStackedAreaFor(id);
  return [
    for (final name in names)
      {
        'name': name,
        'type': 'line',
        'stack': 'composition',
        'areaStyle': {'opacity': 0.75},
        'data': [
          for (final p in points.where((p) => p.series == name)) p.value,
        ],
        'showSymbol': false,
        'smooth': false,
      },
  ];
}

List<Map<String, dynamic>> _streamgraphSeries(String id, List<String> names) {
  final points = streamgraphFor(id);
  final baseline = [
    for (final period in (points.map((p) => p.period).toSet().toList()..sort()))
      points.firstWhere((p) => p.period == period).baseline,
  ];
  return [
    {
      'name': '_centered baseline',
      'type': 'line',
      'stack': 'centered-stream',
      'stackStrategy': 'all',
      'data': baseline,
      'lineStyle': {'opacity': 0},
      'areaStyle': {'opacity': 0},
      'showSymbol': false,
      'silent': true,
    },
    for (final name in names)
      {
        'name': name,
        'type': 'line',
        'stack': 'centered-stream',
        'stackStrategy': 'all',
        'areaStyle': {'opacity': 0.8},
        'data': [
          for (final p in points.where((p) => p.series == name)) p.value,
        ],
        'showSymbol': false,
        'smooth': false,
      },
  ];
}

List<Map<String, dynamic>> _controlSeries(String id) {
  final result = controlChartFor(id);
  return [
    {
      'name': 'Observación',
      'type': 'line',
      'data': [for (final p in result.points) p.value],
      'showSymbol': true,
      'markLine': {
        'symbol': ['none', 'none'],
        'data': [
          {'name': 'Media', 'yAxis': result.stats.mean},
          {'name': 'UCL', 'yAxis': result.stats.upperControlLimit},
          {'name': 'LCL', 'yAxis': result.stats.lowerControlLimit},
        ],
      },
      'markPoint': {
        'data': [
          for (final p in result.points.where((p) => p.outOfControl))
            {
              'name': 'Fuera de control',
              'coord': [p.label, p.value],
              'symbol': 'diamond',
              'symbolSize': 16,
              'itemStyle': {'color': '#b71c1c'},
              'label': {'show': true, 'position': 'top', 'formatter': 'Fuera'},
            },
        ],
      },
    },
  ];
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

List<String> _periodLabels(String id) {
  final Iterable<SingleTimeSeriesPoint> points = switch (id) {
    'indexed-line' => indexedTimeSeriesFor(id),
    'normalized-stacked-area' => normalizedStackedAreaFor(id),
    'streamgraph' => streamgraphFor(id),
    'control-chart' => controlChartFor(id).points,
    _ => cumulativeTimeSeriesFor(id),
  };
  return [
    for (final period in (points.map((p) => p.period).toSet().toList()..sort()))
      points.firstWhere((p) => p.period == period).label,
  ];
}

class GraphifyAnalyticalChart extends StatefulWidget {
  const GraphifyAnalyticalChart({
    super.key,
    required this.id,
    required this.options,
  });
  final String id;
  final Map<String, dynamic> options;

  @override
  State<GraphifyAnalyticalChart> createState() =>
      _GraphifyAnalyticalChartState();
}

class _GraphifyAnalyticalChartState extends State<GraphifyAnalyticalChart> {
  final controller = GraphifyController();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (widget.id == 'control-chart')
        analyticalLegend(const [
          'Observation',
          'Mean',
          'UCL / LCL',
          '◇ Out of control',
        ]),
      Expanded(
        child: GraphifyView(
          controller: controller,
          initialOptions: widget.options,
          onConsoleMessage: (message) =>
              debugPrint('Graphify analytical: $message'),
        ),
      ),
    ],
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
