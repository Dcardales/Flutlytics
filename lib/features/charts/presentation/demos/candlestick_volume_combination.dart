import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/chart_catalog.dart';
import '../../data/combination_data.dart';
import '../../domain/chart_concept.dart';
import '../chart_renderer.dart';

Widget buildCandlestickVolumeCombination(ChartLibrary library) {
  if (library == ChartLibrary.graphify) {
    throw ArgumentError('Graphify uses options');
  }
  return Column(
    children: [
      const Padding(
        padding: EdgeInsets.only(top: 4),
        child: Text('OHLC ficticio · precio', style: TextStyle(fontSize: 11)),
      ),
      Expanded(
        flex: 3,
        child: ChartRenderer.buildChart(
          concept: ChartCatalog.byId('candlestick'),
          library: library,
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 3),
        child: Text(
          'Volumen por sesión · unidades ficticias',
          style: TextStyle(fontSize: 11),
        ),
      ),
      Expanded(
        flex: 1,
        child: switch (library) {
          ChartLibrary.flChart => _flVolume(),
          ChartLibrary.syncfusion => _syncfusionVolume(),
          ChartLibrary.graphic => _graphicVolume(),
          ChartLibrary.graphify => const SizedBox.shrink(),
        },
      ),
    ],
  );
}

Widget _flVolume() => Padding(
  padding: const EdgeInsets.fromLTRB(24, 0, 12, 8),
  child: fl.BarChart(
    fl.BarChartData(
      minY: 0,
      maxY: 220,
      barGroups: [
        for (var i = 0; i < educationalSessions.length; i++)
          fl.BarChartGroupData(
            x: i,
            barRods: [
              fl.BarChartRodData(
                toY: educationalSessions[i].volume,
                width: 10,
                color:
                    educationalSessions[i].ohlc.close >=
                        educationalSessions[i].ohlc.open
                    ? const Color(0xff0d9488)
                    : const Color(0xffea580c),
              ),
            ],
          ),
      ],
      titlesData: const fl.FlTitlesData(show: false),
    ),
  ),
);

Widget _syncfusionVolume() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(isVisible: false),
  primaryYAxis: const sf.NumericAxis(minimum: 0),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  series: <sf.CartesianSeries<SessionVolume, String>>[
    sf.ColumnSeries<SessionVolume, String>(
      dataSource: educationalSessions,
      xValueMapper: (s, _) => s.period,
      yValueMapper: (s, _) => s.volume,
      animationDuration: 0,
    ),
  ],
);

Widget _graphicVolume() => gr.Chart<SessionVolume>(
  data: educationalSessions,
  variables: {
    'period': gr.Variable(accessor: (s) => s.period),
    'volume': gr.Variable(accessor: (s) => s.volume),
  },
  marks: [
    gr.IntervalMark(
      position: gr.Varset('period') * gr.Varset('volume'),
      color: gr.ColorEncode(value: const Color(0xff0d9488)),
    ),
  ],
  axes: [],
  tooltip: gr.TooltipGuide(variables: ['period', 'volume']),
  selections: {
    'period': gr.PointSelection(
      on: {gr.GestureType.hover, gr.GestureType.tap},
      dim: gr.Dim.x,
    ),
  },
);
