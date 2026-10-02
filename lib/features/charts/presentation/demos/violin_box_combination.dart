import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/combination_data.dart';
import '../../data/advanced_distribution_data.dart';
import '../../domain/chart_concept.dart';

Widget buildViolinBoxCombination(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => _fl(),
  ChartLibrary.syncfusion => _syncfusion(),
  ChartLibrary.graphic => _graphic(),
  ChartLibrary.graphify => throw ArgumentError('Graphify uses options'),
};

fl.LineChartBarData _line(
  List<fl.FlSpot> spots,
  Color color, {
  double width = 2,
}) => fl.LineChartBarData(
  spots: spots,
  color: color,
  barWidth: width,
  dotData: const fl.FlDotData(show: false),
);

Widget _fl() {
  final lines = <fl.LineChartBarData>[], fills = <fl.BetweenBarsData>[];
  for (var i = 0; i < violinGroups.length; i++) {
    final points = violinBoxGeometry.where((p) => p.groupIndex == i).toList();
    final start = lines.length, s = violinBoxStats[i], y = i.toDouble();
    lines.add(
      _line([
        for (final p in points) fl.FlSpot(p.value, y - p.halfWidth),
      ], const Color(0xff2563eb)),
    );
    lines.add(
      _line([
        for (final p in points) fl.FlSpot(p.value, y + p.halfWidth),
      ], const Color(0xff2563eb)),
    );
    fills.add(
      fl.BetweenBarsData(
        fromIndex: start,
        toIndex: start + 1,
        color: const Color(0xff2563eb).withValues(alpha: .28),
      ),
    );
    lines.addAll([
      _line([
        fl.FlSpot(s.q1, y - .1),
        fl.FlSpot(s.q3, y - .1),
        fl.FlSpot(s.q3, y + .1),
        fl.FlSpot(s.q1, y + .1),
        fl.FlSpot(s.q1, y - .1),
      ], const Color(0xff334155)),
      _line(
        [fl.FlSpot(s.median, y - .1), fl.FlSpot(s.median, y + .1)],
        const Color(0xffea580c),
        width: 3,
      ),
      _line([
        fl.FlSpot(s.minWhisker, y),
        fl.FlSpot(s.q1, y),
      ], const Color(0xff334155)),
      _line([
        fl.FlSpot(s.q3, y),
        fl.FlSpot(s.maxWhisker, y),
      ], const Color(0xff334155)),
    ]);
  }
  return Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 10, 22),
    child: fl.LineChart(
      fl.LineChartData(
        minX: violinBoxGeometry.first.value,
        maxX: violinBoxGeometry.last.value,
        minY: -.5,
        maxY: violinGroups.length - .5,
        lineBarsData: lines,
        betweenBarsData: fills,
      ),
    ),
  );
}

class _Band {
  const _Band(this.x, this.low, this.high);
  final double x, low, high;
}

class _Point {
  const _Point(this.x, this.y);
  final double x, y;
}

Widget _syncfusion() {
  final series = <sf.CartesianSeries<dynamic, double>>[];
  for (var i = 0; i < violinGroups.length; i++) {
    final points = [
      for (final p in violinBoxGeometry.where((p) => p.groupIndex == i))
        _Band(p.value, i - p.halfWidth, i + p.halfWidth),
    ];
    final s = violinBoxStats[i], y = i.toDouble();
    series.add(
      sf.RangeAreaSeries<_Band, double>(
        dataSource: points,
        animationDuration: 0,
        xValueMapper: (p, _) => p.x,
        lowValueMapper: (p, _) => p.low,
        highValueMapper: (p, _) => p.high,
        color: const Color(0xff2563eb).withValues(alpha: .25),
        borderColor: const Color(0xff2563eb),
      ),
    );
    for (final path in [
      [
        _Point(s.q1, y - .1),
        _Point(s.q3, y - .1),
        _Point(s.q3, y + .1),
        _Point(s.q1, y + .1),
        _Point(s.q1, y - .1),
      ],
      [_Point(s.median, y - .1), _Point(s.median, y + .1)],
      [_Point(s.minWhisker, y), _Point(s.q1, y)],
      [_Point(s.q3, y), _Point(s.maxWhisker, y)],
    ]) {
      series.add(
        sf.LineSeries<_Point, double>(
          dataSource: path,
          animationDuration: 0,
          xValueMapper: (p, _) => p.x,
          yValueMapper: (p, _) => p.y,
          color: const Color(0xff334155),
        ),
      );
    }
  }
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(title: sf.AxisTitle(text: 'Minutos')),
    primaryYAxis: sf.NumericAxis(
      minimum: -.5,
      maximum: violinGroups.length - .5,
      interval: 1,
      title: const sf.AxisTitle(text: 'Área'),
    ),
    tooltipBehavior: sf.TooltipBehavior(enable: true),
    series: series,
  );
}

class _GraphicPoint {
  const _GraphicPoint(this.path, this.group, this.x, this.y, this.density);
  final String path, group;
  final double x, y, density;
}

Widget _graphic() {
  final rows = <_GraphicPoint>[];
  for (var i = 0; i < violinGroups.length; i++) {
    final group = violinGroups[i].label,
        s = violinBoxStats[i],
        y = i.toDouble();
    for (final p in violinBoxGeometry.where((p) => p.groupIndex == i)) {
      rows.add(
        _GraphicPoint('$i-left', group, p.value, y - p.halfWidth, p.density),
      );
      rows.add(
        _GraphicPoint('$i-right', group, p.value, y + p.halfWidth, p.density),
      );
    }
    void path(String name, List<(double, double)> points) {
      for (final p in points) {
        rows.add(_GraphicPoint('$i-$name', group, p.$1, p.$2, 0));
      }
    }

    path('box', [
      (s.q1, y - .1),
      (s.q3, y - .1),
      (s.q3, y + .1),
      (s.q1, y + .1),
      (s.q1, y - .1),
    ]);
    path('median', [(s.median, y - .1), (s.median, y + .1)]);
    path('low', [(s.minWhisker, y), (s.q1, y)]);
    path('high', [(s.q3, y), (s.maxWhisker, y)]);
  }
  return gr.Chart<_GraphicPoint>(
    data: rows,
    variables: {
      'path': gr.Variable(accessor: (p) => p.path),
      'group': gr.Variable(accessor: (p) => p.group),
      'x': gr.Variable(
        accessor: (p) => p.x,
        scale: gr.LinearScale(
          min: violinBoxGeometry.first.value,
          max: violinBoxGeometry.last.value,
        ),
      ),
      'y': gr.Variable(
        accessor: (p) => p.y,
        scale: gr.LinearScale(min: -.5, max: violinGroups.length - .5),
      ),
      'density': gr.Variable(accessor: (p) => p.density),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('x') * gr.Varset('y') / gr.Varset('path'),
        color: gr.ColorEncode(value: const Color(0xff2563eb)),
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
  );
}
