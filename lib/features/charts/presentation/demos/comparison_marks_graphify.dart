import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/sample_datasets.dart';

List<ChartPoint> _points(String id) => ChartDatasetRegistry.pointsFor(id);
List<DumbbellDatum> _dumbbells() => ChartDatasetRegistry.dumbbellData();
List<SlopeDatum> _slopes() => ChartDatasetRegistry.slopeData();
List<ParetoPoint> _pareto() =>
    calculatePareto(ChartDatasetRegistry.paretoSources());

class GraphifyComparisonChart extends StatelessWidget {
  const GraphifyComparisonChart({super.key, required this.options});
  final Map<String, dynamic> options;
  @override
  Widget build(BuildContext context) => _GraphifyView(options: options);
}

class _GraphifyView extends StatefulWidget {
  const _GraphifyView({required this.options});
  final Map<String, dynamic> options;
  @override
  State<_GraphifyView> createState() => _GraphifyViewState();
}

class _GraphifyViewState extends State<_GraphifyView> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) => GraphifyView(
    controller: controller,
    onConsoleMessage: (m) => debugPrint('Graphify comparison: $m'),
    initialOptions: widget.options,
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

Map<String, dynamic> graphifyComparisonOptions(String id) {
  final tooltip = {
    'trigger': 'axis',
    'axisPointer': {'type': 'line'},
  };
  if (id == 'dot-plot') {
    final data = _points(id);
    return {
      'tooltip': tooltip,
      'xAxis': {
        'type': 'category',
        'data': [for (final row in data) row.label],
      },
      'yAxis': {'type': 'value', 'min': 0, 'max': 10},
      'series': [
        {
          'name': 'Satisfacción media',
          'type': 'scatter',
          'symbolSize': 13,
          'data': [
            for (final row in data) [row.label, row.value],
          ],
        },
      ],
    };
  }
  if (id == 'lollipop') {
    final data = _points(id);
    return {
      'tooltip': tooltip,
      'xAxis': {'type': 'value', 'min': 0, 'max': 100},
      'yAxis': {
        'type': 'category',
        'data': [for (final row in data.reversed) row.label],
      },
      'series': [
        {
          'name': 'Tallo hasta el valor',
          'type': 'bar',
          'barWidth': 5,
          'data': [for (final row in data.reversed) row.value],
        },
        {
          'name': 'Descargas',
          'type': 'scatter',
          'symbolSize': 13,
          'data': [
            for (final row in data.reversed) [row.value, row.label],
          ],
        },
      ],
    };
  }
  if (id == 'dumbbell') {
    final data = _dumbbells();
    return {
      'tooltip': tooltip,
      'legend': {
        'data': ['Antes', 'Después'],
      },
      'xAxis': {'type': 'value', 'min': 0, 'max': 10},
      'yAxis': {
        'type': 'category',
        'data': [for (final row in data.reversed) row.label],
      },
      'series': [
        for (final row in data)
          {
            'name': row.label,
            'type': 'line',
            'showSymbol': false,
            'lineStyle': {'color': '#78909c'},
            'data': [
              [row.startValue, row.label],
              [row.endValue, row.label],
            ],
          },
        {
          'name': 'Antes',
          'type': 'scatter',
          'symbol': 'circle',
          'symbolSize': 12,
          'itemStyle': {'color': '#1565c0'},
          'data': [
            for (final row in data) [row.startValue, row.label],
          ],
        },
        {
          'name': 'Después',
          'type': 'scatter',
          'symbol': 'rect',
          'symbolSize': 12,
          'itemStyle': {'color': '#ef6c00'},
          'data': [
            for (final row in data) [row.endValue, row.label],
          ],
        },
      ],
    };
  }
  if (id == 'slope') {
    final data = _slopes();
    return {
      'tooltip': tooltip,
      'legend': {'type': 'scroll'},
      'xAxis': {
        'type': 'category',
        'data': [data.first.startPeriod, data.first.endPeriod],
      },
      'yAxis': {
        'type': 'value',
        'min': 0,
        'max': 40,
        'name': 'Participación (%)',
      },
      'series': [
        for (final row in data)
          {
            'name': row.label,
            'type': 'line',
            'symbol': 'circle',
            'symbolSize': 8,
            'data': [row.startValue, row.endValue],
          },
      ],
    };
  }
  final data = _pareto();
  return {
    'tooltip': tooltip,
    'legend': {
      'data': ['Frecuencia', 'Acumulado (%)'],
    },
    'xAxis': {
      'type': 'category',
      'data': [for (final row in data) row.category],
      'axisLabel': {'rotate': 25},
    },
    'yAxis': [
      {'type': 'value', 'name': 'Incidencias', 'min': 0},
      {
        'type': 'value',
        'name': 'Acumulado (%)',
        'min': 0,
        'max': 100,
        'axisLabel': {'formatter': '{value} %'},
      },
    ],
    'series': [
      {
        'name': 'Frecuencia',
        'type': 'bar',
        'data': [for (final row in data) row.frequency],
      },
      {
        'name': 'Acumulado (%)',
        'type': 'line',
        'yAxisIndex': 1,
        'symbol': 'circle',
        'symbolSize': 7,
        'data': [for (final row in data) row.cumulativePercent],
        'markLine': {
          'symbol': 'none',
          'data': [
            {'yAxis': 80, 'name': '80 %'},
          ],
        },
      },
    ],
  };
}

String encodeGraphifyComparisonOptions(String id) =>
    jsonEncode(graphifyComparisonOptions(id));
