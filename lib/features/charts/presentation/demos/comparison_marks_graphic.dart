import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/sample_datasets.dart';

const _colors = <Color>[
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
  Color(0xff00838f),
];
const _startColor = Color(0xff1565c0);
const _endColor = Color(0xffef6c00);
const _neutral = Color(0xff78909c);
List<ChartPoint> _points(String id) => ChartDatasetRegistry.pointsFor(id);
List<DumbbellDatum> _dumbbells() => ChartDatasetRegistry.dumbbellData();
List<SlopeDatum> _slopes() => ChartDatasetRegistry.slopeData();
List<ParetoPoint> _pareto() =>
    calculatePareto(ChartDatasetRegistry.paretoSources());

Widget buildGraphicComparisonChart(String id) => switch (id) {
  'dot-plot' => _graphicDot(_points(id)),
  'lollipop' => _graphicLollipop(_points(id)),
  'dumbbell' => _graphicDumbbell(_dumbbells()),
  'slope' => _graphicSlope(_slopes()),
  _ => _graphicPareto(_pareto()),
};
typedef _GraphicPoint = ({String label, double value, String role});
typedef _GraphicPair = ({
  String label,
  double value,
  String state,
  double delta,
});
typedef _GraphicSlope = ({String label, String period, double value});
typedef _GraphicPareto = ({
  String category,
  double frequency,
  double cumulative,
  double threshold,
});

