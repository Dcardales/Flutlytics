import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/analytical_time_series.dart';
import 'transformed_time_series_styles.dart';

typedef _AnalyticalRow = ({
  int period,
  String label,
  String series,
  double value,
  double original,
  String status,
  double mean,
  double ucl,
  double lcl,
  double lower,
  double upper,
});

const _monthNames = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];

Widget buildGraphicAnalyticalChart(String id) {
  final rows = _rowsFor(id);
  final labelsByPeriod = {for (final row in rows) row.period: row.label};
  final lowerUpperScale = id == 'streamgraph'
      ? gr.LinearScale(
          min: rows.map((p) => p.lower).reduce((a, b) => a < b ? a : b),
          max: rows.map((p) => p.upper).reduce((a, b) => a > b ? a : b),
        )
      : null;
  final names = stableSeriesNames(
    rows.map((p) => p.series).where((name) => name.isNotEmpty),
  );
  return Column(
    children: [
      if (names.isNotEmpty || id == 'control-chart')
        analyticalLegend(
          id == 'control-chart'
              ? const [
                  'Observación',
                  'Media',
                  'UCL / LCL',
                  '◆ Fuera de control',
                ]
              : names,
        ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: gr.Chart<_AnalyticalRow>(
            data: rows,
            variables: {
              'period': gr.Variable(
                accessor: (_AnalyticalRow p) => p.period,
                scale: gr.LinearScale(
                  min: 1,
                  formatter: (value) =>
                      labelsByPeriod[value.round()] ??
                      (value.round() >= 1 && value.round() <= 12
                          ? _monthNames[value.round() - 1]
                          : '${value.round()}'),
                ),
              ),
              'label': gr.Variable(accessor: (_AnalyticalRow p) => p.label),
              'series': gr.Variable(accessor: (_AnalyticalRow p) => p.series),
              'value': gr.Variable(accessor: (_AnalyticalRow p) => p.value),
              'original': gr.Variable(
                accessor: (_AnalyticalRow p) => p.original,
              ),
              'status': gr.Variable(accessor: (_AnalyticalRow p) => p.status),
              'mean': gr.Variable(accessor: (_AnalyticalRow p) => p.mean),
              'ucl': gr.Variable(accessor: (_AnalyticalRow p) => p.ucl),
              'lcl': gr.Variable(accessor: (_AnalyticalRow p) => p.lcl),
              'lower': gr.Variable(
                accessor: (_AnalyticalRow p) => p.lower,
                scale: lowerUpperScale,
              ),
              'upper': gr.Variable(
                accessor: (_AnalyticalRow p) => p.upper,
                scale: lowerUpperScale,
              ),
            },
            marks: _marks(id),
            axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
            selections: {
              'point': gr.PointSelection(
                on: {gr.GestureType.hover, gr.GestureType.tap},
                dim: gr.Dim.x,
              ),
            },
            tooltip: gr.TooltipGuide(
              variables: id == 'control-chart'
                  ? ['label', 'value', 'status']
                  : id == 'indexed-line'
                  ? ['series', 'label', 'value', 'original']
                  : id == 'normalized-stacked-area'
                  ? ['series', 'label', 'value']
                  : id == 'streamgraph'
                  ? ['series', 'label', 'original']
                  : ['label', 'value'],
            ),
          ),
        ),
      ),
    ],
  );
}

