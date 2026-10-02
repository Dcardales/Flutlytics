import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/combination_data.dart';
import '../../domain/chart_concept.dart';

const _channelNames = ['Directo', 'Agencias', 'En línea'];
const _channelColors = [
  Color(0xff2563eb),
  Color(0xff0d9488),
  Color(0xff7c3aed),
];

class _ChannelRow {
  const _ChannelRow(this.period, this.channel, this.sales, this.marginPercent);
  final String period, channel;
  final double sales, marginPercent;
}

final _rows = [
  for (final s in channelSales) ...[
    _ChannelRow(s.period, _channelNames[0], s.direct, s.marginPercent),
    _ChannelRow(s.period, _channelNames[1], s.agency, s.marginPercent),
    _ChannelRow(s.period, _channelNames[2], s.online, s.marginPercent),
  ],
];

Widget buildStackedColumnLineCombination(ChartLibrary library) =>
    switch (library) {
      ChartLibrary.flChart => _fl(),
      ChartLibrary.syncfusion => _syncfusion(),
      ChartLibrary.graphic => _graphic(),
      _ => throw ArgumentError('Use separate renderer for $library'),
    };

Widget _fl() => Column(
  children: [
    const Text(
      'Ventas · millones COP     Margen % reescalado: 100 % = 60 millones',
      style: TextStyle(fontSize: 11),
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 14, 10, 14),
        child: fl.LineChart(
          fl.LineChartData(
            minX: -.5,
            maxX: channelSales.length - .5,
            minY: 0,
            maxY: 60,
            lineBarsData: [
              for (var i = 0; i < channelSales.length; i++) ...[
                fl.LineChartBarData(
                  spots: [
                    fl.FlSpot(i.toDouble(), 0),
                    fl.FlSpot(i.toDouble(), channelSales[i].direct),
                  ],
                  color: _channelColors[0],
                  barWidth: 24,
                  dotData: const fl.FlDotData(show: false),
                ),
                fl.LineChartBarData(
                  spots: [
                    fl.FlSpot(i.toDouble(), channelSales[i].direct),
                    fl.FlSpot(
                      i.toDouble(),
                      channelSales[i].direct + channelSales[i].agency,
                    ),
                  ],
                  color: _channelColors[1],
                  barWidth: 24,
                  dotData: const fl.FlDotData(show: false),
                ),
                fl.LineChartBarData(
                  spots: [
                    fl.FlSpot(
                      i.toDouble(),
                      channelSales[i].direct + channelSales[i].agency,
                    ),
                    fl.FlSpot(i.toDouble(), channelSales[i].total),
                  ],
                  color: _channelColors[2],
                  barWidth: 24,
                  dotData: const fl.FlDotData(show: false),
                ),
              ],
              fl.LineChartBarData(
                spots: [
                  for (var i = 0; i < channelSales.length; i++)
                    fl.FlSpot(i.toDouble(), channelSales[i].marginPercent * .6),
                ],
                color: const Color(0xffea580c),
                barWidth: 3,
                dotData: const fl.FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
);

Widget _syncfusion() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(
    title: sf.AxisTitle(text: 'Ventas · millones COP'),
    minimum: 0,
  ),
  axes: const <sf.ChartAxis>[
    sf.NumericAxis(
      name: 'margin',
      opposedPosition: true,
      minimum: 0,
      maximum: 100,
      title: sf.AxisTitle(text: 'Margen %'),
    ),
  ],
  legend: const sf.Legend(isVisible: true, position: sf.LegendPosition.bottom),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  series: <sf.CartesianSeries<ChannelSales, String>>[
    sf.StackedColumnSeries<ChannelSales, String>(
      name: 'Directo',
      dataSource: channelSales,
      xValueMapper: (s, _) => s.period,
      yValueMapper: (s, _) => s.direct,
      color: _channelColors[0],
      animationDuration: 0,
    ),
    sf.StackedColumnSeries<ChannelSales, String>(
      name: 'Agencias',
      dataSource: channelSales,
      xValueMapper: (s, _) => s.period,
      yValueMapper: (s, _) => s.agency,
      color: _channelColors[1],
      animationDuration: 0,
    ),
    sf.StackedColumnSeries<ChannelSales, String>(
      name: 'En línea',
      dataSource: channelSales,
      xValueMapper: (s, _) => s.period,
      yValueMapper: (s, _) => s.online,
      color: _channelColors[2],
      animationDuration: 0,
    ),
    sf.LineSeries<ChannelSales, String>(
      name: 'Margen %',
      dataSource: channelSales,
      xValueMapper: (s, _) => s.period,
      yValueMapper: (s, _) => s.marginPercent,
      yAxisName: 'margin',
      color: const Color(0xffea580c),
      animationDuration: 0,
    ),
  ],
);

Widget _graphic() => Column(
  children: [
    const Text(
      'Ventas · millones COP     Margen % reescalado: 100 % = 60 millones',
      style: TextStyle(fontSize: 11),
    ),
    Expanded(
      child: gr.Chart<_ChannelRow>(
        data: _rows,
        variables: {
          'period': gr.Variable(accessor: (r) => r.period),
          'channel': gr.Variable(accessor: (r) => r.channel),
          'sales': gr.Variable(
            accessor: (r) => r.sales,
            scale: gr.LinearScale(min: 0, max: 60),
          ),
          'marginPlot': gr.Variable(
            accessor: (r) => r.marginPercent * .6,
            scale: gr.LinearScale(min: 0, max: 60),
          ),
          'marginPercent': gr.Variable(accessor: (r) => r.marginPercent),
        },
        marks: [
          gr.IntervalMark(
            position: gr.Varset('period') * gr.Varset('sales'),
            color: gr.ColorEncode(variable: 'channel', values: _channelColors),
            modifiers: [gr.StackModifier()],
          ),
          gr.LineMark(
            position: gr.Varset('period') * gr.Varset('marginPlot'),
            color: gr.ColorEncode(value: const Color(0xffea580c)),
          ),
        ],
        axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
        tooltip: gr.TooltipGuide(
          variables: ['period', 'sales', 'marginPercent'],
        ),
        selections: {
          'period': gr.PointSelection(
            on: {gr.GestureType.hover, gr.GestureType.tap},
            dim: gr.Dim.x,
          ),
        },
      ),
    ),
  ],
);
