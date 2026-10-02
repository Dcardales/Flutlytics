import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/combination_data.dart';
import '../../data/advanced_distribution_data.dart';
import '../../domain/chart_concept.dart';

Widget buildBoxStripCombination(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => _fl(),
  ChartLibrary.syncfusion => _syncfusion(),
  ChartLibrary.graphic => _graphic(),
  ChartLibrary.graphify => throw ArgumentError('Graphify uses options'),
};

class _StripRow {
  const _StripRow(this.x, this.y, this.label);
  final double x, y;
  final String label;
}

final _strip = [
  for (var i = 0; i < boxStripData.length; i++)
    for (final p in boxStripData[i].strip)
      _StripRow(i.toDouble() + p.jitter, p.value, boxStripData[i].group.label),
];

fl.LineChartBarData _line(
  List<fl.FlSpot> spots,
  Color color, {
  double width = 2,
  bool dots = false,
}) => fl.LineChartBarData(
  spots: spots,
  color: color,
  barWidth: width,
  dotData: fl.FlDotData(
    show: dots,
    getDotPainter: (_, _, _, _) =>
        fl.FlDotCirclePainter(radius: 3, color: const Color(0xff2563eb)),
  ),
);

Widget _fl() {
  final lines = <fl.LineChartBarData>[];
  for (var i = 0; i < boxStripData.length; i++) {
    final s = boxStripData[i].stats, x = i.toDouble();
    lines.addAll([
      _line([
        fl.FlSpot(x - .2, s.q1),
        fl.FlSpot(x - .2, s.q3),
        fl.FlSpot(x + .2, s.q3),
        fl.FlSpot(x + .2, s.q1),
        fl.FlSpot(x - .2, s.q1),
      ], const Color(0xff334155)),
      _line(
        [fl.FlSpot(x - .2, s.median), fl.FlSpot(x + .2, s.median)],
        const Color(0xffea580c),
        width: 3,
      ),
      _line([
        fl.FlSpot(x, s.minWhisker),
        fl.FlSpot(x, s.q1),
      ], const Color(0xff334155)),
      _line([
        fl.FlSpot(x, s.q3),
        fl.FlSpot(x, s.maxWhisker),
      ], const Color(0xff334155)),
    ]);
  }
  lines.add(
    _line(
      [for (final p in _strip) fl.FlSpot(p.x, p.y)],
      Colors.transparent,
      width: 0,
      dots: true,
    ),
  );
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 18, 12, 20),
    child: fl.LineChart(
      fl.LineChartData(
        minX: -.5,
        maxX: boxStripData.length - .5,
        minY: 0,
        maxY: 42,
        lineBarsData: lines,
        lineTouchData: fl.LineTouchData(
          touchTooltipData: fl.LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final spot in spots)
                spot.barIndex == lines.length - 1
                    ? fl.LineTooltipItem(
                        '${_strip[spot.spotIndex].label}: '
                        '${_strip[spot.spotIndex].y.toStringAsFixed(1)} min',
                        const TextStyle(color: Colors.white),
                      )
                    : null,
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _syncfusion() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(
    minimum: -.5,
    maximum: 3.5,
    interval: 1,
    title: sf.AxisTitle(text: '0 Bogotá · 1 Medellín · 2 Cartagena · 3 Cali'),
  ),
  primaryYAxis: const sf.NumericAxis(title: sf.AxisTitle(text: 'Minutos')),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  series: <sf.CartesianSeries<dynamic, double>>[
    sf.BoxAndWhiskerSeries<DistributionGroup, double>(
      dataSource: [for (final e in boxStripData) e.group],
      animationDuration: 0,
      xValueMapper: (g, _) =>
          boxStripData.indexWhere((e) => e.group == g).toDouble(),
      yValueMapper: (g, _) => g.values,
      showMean: false,
    ),
    sf.ScatterSeries<_StripRow, double>(
      dataSource: _strip,
      animationDuration: 0,
      xValueMapper: (p, _) => p.x,
      yValueMapper: (p, _) => p.y,
      color: const Color(0xff2563eb),
      markerSettings: const sf.MarkerSettings(width: 5, height: 5),
    ),
  ],
);

class _GraphicRow {
  const _GraphicRow(this.path, this.role, this.x, this.y, this.label);
  final String path, role, label;
  final double x, y;
}

Widget _graphic() {
  final rows = <_GraphicRow>[];
  for (var i = 0; i < boxStripData.length; i++) {
    final s = boxStripData[i].stats,
        x = i.toDouble(),
        label = boxStripData[i].group.label;
    void path(String name, List<(double, double)> points) {
      for (final p in points) {
        rows.add(_GraphicRow('$i-$name', 'box', p.$1, p.$2, label));
      }
    }

    path('box', [
      (x - .2, s.q1),
      (x - .2, s.q3),
      (x + .2, s.q3),
      (x + .2, s.q1),
      (x - .2, s.q1),
    ]);
    path('median', [(x - .2, s.median), (x + .2, s.median)]);
    path('low', [(x, s.minWhisker), (x, s.q1)]);
    path('high', [(x, s.q3), (x, s.maxWhisker)]);
  }
  for (var i = 0; i < _strip.length; i++) {
    final p = _strip[i];
    rows.add(_GraphicRow('point-$i', 'observation', p.x, p.y, p.label));
  }
  return gr.Chart<_GraphicRow>(
    data: rows,
    variables: {
      'path': gr.Variable(accessor: (p) => p.path),
      'role': gr.Variable(accessor: (p) => p.role),
      'x': gr.Variable(
        accessor: (p) => p.x,
        scale: gr.LinearScale(min: -.5, max: boxStripData.length - .5),
      ),
      'y': gr.Variable(
        accessor: (p) => p.y,
        scale: gr.LinearScale(min: 0, max: 42),
      ),
      'label': gr.Variable(accessor: (p) => p.label),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('x') * gr.Varset('y') / gr.Varset('path'),
        color: gr.ColorEncode(value: const Color(0xff334155)),
      ),
      gr.PointMark(
        position: gr.Varset('x') * gr.Varset('y'),
        color: gr.ColorEncode(
          variable: 'role',
          values: [Colors.transparent, const Color(0xff2563eb)],
        ),
        size: gr.SizeEncode(variable: 'role', values: [0, 5]),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'y', 'role']),
    selections: {
      'point': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
  );
}
