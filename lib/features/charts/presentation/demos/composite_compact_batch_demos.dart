import 'dart:convert';

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:graphify/graphify.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart' as sf_spark;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/composite_compact_data.dart';
import '../../domain/chart_concept.dart';
import 'demo_registration.dart';

const _blue = Color(0xff1565c0);
const _orange = Color(0xffef6c00);
const _green = Color(0xff2e7d32);
const _purple = Color(0xff7b1fa2);
const _panelColors = [_blue, _orange, _green, _purple];
const _ids = [
  'bar-line',
  'area-line',
  'small-multiples-line',
  'small-multiples-bar',
  'sparkline',
];

class CompositeCompactBatchDemos {
  CompositeCompactBatchDemos._();
  static const newConcepts = _ids;
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in newConcepts)
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => CompositeCompactChart(id: id, library: library),
        ),
  ]);
}

class CompositeCompactChart extends StatelessWidget {
  const CompositeCompactChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) {
    validateBatchFiveData();
    if (library == ChartLibrary.graphify) {
      return GraphifyCompositeCompactChart(id: id);
    }
    if (id == 'sparkline') return _sparkCards(library);
    if (id == 'small-multiples-line' || id == 'small-multiples-bar') {
      return _smallMultiples(id, library);
    }
    return _composite(id, library);
  }
}

Widget _composite(String id, ChartLibrary library) => Column(
  children: [
    _keyLegend(id, library),
    Expanded(
      child: switch (library) {
        ChartLibrary.flChart => id == 'bar-line' ? _flBarLine() : _flAreaLine(),
        ChartLibrary.syncfusion =>
          id == 'bar-line' ? _sfBarLine() : _sfAreaLine(),
        ChartLibrary.graphic =>
          id == 'bar-line' ? _graphicBarLine() : _graphicAreaLine(),
        ChartLibrary.graphify => _GraphifyView(
          options: graphifyCompositeCompactOptions(id),
        ),
      },
    ),
  ],
);

Widget _keyLegend(String id, ChartLibrary library) => Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisSize: MainAxisSize.min,
  children: id == 'bar-line' && library == ChartLibrary.graphic
      ? [
          _legend(Icons.bar_chart, _blue, 'Ventas · $barLineBarUnit'),
          _legend(
            Icons.show_chart,
            _orange,
            'Margen · $barLineUnit · porcentaje reescalado para superponer',
          ),
        ]
      : id == 'bar-line'
      ? [
          _legend(
            Icons.bar_chart,
            _blue,
            'Ventas · $barLineBarUnit · eje izquierdo',
          ),
          _legend(
            Icons.show_chart,
            _orange,
            'Margen · $barLineUnit · eje derecho (0–100 %)',
          ),
        ]
      : [
          _legend(Icons.area_chart, _blue, 'Consumo real · $areaLineUnit'),
          _legend(Icons.show_chart, _orange, 'Meta diaria · $areaLineUnit'),
        ],
);

Widget _legend(IconData icon, Color color, String text) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 3),
    Flexible(child: Text(text, style: const TextStyle(fontSize: 10))),
  ],
);

Widget _flBarLine() {
  final points = barLinePeriods;
  return Padding(
    padding: const EdgeInsets.fromLTRB(25, 4, 22, 4),
    child: _FlBarLineOverlay(points: points),
  );
}

