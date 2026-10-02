import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/advanced_distribution_data.dart';

const _blue = Color(0xff1565c0);
const _palette = [
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
];

Widget buildGraphicAdvancedDistribution(String id) => switch (id) {
  'box-plot' => _boxPlot(),
  'violin' => _violin(),
  'ridgeline' => _ridgeline(),
  'hexbin' => _hexbin(),
  _ => _heatmap(),
};

class _BoxMarkPoint {
  const _BoxMarkPoint(
    this.path,
    this.x,
    this.value,
    this.label,
    this.kind,
    this.q1,
    this.median,
    this.q3,
    this.lowWhisker,
    this.highWhisker,
  );
  final String path, label, kind;
  final double x, value, q1, median, q3, lowWhisker, highWhisker;
}

Widget _boxPlot() {
  final rows = <_BoxMarkPoint>[];
  for (var i = 0; i < boxPlotGroups.length; i++) {
    final group = boxPlotGroups[i];
    final s = calculateBoxPlotStats(group.values);
    final left = i - .22, right = i + .22, x = i.toDouble();
    void path(String name, List<(double, double)> points) {
      for (var j = 0; j < points.length; j++) {
        rows.add(
          _BoxMarkPoint(
            '${group.label}-$name',
            points[j].$1,
            points[j].$2,
            group.label,
            name,
            s.q1,
            s.median,
            s.q3,
            s.minWhisker,
            s.maxWhisker,
          ),
        );
      }
    }

    path('box', [
      (left, s.q1),
      (left, s.q3),
      (right, s.q3),
      (right, s.q1),
      (left, s.q1),
    ]);
    path('median', [(left, s.median), (right, s.median)]);
    path('whisker-low', [(x, s.minWhisker), (x, s.q1)]);
    path('whisker-high', [(x, s.q3), (x, s.maxWhisker)]);
    path('cap-low', [(left, s.minWhisker), (right, s.minWhisker)]);
    path('cap-high', [(left, s.maxWhisker), (right, s.maxWhisker)]);
    for (final outlier in s.outliers) {
      path('outlier-$outlier', [(x - .035, outlier), (x + .035, outlier)]);
    }
  }
  return Padding(
    padding: const EdgeInsets.all(8),
    child: gr.Chart<_BoxMarkPoint>(
      data: rows,
      variables: {
        'path': gr.Variable(accessor: (_BoxMarkPoint p) => p.path),
        'category': gr.Variable(
          accessor: (_BoxMarkPoint p) => p.x,
          scale: gr.LinearScale(min: -.5, max: boxPlotGroups.length - .5),
        ),
        'value': gr.Variable(accessor: (_BoxMarkPoint p) => p.value),
        'label': gr.Variable(accessor: (_BoxMarkPoint p) => p.label),
        'kind': gr.Variable(accessor: (_BoxMarkPoint p) => p.kind),
        'q1': gr.Variable(accessor: (_BoxMarkPoint p) => p.q1),
        'median': gr.Variable(accessor: (_BoxMarkPoint p) => p.median),
        'q3': gr.Variable(accessor: (_BoxMarkPoint p) => p.q3),
        'lowWhisker': gr.Variable(accessor: (_BoxMarkPoint p) => p.lowWhisker),
        'highWhisker': gr.Variable(
          accessor: (_BoxMarkPoint p) => p.highWhisker,
        ),
      },
      marks: [
        gr.LineMark(
          position: gr.Varset('category') * gr.Varset('value'),
          color: gr.ColorEncode(
            variable: 'path',
            values: [
              for (final path in rows.map((p) => p.path).toSet())
                path.contains('-outlier-') ? Colors.red : _blue,
            ],
          ),
          size: gr.SizeEncode(value: 2),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      tooltip: gr.TooltipGuide(
        variables: [
          'label',
          'kind',
          'value',
          'q1',
          'median',
          'q3',
          'lowWhisker',
          'highWhisker',
        ],
      ),
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
    ),
  );
}

class _ViolinRow {
  const _ViolinRow(
    this.group,
    this.value,
    this.lower,
    this.upper,
    this.density,
  );
  final String group;
  final double value, lower, upper, density;
}

Widget _violin() {
  final geometry = buildViolinGeometry(violinGroups, bandwidth: 1.5);
  final valueScale = gr.LinearScale(
    min: geometry.first.value,
    max: geometry[79].value,
  );
  final categoryScale = gr.LinearScale(min: -.5, max: violinGroups.length - .5);
  final rows = [
    for (final p in geometry)
      _ViolinRow(
        p.group,
        p.value,
        p.groupIndex - p.halfWidth,
        p.groupIndex + p.halfWidth,
        p.density,
      ),
  ];
  return Padding(
    padding: const EdgeInsets.all(8),
    child: gr.Chart<_ViolinRow>(
      data: rows,
      variables: {
        'group': gr.Variable(accessor: (_ViolinRow p) => p.group),
        'value': gr.Variable(
          accessor: (_ViolinRow p) => p.value,
          scale: valueScale,
        ),
        'lower': gr.Variable(
          accessor: (_ViolinRow p) => p.lower,
          scale: categoryScale,
        ),
        'upper': gr.Variable(
          accessor: (_ViolinRow p) => p.upper,
          scale: categoryScale,
        ),
        'density': gr.Variable(accessor: (_ViolinRow p) => p.density),
      },
      marks: [
        gr.AreaMark(
          position:
              gr.Varset('value') * (gr.Varset('lower') + gr.Varset('upper')),
          color: gr.ColorEncode(
            variable: 'group',
            values: _palette.sublist(0, violinGroups.length),
          ),
        ),
        gr.LineMark(
          position: gr.Varset('value') * gr.Varset('lower'),
          color: gr.ColorEncode(
            variable: 'group',
            values: _palette.sublist(0, violinGroups.length),
          ),
          size: gr.SizeEncode(value: 1),
        ),
        gr.LineMark(
          position: gr.Varset('value') * gr.Varset('upper'),
          color: gr.ColorEncode(
            variable: 'group',
            values: _palette.sublist(0, violinGroups.length),
          ),
          size: gr.SizeEncode(value: 1),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      tooltip: gr.TooltipGuide(variables: ['group', 'value', 'density']),
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
    ),
  );
}

class _RidgeRow {
  const _RidgeRow(this.group, this.x, this.base, this.top, this.density);
  final String group;
  final double x, base, top, density;
}

Widget _ridgeline() {
  final ridges = buildRidgeline(ridgelineGroups, bandwidth: 2.0);
  final xScale = gr.LinearScale(
    min: ridges.first.points.first.x,
    max: ridges.first.points.last.x,
  );
  final yScale = gr.LinearScale(min: -.3, max: ridges.length.toDouble());
  final rows = [
    for (final series in ridges)
      for (final p in series.points)
        _RidgeRow(p.group, p.x, p.baseline, p.baseline + p.height, p.density),
  ];
  return Padding(
    padding: const EdgeInsets.all(8),
    child: gr.Chart<_RidgeRow>(
      data: rows,
      variables: {
        'group': gr.Variable(accessor: (_RidgeRow p) => p.group),
        'x': gr.Variable(accessor: (_RidgeRow p) => p.x, scale: xScale),
        'base': gr.Variable(accessor: (_RidgeRow p) => p.base, scale: yScale),
        'top': gr.Variable(accessor: (_RidgeRow p) => p.top, scale: yScale),
        'density': gr.Variable(accessor: (_RidgeRow p) => p.density),
      },
      marks: [
        gr.AreaMark(
          position: gr.Varset('x') * (gr.Varset('base') + gr.Varset('top')),
          color: gr.ColorEncode(
            variable: 'group',
            values: _palette.sublist(0, ridges.length),
          ),
        ),
        gr.LineMark(
          position: gr.Varset('x') * gr.Varset('top'),
          color: gr.ColorEncode(
            variable: 'group',
            values: _palette.sublist(0, ridges.length),
          ),
          size: gr.SizeEncode(value: 1.2),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      tooltip: gr.TooltipGuide(variables: ['group', 'x', 'density']),
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
    ),
  );
}

class _HexDatum {
  const _HexDatum(this.bin);
  final HexBin bin;
}

class _HexagonGraphicShape extends gr.PolygonShape {
  @override
  bool equalTo(Object other) => other is _HexagonGraphicShape;
  @override
  List<gr.MarkElement> drawGroupPrimitives(
    List<gr.Attributes> group,
    gr.CoordConv coord,
    Offset origin,
  ) => [
    for (final item in group)
      () {
        final center = coord.convert(item.position.last);
        final radius = (item.size ?? 16) / 2;
        final vertices = [
          for (var i = 0; i < 6; i++)
            center +
                Offset(
                      math.cos(-math.pi / 2 + i * math.pi / 3),
                      math.sin(-math.pi / 2 + i * math.pi / 3),
                    ) *
                    radius,
        ];
        return gr.PolygonElement(
          points: vertices,
          style: gr.getPaintStyle(item, false, 0, null, null),
          tag: item.tag,
        );
      }(),
  ];
  @override
  List<gr.MarkElement> drawGroupLabels(
    List<gr.Attributes> group,
    gr.CoordConv coord,
    Offset origin,
  ) => const [];
}

Widget _hexbin() {
  final bins = buildHexBins(
    hexbinObservations,
    hexSize: .11,
    minX: 0,
    maxX: 10,
    minY: 0,
    maxY: 2000,
  );
  final max = bins.fold<int>(0, (m, b) => math.max(m, b.count));
  final rows = [for (final bin in bins) _HexDatum(bin)];
  final xScale = gr.LinearScale(min: 0, max: 10);
  final yScale = gr.LinearScale(min: 0, max: 2000);
  return Padding(
    padding: const EdgeInsets.all(8),
    child: gr.Chart<_HexDatum>(
      data: rows,
      variables: {
        'x': gr.Variable(
          accessor: (_HexDatum p) => p.bin.centerX,
          scale: xScale,
        ),
        'y': gr.Variable(
          accessor: (_HexDatum p) => p.bin.centerY,
          scale: yScale,
        ),
        'count': gr.Variable(accessor: (_HexDatum p) => p.bin.count.toDouble()),
      },
      marks: [
        gr.PolygonMark(
          position: gr.Varset('x') * gr.Varset('y'),
          color: gr.ColorEncode(
            variable: 'count',
            values: [const Color(0xffe3f2fd), const Color(0xff0d47a1)],
            stops: [1, max.toDouble()],
          ),
          shape: gr.ShapeEncode<gr.PolygonShape>(value: _HexagonGraphicShape()),
          size: gr.SizeEncode(value: 22),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      tooltip: gr.TooltipGuide(variables: ['count', 'x', 'y']),
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
    ),
  );
}

Widget _heatmap() {
  final matrix = heatmapMatrix;
  return Padding(
    padding: const EdgeInsets.all(8),
    child: gr.Chart<HeatmapCell>(
      data: matrix.orderedCells,
      variables: {
        'x': gr.Variable(accessor: (HeatmapCell c) => c.xCategory),
        'y': gr.Variable(accessor: (HeatmapCell c) => c.yCategory),
        'value': gr.Variable(
          accessor: (HeatmapCell c) => c.value,
          scale: gr.LinearScale(min: matrix.minValue, max: matrix.maxValue),
        ),
      },
      marks: [
        gr.PolygonMark(
          position: gr.Varset('x') * gr.Varset('y'),
          shape: gr.ShapeEncode<gr.PolygonShape>(
            value: gr.HeatmapShape(
              tileCounts: [
                matrix.xCategories.length,
                matrix.yCategories.length,
              ],
            ),
          ),
          color: gr.ColorEncode(
            variable: 'value',
            values: [const Color(0xffe3f2fd), const Color(0xff0d47a1)],
            stops: [matrix.minValue, matrix.maxValue],
          ),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      tooltip: gr.TooltipGuide(variables: ['y', 'x', 'value']),
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
    ),
  );
}
