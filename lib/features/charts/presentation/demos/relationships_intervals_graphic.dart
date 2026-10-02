import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/relationships_intervals_data.dart';

const _palette = [
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
  Color(0xff00838f),
  Color(0xffc62828),
  Color(0xff6d4c41),
  Color(0xff3949ab),
];

Widget buildGraphicRelationshipsIntervals(String id) {
  final chart = switch (id) {
    'scatter' => _scatter(),
    'bubble' => _bubble(),
    'connected-scatter' => _connected(),
    'error-bar' => _errorBar(),
    _ => _rangeColumn(),
  };
  final (x, y) = switch (id) {
    'scatter' => ('X: noches', 'Y: gasto total (mil COP)'),
    'bubble' => ('X: visitantes (miles)', 'Y: gasto/turista (mil COP)'),
    'connected-scatter' => ('X: ocupacion (%)', 'Y: tarifa (mil COP)'),
    'error-bar' => ('X: servicio', 'Y: espera (minutos)'),
    _ => ('X: dia', 'Y: temperatura (C)'),
  };
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(x, style: const TextStyle(fontSize: 11)),
            Text(y, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
      Expanded(child: chart),
    ],
  );
}

Widget _scatter() => gr.Chart<ScatterObservation>(
  data: scatterObservations,
  variables: {
    'label': gr.Variable(accessor: (p) => p.label),
    'x': gr.Variable(
      accessor: (p) => p.nights,
      scale: gr.LinearScale(min: 0, max: 8),
    ),
    'y': gr.Variable(accessor: (p) => p.spendThousands),
  },
  marks: [
    gr.PointMark(
      position: gr.Varset('x') * gr.Varset('y'),
      color: gr.ColorEncode(value: _palette[0]),
      size: gr.SizeEncode(value: 8),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  tooltip: gr.TooltipGuide(variables: ['label', 'x', 'y']),
  selections: _selection(),
);

class _BubbleRow {
  const _BubbleRow(this.point, this.size);
  final BubbleObservation point;
  final double size;
}

Widget _bubble() {
  final radii = bubbleDestinationRadii;
  final rows = [
    for (var i = 0; i < bubbleDestinations.length; i++)
      _BubbleRow(bubbleDestinations[i], 2 * radii[i]),
  ];
  final minSize = rows.map((p) => p.size).reduce((a, b) => a < b ? a : b);
  final maxSize = rows.map((p) => p.size).reduce((a, b) => a > b ? a : b);
  return gr.Chart<_BubbleRow>(
    data: rows,
    variables: {
      'label': gr.Variable(accessor: (r) => r.point.label),
      'x': gr.Variable(
        accessor: (r) => r.point.visitorsThousands,
        scale: gr.LinearScale(min: 0, max: 1000),
      ),
      'y': gr.Variable(accessor: (r) => r.point.spendPerVisitorThousands),
      'establishments': gr.Variable(accessor: (r) => r.point.establishments),
      'size': gr.Variable(
        accessor: (r) => r.size,
        scale: gr.LinearScale(min: minSize, max: maxSize),
      ),
    },
    marks: [
      gr.PointMark(
        position: gr.Varset('x') * gr.Varset('y'),
        color: gr.ColorEncode(value: _palette[0].withValues(alpha: .72)),
        size: gr.SizeEncode(encoder: (tuple) => tuple['size'] as double),
        shape: gr.ShapeEncode<gr.PointShape>(value: gr.CircleShape()),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'x', 'y', 'establishments']),
    selections: _selection(),
  );
}

Widget _connected() => gr.Chart<ConnectedScatterPoint>(
  data: connectedScatterPoints,
  variables: {
    'label': gr.Variable(accessor: (p) => p.label),
    'order': gr.Variable(accessor: (p) => p.order.toDouble()),
    'x': gr.Variable(
      accessor: (p) => p.x,
      scale: gr.LinearScale(min: 50, max: 86),
    ),
    'y': gr.Variable(
      accessor: (p) => p.y,
      scale: gr.LinearScale(min: 290, max: 460),
    ),
  },
  marks: [
    gr.LineMark(
      position: gr.Varset('x') * gr.Varset('y'),
      color: gr.ColorEncode(value: _palette[0]),
      size: gr.SizeEncode(value: 2),
    ),
    gr.PointMark(
      position: gr.Varset('x') * gr.Varset('y'),
      color: gr.ColorEncode(
        variable: 'label',
        values: [
          Colors.green,
          ...List.filled(connectedScatterPoints.length - 2, _palette[0]),
          Colors.red,
        ],
      ),
      size: gr.SizeEncode(value: 7),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  tooltip: gr.TooltipGuide(variables: ['label', 'order', 'x', 'y']),
  selections: _selection(),
);

class _ErrorGraphicPoint {
  const _ErrorGraphicPoint(
    this.label,
    this.x,
    this.y,
    this.estimate,
    this.role,
  );
  final String label, role;
  final double x, y, estimate;
}

Widget _errorBar() {
  final rows = <_ErrorGraphicPoint>[];
  for (var i = 0; i < errorBarEstimates.length; i++) {
    final p = errorBarEstimates[i];
    rows.addAll([
      _ErrorGraphicPoint(
        p.label,
        i.toDouble(),
        p.lower,
        p.estimate,
        'interval',
      ),
      _ErrorGraphicPoint(
        p.label,
        i.toDouble(),
        p.estimate,
        p.estimate,
        'estimate',
      ),
      _ErrorGraphicPoint(
        p.label,
        i.toDouble(),
        p.upper,
        p.estimate,
        'interval',
      ),
    ]);
  }
  return gr.Chart<_ErrorGraphicPoint>(
    data: rows,
    variables: {
      'label': gr.Variable(accessor: (p) => p.label),
      'x': gr.Variable(
        accessor: (p) => p.x,
        scale: gr.LinearScale(min: -.5, max: errorBarEstimates.length - .5),
      ),
      'y': gr.Variable(accessor: (p) => p.y),
      'estimate': gr.Variable(accessor: (p) => p.estimate),
      'role': gr.Variable(accessor: (p) => p.role),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('x') * gr.Varset('y') / gr.Varset('label'),
        color: gr.ColorEncode(
          variable: 'label',
          values: _palette.sublist(0, errorBarEstimates.length),
        ),
        size: gr.SizeEncode(value: 2),
      ),
      gr.PointMark(
        position: gr.Varset('x') * gr.Varset('y'),
        color: gr.ColorEncode(
          variable: 'role',
          values: [_palette[0].withValues(alpha: .3), Colors.black],
        ),
        size: gr.SizeEncode(variable: 'role', values: [0, 8]),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'estimate', 'y', 'role']),
    selections: _selection(),
  );
}

Widget _rangeColumn() {
  final low = dailyTemperatureRanges
      .map((p) => p.low)
      .reduce((a, b) => a < b ? a : b);
  final high = dailyTemperatureRanges
      .map((p) => p.high)
      .reduce((a, b) => a > b ? a : b);
  final yScale = gr.LinearScale(min: low - 2, max: high + 2);
  return gr.Chart<RangeValue>(
    data: dailyTemperatureRanges,
    variables: {
      'label': gr.Variable(accessor: (p) => p.label),
      'low': gr.Variable(accessor: (p) => p.low, scale: yScale),
      'high': gr.Variable(accessor: (p) => p.high, scale: yScale),
      'span': gr.Variable(accessor: (p) => p.span),
    },
    marks: [
      gr.IntervalMark(
        position: gr.Varset('label') * (gr.Varset('low') + gr.Varset('high')),
        color: gr.ColorEncode(value: _palette[0]),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'low', 'high', 'span']),
    selections: _selection(),
  );
}

Map<String, gr.Selection> _selection() => {
  'point': gr.PointSelection(
    on: {gr.GestureType.hover, gr.GestureType.tap},
    dim: gr.Dim.x,
  ),
};
