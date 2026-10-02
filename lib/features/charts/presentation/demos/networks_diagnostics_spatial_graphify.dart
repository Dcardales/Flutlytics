import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/networks_diagnostics_spatial_data.dart';
import 'networks_diagnostics_spatial_batch_demos.dart' show networkTooltip;

Map<String, dynamic> networksDiagnosticsSpatialOptions(String id) =>
    switch (id) {
      'network-graph' => _network(),
      'qq-plot' => _qq(),
      'parallel-coordinates' => _parallel(),
      'contour' => _contour(),
      'calendar-heatmap' => _calendar(),
      _ => throw ArgumentError.value(id, 'id'),
    };

Map<String, dynamic> _network() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'series': [
    {
      'type': 'graph',
      'layout': 'none',
      'roam': false,
      'label': {'show': true, 'position': 'right', 'fontSize': 10},
      'lineStyle': {'color': '#90a4ae', 'width': 2},
      'data': [
        for (final p in touristNetwork.positions)
          {
            'id': p.node.id,
            'name': networkTooltip(p),
            'x': p.x * 115 + 150,
            'y': p.y * 105 + 125,
            'symbolSize': 12 + p.node.weight,
            'itemStyle': {
              'color': p.node.group == 'Destino'
                  ? '#1565c0'
                  : p.node.group == 'Transporte'
                  ? '#ef6c00'
                  : '#2e7d32',
            },
            'label': {'formatter': p.node.label},
            'value': p.node.weight,
          },
      ],
      'links': [
        for (final e in touristNetwork.edges)
          {'source': e.sourceId, 'target': e.targetId, 'value': e.weight},
      ],
    },
  ],
};

Map<String, dynamic> _qq() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'grid': {'left': 48, 'right': 22, 'top': 18, 'bottom': 42},
  'xAxis': {'type': 'value', 'min': -3, 'max': 3, 'name': 'Normal teórica'},
  'yAxis': {'type': 'value', 'min': -3, 'max': 3, 'name': 'Observado z'},
  'series': [
    {
      'type': 'line',
      'name': 'Ideal y=x',
      'silent': true,
      'showSymbol': false,
      'lineStyle': {'type': 'dashed', 'color': '#78909c'},
      'data': [
        [-3, -3],
        [3, 3],
      ],
    },
    {
      'type': 'scatter',
      'name': 'Cuantiles',
      'symbolSize': 7,
      'data': [
        for (final p in serviceQq)
          {
            'name':
                'Normal ${p.theoretical.toStringAsFixed(2)}; observado z=${p.observed.toStringAsFixed(2)}',
            'value': [p.theoretical, p.observed],
          },
      ],
    },
  ],
};

Map<String, dynamic> _parallel() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'parallel': {'left': 45, 'right': 45, 'top': 35, 'bottom': 45},
  'parallelAxis': [
    for (var i = 0; i < touristParallel.variables.length; i++)
      {
        'dim': i,
        'name': touristParallel.variables[i].label,
        'min': 0,
        'max': 1,
        'nameTextStyle': {'fontSize': 10},
      },
  ],
  'series': [
    {
      'type': 'parallel',
      'name': 'Destinos',
      'lineStyle': {'width': 2, 'opacity': .7},
      'data': [
        for (final o in touristParallel.observations)
          {
            'name':
                '${o.label}: ${[for (final p in touristParallel.forObservation(o)) '${p.variable.label} ${p.raw.toStringAsFixed(1)} ${p.variable.unit}'].join('; ')}',
            'value': [
              for (final p in touristParallel.forObservation(o)) p.normalized,
            ],
          },
      ],
    },
  ],
};

Map<String, dynamic> _contour() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'grid': {'left': 42, 'right': 18, 'top': 18, 'bottom': 40},
  'xAxis': {'type': 'value', 'min': 0, 'max': 24, 'name': 'Este-oeste'},
  'yAxis': {'type': 'value', 'min': 0, 'max': 19, 'name': 'Norte-sur'},
  'series': [
    for (final s in touristContour.segments)
      {
        'type': 'line',
        'name': 'Nivel ${s.level.toStringAsFixed(1)}',
        'showSymbol': false,
        'animation': false,
        'lineStyle': {
          'width': 1.5,
          'color': const [
            '#1565c0',
            '#00897b',
            '#7cb342',
            '#f9a825',
            '#ef6c00',
            '#ad1457',
          ][touristContour.levels.indexOf(s.level)],
        },
        'data': [
          {
            'name': 'Intensidad ${s.level.toStringAsFixed(1)}',
            'value': [s.a.x, s.a.y],
          },
          {
            'name': 'Intensidad ${s.level.toStringAsFixed(1)}',
            'value': [s.b.x, s.b.y],
          },
        ],
      },
  ],
};

Map<String, dynamic> _calendar() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'visualMap': {
    'min': bookingCalendar.minValue,
    'max': bookingCalendar.maxValue,
    'show': false,
    'inRange': {
      'color': ['#e3f2fd', '#64b5f6', '#0d47a1'],
    },
  },
  'calendar': {
    'range': ['2025-10-01', '2026-03-30'],
    'left': 30,
    'right': 12,
    'top': 30,
    'bottom': 25,
    'cellSize': ['auto', 'auto'],
    'dayLabel': {
      'firstDay': 1,
      'nameMap': ['D', 'L', 'M', 'X', 'J', 'V', 'S'],
    },
    'monthLabel': {'nameMap': 'es', 'fontSize': 10},
    'yearLabel': {'show': false},
  },
  'series': [
    {
      'type': 'heatmap',
      'coordinateSystem': 'calendar',
      'data': [
        for (final c in bookingCalendar.cells)
          {
            'name':
                '${isoDay(c.day.date)}: ${c.day.value.toStringAsFixed(0)} reservas',
            'value': [isoDay(c.day.date), c.day.value],
          },
      ],
    },
  ],
};

class NetworksDiagnosticsSpatialGraphifyChart extends StatefulWidget {
  const NetworksDiagnosticsSpatialGraphifyChart({super.key, required this.id});
  final String id;
  @override
  State<NetworksDiagnosticsSpatialGraphifyChart> createState() =>
      _NetworksDiagnosticsSpatialGraphifyChartState();
}

class _NetworksDiagnosticsSpatialGraphifyChartState
    extends State<NetworksDiagnosticsSpatialGraphifyChart> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) => GraphifyView(
    controller: controller,
    initialOptions: networksDiagnosticsSpatialOptions(widget.id),
  );
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
