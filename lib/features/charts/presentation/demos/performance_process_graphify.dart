import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/performance_process_data.dart';
import 'performance_process_batch_demos.dart';

Map<String, dynamic> performanceProcessOptions(String id) => switch (id) {
  'funnel' => _funnel(),
  'pyramid' => _pyramid(),
  'gauge' => _gauge(),
  'bullet' => _bullet(),
  'timeline' => _timeline(),
  _ => throw ArgumentError.value(id, 'id'),
};

Map<String, dynamic> _funnel() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'series': [
    {
      'type': 'funnel',
      'name': 'Reservas turísticas',
      'left': '12%',
      'top': 25,
      'bottom': 25,
      'width': '76%',
      'min': 0,
      'max': bookingFunnel.maxValue,
      'minSize':
          '${(100 * bookingFunnel.stages.last.value / bookingFunnel.maxValue).toStringAsFixed(1)}%',
      'maxSize': '100%',
      'sort': 'none',
      'gap': 2,
      'label': {'show': true, 'position': 'inside', 'fontSize': 10},
      'data': [
        for (final step in bookingFunnel.steps)
          {
            'name': funnelTip(step),
            'value': step.stage.value,
            'label': {'formatter': funnelShortLabels[step.index]},
            'itemStyle': {
              'color': const [
                '#0d47a1',
                '#1565c0',
                '#1976d2',
                '#42a5f5',
                '#90caf9',
              ][step.index],
            },
          },
      ],
    },
  ],
};

Map<String, dynamic> _pyramid() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'legend': {
    'top': 0,
    'data': ['Nacionales', 'Internacionales'],
  },
  'grid': {'left': 65, 'right': 22, 'top': 38, 'bottom': 32},
  'xAxis': {
    'type': 'value',
    'min': touristAgePyramid.minAxis,
    'max': touristAgePyramid.maxAxis,
  },
  'yAxis': {
    'type': 'category',
    'data': [for (final r in touristAgePyramid.rows) r.category],
  },
  'series': [
    {
      'type': 'bar',
      'name': 'Nacionales',
      'barWidth': 13,
      'itemStyle': {'color': '#1565c0'},
      'data': [
        for (final r in touristAgePyramid.rows)
          {'name': pyramidTip(r), 'value': r.leftCoordinate},
      ],
    },
    {
      'type': 'bar',
      'name': 'Internacionales',
      'barWidth': 13,
      'itemStyle': {'color': '#ef6c00'},
      'data': [
        for (final r in touristAgePyramid.rows)
          {'name': pyramidTip(r), 'value': r.rightCoordinate},
      ],
    },
  ],
};

Map<String, dynamic> _gauge() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'series': [
    {
      'type': 'gauge',
      'min': hotelOccupancyGauge.min,
      'max': hotelOccupancyGauge.max,
      'startAngle': 210,
      'endAngle': -30,
      'radius': '88%',
      'axisLine': {
        'lineStyle': {
          'width': 16,
          'color': [
            [.6, '#b0bec5'],
            [.85, '#64b5f6'],
            [1, '#ef9a9a'],
          ],
        },
      },
      'progress': {
        'show': true,
        'width': 16,
        'itemStyle': {'color': '#1565c0'},
      },
      'pointer': {'show': true, 'width': 4, 'length': '60%'},
      'detail': {
        'formatter': '{value}%',
        'fontSize': 22,
        'offsetCenter': [0, '65%'],
      },
      'data': [
        {'name': gaugeTip(), 'value': hotelOccupancyGauge.value},
      ],
    },
    {
      'type': 'gauge',
      'min': hotelOccupancyGauge.min,
      'max': hotelOccupancyGauge.max,
      'startAngle': 210,
      'endAngle': -30,
      'radius': '88%',
      'axisLine': {'show': false},
      'axisTick': {'show': false},
      'splitLine': {'show': false},
      'axisLabel': {'show': false},
      'pointer': {
        'show': true,
        'width': 2,
        'length': '80%',
        'itemStyle': {'color': '#c62828'},
      },
      'detail': {'show': false},
      'title': {'show': false},
      'data': [
        {'name': 'Meta 80%', 'value': hotelOccupancyGauge.target},
      ],
    },
  ],
};

Map<String, dynamic> _bullet() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'grid': {'left': 48, 'right': 25, 'top': 35, 'bottom': 35},
  'xAxis': {
    'type': 'value',
    'min': monthlyRevenueBullet.min,
    'max': monthlyRevenueBullet.max,
    'name': 'M COP',
  },
  'yAxis': {
    'type': 'category',
    'data': ['Ingresos'],
  },
  'series': [
    {
      'type': 'bar',
      'name': 'Actual',
      'barWidth': 18,
      'itemStyle': {'color': '#1565c0'},
      'data': [
        {'name': bulletTip(), 'value': monthlyRevenueBullet.value},
      ],
      'markArea': {
        'silent': true,
        'data': [
          for (var i = 0; i < monthlyRevenueBullet.bands.length; i++)
            [
              {
                'xAxis': monthlyRevenueBullet.bands[i].start,
                'itemStyle': {
                  'color': const ['#eceff1', '#b0bec5', '#78909c'][i],
                  'opacity': .65,
                },
              },
              {'xAxis': monthlyRevenueBullet.bands[i].end},
            ],
        ],
      },
      'markLine': {
        'symbol': 'none',
        'silent': true,
        'lineStyle': {'color': '#c62828', 'width': 3},
        'label': {'show': true, 'formatter': 'Meta 90'},
        'data': [
          {'xAxis': monthlyRevenueBullet.target},
        ],
      },
    },
  ],
};

Map<String, dynamic> _timeline() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'grid': {'left': 45, 'right': 30, 'top': 52, 'bottom': 55},
  'xAxis': {
    'type': 'time',
    'min': isoDate(flutterMilestones.events.first.date),
    'max': isoDate(flutterMilestones.events.last.date),
  },
  'yAxis': {'type': 'value', 'min': -1.5, 'max': 1.5, 'show': false},
  'series': [
    {
      'type': 'line',
      'name': 'Eje temporal',
      'showSymbol': false,
      'silent': true,
      'lineStyle': {'color': '#607d8b', 'width': 2},
      'data': [
        [isoDate(flutterMilestones.events.first.date), 0],
        [isoDate(flutterMilestones.events.last.date), 0],
      ],
    },
    for (final p in flutterMilestones.points)
      {
        'type': 'line',
        'name': p.event.title,
        'showSymbol': false,
        'silent': true,
        'lineStyle': {'color': '#1565c0', 'width': 1.5},
        'data': [
          [isoDate(p.event.date), 0],
          [isoDate(p.event.date), p.lane],
        ],
      },
    {
      'type': 'scatter',
      'name': 'Hitos',
      'symbolSize': 10,
      'data': [
        for (final p in flutterMilestones.points)
          {
            'name': timelineTip(p),
            'value': [isoDate(p.event.date), p.lane],
            'label': {
              'show': true,
              'position': p.lane > 0 ? 'top' : 'bottom',
              'formatter': p.event.title,
              'fontSize': 10,
            },
          },
      ],
    },
  ],
};

class PerformanceProcessGraphifyChart extends StatefulWidget {
  const PerformanceProcessGraphifyChart({super.key, required this.id});
  final String id;
  @override
  State<PerformanceProcessGraphifyChart> createState() =>
      _PerformanceProcessGraphifyChartState();
}

class _PerformanceProcessGraphifyChartState
    extends State<PerformanceProcessGraphifyChart> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) => GraphifyView(
    controller: controller,
    initialOptions: performanceProcessOptions(widget.id),
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
