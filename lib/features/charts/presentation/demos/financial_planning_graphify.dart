import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/financial_planning_data.dart';

Map<String, dynamic> financialPlanningOptions(String id) => switch (id) {
  'range-area' => _rangeArea(),
  'candlestick' => _candlestick(),
  'ohlc' => _ohlc(),
  'waterfall' => _waterfall(),
  'gantt' => _gantt(),
  _ => throw ArgumentError.value(id, 'id'),
};

Map<String, dynamic> _rangeArea() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'xAxis': {
    'type': 'category',
    'name': 'Mes',
    'data': [for (final p in hotelOccupancyRange) p.period.substring(3)],
  },
  'yAxis': {'type': 'value', 'name': 'Ocupación (%)', 'min': 45, 'max': 95},
  'series': [
    {
      'type': 'line',
      'name': 'Límite inferior',
      'stack': 'rango',
      'symbol': 'none',
      'silent': true,
      'lineStyle': {'opacity': 0},
      'areaStyle': {'opacity': 0},
      'data': [for (final p in hotelOccupancyRange) p.low],
    },
    {
      'type': 'line',
      'name': 'Banda low–high',
      'stack': 'rango',
      'symbol': 'circle',
      'symbolSize': 5,
      'lineStyle': {'color': '#1565c0'},
      'areaStyle': {'color': '#90caf9', 'opacity': .75},
      'data': [
        for (final p in hotelOccupancyRange)
          {
            'name':
                '${p.period.substring(3)} · Low ${p.low}% · High ${p.high}% · Banda ${p.span} pp',
            'value': p.span,
          },
      ],
    },
  ],
};

Map<String, dynamic> _candlestick() => {
  'tooltip': {'trigger': 'item'},
  'xAxis': {
    'type': 'category',
    'name': 'Sesión',
    'data': [for (final p in educationalOhlc) p.period],
  },
  'yAxis': {'type': 'value', 'name': 'Índice educativo', 'min': 96, 'max': 114},
  'series': [
    {
      'type': 'candlestick',
      'name': 'OHLC educativo',
      'itemStyle': {
        'color': '#2e7d32',
        'color0': '#c62828',
        'borderColor': '#1b5e20',
        'borderColor0': '#8e0000',
      },
      'data': [
        for (final p in educationalOhlc)
          {
            'name':
                'Sesión ${p.period} · O ${p.open} H ${p.high} L ${p.low} C ${p.close}',
            'value': [p.open, p.close, p.low, p.high],
          },
      ],
    },
  ],
};

Map<String, dynamic> _ohlc() {
  final series = <Map<String, dynamic>>[];
  for (var i = 0; i < educationalOhlc.length; i++) {
    final p = educationalOhlc[i];
    final label =
        'Sesión ${p.period} · O ${p.open} H ${p.high} L ${p.low} C ${p.close}';
    for (final (part, data) in [
      (
        'High–Low',
        [
          [i.toDouble(), p.low],
          [i.toDouble(), p.high],
        ],
      ),
      (
        'Open ←',
        [
          [i - .25, p.open],
          [i.toDouble(), p.open],
        ],
      ),
      (
        'Close →',
        [
          [i.toDouble(), p.close],
          [i + .25, p.close],
        ],
      ),
    ]) {
      series.add({
        'type': 'line',
        'name': '$label · $part',
        'showSymbol': false,
        'silent': false,
        'lineStyle': {'color': p.isBullish ? '#2e7d32' : '#c62828', 'width': 2},
        'data': data,
      });
    }
  }
  return {
    'tooltip': {'trigger': 'item'},
    'xAxis': {
      'type': 'value',
      'name': 'Sesión',
      'min': -.5,
      'max': 11.5,
      'interval': 2,
    },
    'yAxis': {
      'type': 'value',
      'name': 'Índice educativo',
      'min': 96,
      'max': 114,
    },
    'series': series,
  };
}

Map<String, dynamic> _waterfall() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'xAxis': {
    'type': 'category',
    'data': [for (final b in hotelWaterfall) b.step.label],
    'axisLabel': {'rotate': 32, 'fontSize': 10},
  },
  'yAxis': {'type': 'value', 'name': 'Millones COP', 'min': 0},
  'series': [
    {
      'type': 'bar',
      'stack': 'acumulado',
      'name': 'Base invisible',
      'silent': true,
      'itemStyle': {'color': 'rgba(0,0,0,0)'},
      'data': [
        for (final b in hotelWaterfall)
          b.step.type == WaterfallType.decrease ? b.endY : b.startY,
      ],
    },
    {
      'type': 'bar',
      'stack': 'acumulado',
      'name': 'Contribución',
      'data': [
        for (final b in hotelWaterfall)
          {
            'name':
                '${b.step.label}: ${b.contribution >= 0 ? '+' : ''}${b.contribution}; acumulado ${b.endY}',
            'value': (b.endY - b.startY).abs(),
            'itemStyle': {
              'color': switch (b.step.type) {
                WaterfallType.start || WaterfallType.total => '#1565c0',
                WaterfallType.increase => '#2e7d32',
                _ => '#c62828',
              },
            },
          },
      ],
    },
  ],
};

Map<String, dynamic> _gantt() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'grid': {'left': 102, 'right': 20, 'bottom': 55},
  'xAxis': {
    'type': 'value',
    'name': 'Fecha (oct 2026)',
    'min': 1,
    'max': 21,
    'interval': 4,
    'axisLabel': {'formatter': '{value}/10'},
  },
  'yAxis': {
    'type': 'category',
    'inverse': true,
    'data': [for (final t in flutterFeatureTasks) t.label],
  },
  'series': [
    {
      'type': 'bar',
      'stack': 'tiempo',
      'name': 'Inicio',
      'silent': true,
      'itemStyle': {'color': 'rgba(0,0,0,0)'},
      'data': [for (final t in flutterFeatureTasks) ganttDay(t.start)],
    },
    {
      'type': 'bar',
      'stack': 'tiempo',
      'name': 'Duración',
      'barWidth': 16,
      'data': [
        for (final t in flutterFeatureTasks)
          {
            'name':
                '${t.label}: ${ganttDate(ganttDay(t.start))}–${ganttDate(ganttDay(t.end))} · ${t.duration.inDays} días · ${(t.progress * 100).round()}%',
            'value': t.duration.inHours / 24,
          },
      ],
    },
  ],
};

class FinancialPlanningGraphifyChart extends StatefulWidget {
  const FinancialPlanningGraphifyChart({super.key, required this.options});
  final Map<String, dynamic> options;
  @override
  State<FinancialPlanningGraphifyChart> createState() =>
      _FinancialPlanningGraphifyChartState();
}

class _FinancialPlanningGraphifyChartState
    extends State<FinancialPlanningGraphifyChart> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) =>
      GraphifyView(controller: controller, initialOptions: widget.options);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
