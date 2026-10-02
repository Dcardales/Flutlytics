import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/analytical_structures_data.dart';
import 'analytical_structures_batch_demos.dart' show matrixGrid;

Widget buildGraphicAnalyticalStructures(String id) => switch (id) {
  'diverging-stacked-bar' => _diverging(),
  'scatterplot-matrix' => matrixGrid(_matrixCell),
  'ternary-plot' => _ternary(),
  'fan-chart' => _fan(),
  'calibration-plot' => _calibration(),
  _ => throw ArgumentError.value(id, 'id'),
};

Map<String, gr.Selection> _selection() => {
  'point': gr.PointSelection(
    on: {gr.GestureType.hover, gr.GestureType.tap},
    dim: gr.Dim.x,
  ),
};

Widget _diverging() => gr.Chart<LikertSegment>(
  data: touristLikertSegments,
  variables: {
    'dimension': gr.Variable(accessor: (s) => s.dimension),
    'from': gr.Variable(
      accessor: (s) => s.start,
      scale: gr.LinearScale(min: -55, max: 85),
    ),
    'to': gr.Variable(
      accessor: (s) => s.end,
      scale: gr.LinearScale(min: -55, max: 85),
    ),
    'response': gr.Variable(accessor: (s) => '${s.response} ${s.side}'),
    'percent': gr.Variable(accessor: (s) => s.percentage),
  },
  marks: [
    gr.IntervalMark(
      position: gr.Varset('dimension') * (gr.Varset('from') + gr.Varset('to')),
      color: gr.ColorEncode(
        variable: 'response',
        values: const [
          Color(0xffb0bec5),
          Color(0xffef9a9a),
          Color(0xffc62828),
          Color(0xffb0bec5),
          Color(0xff81c784),
          Color(0xff2e7d32),
        ],
      ),
    ),
  ],
  coord: gr.RectCoord(transposed: true),
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  tooltip: gr.TooltipGuide(variables: ['dimension', 'response', 'percent']),
  selections: _selection(),
);

Widget _matrixCell(MatrixCell cell) {
  final xs = touristMatrix.scales[cell.x.id]!;
  final ys = touristMatrix.scales[cell.y.id]!;
  return Column(
    children: [
      Text(
        '${cell.y.label} × ${cell.x.label}',
        style: const TextStyle(fontSize: 9),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Expanded(
        child: gr.Chart<MultivariateObservation>(
          data: touristMatrix.observations,
          variables: {
            'label': gr.Variable(accessor: (o) => o.label),
            'x': gr.Variable(
              accessor: (o) => o.value(cell.x),
              scale: gr.LinearScale(min: xs.min, max: xs.max),
            ),
            'y': gr.Variable(
              accessor: (o) => o.value(cell.y),
              scale: gr.LinearScale(min: ys.min, max: ys.max),
            ),
          },
          marks: [
            gr.PointMark(
              position: gr.Varset('x') * gr.Varset('y'),
              size: gr.SizeEncode(value: 5),
              color: gr.ColorEncode(value: const Color(0xff1565c0)),
            ),
          ],
          axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
          tooltip: gr.TooltipGuide(variables: ['label', 'x', 'y']),
          selections: _selection(),
        ),
      ),
    ],
  );
}

class _TernaryRow {
  const _TernaryRow(
    this.label,
    this.group,
    this.kind,
    this.x,
    this.y,
    this.a,
    this.b,
    this.c,
  );
  final String label, group, kind;
  final double x, y, a, b, c;
}

Widget _ternary() {
  final rows = <_TernaryRow>[
    const _TernaryRow('B', 'boundary', 'boundary', 0, 0, 0, 100, 0),
    const _TernaryRow('C', 'boundary', 'boundary', 1, 0, 0, 0, 100),
    const _TernaryRow(
      'A',
      'boundary',
      'boundary',
      .5,
      ternaryHeight,
      100,
      0,
      0,
    ),
    const _TernaryRow('B', 'boundary', 'boundary', 0, 0, 0, 100, 0),
    for (final p in touristBudgetMix)
      _TernaryRow(p.label, p.label, 'point', p.x, p.y, p.a, p.b, p.c),
  ];
  return Column(
    children: [
      const Text('Alojamiento', style: TextStyle(fontSize: 11)),
      Expanded(
        child: gr.Chart<_TernaryRow>(
          data: rows,
          variables: {
            'label': gr.Variable(accessor: (r) => r.label),
            'group': gr.Variable(accessor: (r) => r.group),
            'kind': gr.Variable(accessor: (r) => r.kind),
            'x': gr.Variable(
              accessor: (r) => r.x,
              scale: gr.LinearScale(min: 0, max: 1),
            ),
            'y': gr.Variable(
              accessor: (r) => r.y,
              scale: gr.LinearScale(min: 0, max: ternaryHeight),
            ),
            'alojamiento': gr.Variable(accessor: (r) => r.a),
            'alimentacion': gr.Variable(accessor: (r) => r.b),
            'transporte': gr.Variable(accessor: (r) => r.c),
          },
          marks: [
            gr.LineMark(
              position: gr.Varset('x') * gr.Varset('y') / gr.Varset('group'),
              color: gr.ColorEncode(value: const Color(0xff455a64)),
            ),
            gr.PointMark(
              position: gr.Varset('x') * gr.Varset('y'),
              size: gr.SizeEncode(variable: 'kind', values: [0, 9]),
              color: gr.ColorEncode(value: const Color(0xff1565c0)),
            ),
          ],
          axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
          tooltip: gr.TooltipGuide(
            variables: ['label', 'alojamiento', 'alimentacion', 'transporte'],
          ),
          selections: _selection(),
        ),
      ),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Alimentación', style: TextStyle(fontSize: 11)),
          Text('Transporte', style: TextStyle(fontSize: 11)),
        ],
      ),
    ],
  );
}

