import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/advanced_distribution_data.dart';

Map<String, dynamic> graphifyAdvancedDistributionOptions(String id) {
  switch (id) {
    case 'box-plot':
      final stats = [
        for (final group in boxPlotGroups) calculateBoxPlotStats(group.values),
      ];
      final outliers = [
        for (var i = 0; i < stats.length; i++)
          for (final value in stats[i].outliers) [i, value],
      ];
      return {
        'tooltip': {'trigger': 'item'},
        'xAxis': {
          'type': 'category',
          'data': [for (final group in boxPlotGroups) group.label],
          'name': 'Sucursal',
        },
        'yAxis': {'type': 'value', 'name': 'Tiempo (minutos)'},
        'series': [
          {
            'name': 'Resumen IQR',
            'type': 'boxplot',
            'data': [
              for (final s in stats)
                [s.minWhisker, s.q1, s.median, s.q3, s.maxWhisker],
            ],
          },
          {
            'name': 'Outliers (1.5 IQR)',
            'type': 'scatter',
            'data': outliers,
            'symbolSize': 8,
          },
        ],
      };
    case 'violin':
      final geometry = buildViolinGeometry(violinGroups, bandwidth: 1.5);
      final data = [
        for (var i = 0; i < violinGroups.length; i++)
          geometry.where((p) => p.groupIndex == i).toList(),
      ];
      return {
        'tooltip': {'trigger': 'item'},
        'legend': {
          'data': [for (final g in violinGroups) g.label],
        },
        'xAxis': {'type': 'value', 'name': 'Tiempo (minutos)'},
        'yAxis': {
          'type': 'value',
          'min': -0.5,
          'max': violinGroups.length - 0.5,
          'show': false,
        },
        'series': [
          for (var i = 0; i < violinGroups.length; i++)
            for (final side in [-1, 1])
              {
                'name': violinGroups[i].label,
                'type': 'line',
                'showSymbol': false,
                'lineStyle': {'width': 1.5},
                'data': [
                  for (final p in data[i])
                    [p.value, i + side * p.halfWidth, p.density],
                ],
                'dimensions': ['minutes', 'visualOffset', 'density'],
                'encode': {
                  'x': 'minutes',
                  'y': 'visualOffset',
                  'tooltip': ['minutes', 'density'],
                },
              },
        ],
      };
    case 'ridgeline':
      final ridges = buildRidgeline(ridgelineGroups, bandwidth: 2.0);
      return {
        'tooltip': {'trigger': 'item'},
        'legend': {
          'type': 'scroll',
          'data': [for (final r in ridges) r.label],
        },
        'xAxis': {
          'type': 'value',
          'name': 'Tiempo (minutos)',
          'min': ridges.first.points.first.x,
          'max': ridges.first.points.last.x,
        },
        'yAxis': {
          'type': 'value',
          'min': -0.3,
          'max': ridges.length,
          'show': false,
        },
        'series': [
          for (final ridge in ridges)
            {
              'name': ridge.label,
              'type': 'line',
              'showSymbol': false,
              'data': [
                for (final p in ridge.points)
                  [p.x, p.baseline + p.height, p.density],
              ],
              'dimensions': ['minutes', 'visualOffset', 'density'],
              'encode': {
                'x': 'minutes',
                'y': 'visualOffset',
                'tooltip': ['minutes', 'density'],
              },
            },
        ],
      };
    case 'hexbin':
      final bins = buildHexBins(
        hexbinObservations,
        hexSize: .11,
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 2000,
      );
      final maxCount = bins.fold<int>(0, (m, b) => b.count > m ? b.count : m);
      return {
        'tooltip': {'trigger': 'item'},
        'xAxis': {
          'type': 'value',
          'min': 0,
          'max': 10,
          'name': 'Duracion de visita (h)',
        },
        'yAxis': {
          'type': 'value',
          'min': 0,
          'max': 2000,
          'name': 'Gasto (mil COP)',
        },
        'visualMap': {
          'type': 'continuous',
          'min': 1,
          'max': maxCount,
          'dimension': 2,
          'inRange': {
            'color': ['#e3f2fd', '#0d47a1'],
          },
        },
        'series': [
          {
            'name': 'Visitas agregadas por hexagono',
            'type': 'scatter',
            'symbol':
                'path://M0,-1L0.866,-0.5L0.866,0.5L0,1L-0.866,0.5L-0.866,-0.5Z',
            'symbolSize': 24,
            'dimensions': ['duration', 'spend', 'count'],
            'encode': {
              'x': 'duration',
              'y': 'spend',
              'tooltip': ['duration', 'spend', 'count'],
            },
            'data': [
              for (final bin in bins) [bin.centerX, bin.centerY, bin.count],
            ],
          },
        ],
      };
    case 'heatmap':
      final matrix = heatmapMatrix;
      return {
        'tooltip': {'position': 'top'},
        'grid': {'height': '62%', 'top': '12%'},
        'xAxis': {
          'type': 'category',
          'data': matrix.xCategories,
          'splitArea': {'show': true},
        },
        'yAxis': {
          'type': 'category',
          'data': matrix.yCategories,
          'splitArea': {'show': true},
        },
        'visualMap': {
          'min': matrix.minValue,
          'max': matrix.maxValue,
          'calculable': false,
          'orient': 'horizontal',
          'left': 'center',
          'bottom': '2%',
          'inRange': {
            'color': ['#e3f2fd', '#0d47a1'],
          },
        },
        'series': [
          {
            'name': 'Visitas',
            'type': 'heatmap',
            'data': [
              for (final c in matrix.orderedCells)
                [
                  matrix.xCategories.indexOf(c.xCategory),
                  matrix.yCategories.indexOf(c.yCategory),
                  c.value,
                ],
            ],
            'label': {'show': true, 'fontSize': 8},
            'emphasis': {
              'itemStyle': {'shadowBlur': 8, 'shadowColor': 'rgba(0,0,0,0.35)'},
            },
          },
        ],
      };
    default:
      throw ArgumentError.value(
        id,
        'id',
        'Unknown advanced distribution concept.',
      );
  }
}

String encodeGraphifyAdvancedDistributionOptions(String id) =>
    jsonEncode(graphifyAdvancedDistributionOptions(id));

class GraphifyAdvancedDistributionChart extends StatefulWidget {
  const GraphifyAdvancedDistributionChart({super.key, required this.options});
  final Map<String, dynamic> options;

  Widget buildGraphifyView(GraphifyController controller) => GraphifyView(
    controller: controller,
    onConsoleMessage: (m) => debugPrint('Graphify advanced distribution: $m'),
    initialOptions: options,
  );

  @override
  State<GraphifyAdvancedDistributionChart> createState() =>
      _GraphifyAdvancedDistributionChartState();
}

class _GraphifyAdvancedDistributionChartState
    extends State<GraphifyAdvancedDistributionChart> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) => widget.buildGraphifyView(controller);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
