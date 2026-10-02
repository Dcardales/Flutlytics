import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/combination_data.dart';
import '../../data/relationships_intervals_data.dart';
import '../../domain/chart_concept.dart';

Widget buildBarErrorCombination(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => _fl(),
  ChartLibrary.syncfusion => _syncfusion(),
  ChartLibrary.graphic => _graphic(),
  ChartLibrary.graphify => throw ArgumentError('Graphify uses options'),
};

fl.LineChartBarData _line(List<fl.FlSpot> spots, Color color, double width) =>
    fl.LineChartBarData(
      spots: spots,
      color: color,
      barWidth: width,
      dotData: const fl.FlDotData(show: false),
    );

Widget _fl() {
  final lines = <fl.LineChartBarData>[];
  for (var i = 0; i < combinationErrorEstimates.length; i++) {
    final e = combinationErrorEstimates[i], x = i.toDouble();
    lines.addAll([
      _line(
        [fl.FlSpot(x, 0), fl.FlSpot(x, e.estimate)],
        const Color(0xff2563eb),
        28,
      ),
      _line(
        [fl.FlSpot(x, e.lower), fl.FlSpot(x, e.upper)],
        const Color(0xffea580c),
        2,
      ),
      _line(
        [fl.FlSpot(x - .12, e.lower), fl.FlSpot(x + .12, e.lower)],
        const Color(0xffea580c),
        2,
      ),
      _line(
        [fl.FlSpot(x - .12, e.upper), fl.FlSpot(x + .12, e.upper)],
        const Color(0xffea580c),
        2,
      ),
    ]);
  }
  return Padding(
    padding: const EdgeInsets.fromLTRB(28, 18, 10, 18),
    child: fl.LineChart(
      fl.LineChartData(
        minX: -.5,
        maxX: combinationErrorEstimates.length - .5,
        minY: 0,
        lineBarsData: lines,
        lineTouchData: fl.LineTouchData(
          touchTooltipData: fl.LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final s in spots)
                () {
                  final e =
                      combinationErrorEstimates[s.x.round().clamp(
                        0,
                        combinationErrorEstimates.length - 1,
                      )];
                  return fl.LineTooltipItem(
                    '${e.label}: media ${e.estimate.toStringAsFixed(2)}; '
                    'IC 95 % [${e.lower.toStringAsFixed(2)}, ${e.upper.toStringAsFixed(2)}]',
                    const TextStyle(color: Colors.white),
                  );
                }(),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _syncfusion() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(
    title: sf.AxisTitle(text: 'Servicio'),
    labelRotation: -30,
  ),
  primaryYAxis: const sf.NumericAxis(
    title: sf.AxisTitle(text: 'Minutos'),
    minimum: 0,
  ),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  series: <sf.CartesianSeries<IntervalEstimate, String>>[
    sf.ColumnSeries<IntervalEstimate, String>(
      name: 'Media',
      dataSource: combinationErrorEstimates,
      xValueMapper: (e, _) => e.label,
      yValueMapper: (e, _) => e.estimate,
      color: const Color(0xff2563eb),
      animationDuration: 0,
    ),
    for (final e in combinationErrorEstimates)
      sf.ErrorBarSeries<IntervalEstimate, String>(
        name: 'IC 95 %',
        dataSource: [e],
        xValueMapper: (p, _) => p.label,
        yValueMapper: (p, _) => p.estimate,
        type: sf.ErrorBarType.custom,
        verticalPositiveErrorValue: e.upper - e.estimate,
        verticalNegativeErrorValue: e.estimate - e.lower,
        capLength: 10,
        animationDuration: 0,
      ),
  ],
);

class _ErrorRow {
  const _ErrorRow(this.group, this.x, this.y, this.mean, this.role);
  final String group, role;
  final double x, y, mean;
}

Widget _graphic() {
  final rows = <_ErrorRow>[];
  for (var i = 0; i < combinationErrorEstimates.length; i++) {
    final e = combinationErrorEstimates[i], x = i.toDouble();
    rows.addAll([
      _ErrorRow('${e.label}-bar', x, 0, e.estimate, 'bar'),
      _ErrorRow('${e.label}-bar', x, e.estimate, e.estimate, 'bar'),
      _ErrorRow('${e.label}-ci', x, e.lower, e.estimate, 'ci'),
      _ErrorRow('${e.label}-ci', x, e.upper, e.estimate, 'ci'),
    ]);
  }
  return gr.Chart<_ErrorRow>(
    data: rows,
    variables: {
      'group': gr.Variable(accessor: (r) => r.group),
      'x': gr.Variable(
        accessor: (r) => r.x,
        scale: gr.LinearScale(
          min: -.5,
          max: combinationErrorEstimates.length - .5,
        ),
      ),
      'y': gr.Variable(accessor: (r) => r.y, scale: gr.LinearScale(min: 0)),
      'mean': gr.Variable(accessor: (r) => r.mean),
      'role': gr.Variable(accessor: (r) => r.role),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('x') * gr.Varset('y') / gr.Varset('group'),
        color: gr.ColorEncode(
          variable: 'role',
          values: [const Color(0xff2563eb), const Color(0xffea580c)],
        ),
        size: gr.SizeEncode(variable: 'role', values: [12, 2]),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['group', 'mean', 'y']),
    selections: {
      'x': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
  );
}
