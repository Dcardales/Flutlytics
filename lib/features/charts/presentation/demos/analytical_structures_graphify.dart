import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../../data/analytical_structures_data.dart';

Map<String, dynamic> analyticalStructuresOptions(String id) => switch (id) {
  'diverging-stacked-bar' => _diverging(),
  'scatterplot-matrix' => _matrix(),
  'ternary-plot' => _ternary(),
  'fan-chart' => _fan(),
  'calibration-plot' => _calibration(),
  _ => throw ArgumentError.value(id, 'id'),
};

const _likertParts = <(String, String, String)>[
  ('Neutral', 'left', '#b0bec5'),
  ('Insatisfecho', 'left', '#ef9a9a'),
  ('Muy insatisfecho', 'left', '#c62828'),
  ('Neutral', 'right', '#b0bec5'),
  ('Satisfecho', 'right', '#81c784'),
  ('Muy satisfecho', 'right', '#2e7d32'),
];

Map<String, dynamic> _diverging() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'legend': {'top': 0, 'type': 'scroll'},
  'grid': {'left': 96, 'right': 18, 'top': 52, 'bottom': 38},
  'xAxis': {
    'type': 'value',
    'min': -55,
    'max': 85,
    'name': '%',
    'axisLine': {'onZero': true},
  },
  'yAxis': {
    'type': 'category',
    'inverse': true,
    'data': [for (final r in touristLikert) r.label],
  },
  'series': [
    for (final (response, side, color) in _likertParts)
      {
        'type': 'bar',
        'stack': side,
        'name': response == 'Neutral' ? 'Neutral $side' : response,
        'itemStyle': {'color': color},
        'barWidth': 22,
        'data': [
          for (final row in touristLikert)
            () {
              final s = divergingLikert(row)
                  .firstWhere((v) => v.response == response && v.side == side);
              return {
                'name':
                    '${row.label} · $response: ${s.percentage.toStringAsFixed(1)}%',
                'value': s.signedValue,
              };
            }(),
        ],
      },
  ],
};

Map<String, dynamic> _matrix() {
  final variables = touristMatrix.variables;
  return {
    'tooltip': {'trigger': 'item', 'formatter': '{b}'},
    'grid': [
      for (final cell in touristMatrix.cells)
        {
          'left': '${5 + cell.column * 23}%',
          'top': '${5 + cell.row * 23}%',
          'width': '19%',
          'height': '19%',
          'show': true,
          'borderColor': '#cfd8dc',
        },
    ],
    'xAxis': [
      for (final cell in touristMatrix.cells)
        {
          'type': 'value',
          'gridIndex': cell.row * variables.length + cell.column,
          'min': touristMatrix.scales[cell.x.id]!.min,
          'max': touristMatrix.scales[cell.x.id]!.max,
          'axisLabel': {
            'show': cell.row == variables.length - 1,
            'fontSize': 9,
          },
        },
    ],
    'yAxis': [
      for (final cell in touristMatrix.cells)
        {
          'type': 'value',
          'gridIndex': cell.row * variables.length + cell.column,
          'min': touristMatrix.scales[cell.y.id]!.min,
          'max': touristMatrix.scales[cell.y.id]!.max,
          'axisLabel': {'show': cell.column == 0, 'fontSize': 9},
        },
    ],
    'series': [
      for (final cell in touristMatrix.cells)
        if (!cell.isDiagonal)
          {
            'type': 'scatter',
            'xAxisIndex': cell.row * variables.length + cell.column,
            'yAxisIndex': cell.row * variables.length + cell.column,
            'symbolSize': 6,
            'name': '${cell.y.label} × ${cell.x.label}',
            'data': [
              for (final o in touristMatrix.observations)
                {
                  'name':
                      '${o.label}: ${cell.x.label} ${o.value(cell.x).toStringAsFixed(1)} ${cell.x.unit}; ${cell.y.label} ${o.value(cell.y).toStringAsFixed(1)} ${cell.y.unit}',
                  'value': [o.value(cell.x), o.value(cell.y)],
                },
            ],
          },
    ],
    'title': [
      for (final cell in touristMatrix.cells)
        if (cell.isDiagonal)
          {
            'text': cell.x.label,
            'subtext': cell.x.unit,
            'left': '${6 + cell.column * 23}%',
            'top': '${10 + cell.row * 23}%',
            'textStyle': {'fontSize': 12},
            'subtextStyle': {'fontSize': 10},
          },
    ],
  };
}

