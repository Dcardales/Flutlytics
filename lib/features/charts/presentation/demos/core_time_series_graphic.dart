import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/time_series_data.dart';
import 'core_time_series_fl_chart.dart';

typedef _GraphicTimePoint = ({int period, String label, double value});
typedef _GraphicMultiPoint = ({
  int period,
  String label,
  String series,
  double value,
});

const _monthLabels = [
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

String _formatPeriod(int period, Map<int, String> labels) =>
    labels[period] ??
    (period >= 1 && period <= 12 ? _monthLabels[period - 1] : '$period');

Widget buildGraphicTimeSeriesChart(String id) {
  final multi = id == 'multi-line';
  final stacked = id == 'stacked-area';
  final rows = multi || stacked
      ? multiTimeSeriesFor(id)
            .map(
              (p) => (
                period: p.period,
                label: p.label,
                series: p.series,
                value: p.value,
              ),
            )
            .toList()
      : singleTimeSeriesFor(id)
            .map((p) => (period: p.period, label: p.label, value: p.value))
            .toList();
  final periodLabels = multi || stacked
      ? {for (final point in multiTimeSeriesFor(id)) point.period: point.label}
      : {
          for (final point in singleTimeSeriesFor(id))
            point.period: point.label,
        };
  return Column(
    children: [
      if (multi || stacked) _graphicLegend(id),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: multi || stacked
              ? gr.Chart<_GraphicMultiPoint>(
                  data: rows.cast<_GraphicMultiPoint>(),
                  variables: {
                    'period': gr.Variable(
                      accessor: (_GraphicMultiPoint p) => p.period,
                      scale: gr.LinearScale(
                        min: 1,
                        formatter: (value) =>
                            _formatPeriod(value.round(), periodLabels),
                      ),
                    ),
                    'label': gr.Variable(
                      accessor: (_GraphicMultiPoint p) => p.label,
                    ),
                    'series': gr.Variable(
                      accessor: (_GraphicMultiPoint p) => p.series,
                    ),
                    'value': gr.Variable(
                      accessor: (_GraphicMultiPoint p) => p.value,
                      scale: gr.LinearScale(min: 0),
                    ),
                  },
                  marks: stacked
                      ? [
                          gr.AreaMark(
                            position: gr.Varset('period') * gr.Varset('value'),
                            color: gr.ColorEncode(
                              variable: 'series',
                              values: timeSeriesColors,
                            ),
                            modifiers: [gr.StackModifier()],
                          ),
                        ]
                      : [
                          gr.LineMark(
                            position: gr.Varset('period') * gr.Varset('value'),
                            color: gr.ColorEncode(
                              variable: 'series',
                              values: timeSeriesColors,
                            ),
                          ),
                          gr.PointMark(
                            position: gr.Varset('period') * gr.Varset('value'),
                            color: gr.ColorEncode(
                              variable: 'series',
                              values: timeSeriesColors,
                            ),
                          ),
                        ],
                  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
                  selections: {
                    'point': gr.PointSelection(
                      on: {gr.GestureType.hover, gr.GestureType.tap},
                      dim: gr.Dim.x,
                    ),
                  },
                  tooltip: gr.TooltipGuide(
                    variables: ['label', 'series', 'value'],
                  ),
                )
              : _singleGraphic(id, rows.cast<_GraphicTimePoint>()),
        ),
      ),
    ],
  );
}

Widget _singleGraphic(String id, List<_GraphicTimePoint> rows) =>
    gr.Chart<_GraphicTimePoint>(
      data: rows,
      variables: {
        'period': gr.Variable(
          accessor: (_GraphicTimePoint p) => p.period,
          scale: gr.LinearScale(
            min: 1,
            formatter: (value) => _formatPeriod(value.round(), {
              for (final row in rows) row.period: row.label,
            }),
          ),
        ),
        'label': gr.Variable(accessor: (_GraphicTimePoint p) => p.label),
        'value': gr.Variable(
          accessor: (_GraphicTimePoint p) => p.value,
          scale: gr.LinearScale(min: 0),
        ),
      },
      marks: id == 'area'
          ? [
              gr.AreaMark(
                position: gr.Varset('period') * gr.Varset('value'),
                color: gr.ColorEncode(
                  value: timeSeriesColors.first.withValues(alpha: 0.35),
                ),
                shape: gr.ShapeEncode(value: gr.BasicAreaShape()),
              ),
            ]
          : [
              gr.LineMark(
                position: gr.Varset('period') * gr.Varset('value'),
                shape: gr.ShapeEncode(
                  value: gr.BasicLineShape(stepped: id == 'step-line'),
                ),
                color: gr.ColorEncode(value: timeSeriesColors.first),
              ),
              if (id == 'step-line')
                gr.PointMark(
                  position: gr.Varset('period') * gr.Varset('value'),
                  color: gr.ColorEncode(value: timeSeriesColors.first),
                ),
            ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
      tooltip: gr.TooltipGuide(variables: ['label', 'value']),
    );

Widget _graphicLegend(String id) {
  final names =
      (id == 'multi-line'
              ? multiTimeSeriesFor(id).map((p) => p.series)
              : stackedAreaFor(id).map((p) => p.series))
          .toSet()
          .toList()
        ..sort();
  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    children: [
      for (var i = 0; i < names.length; i++)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 9, color: timeSeriesColors[i]),
            const SizedBox(width: 4),
            Text(names[i], style: const TextStyle(fontSize: 11)),
          ],
        ),
    ],
  );
}
