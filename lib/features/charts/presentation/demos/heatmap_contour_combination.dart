import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/combination_data.dart';
import '../../data/networks_diagnostics_spatial_data.dart';
import '../../domain/chart_concept.dart';

const _heatLight = Color(0xffdbeafe);
const _heatDark = Color(0xff1d4ed8);
const _contourColor = Color(0xff172554);

Widget buildHeatmapContourCombination(ChartLibrary library) =>
    switch (library) {
      ChartLibrary.flChart => _fl(),
      ChartLibrary.syncfusion => _syncfusion(),
      ChartLibrary.graphic => _graphic(),
      ChartLibrary.graphify => throw ArgumentError('Graphify uses options'),
    };

Color _fieldColor(double value) => Color.lerp(
  _heatLight,
  _heatDark,
  (value - combinationContour.minZ) /
      (combinationContour.maxZ - combinationContour.minZ),
)!;

List<FieldPoint> get _fieldPoints => [
  for (final row in combinationContour.grid) ...row,
];

Widget _fl() => LayoutBuilder(
  builder: (context, constraints) {
    final cellSize =
        math.min(constraints.maxWidth / 26, constraints.maxHeight / 21) * .9;
    return Stack(
      children: [
        fl.ScatterChart(
          fl.ScatterChartData(
            minX: -.5,
            maxX: 24.5,
            minY: -.5,
            maxY: 19.5,
            titlesData: const fl.FlTitlesData(show: false),
            gridData: const fl.FlGridData(show: false),
            borderData: fl.FlBorderData(show: false),
            scatterSpots: [
              for (final point in _fieldPoints)
                fl.ScatterSpot(
                  point.x,
                  point.y,
                  dotPainter: fl.FlDotSquarePainter(
                    size: cellSize,
                    color: _fieldColor(point.z),
                    strokeWidth: 0,
                  ),
                ),
            ],
          ),
        ),
        IgnorePointer(
          child: fl.LineChart(
            fl.LineChartData(
              minX: -.5,
              maxX: 24.5,
              minY: -.5,
              maxY: 19.5,
              titlesData: const fl.FlTitlesData(show: false),
              gridData: const fl.FlGridData(show: false),
              borderData: fl.FlBorderData(show: false),
              lineBarsData: [
                for (final segment in combinationContour.segments)
                  fl.LineChartBarData(
                    spots: [
                      fl.FlSpot(segment.a.x, segment.a.y),
                      fl.FlSpot(segment.b.x, segment.b.y),
                    ],
                    color: _contourColor,
                    barWidth: 1.4,
                    dotData: const fl.FlDotData(show: false),
                  ),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 8,
          top: 6,
          child: Text(
            'Intensidad + isolíneas',
            style: TextStyle(
              color: _contourColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  },
);

Widget _syncfusion() => sf.SfCartesianChart(
  margin: EdgeInsets.zero,
  plotAreaBorderWidth: 0,
  primaryXAxis: const sf.NumericAxis(
    minimum: -.5,
    maximum: 24.5,
    isVisible: false,
  ),
  primaryYAxis: const sf.NumericAxis(
    minimum: -.5,
    maximum: 19.5,
    isVisible: false,
  ),
  series: <sf.CartesianSeries<FieldPoint, double>>[
    sf.ScatterSeries<FieldPoint, double>(
      dataSource: _fieldPoints,
      xValueMapper: (point, _) => point.x,
      yValueMapper: (point, _) => point.y,
      pointColorMapper: (point, _) => _fieldColor(point.z),
      markerSettings: const sf.MarkerSettings(
        isVisible: true,
        shape: sf.DataMarkerType.rectangle,
        width: 10,
        height: 10,
      ),
      animationDuration: 0,
    ),
    for (final segment in combinationContour.segments)
      sf.LineSeries<FieldPoint, double>(
        dataSource: [segment.a, segment.b],
        xValueMapper: (point, _) => point.x,
        yValueMapper: (point, _) => point.y,
        color: _contourColor,
        width: 1.4,
        animationDuration: 0,
      ),
  ],
);

class _GraphicHeatmapCell {
  const _GraphicHeatmapCell(this.x, this.y, this.value);
  final String x, y;
  final double value;
}

final _graphicHeatmapCells = [
  for (final row in combinationContour.grid)
    for (final point in row)
      _GraphicHeatmapCell(
        'x${point.x.toInt()}',
        'y${point.y.toInt()}',
        point.z,
      ),
];

class _SegmentPoint {
  const _SegmentPoint(this.segment, this.x, this.y, this.level);
  final String segment;
  final double x, y, level;
}

final _graphicContourPoints = [
  for (var i = 0; i < combinationContour.segments.length; i++) ...[
    _SegmentPoint(
      '$i',
      combinationContour.segments[i].a.x,
      combinationContour.segments[i].a.y,
      combinationContour.segments[i].level,
    ),
    _SegmentPoint(
      '$i',
      combinationContour.segments[i].b.x,
      combinationContour.segments[i].b.y,
      combinationContour.segments[i].level,
    ),
  ],
];

Widget _graphic() => Stack(
  children: [
    Positioned.fill(child: _graphicHeatmap()),
    Positioned.fill(child: IgnorePointer(child: _graphicContours())),
    const Positioned(
      left: 8,
      top: 6,
      child: Text(
        'Intensidad + isolíneas',
        style: TextStyle(
          color: _contourColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
);

Widget _graphicHeatmap() => gr.Chart<_GraphicHeatmapCell>(
  data: _graphicHeatmapCells,
  variables: {
    'x': gr.Variable(accessor: (point) => point.x),
    'y': gr.Variable(accessor: (point) => point.y),
    'value': gr.Variable(
      accessor: (point) => point.value,
      scale: gr.LinearScale(
        min: combinationContour.minZ,
        max: combinationContour.maxZ,
      ),
    ),
  },
  marks: [
    gr.PolygonMark(
      position: gr.Varset('x') * gr.Varset('y'),
      shape: gr.ShapeEncode<gr.PolygonShape>(
        value: gr.HeatmapShape(tileCounts: const [25, 20]),
      ),
      color: gr.ColorEncode(
        variable: 'value',
        values: [_heatLight, _heatDark],
        stops: [combinationContour.minZ, combinationContour.maxZ],
      ),
    ),
  ],
  axes: [],
  padding: (_) => EdgeInsets.zero,
);

Widget _graphicContours() => gr.Chart<_SegmentPoint>(
  data: _graphicContourPoints,
  variables: {
    'segment': gr.Variable(accessor: (point) => point.segment),
    'x': gr.Variable(
      accessor: (point) => point.x,
      scale: gr.LinearScale(min: -.5, max: 24.5),
    ),
    'y': gr.Variable(
      accessor: (point) => point.y,
      scale: gr.LinearScale(min: -.5, max: 19.5),
    ),
    'level': gr.Variable(accessor: (point) => point.level),
  },
  marks: [
    gr.LineMark(
      position: gr.Varset('x') * gr.Varset('y') / gr.Varset('segment'),
      color: gr.ColorEncode(value: _contourColor),
      size: gr.SizeEncode(value: 1.4),
    ),
  ],
  axes: [],
  padding: (_) => EdgeInsets.zero,
  tooltip: gr.TooltipGuide(variables: ['level']),
  selections: {
    'point': gr.PointSelection(
      on: {gr.GestureType.hover, gr.GestureType.tap},
      dim: gr.Dim.x,
    ),
  },
);