Widget _graphicDot(List<ChartPoint> data) {
  final rows = [
    for (final point in data)
      (label: point.label, value: point.value, role: 'score'),
  ];
  return gr.Chart<_GraphicPoint>(
    data: rows,
    variables: {
      'label': gr.Variable(accessor: (_GraphicPoint r) => r.label),
      'value': gr.Variable(
        accessor: (_GraphicPoint r) => r.value,
        scale: gr.LinearScale(min: 0, max: 10),
      ),
    },
    marks: [
      gr.PointMark(
        position: gr.Varset('value') * gr.Varset('label'),
        color: gr.ColorEncode(variable: 'label', values: _colors),
        size: gr.SizeEncode(value: 8),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'value']),
    selections: {
      'point': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
  );
}

Widget _graphicLollipop(List<ChartPoint> data) {
  final rows = <({String label, double value, String role})>[];
  for (final row in data) {
    rows.add((label: row.label, value: 0, role: 'base'));
    rows.add((label: row.label, value: row.value, role: 'value'));
  }
  return gr.Chart<({String label, double value, String role})>(
    data: rows,
    variables: {
      'label': gr.Variable(accessor: (r) => r.label),
      'value': gr.Variable(
        accessor: (r) => r.value,
        scale: gr.LinearScale(min: 0, max: 100),
      ),
      'role': gr.Variable(accessor: (r) => r.role),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('label') * gr.Varset('value'),
        color: gr.ColorEncode(variable: 'label', values: _colors),
        size: gr.SizeEncode(value: 2),
      ),
      gr.PointMark(
        position: gr.Varset('label') * gr.Varset('value'),
        color: gr.ColorEncode(
          variable: 'role',
          values: [Colors.transparent, _endColor],
        ),
        size: gr.SizeEncode(value: 9),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'value']),
    selections: {
      'point': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
  );
}

Widget _graphicDumbbell(List<DumbbellDatum> data) {
  final rows = <_GraphicPair>[];
  for (final row in data) {
    rows.add((
      label: row.label,
      value: row.startValue,
      state: 'Antes',
      delta: row.delta,
    ));
    rows.add((
      label: row.label,
      value: row.endValue,
      state: 'Después',
      delta: row.delta,
    ));
  }
  return gr.Chart<_GraphicPair>(
    data: rows,
    variables: {
      'label': gr.Variable(accessor: (_GraphicPair r) => r.label),
      'value': gr.Variable(
        accessor: (_GraphicPair r) => r.value,
        scale: gr.LinearScale(min: 0, max: 10),
      ),
      'state': gr.Variable(accessor: (_GraphicPair r) => r.state),
      'delta': gr.Variable(accessor: (_GraphicPair r) => r.delta),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('value') * gr.Varset('label'),
        color: gr.ColorEncode(variable: 'label', values: _colors),
        size: gr.SizeEncode(value: 2),
      ),
      gr.PointMark(
        position: gr.Varset('value') * gr.Varset('label'),
        color: gr.ColorEncode(
          variable: 'state',
          values: [_startColor, _endColor],
        ),
        size: gr.SizeEncode(value: 9),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'state', 'value', 'delta']),
    selections: {
      'point': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
  );
}

Widget _graphicSlope(List<SlopeDatum> data) {
  final rows = <({String label, String period, double value})>[];
  for (final row in data) {
    rows.add((
      label: row.label,
      period: row.startPeriod,
      value: row.startValue,
    ));
    rows.add((label: row.label, period: row.endPeriod, value: row.endValue));
  }
  return gr.Chart<_GraphicSlope>(
    data: rows,
    variables: {
      'label': gr.Variable(accessor: (_GraphicSlope r) => r.label),
      'period': gr.Variable(accessor: (_GraphicSlope r) => r.period),
      'value': gr.Variable(
        accessor: (_GraphicSlope r) => r.value,
        scale: gr.LinearScale(min: 0, max: 40),
      ),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('period') * gr.Varset('value'),
        color: gr.ColorEncode(variable: 'label', values: _colors),
        size: gr.SizeEncode(value: 2),
      ),
      gr.PointMark(
        position: gr.Varset('period') * gr.Varset('value'),
        color: gr.ColorEncode(variable: 'label', values: _colors),
        size: gr.SizeEncode(value: 8),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'period', 'value']),
    selections: {
      'point': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
  );
}

Widget _graphicPareto(List<ParetoPoint> data) {
  final rows = [
    for (final row in data)
      (
        category: row.category,
        frequency: row.frequency,
        cumulative: row.cumulativePercent,
        threshold: 80.0,
      ),
  ];
  final max =
      data.fold<double>(0, (m, r) => r.frequency > m ? r.frequency : m) * 1.12;
  return gr.Chart<_GraphicPareto>(
    data: rows,
    variables: {
      'category': gr.Variable(accessor: (_GraphicPareto r) => r.category),
      'frequency': gr.Variable(
        accessor: (_GraphicPareto r) => r.frequency,
        scale: gr.LinearScale(min: 0, max: max),
      ),
      'cumulative': gr.Variable(
        accessor: (_GraphicPareto r) => r.cumulative,
        scale: gr.LinearScale(min: 0, max: 100),
      ),
      'threshold': gr.Variable(
        accessor: (_GraphicPareto r) => r.threshold,
        scale: gr.LinearScale(min: 0, max: 100),
      ),
    },
    marks: [
      gr.IntervalMark(
        position: gr.Varset('category') * gr.Varset('frequency'),
        color: gr.ColorEncode(value: _colors[0]),
      ),
      gr.LineMark(
        position: gr.Varset('category') * gr.Varset('cumulative'),
        color: gr.ColorEncode(value: _endColor),
        size: gr.SizeEncode(value: 2),
      ),
      gr.PointMark(
        position: gr.Varset('category') * gr.Varset('cumulative'),
        color: gr.ColorEncode(value: _endColor),
        size: gr.SizeEncode(value: 6),
      ),
      gr.LineMark(
        position: gr.Varset('category') * gr.Varset('threshold'),
        color: gr.ColorEncode(value: _neutral),
        size: gr.SizeEncode(value: 1),
      ),
    ],
    axes: [
      gr.Defaults.horizontalAxis,
      gr.Defaults.verticalAxis,
      gr.AxisGuide(
        dim: gr.Dim.y,
        variable: 'cumulative',
        position: 1,
        flip: true,
        label: gr.LabelStyle(textStyle: const TextStyle(fontSize: 8)),
      ),
    ],
    tooltip: gr.TooltipGuide(
      variables: ['category', 'frequency', 'cumulative'],
    ),
    selections: {
      'point': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
  );
}
