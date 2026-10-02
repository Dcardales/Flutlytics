import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/combination_data.dart';
import '../../domain/chart_concept.dart';

class _BinPoint {
  const _BinPoint(
    this.index,
    this.label,
    this.frequency,
    this.densityFrequency,
  );
  final int index;
  final String label;
  final double frequency, densityFrequency;
}

final _points = [
  for (var i = 0; i < combinationHistogramBins.length; i++)
    _BinPoint(
      i,
      combinationHistogramBins[i].label,
      combinationHistogramBins[i].frequency.toDouble(),
      combinationDensityAsFrequency
          .reduce(
            (a, b) =>
                (a.x - combinationHistogramBins[i].midpoint).abs() <
                    (b.x - combinationHistogramBins[i].midpoint).abs()
                ? a
                : b,
          )
          .y,
    ),
];
final _maxY =
    math.max(
      _points.map((p) => p.frequency).reduce(math.max),
      _points.map((p) => p.densityFrequency).reduce(math.max),
    ) *
    1.2;

Widget buildHistogramDensityCombination(ChartLibrary library) =>
    switch (library) {
      ChartLibrary.flChart => _fl(),
      ChartLibrary.syncfusion => _syncfusion(),
      ChartLibrary.graphic => _graphic(),
      ChartLibrary.graphify => throw ArgumentError('Graphify uses options'),
    };

Widget _fl() => Padding(
  padding: const EdgeInsets.fromLTRB(28, 18, 12, 24),
  child: fl.LineChart(
    fl.LineChartData(
      minX: -.5,
      maxX: _points.length - .5,
      minY: 0,
      maxY: _maxY,
      lineBarsData: [
        for (final p in _points)
          fl.LineChartBarData(
            spots: [
              fl.FlSpot(p.index.toDouble(), 0),
              fl.FlSpot(p.index.toDouble(), p.frequency),
            ],
            color: const Color(0xff2563eb).withValues(alpha: .65),
            barWidth: 24,
            dotData: const fl.FlDotData(show: false),
          ),
        fl.LineChartBarData(
          spots: [
            for (final p in _points)
              fl.FlSpot(p.index.toDouble(), p.densityFrequency),
          ],
          color: const Color(0xffea580c),
          barWidth: 3,
          dotData: const fl.FlDotData(show: false),
        ),
      ],
    ),
  ),
);

Widget _syncfusion() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(
    title: sf.AxisTitle(text: 'Minutos por bin'),
  ),
  primaryYAxis: const sf.NumericAxis(
    title: sf.AxisTitle(text: 'Frecuencia'),
    minimum: 0,
  ),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  series: <sf.CartesianSeries<_BinPoint, String>>[
    sf.ColumnSeries<_BinPoint, String>(
      dataSource: _points,
      animationDuration: 0,
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => p.frequency,
      color: const Color(0xff2563eb),
    ),
    sf.SplineSeries<_BinPoint, String>(
      dataSource: _points,
      animationDuration: 0,
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => p.densityFrequency,
      color: const Color(0xffea580c),
    ),
  ],
);

Widget _graphic() => gr.Chart<_BinPoint>(
  data: _points,
  variables: {
    'bin': gr.Variable(accessor: (p) => p.label),
    'frequency': gr.Variable(
      accessor: (p) => p.frequency,
      scale: gr.LinearScale(min: 0, max: _maxY),
    ),
    'density': gr.Variable(
      accessor: (p) => p.densityFrequency,
      scale: gr.LinearScale(min: 0, max: _maxY),
    ),
  },
  marks: [
    gr.IntervalMark(
      position: gr.Varset('bin') * gr.Varset('frequency'),
      color: gr.ColorEncode(value: const Color(0xff2563eb)),
    ),
    gr.LineMark(
      position: gr.Varset('bin') * gr.Varset('density'),
      color: gr.ColorEncode(value: const Color(0xffea580c)),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  tooltip: gr.TooltipGuide(variables: ['bin', 'frequency', 'density']),
  selections: {
    'bin': gr.PointSelection(
      on: {gr.GestureType.hover, gr.GestureType.tap},
      dim: gr.Dim.x,
    ),
  },
);