Widget _fan() => Column(
  children: [
    const Wrap(
      spacing: 12,
      children: [
        Text('░ 95%', style: TextStyle(fontSize: 11)),
        Text('▒ 80%', style: TextStyle(fontSize: 11)),
        Text('▓ 50%', style: TextStyle(fontSize: 11)),
        Text('— Mediana', style: TextStyle(fontSize: 11)),
      ],
    ),
    Expanded(
      child: gr.Chart<ForecastPoint>(
        data: hotelForecastFan,
        variables: {
          'period': gr.Variable(accessor: (p) => p.period),
          for (final (key, getter)
              in <(String, double Function(ForecastPoint))>[
                ('low95', (p) => p.lower95),
                ('high95', (p) => p.upper95),
                ('low80', (p) => p.lower80),
                ('high80', (p) => p.upper80),
                ('low50', (p) => p.lower50),
                ('high50', (p) => p.upper50),
                ('median', (p) => p.median),
              ])
            key: gr.Variable(
              accessor: getter,
              scale: gr.LinearScale(min: 40, max: 100),
            ),
        },
        marks: [
          gr.AreaMark(
            position:
                gr.Varset('period') *
                (gr.Varset('low95') + gr.Varset('high95')),
            color: gr.ColorEncode(value: const Color(0xffbbdefb)),
          ),
          gr.AreaMark(
            position:
                gr.Varset('period') *
                (gr.Varset('low80') + gr.Varset('high80')),
            color: gr.ColorEncode(value: const Color(0xff64b5f6)),
          ),
          gr.AreaMark(
            position:
                gr.Varset('period') *
                (gr.Varset('low50') + gr.Varset('high50')),
            color: gr.ColorEncode(value: const Color(0xff1976d2)),
          ),
          gr.LineMark(
            position: gr.Varset('period') * gr.Varset('median'),
            color: gr.ColorEncode(value: const Color(0xff0d47a1)),
            size: gr.SizeEncode(value: 2),
          ),
        ],
        axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
        tooltip: gr.TooltipGuide(
          variables: [
            'period',
            'median',
            'low50',
            'high50',
            'low80',
            'high80',
            'low95',
            'high95',
          ],
        ),
        selections: _selection(),
      ),
    ),
  ],
);

class _CalibrationRow {
  const _CalibrationRow(this.group, this.kind, this.x, this.y, this.count);
  final String group, kind;
  final double x, y;
  final int count;
}

Widget _calibration() {
  final rows = <_CalibrationRow>[
    const _CalibrationRow('ideal', 'ideal', 0, 0, 0),
    const _CalibrationRow('ideal', 'ideal', 1, 1, 0),
    for (final b in cancellationCalibration)
      _CalibrationRow(
        'bin${b.index}',
        'bin',
        b.avgPredicted,
        b.observedRate,
        b.count,
      ),
  ];
  return gr.Chart<_CalibrationRow>(
    data: rows,
    variables: {
      'group': gr.Variable(accessor: (r) => r.group),
      'kind': gr.Variable(accessor: (r) => r.kind),
      'predicha': gr.Variable(
        accessor: (r) => r.x,
        scale: gr.LinearScale(min: 0, max: 1),
      ),
      'observada': gr.Variable(
        accessor: (r) => r.y,
        scale: gr.LinearScale(min: 0, max: 1),
      ),
      'n': gr.Variable(accessor: (r) => r.count),
    },
    marks: [
      gr.LineMark(
        position:
            gr.Varset('predicha') * gr.Varset('observada') / gr.Varset('group'),
        color: gr.ColorEncode(value: const Color(0xff607d8b)),
      ),
      gr.PointMark(
        position: gr.Varset('predicha') * gr.Varset('observada'),
        size: gr.SizeEncode(variable: 'kind', values: [0, 10]),
        color: gr.ColorEncode(value: const Color(0xff1565c0)),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['predicha', 'observada', 'n']),
    selections: _selection(),
  );
}