Map<String, dynamic> _ternary() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'grid': {'left': '10%', 'right': '10%', 'top': '11%', 'bottom': '19%'},
  'xAxis': {'type': 'value', 'min': 0, 'max': 1, 'show': false},
  'yAxis': {'type': 'value', 'min': 0, 'max': ternaryHeight, 'show': false},
  'series': [
    {
      'type': 'line',
      'name': 'Triángulo A/B/C',
      'showSymbol': false,
      'silent': true,
      'lineStyle': {'color': '#455a64', 'width': 2},
      'data': [
        [0, 0],
        [1, 0],
        [.5, ternaryHeight],
        [0, 0],
      ],
    },
    {
      'type': 'scatter',
      'name': 'Presupuesto turístico',
      'symbolSize': 10,
      'data': [
        for (final p in touristBudgetMix)
          {
            'name':
                '${p.label}: alojamiento ${p.a}%, alimentación ${p.b}%, transporte ${p.c}%',
            'value': [p.x, p.y],
          },
      ],
    },
  ],
  'graphic': [
    {
      'type': 'text',
      'left': '49%',
      'top': '1%',
      'style': {'text': 'Alojamiento', 'fill': '#263238', 'fontSize': 11},
    },
    {
      'type': 'text',
      'left': '2%',
      'bottom': 5,
      'style': {'text': 'Alimentación', 'fill': '#263238', 'fontSize': 11},
    },
    {
      'type': 'text',
      'right': 2,
      'bottom': 5,
      'style': {'text': 'Transporte', 'fill': '#263238', 'fontSize': 11},
    },
  ],
};

Map<String, dynamic> _fan() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'legend': {
    'top': 0,
    'data': ['95%', '80%', '50%', 'Mediana'],
  },
  'grid': {'left': 45, 'right': 16, 'top': 42, 'bottom': 34},
  'xAxis': {
    'type': 'category',
    'name': 'Mes futuro',
    'data': [for (final p in hotelForecastFan) p.period],
  },
  'yAxis': {'type': 'value', 'name': 'Ocupación (%)', 'min': 40, 'max': 100},
  'series': [
    for (final (name, low, high, shade)
        in <
          (
            String,
            double Function(ForecastPoint),
            double Function(ForecastPoint),
            String,
          )
        >[
          ('95%', (p) => p.lower95, (p) => p.upper95, '#bbdefb'),
          ('80%', (p) => p.lower80, (p) => p.upper80, '#64b5f6'),
          ('50%', (p) => p.lower50, (p) => p.upper50, '#1976d2'),
        ]) ...[
      {
        'type': 'line',
        'name': '_base$name',
        'stack': 'band$name',
        'silent': true,
        'showSymbol': false,
        'lineStyle': {'opacity': 0},
        'areaStyle': {'opacity': 0},
        'data': [for (final p in hotelForecastFan) low(p)],
      },
      {
        'type': 'line',
        'name': name,
        'stack': 'band$name',
        'showSymbol': false,
        'lineStyle': {'opacity': 0},
        'areaStyle': {'color': shade, 'opacity': .85},
        'data': [
          for (final p in hotelForecastFan)
            {
              'name':
                  '${p.period}: $name [${low(p).toStringAsFixed(1)}, ${high(p).toStringAsFixed(1)}]%, mediana ${p.median.toStringAsFixed(1)}%',
              'value': high(p) - low(p),
            },
        ],
      },
    ],
    {
      'type': 'line',
      'name': 'Mediana',
      'showSymbol': true,
      'symbolSize': 5,
      'lineStyle': {'color': '#0d47a1', 'width': 2},
      'data': [
        for (final p in hotelForecastFan)
          {
            'name':
                '${p.period}: mediana ${p.median.toStringAsFixed(1)}%, 50% [${p.lower50.toStringAsFixed(1)}, ${p.upper50.toStringAsFixed(1)}], 80% [${p.lower80.toStringAsFixed(1)}, ${p.upper80.toStringAsFixed(1)}], 95% [${p.lower95.toStringAsFixed(1)}, ${p.upper95.toStringAsFixed(1)}]',
            'value': p.median,
          },
      ],
    },
  ],
};

Map<String, dynamic> _calibration() => {
  'tooltip': {'trigger': 'item', 'formatter': '{b}'},
  'xAxis': {
    'type': 'value',
    'name': 'Probabilidad predicha',
    'min': 0,
    'max': 1,
  },
  'yAxis': {
    'type': 'value',
    'name': 'Frecuencia observada',
    'min': 0,
    'max': 1,
  },
  'series': [
    {
      'type': 'line',
      'name': 'Ideal y=x',
      'showSymbol': false,
      'silent': true,
      'lineStyle': {'type': 'dashed', 'color': '#546e7a'},
      'data': [
        [0, 0],
        [1, 1],
      ],
    },
    {
      'type': 'scatter',
      'name': 'Bins de cancelación',
      'symbolSize': 12,
      'data': [
        for (final b in cancellationCalibration)
          {
            'name':
                'Bin ${b.index + 1}: predicha ${b.avgPredicted.toStringAsFixed(2)}, observada ${b.observedRate.toStringAsFixed(2)}, n=${b.count}',
            'value': [b.avgPredicted, b.observedRate],
          },
      ],
    },
  ],
};

class AnalyticalStructuresGraphifyChart extends StatefulWidget {
  const AnalyticalStructuresGraphifyChart({super.key, required this.id});
  final String id;
  @override
  State<AnalyticalStructuresGraphifyChart> createState() =>
      _AnalyticalStructuresGraphifyChartState();
}

class _AnalyticalStructuresGraphifyChartState
    extends State<AnalyticalStructuresGraphifyChart> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) {
    final view = GraphifyView(
      controller: controller,
      initialOptions: analyticalStructuresOptions(widget.id),
    );
    if (widget.id != 'scatterplot-matrix') return view;
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: 720, height: 720, child: view),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
