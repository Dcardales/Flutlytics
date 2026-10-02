import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/relationships_intervals_data.dart';

Map<String, dynamic> relationshipsIntervalsOptions(String id) {
  switch (id) {
    case 'scatter':
      return {
        'tooltip': {'trigger': 'item'},
        'xAxis': {'type': 'value', 'name': 'Noches'},
        'yAxis': {'type': 'value', 'name': 'Gasto (mil COP)'},
        'series': [
          {
            'type': 'scatter',
            'name': 'Estadias',
            'data': [
              for (final p in scatterObservations)
                {
                  'name': p.label,
                  'value': [p.nights, p.spendThousands],
                },
            ],
          },
        ],
      };
    case 'bubble':
      final radii = bubbleDestinationRadii;
      return {
        'tooltip': {'trigger': 'item'},
        'xAxis': {'type': 'value', 'name': 'Visitantes (miles)'},
        'yAxis': {'type': 'value', 'name': 'Gasto por turista (mil COP)'},
        'series': [
          for (var i = 0; i < bubbleDestinations.length; i++)
            {
              'type': 'scatter',
              'name': bubbleDestinations[i].label,
              'symbolSize': 2 * radii[i],
              'itemStyle': {'color': '#1565c0', 'opacity': 0.72},
              'dimensions': ['visitors', 'spendPerVisitor', 'establishments'],
              'encode': {
                'x': 'visitors',
                'y': 'spendPerVisitor',
                'tooltip': ['visitors', 'spendPerVisitor', 'establishments'],
              },
              'data': [
                {
                  'name': bubbleDestinations[i].label,
                  'value': [
                    bubbleDestinations[i].visitorsThousands,
                    bubbleDestinations[i].spendPerVisitorThousands,
                    bubbleDestinations[i].establishments,
                  ],
                },
              ],
            },
        ],
      };
    case 'connected-scatter':
      final points = connectedScatterPoints;
      return {
        'tooltip': {'trigger': 'item'},
        'xAxis': {'type': 'value', 'name': 'Ocupacion (%)'},
        'yAxis': {'type': 'value', 'name': 'Tarifa media (mil COP)'},
        'series': [
          {
            'type': 'line',
            'name': 'Trayectoria mensual',
            'showSymbol': true,
            'symbolSize': 8,
            'data': [
              for (final p in points)
                {
                  'name': p.label,
                  'value': [p.x, p.y],
                },
            ],
            'markPoint': {
              'symbolSize': 14,
              'data': [
                {
                  'name': 'Inicio · ${points.first.label}',
                  'coord': [points.first.x, points.first.y],
                },
                {
                  'name': 'Fin · ${points.last.label}',
                  'coord': [points.last.x, points.last.y],
                },
              ],
            },
          },
        ],
      };
    case 'error-bar':
      final estimates = errorBarEstimates;
      return {
        'tooltip': {
          'trigger': 'item',
          'formatter': '{b}<br/>Estimate: {@estimate} min<br/>Lower: {@lower} min<br/>Upper: {@upper} min',
        },
        'xAxis': {
          'type': 'category',
          'data': [for (final p in estimates) p.label],
          'name': 'Service',
        },
        'yAxis': {'type': 'value', 'name': 'Mean wait (minutes)'},
        'series': [
          {
            'type': 'scatter',
            'name': 'Mean estimate',
            'dimensions': ['service', 'estimate', 'lower', 'upper'],
            'encode': {
              'x': 'service',
              'y': 'estimate',
              'tooltip': ['estimate', 'lower', 'upper'],
            },
            'data': [
              for (final estimate in estimates)
                {
                  'name': estimate.label,
                  'value': [
                    estimate.label,
                    estimate.estimate,
                    estimate.lower,
                    estimate.upper,
                  ],
                },
            ],
          },
          for (final estimate in estimates)
            {
              'type': 'line',
              'name': '${estimate.label} approximate 95% interval',
              'showSymbol': false,
              'data': [
                [estimate.label, estimate.lower],
                [estimate.label, estimate.upper],
              ],
            },
        ],
      };
    case 'range-column':
      final ranges = dailyTemperatureRanges;
      return {
        'tooltip': {'trigger': 'item'},
        'xAxis': {
          'type': 'category',
          'data': [for (final range in ranges) range.label],
          'name': 'Dia',
        },
        'yAxis': {'type': 'value', 'name': 'Temperatura (°C)', 'min': 14},
        'series': [
          {
            'type': 'bar',
            'name': 'Base inferior',
            'stack': 'range',
            'silent': true,
            'tooltip': {'show': false},
            'itemStyle': {'color': 'rgba(0,0,0,0)'},
            'data': [for (final range in ranges) range.low],
          },
          {
            'type': 'bar',
            'name': 'Rango low–high (°C)',
            'stack': 'range',
            'dimensions': ['day', 'low', 'high', 'span'],
            'encode': {
              'x': 'day',
              'y': 'span',
              'tooltip': ['low', 'high'],
            },
            'data': [
              for (final range in ranges)
                [range.label, range.low, range.high, range.span],
            ],
          },
        ],
      };
    default:
      throw ArgumentError.value(id, 'id', 'Unknown relationships concept.');
  }
}

String encodeRelationshipsIntervalsOptions(String id) =>
    jsonEncode(relationshipsIntervalsOptions(id));

class RelationshipsIntervalsGraphifyChart extends StatefulWidget {
  const RelationshipsIntervalsGraphifyChart({super.key, required this.options});
  final Map<String, dynamic> options;
  @override
  State<RelationshipsIntervalsGraphifyChart> createState() =>
      _RelationshipsIntervalsGraphifyChartState();
}

class _RelationshipsIntervalsGraphifyChartState
    extends State<RelationshipsIntervalsGraphifyChart> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) => GraphifyView(
    controller: controller,
    onConsoleMessage: (message) =>
        debugPrint('Graphify relationships/intervals: $message'),
    initialOptions: widget.options,
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
