import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/distribution_basics_data.dart';

const _bins = 6;
const _bandwidth = 2.4;

Map<String, dynamic> graphifyDistributionOptions(String id) {
  final sample = touristServiceSample;
  final bins = buildHistogramBins(sample.values, binCount: _bins);
  final tooltip = {'trigger': 'item'};
  if (id == 'histogram') {
    return {
      'tooltip': tooltip,
      'xAxis': {
        'type': 'value',
        'name': 'Tiempo (minutos)',
        'min': bins.first.lowerBound,
        'max': bins.last.upperBound,
      },
      'yAxis': {'type': 'value', 'name': 'Frecuencia', 'min': 0},
      'series': [
        {
          'name': 'Frecuencia por intervalo',
          'type': 'bar',
          'barWidth': '92%',
          'dimensions': ['midpoint', 'frequency', 'interval'],
          'data': [
            for (final bin in bins) [bin.midpoint, bin.frequency, bin.label],
          ],
          'encode': {
            'x': 'midpoint',
            'y': 'frequency',
            'tooltip': ['interval', 'frequency'],
          },
        },
      ],
    };
  }
  if (id == 'strip-plot') {
    final points = buildStripPoints(sample.values);
    return {
      'tooltip': tooltip,
      'xAxis': {
        'type': 'value',
        'name': 'Tiempo (minutos)',
        'min': 5,
        'max': 28,
      },
      'yAxis': {'type': 'value', 'min': -0.16, 'max': 0.16, 'show': false},
      'series': [
        {
          'name': 'Observación individual',
          'type': 'scatter',
          'symbolSize': 9,
          'dimensions': ['value', 'visualJitter'],
          'data': [
            for (final p in points) [p.value, p.jitter],
          ],
          'encode': {
            'x': 'value',
            'y': 'visualJitter',
            'tooltip': ['value'],
          },
        },
      ],
    };
  }
  final List<DistributionPoint> points = switch (id) {
    'frequency-polygon' => buildFrequencyPolygon(bins),
    'ogive' => [
      for (final p in buildOgive(bins))
        DistributionPoint(p.upperBound, p.cumulativePercentage),
    ],
    _ => buildGaussianKde(sample.values, bandwidth: _bandwidth),
  };
  final isOgive = id == 'ogive';
  final isDensity = id == 'density';
  final title = isOgive
      ? 'Acumulado (%)'
      : isDensity
      ? 'Densidad estimada'
      : 'Frecuencia';
  return {
    'tooltip': tooltip,
    'xAxis': {'type': 'value', 'name': 'Tiempo (minutos)'},
    'yAxis': {
      'type': 'value',
      'name': title,
      'min': 0,
      if (isOgive) 'max': 100,
    },
    'series': [
      {
        'name': title,
        'type': 'line',
        'showSymbol': !isDensity,
        'smooth': isDensity,
        'dimensions': [
          'time',
          isOgive ? 'cumulativePercentage' : 'value',
          if (isOgive) 'cumulativeFrequency',
          if (id == 'frequency-polygon') 'interval',
        ],
        'data': [
          for (var i = 0; i < points.length; i++)
            [
              points[i].x,
              points[i].y,
              if (isOgive) buildOgive(bins)[i].cumulativeFrequency,
              if (id == 'frequency-polygon') points[i].detail,
            ],
        ],
        'encode': {
          'x': 'time',
          'y': isOgive ? 'cumulativePercentage' : 'value',
          if (isOgive)
            'tooltip': ['time', 'cumulativeFrequency', 'cumulativePercentage'],
          if (id == 'frequency-polygon') 'tooltip': ['interval', 'value'],
        },
      },
    ],
  };
}

String encodeGraphifyDistributionOptions(String id) =>
    jsonEncode(graphifyDistributionOptions(id));

class GraphifyDistributionChart extends StatefulWidget {
  const GraphifyDistributionChart({super.key, required this.options});
  final Map<String, dynamic> options;
  @override
  State<GraphifyDistributionChart> createState() =>
      _GraphifyDistributionChartState();
}

class _GraphifyDistributionChartState extends State<GraphifyDistributionChart> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) => GraphifyView(
    controller: controller,
    onConsoleMessage: (m) => debugPrint('Graphify distribution: $m'),
    initialOptions: widget.options,
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
