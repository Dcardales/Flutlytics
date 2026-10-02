import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/sample_datasets.dart';
import '../../data/time_series_data.dart';

Map<String, dynamic> graphifyTimeSeriesOptions(String id) {
  final multiple = id == 'multi-line' || id == 'stacked-area';
  final multiPoints = multiple
      ? multiTimeSeriesFor(id)
      : <MultiTimeSeriesPoint>[];
  final singlePoints = multiple
      ? <SingleTimeSeriesPoint>[]
      : singleTimeSeriesFor(id);
  final points = multiple ? multiPoints : singlePoints;
  final periods = points.map((p) => p.period).toSet().toList()..sort();
  final labels = [
    for (final period in periods)
      points.firstWhere((p) => p.period == period).label,
  ];
  final isStacked = id == 'stacked-area';
  final isMulti = id == 'multi-line';
  final isArea = id == 'area';
  final isStep = id == 'step-line';
  final List<Map<String, dynamic>> series;
  if (multiple) {
    final names = multiPoints.map((p) => p.series).toSet().toList()..sort();
    series = [
      for (final name in names)
        {
          'name': name,
          'type': 'line',
          'data': [
            for (final period in periods)
              multiPoints
                  .singleWhere((p) => p.series == name && p.period == period)
                  .value,
          ],
          if (isStacked) 'stack': 'reservations',
          if (isStacked) 'areaStyle': <String, Object>{'opacity': 0.72},
          'smooth': false,
          'showSymbol': true,
        },
    ];
  } else {
    series = [
      {
        'name': id,
        'type': 'line',
        'data': [for (final p in points) p.value],
        if (isStep) 'step': 'end',
        if (isArea) 'areaStyle': <String, Object>{'opacity': 0.32},
        'smooth': false,
        'showSymbol': true,
      },
    ];
  }
  return {
    'animation': false,
    'tooltip': {
      'trigger': 'axis',
      'axisPointer': {'type': 'line'},
    },
    'legend': {'show': isMulti || isStacked, 'bottom': 0},
    'grid': {
      'left': 48,
      'right': 16,
      'top': 16,
      'bottom': isMulti || isStacked ? 54 : 32,
    },
    'xAxis': {'type': 'category', 'data': labels, 'boundaryGap': false},
    'yAxis': {
      'type': 'value',
      'name': ChartDatasetRegistry.forConcept(id)!.unit,
      'min': 0,
    },
    'series': series,
  };
}

String encodeGraphifyTimeSeriesOptions(String id) =>
    jsonEncode(graphifyTimeSeriesOptions(id));

class GraphifyTimeSeriesChart extends StatefulWidget {
  const GraphifyTimeSeriesChart({super.key, required this.options});
  final Map<String, dynamic> options;

  @override
  State<GraphifyTimeSeriesChart> createState() =>
      _GraphifyTimeSeriesChartState();
}

class _GraphifyTimeSeriesChartState extends State<GraphifyTimeSeriesChart> {
  final controller = GraphifyController();

  @override
  Widget build(BuildContext context) => GraphifyView(
    controller: controller,
    initialOptions: widget.options,
    onConsoleMessage: (message) => debugPrint('Graphify time series: $message'),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
