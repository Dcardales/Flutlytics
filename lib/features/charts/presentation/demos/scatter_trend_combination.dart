import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/combination_data.dart';
import '../../data/relationships_intervals_data.dart';
import '../../domain/chart_concept.dart';

final _observations = List<ScatterObservation>.unmodifiable(
  List<ScatterObservation>.of(scatterObservations)
    ..sort((a, b) => a.nights.compareTo(b.nights)),
);

Widget buildScatterTrendCombination(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => _fl(),
  ChartLibrary.syncfusion => _syncfusion(),
  ChartLibrary.graphic => _graphic(),
  ChartLibrary.graphify => throw ArgumentError('Graphify uses options'),
};

Widget _fl() => Padding(
  padding: const EdgeInsets.fromLTRB(26, 20, 10, 16),
  child: fl.LineChart(
    fl.LineChartData(
      minX: 0,
      maxX: 8,
      minY: 0,
      maxY: 6000,
      lineBarsData: [
        fl.LineChartBarData(
          spots: [
            for (final p in _observations)
              fl.FlSpot(p.nights, p.spendThousands),
          ],
          color: Colors.transparent,
          barWidth: 0,
          dotData: fl.FlDotData(
            show: true,
            getDotPainter: (_, _, _, _) => fl.FlDotCirclePainter(
              radius: 4,
              color: const Color(0xff2563eb),
            ),
          ),
        ),
        fl.LineChartBarData(
          spots: [
            for (final p in [_observations.first, _observations.last])
              fl.FlSpot(p.nights, scatterTrendFit.at(p.nights)),
          ],
          color: const Color(0xffea580c),
          barWidth: 3,
          dotData: const fl.FlDotData(show: false),
        ),
      ],
      lineTouchData: fl.LineTouchData(
        touchTooltipData: fl.LineTouchTooltipData(
          getTooltipItems: (spots) => [
            for (final spot in spots)
              spot.barIndex == 0
                  ? fl.LineTooltipItem(
                      '${_observations[spot.spotIndex].label}: '
                      '${_observations[spot.spotIndex].nights} noches, '
                      '${_observations[spot.spotIndex].spendThousands.toStringAsFixed(0)} mil COP',
                      const TextStyle(color: Colors.white),
                    )
                  : null,
          ],
        ),
      ),
    ),
  ),
);

Widget _syncfusion() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(title: sf.AxisTitle(text: 'Noches')),
  primaryYAxis: const sf.NumericAxis(
    title: sf.AxisTitle(text: 'Gasto (mil COP)'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      if (data is! ScatterObservation) return const SizedBox.shrink();
      return Text(
        '${data.label}: ${data.nights} noches, ${data.spendThousands.toStringAsFixed(0)} mil COP',
        style: const TextStyle(color: Colors.white),
      );
    },
  ),
  series: <sf.CartesianSeries<ScatterObservation, double>>[
    sf.ScatterSeries<ScatterObservation, double>(
      dataSource: _observations,
      animationDuration: 0,
      xValueMapper: (p, _) => p.nights,
      yValueMapper: (p, _) => p.spendThousands,
      markerSettings: const sf.MarkerSettings(width: 9, height: 9),
    ),
    sf.LineSeries<ScatterObservation, double>(
      dataSource: [_observations.first, _observations.last],
      animationDuration: 0,
      xValueMapper: (p, _) => p.nights,
      yValueMapper: (p, _) => scatterTrendFit.at(p.nights),
      color: const Color(0xffea580c),
    ),
  ],
);

Widget _graphic() => gr.Chart<ScatterObservation>(
  data: _observations,
  variables: {
    'label': gr.Variable(accessor: (p) => p.label),
    'x': gr.Variable(
      accessor: (p) => p.nights,
      scale: gr.LinearScale(min: 0, max: 8),
    ),
    'observed': gr.Variable(
      accessor: (p) => p.spendThousands,
      scale: gr.LinearScale(min: 0, max: 6000),
    ),
    'trend': gr.Variable(
      accessor: (p) => scatterTrendFit.at(p.nights),
      scale: gr.LinearScale(min: 0, max: 6000),
    ),
  },
  marks: [
    gr.PointMark(
      position: gr.Varset('x') * gr.Varset('observed'),
      color: gr.ColorEncode(value: const Color(0xff2563eb)),
      size: gr.SizeEncode(value: 7),
    ),
    gr.LineMark(
      position: gr.Varset('x') * gr.Varset('trend'),
      color: gr.ColorEncode(value: const Color(0xffea580c)),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  selections: {
    'point': gr.PointSelection(
      on: {gr.GestureType.hover, gr.GestureType.tap},
      dim: gr.Dim.x,
    ),
  },
  tooltip: gr.TooltipGuide(variables: ['label', 'x', 'observed']),
);