class _FlBarLineOverlay extends StatelessWidget {
  const _FlBarLineOverlay({required this.points});
  final List<BarLinePoint> points;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final width = size.maxWidth;
      return Stack(
        children: [
          fl.BarChart(
            fl.BarChartData(
              minY: 0,
              maxY: 60,
              barGroups: [
                for (final p in points)
                  fl.BarChartGroupData(
                    x: p.period,
                    barRods: [
                      fl.BarChartRodData(
                        toY: p.barValue,
                        color: _blue,
                        width: width / 15,
                      ),
                    ],
                  ),
              ],
              titlesData: _flPeriodTitles(
                points.map((p) => (p.period, p.label)).toList(),
                left: true,
                right: true,
              ),
              gridData: const fl.FlGridData(show: true),
              borderData: fl.FlBorderData(show: true),
              barTouchData: fl.BarTouchData(
                touchTooltipData: fl.BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, _) => fl.BarTooltipItem(
                    '${points[group.x - 1].label}\nVentas: ${rod.toY} $barLineBarUnit',
                    const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
          fl.LineChart(
            fl.LineChartData(
              minX: 1,
              maxX: 6,
              minY: 0,
              maxY: 60,
              titlesData: _flPeriodTitles(
                points.map((p) => (p.period, p.label)).toList(),
                right: true,
                bottom: false,
              ),
              gridData: const fl.FlGridData(show: false),
              borderData: fl.FlBorderData(show: false),
              lineTouchData: fl.LineTouchData(
                enabled: true,
                touchTooltipData: fl.LineTouchTooltipData(
                  getTooltipItems: (spots) => [
                    for (final s in spots)
                      fl.LineTooltipItem(
                        '${points[s.x.toInt() - 1].label}\nMargen: ${points[s.x.toInt() - 1].lineValue}% · $barLineUnit',
                        const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                  ],
                ),
              ),
              lineBarsData: [
                fl.LineChartBarData(
                  spots: [
                    for (final p in points)
                      fl.FlSpot(p.period.toDouble(), p.lineValue * .6),
                  ],
                  color: _orange,
                  barWidth: 3,
                  dotData: const fl.FlDotData(show: true),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

fl.FlTitlesData _flPeriodTitles(
  List<(int, String)> periods, {
  bool left = false,
  bool right = false,
  bool bottom = true,
}) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  leftTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: left,
      reservedSize: 30,
      getTitlesWidget: (v, _) =>
          Text('${v.toInt()}', style: const TextStyle(fontSize: 8)),
    ),
  ),
  rightTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: right,
      reservedSize: 30,
      getTitlesWidget: (v, _) =>
          Text('${(v / .6).round()}%', style: const TextStyle(fontSize: 8)),
    ),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: bottom,
      reservedSize: 24,
      getTitlesWidget: (v, _) {
        final p = periods.where((p) => p.$1 == v.toInt()).firstOrNull;
        return p == null
            ? const SizedBox.shrink()
            : Text(p.$2, style: const TextStyle(fontSize: 8));
      },
    ),
  ),
);

Widget _flAreaLine() => fl.LineChart(
  fl.LineChartData(
    minX: 1,
    maxX: 6,
    minY: 0,
    maxY: 650,
    titlesData: _flPeriodTitles(
      areaLinePeriods.map((p) => (p.period, p.label)).toList(),
    ),
    lineTouchData: fl.LineTouchData(
      touchTooltipData: fl.LineTouchTooltipData(
        getTooltipItems: (spots) => [
          for (final spot in spots)
            fl.LineTooltipItem(
              '${areaLinePeriods[spot.x.toInt() - 1].label}\n${spot.barIndex == 0 ? 'Real' : 'Meta'}: ${spot.y.round()} $areaLineUnit',
              const TextStyle(color: Colors.white, fontSize: 10),
            ),
        ],
      ),
    ),
    lineBarsData: [
      fl.LineChartBarData(
        spots: [
          for (final p in areaLinePeriods)
            fl.FlSpot(p.period.toDouble(), p.areaValue),
        ],
        color: _blue,
        barWidth: 2,
        dotData: const fl.FlDotData(show: true),
        belowBarData: fl.BarAreaData(
          show: true,
          color: _blue.withValues(alpha: .24),
          applyCutOffY: true,
          cutOffY: 0,
        ),
      ),
      fl.LineChartBarData(
        spots: [
          for (final p in areaLinePeriods)
            fl.FlSpot(p.period.toDouble(), p.lineValue),
        ],
        color: _orange,
        barWidth: 3,
        dotData: const fl.FlDotData(show: true),
      ),
    ],
  ),
);

Widget _sfBarLine() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 60,
    title: sf.AxisTitle(text: barLineBarUnit),
  ),
  axes: const <sf.ChartAxis>[
    sf.NumericAxis(
      name: 'marginAxis',
      minimum: 0,
      maximum: 100,
      opposedPosition: true,
      title: sf.AxisTitle(text: barLineUnit),
    ),
  ],
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  series: <sf.CartesianSeries<BarLinePoint, String>>[
    sf.ColumnSeries<BarLinePoint, String>(
      name: 'Ventas · $barLineBarUnit',
      dataSource: barLinePeriods,
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => p.barValue,
      animationDuration: 0,
    ),
    sf.LineSeries<BarLinePoint, String>(
      name: 'Margen · $barLineUnit',
      dataSource: barLinePeriods,
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => p.lineValue,
      yAxisName: 'marginAxis',
      color: _orange,
      markerSettings: const sf.MarkerSettings(isVisible: true),
      animationDuration: 0,
    ),
  ],
);

Widget _sfAreaLine() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 650,
    title: sf.AxisTitle(text: areaLineUnit),
  ),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  series: <sf.CartesianSeries<AreaLinePoint, String>>[
    sf.AreaSeries<AreaLinePoint, String>(
      name: 'Real · $areaLineUnit',
      dataSource: areaLinePeriods,
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => p.areaValue,
      color: _blue.withValues(alpha: .28),
      borderColor: _blue,
      animationDuration: 0,
    ),
    sf.LineSeries<AreaLinePoint, String>(
      name: 'Meta · $areaLineUnit',
      dataSource: areaLinePeriods,
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => p.lineValue,
      color: _orange,
      markerSettings: const sf.MarkerSettings(isVisible: true),
      animationDuration: 0,
    ),
  ],
);

Widget _graphicBarLine() => gr.Chart<BarLinePoint>(
  data: barLinePeriods,
  variables: {
    'period': gr.Variable(accessor: (BarLinePoint p) => p.label),
    'barValue': gr.Variable(
      accessor: (BarLinePoint p) => p.barValue,
      scale: gr.LinearScale(min: 0, max: 60),
    ),
    'linePlot': gr.Variable(
      accessor: (BarLinePoint p) => p.lineValue * .6,
      scale: gr.LinearScale(min: 0, max: 60),
    ),
    'margin': gr.Variable(accessor: (BarLinePoint p) => p.lineValue),
  },
  marks: [
    gr.IntervalMark(
      position: gr.Varset('period') * gr.Varset('barValue'),
      color: gr.ColorEncode(value: _blue),
    ),
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('linePlot'),
      color: gr.ColorEncode(value: _orange),
    ),
    gr.PointMark(
      position: gr.Varset('period') * gr.Varset('linePlot'),
      color: gr.ColorEncode(value: _orange),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  selections: {
    'period': gr.PointSelection(
      on: {gr.GestureType.hover, gr.GestureType.tap},
      dim: gr.Dim.x,
    ),
  },
  tooltip: gr.TooltipGuide(variables: ['period', 'barValue', 'margin']),
);

Widget _graphicAreaLine() => gr.Chart<AreaLinePoint>(
  data: areaLinePeriods,
  variables: {
    'period': gr.Variable(accessor: (AreaLinePoint p) => p.label),
    'real': gr.Variable(
      accessor: (AreaLinePoint p) => p.areaValue,
      scale: gr.LinearScale(min: 0, max: 650),
    ),
    'target': gr.Variable(
      accessor: (AreaLinePoint p) => p.lineValue,
      scale: gr.LinearScale(min: 0, max: 650),
    ),
  },
  marks: [
    gr.AreaMark(
      position: gr.Varset('period') * gr.Varset('real'),
      color: gr.ColorEncode(value: _blue.withValues(alpha: .3)),
    ),
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('target'),
      color: gr.ColorEncode(value: _orange),
    ),
    gr.PointMark(
      position: gr.Varset('period') * gr.Varset('target'),
      color: gr.ColorEncode(value: _orange),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  selections: {
    'period': gr.PointSelection(
      on: {gr.GestureType.hover, gr.GestureType.tap},
      dim: gr.Dim.x,
    ),
  },
  tooltip: gr.TooltipGuide(variables: ['period', 'real', 'target']),
);

Widget _smallMultiples(String id, ChartLibrary library) => LayoutBuilder(
  builder: (context, box) {
    final columns = box.maxWidth >= 420 ? 2 : 1;
    final gap = 8.0;
    final tileWidth = (box.maxWidth - gap * (columns - 1)) / columns;
    final line = id == 'small-multiples-line';
    final panels = line ? smallMultiplesLinePanels : smallMultiplesBarPanels;
    final globalMax = line
        ? 100.0
        : maxAcrossPanels(smallMultiplesBarPanels, (p) => p.value);
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Wrap(
        spacing: gap,
        runSpacing: 3,
        children: [
          for (var i = 0; i < panels.length; i++)
            SizedBox(
              width: tileWidth,
              height: 112,
              child: Column(
                children: [
                  Text(
                    panels[i].label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(child: _smallChart(line, i, library, globalMax)),
                ],
              ),
            ),
        ],
      ),
    );
  },
);

Widget _smallChart(
  bool line,
  int index,
  ChartLibrary library,
  double globalMax,
) {
  final color = _panelColors[index % _panelColors.length];
  if (library == ChartLibrary.flChart) {
    if (line) {
      final p = smallMultiplesLinePanels[index].points;
      return fl.LineChart(
        fl.LineChartData(
          minX: 1,
          maxX: 6,
          minY: 0,
          maxY: globalMax,
          titlesData: _miniFlTitles(p.map((x) => (x.period, x.label)).toList()),
          lineBarsData: [
            fl.LineChartBarData(
              spots: [
                for (final v in p) fl.FlSpot(v.period.toDouble(), v.value),
              ],
              color: color,
              barWidth: 2,
              dotData: const fl.FlDotData(show: false),
            ),
          ],
          lineTouchData: fl.LineTouchData(
            touchTooltipData: fl.LineTouchTooltipData(
              getTooltipItems: (spots) => [
                for (final s in spots)
                  fl.LineTooltipItem(
                    '${p[s.x.toInt() - 1].label}: ${s.y}% ocupación',
                    const TextStyle(color: Colors.white, fontSize: 9),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    final p = smallMultiplesBarPanels[index].points;
    return fl.BarChart(
      fl.BarChartData(
        minY: 0,
        maxY: globalMax,
        barGroups: [
          for (var i = 0; i < p.length; i++)
            fl.BarChartGroupData(
              x: i,
              barRods: [
                fl.BarChartRodData(toY: p[i].value, color: color, width: 15),
              ],
            ),
        ],
        titlesData: _miniBarTitles(p.map((x) => x.category).toList()),
        barTouchData: fl.BarTouchData(
          touchTooltipData: fl.BarTouchTooltipData(
            getTooltipItem: (g, _, rod, _) => fl.BarTooltipItem(
              '${p[g.x].category}: ${rod.toY} $smallMultiplesBarUnit',
              const TextStyle(color: Colors.white, fontSize: 9),
            ),
          ),
        ),
      ),
    );
  }
  if (library == ChartLibrary.syncfusion) {
    if (line) {
      final p = smallMultiplesLinePanels[index].points;
      return sf.SfCartesianChart(
        margin: EdgeInsets.zero,
        primaryXAxis: sf.NumericAxis(
          minimum: 1,
          maximum: 6,
          interval: 2,
          axisLabelFormatter: (details) {
            final point = p
                .where((v) => v.period == details.value.toInt())
                .firstOrNull;
            return sf.ChartAxisLabel(point?.label ?? '', details.textStyle);
          },
        ),
        primaryYAxis: const sf.NumericAxis(
          minimum: 0,
          maximum: 100,
          isVisible: false,
        ),
        tooltipBehavior: sf.TooltipBehavior(enable: true),
        series: <sf.CartesianSeries<SmallLinePoint, int>>[
          sf.LineSeries<SmallLinePoint, int>(
            dataSource: p,
            xValueMapper: (v, _) => v.period,
            yValueMapper: (v, _) => v.value,
            color: color,
            markerSettings: const sf.MarkerSettings(
              isVisible: true,
              height: 4,
              width: 4,
            ),
            animationDuration: 0,
          ),
        ],
      );
    }
    final p = smallMultiplesBarPanels[index].points;
    return sf.SfCartesianChart(
      margin: EdgeInsets.zero,
      primaryXAxis: const sf.CategoryAxis(labelStyle: TextStyle(fontSize: 7)),
      primaryYAxis: sf.NumericAxis(
        minimum: 0,
        maximum: globalMax,
        isVisible: false,
      ),
      tooltipBehavior: sf.TooltipBehavior(enable: true),
      series: <sf.CartesianSeries<SmallBarPoint, String>>[
        sf.ColumnSeries<SmallBarPoint, String>(
          dataSource: p,
          xValueMapper: (v, _) => v.category,
          yValueMapper: (v, _) => v.value,
          color: color,
          animationDuration: 0,
        ),
      ],
    );
  }
  if (library == ChartLibrary.graphify) {
    final options = graphifyCompositeCompactOptions(
      line ? 'small-multiples-line' : 'small-multiples-bar',
      panelIndex: index,
    );
    return _GraphifyView(options: options);
  }
  if (line) {
    final panel = smallMultiplesLinePanels[index];
    return gr.Chart<SmallLinePoint>(
      data: panel.points,
      variables: {
        'period': gr.Variable(
          accessor: (SmallLinePoint p) => p.period,
          scale: gr.LinearScale(
            min: 1,
            max: 6,
            formatter: (value) => panel.points[value.round() - 1].label,
          ),
        ),
        'value': gr.Variable(
          accessor: (SmallLinePoint p) => p.value,
          scale: gr.LinearScale(min: 0, max: 100),
        ),
      },
      marks: [gr.LineMark(color: gr.ColorEncode(value: color))],
      axes: [gr.Defaults.horizontalAxis],
      selections: {
        'p': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
      tooltip: gr.TooltipGuide(variables: ['period', 'value']),
    );
  }
  final panel = smallMultiplesBarPanels[index];
  return gr.Chart<SmallBarPoint>(
    data: panel.points,
    variables: {
      'category': gr.Variable(accessor: (SmallBarPoint p) => p.category),
      'value': gr.Variable(
        accessor: (SmallBarPoint p) => p.value,
        scale: gr.LinearScale(min: 0, max: globalMax),
      ),
    },
    marks: [gr.IntervalMark(color: gr.ColorEncode(value: color))],
    axes: [gr.Defaults.horizontalAxis],
    selections: {
      'category': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
    tooltip: gr.TooltipGuide(variables: ['category', 'value']),
  );
}

fl.FlTitlesData _miniFlTitles(List<(int, String)> periods) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  leftTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: 16,
      interval: 2,
      getTitlesWidget: (v, _) {
        final p = periods.where((p) => p.$1 == v.toInt()).firstOrNull;
        return p == null
            ? const SizedBox.shrink()
            : Text(p.$2, style: const TextStyle(fontSize: 7));
      },
    ),
  ),
);

fl.FlTitlesData _miniBarTitles(List<String> categories) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  leftTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: 25,
      getTitlesWidget: (v, _) {
        final i = v.toInt();
        return i < 0 || i >= categories.length
            ? const SizedBox.shrink()
            : RotatedBox(
                quarterTurns: 3,
                child: Text(categories[i], style: const TextStyle(fontSize: 7)),
              );
      },
    ),
  ),
);

Widget _sparkCards(ChartLibrary library) => LayoutBuilder(
  builder: (context, box) {
    final cols = box.maxWidth >= 420 ? 2 : 1;
    final width = (box.maxWidth - 8 * (cols - 1)) / cols;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final kpi in sparklineKpis)
          SizedBox(
            width: width,
            height: 88,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(kpi.label, style: const TextStyle(fontSize: 11)),
                          Text(
                            '${kpi.currentValue} ${kpi.unit}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width * .39,
                      height: 48,
                      child: _sparkChart(kpi, library),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  },
);

Widget _sparkChart(SparklineKpi kpi, ChartLibrary library) {
  final color = kpi.label == 'Cancelaciones' ? _orange : _blue;
  if (library == ChartLibrary.flChart) {
    return fl.LineChart(
      fl.LineChartData(
        minY:
            kpi.points.map((p) => p.value).reduce((a, b) => a < b ? a : b) *
            .94,
        maxY:
            kpi.points.map((p) => p.value).reduce((a, b) => a > b ? a : b) *
            1.06,
        titlesData: const fl.FlTitlesData(show: false),
        gridData: const fl.FlGridData(show: false),
        borderData: fl.FlBorderData(show: false),
        lineTouchData: const fl.LineTouchData(enabled: false),
        lineBarsData: [
          fl.LineChartBarData(
            spots: [
              for (var i = 0; i < kpi.points.length; i++)
                fl.FlSpot(i.toDouble(), kpi.points[i].value),
            ],
            color: color,
            barWidth: 2,
            dotData: fl.FlDotData(
              show: true,
              checkToShowDot: (spot, _) => spot.x == kpi.points.length - 1,
              getDotPainter: (spot, percent, bar, index) =>
                  fl.FlDotCirclePainter(
                    radius: 3,
                    color: color,
                    strokeWidth: 0,
                  ),
            ),
          ),
        ],
      ),
    );
  }
  if (library == ChartLibrary.syncfusion) {
    return sf_spark.SfSparkLineChart(
      data: [for (final p in kpi.points) p.value],
      color: color,
      width: 2,
      lastPointColor: color,
    );
  }
  if (library == ChartLibrary.graphify) {
    return _GraphifyView(
      options: graphifyCompositeCompactOptions(
        'sparkline',
        sparkLabel: kpi.label,
      ),
    );
  }
  return gr.Chart<SparklinePoint>(
    data: kpi.points,
    variables: {
      'period': gr.Variable(
        accessor: (SparklinePoint p) => p.period,
        scale: gr.LinearScale(min: 1, max: kpi.points.length.toDouble()),
      ),
      'value': gr.Variable(accessor: (SparklinePoint p) => p.value),
    },
    marks: [gr.LineMark(color: gr.ColorEncode(value: color))],
    axes: [],
  );
}

Map<String, dynamic> graphifyCompositeCompactOptions(
  String id, {
  int panelIndex = 0,
  String? sparkLabel,
}) {
  if (id == 'bar-line') {
    return {
      'animation': false,
      'tooltip': {'trigger': 'axis'},
      'legend': {
        'data': ['Ventas · $barLineBarUnit', 'Margen · $barLineUnit'],
      },
      'grid': {'left': 48, 'right': 48, 'top': 32, 'bottom': 34},
      'xAxis': {
        'type': 'category',
        'data': [for (final p in barLinePeriods) p.label],
        'boundaryGap': true,
      },
      'yAxis': [
        {'type': 'value', 'name': barLineBarUnit, 'min': 0, 'max': 60},
        {
          'type': 'value',
          'name': barLineUnit,
          'min': 0,
          'max': 100,
          'position': 'right',
          'axisLabel': {'formatter': '{value}%'},
        },
      ],
      'series': [
        {
          'name': 'Ventas · $barLineBarUnit',
          'type': 'bar',
          'yAxisIndex': 0,
          'data': [for (final p in barLinePeriods) p.barValue],
        },
        {
          'name': 'Margen · $barLineUnit',
          'type': 'line',
          'yAxisIndex': 1,
          'data': [for (final p in barLinePeriods) p.lineValue],
          'showSymbol': true,
        },
      ],
    };
  }
  if (id == 'area-line') {
    return {
      'animation': false,
      'tooltip': {'trigger': 'axis'},
      'legend': {
        'data': ['Real', 'Meta'],
      },
      'grid': {'left': 48, 'right': 16, 'top': 28, 'bottom': 34},
      'xAxis': {
        'type': 'category',
        'data': [for (final p in areaLinePeriods) p.label],
        'boundaryGap': false,
      },
      'yAxis': {'type': 'value', 'name': areaLineUnit, 'min': 0},
      'series': [
        {
          'name': 'Real',
          'type': 'line',
          'data': [for (final p in areaLinePeriods) p.areaValue],
          'areaStyle': {'opacity': .3},
          'showSymbol': true,
        },
        {
          'name': 'Meta',
          'type': 'line',
          'data': [for (final p in areaLinePeriods) p.lineValue],
          'showSymbol': true,
        },
      ],
    };
  }
  if (id == 'small-multiples-line') {
    final panel = smallMultiplesLinePanels[panelIndex];
    return _miniGraphify(
      panel.points.map((p) => p.label).toList(),
      panel.points.map((p) => p.value).toList(),
      100,
      '% ocupación',
    );
  }
  if (id == 'small-multiples-bar') {
    final panel = smallMultiplesBarPanels[panelIndex];
    return _miniGraphify(
      panel.points.map((p) => p.category).toList(),
      panel.points.map((p) => p.value).toList(),
      maxAcrossPanels(smallMultiplesBarPanels, (p) => p.value),
      smallMultiplesBarUnit,
      type: 'bar',
    );
  }
  final kpi = sparklineKpis.singleWhere((k) => k.label == sparkLabel);
  return {
    'animation': false,
    'tooltip': {'show': false},
    'grid': {'left': 2, 'right': 2, 'top': 3, 'bottom': 3},
    'xAxis': {
      'type': 'category',
      'show': false,
      'boundaryGap': false,
      'data': [for (final p in kpi.points) '${p.period}'],
    },
    'yAxis': {
      'type': 'value',
      'show': false,
      'scale': true,
      'min':
          kpi.points.map((p) => p.value).reduce((a, b) => a < b ? a : b) * .94,
      'max':
          kpi.points.map((p) => p.value).reduce((a, b) => a > b ? a : b) * 1.06,
    },
    'series': [
      {
        'type': 'line',
        'data': [for (final p in kpi.points) p.value],
        'showSymbol': false,
        'lineStyle': {'width': 2},
        'markPoint': {
          'symbolSize': 4,
          'label': {'show': false},
          'data': [
            {
              'coord': ['${kpi.points.last.period}', kpi.currentValue],
              'value': kpi.currentValue,
            },
          ],
        },
      },
    ],
  };
}

Map<String, dynamic> _miniGraphify(
  List<String> categories,
  List<double> values,
  double max,
  String unit, {
  String type = 'line',
}) => {
  'animation': false,
  'tooltip': {'trigger': 'axis'},
  'grid': {'left': 10, 'right': 8, 'top': 4, 'bottom': type == 'bar' ? 22 : 15},
  'xAxis': {
    'type': 'category',
    'data': categories,
    'axisLabel': {'fontSize': 8},
  },
  'yAxis': {
    'type': 'value',
    'min': 0,
    'max': max,
    'name': unit,
    'axisLabel': {'show': false},
    'splitLine': {'show': false},
  },
  'series': [
    {
      'type': type,
      'data': values,
      'showSymbol': type == 'line',
      'symbolSize': 3,
    },
  ],
};

String encodeGraphifyCompositeCompactOptions(
  String id, {
  int panelIndex = 0,
  String? sparkLabel,
}) => jsonEncode(
  graphifyCompositeCompactOptions(
    id,
    panelIndex: panelIndex,
    sparkLabel: sparkLabel,
  ),
);

class GraphifyCompositeCompactChart extends StatelessWidget {
  const GraphifyCompositeCompactChart({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    if (id == 'sparkline') return _sparkCards(ChartLibrary.graphify);
    if (id == 'small-multiples-line' || id == 'small-multiples-bar') {
      return _smallMultiples(id, ChartLibrary.graphify);
    }
    return Column(
      children: [
        _keyLegend(id, ChartLibrary.graphify),
        Expanded(
          child: _GraphifyView(options: graphifyCompositeCompactOptions(id)),
        ),
      ],
    );
  }
}

class _GraphifyView extends StatefulWidget {
  const _GraphifyView({required this.options});
  final Map<String, dynamic> options;
  @override
  State<_GraphifyView> createState() => _GraphifyViewState();
}

class _GraphifyViewState extends State<_GraphifyView> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) =>
      GraphifyView(controller: controller, initialOptions: widget.options);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