List<gr.Mark> _marks(String id) => switch (id) {
  'cumulative-line' => [
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('value'),
      color: gr.ColorEncode(value: analyticalSeriesColors.first),
    ),
    gr.PointMark(
      position: gr.Varset('period') * gr.Varset('value'),
      color: gr.ColorEncode(value: analyticalSeriesColors.first),
    ),
  ],
  'indexed-line' => [
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('value'),
      color: gr.ColorEncode(variable: 'series', values: analyticalSeriesColors),
    ),
    gr.PointMark(
      position: gr.Varset('period') * gr.Varset('value'),
      color: gr.ColorEncode(variable: 'series', values: analyticalSeriesColors),
      shape: gr.ShapeEncode<gr.PointShape>(
        variable: 'series',
        values: [gr.CircleShape(), gr.SquareShape(), gr.CircleShape()],
      ),
      size: gr.SizeEncode(value: 6),
    ),
  ],
  'normalized-stacked-area' => [
    gr.AreaMark(
      position: gr.Varset('period') * gr.Varset('value'),
      color: gr.ColorEncode(variable: 'series', values: analyticalSeriesColors),
      modifiers: [gr.StackModifier()],
    ),
  ],
  'streamgraph' => [
    gr.AreaMark(
      position: gr.Varset('period') * (gr.Varset('lower') + gr.Varset('upper')),
      color: gr.ColorEncode(variable: 'series', values: analyticalSeriesColors),
    ),
  ],
  'control-chart' => [
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('mean'),
      color: gr.ColorEncode(value: Colors.black54),
      size: gr.SizeEncode(value: 1),
    ),
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('ucl'),
      color: gr.ColorEncode(value: Colors.red.shade700),
      size: gr.SizeEncode(value: 1),
    ),
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('lcl'),
      color: gr.ColorEncode(value: Colors.red.shade700),
      size: gr.SizeEncode(value: 1),
    ),
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('value'),
      color: gr.ColorEncode(value: analyticalSeriesColors.first),
    ),
    gr.PointMark(
      position: gr.Varset('period') * gr.Varset('value'),
      color: gr.ColorEncode(
        variable: 'status',
        values: [analyticalSeriesColors.first, Colors.red.shade700],
      ),
      size: gr.SizeEncode(variable: 'status', values: [5, 10]),
      shape: gr.ShapeEncode<gr.PointShape>(
        variable: 'status',
        values: [gr.CircleShape(), gr.SquareShape()],
      ),
    ),
  ],
  _ => throw ArgumentError.value(id, 'id'),
};

List<_AnalyticalRow> _rowsFor(String id) {
  if (id == 'cumulative-line') {
    return [
      for (final p in cumulativeTimeSeriesFor(id))
        _row(p.period, p.label, value: p.value, original: p.value),
    ];
  }
  if (id == 'indexed-line') {
    return [
      for (final p in indexedTimeSeriesFor(id))
        _row(
          p.period,
          p.label,
          series: p.series,
          value: p.value,
          original: p.originalValue,
        ),
    ];
  }
  if (id == 'normalized-stacked-area') {
    return [
      for (final p in normalizedStackedAreaFor(id))
        _row(
          p.period,
          p.label,
          series: p.series,
          value: p.value,
          original: p.value,
        ),
    ];
  }
  if (id == 'streamgraph') {
    return [
      for (final p in streamgraphFor(id))
        _row(
          p.period,
          p.label,
          series: p.series,
          value: p.value,
          original: p.value,
          lower: p.lower,
          upper: p.upper,
        ),
    ];
  }
  if (id == 'control-chart') {
    final result = controlChartFor(id);
    return [
      for (final p in result.points)
        _row(
          p.period,
          p.label,
          value: p.value,
          original: p.value,
          status: p.outOfControl ? 'Fuera de control' : 'Dentro de límites',
          mean: result.stats.mean,
          ucl: result.stats.upperControlLimit,
          lcl: result.stats.lowerControlLimit,
        ),
    ];
  }
  throw ArgumentError.value(id, 'id');
}

_AnalyticalRow _row(
  int period,
  String label, {
  String series = '',
  double value = 0,
  double original = 0,
  String status = '',
  double mean = 0,
  double ucl = 0,
  double lcl = 0,
  double lower = 0,
  double upper = 0,
}) => (
  period: period,
  label: label,
  series: series,
  value: value,
  original: original,
  status: status,
  mean: mean,
  ucl: ucl,
  lcl: lcl,
  lower: lower,
  upper: upper,
);
