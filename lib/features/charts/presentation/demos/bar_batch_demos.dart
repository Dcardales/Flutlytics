import 'dart:convert';

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:graphify/graphify.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/sample_datasets.dart';
import '../../domain/chart_concept.dart';
import 'demo_registration.dart';

const _seriesColors = <Color>[
  Color(0xff1976d2),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
];

class BarBatchDemos {
  BarBatchDemos._();

  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in const [
      'grouped-bar',
      'stacked-bar',
      'normalized-stacked-bar',
      'diverging-bar',
    ])
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => BarBatchChart(id: id, library: library),
        ),
  ]);
}

class BarBatchChart extends StatelessWidget {
  const BarBatchChart({super.key, required this.id, required this.library});
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) {
    if (id == 'diverging-bar') {
      final points = ChartDatasetRegistry.pointsFor(id);
      return switch (library) {
        ChartLibrary.flChart => _FlDiverging(points: points),
        ChartLibrary.syncfusion => _SfDiverging(points: points),
        ChartLibrary.graphic => _GraphicDiverging(points: points),
        ChartLibrary.graphify => _GraphifyChart(options: graphifyOptions(id)),
      };
    }
    final raw = ChartDatasetRegistry.barDataFor(id);
    final data = id == 'normalized-stacked-bar' ? normalizeBars(raw) : raw;
    final categories = raw.map((row) => row.category).toSet().toList();
    final series = raw.map((row) => row.series).toSet().toList();
    return switch (library) {
      ChartLibrary.flChart => _FlMulti(
        id: id,
        data: data,
        categories: categories,
        series: series,
      ),
      ChartLibrary.syncfusion => _SfMulti(
        id: id,
        data: data,
        categories: categories,
        series: series,
      ),
      ChartLibrary.graphic => _GraphicMulti(
        id: id,
        data: data,
        categories: categories,
        series: series,
      ),
      ChartLibrary.graphify => _GraphifyChart(options: graphifyOptions(id)),
    };
  }
}

Widget _legend(List<String> series) => Wrap(
  alignment: WrapAlignment.center,
  spacing: 10,
  runSpacing: 2,
  children: [
    for (var i = 0; i < series.length; i++)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            color: _seriesColors[i % _seriesColors.length],
          ),
          const SizedBox(width: 4),
          Text(series[i], style: const TextStyle(fontSize: 10)),
        ],
      ),
  ],
);

class _FlMulti extends StatelessWidget {
  const _FlMulti({
    required this.id,
    required this.data,
    required this.categories,
    required this.series,
  });
  final String id;
  final List<BarDatum> data;
  final List<String> categories;
  final List<String> series;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: fl.BarChart(
          fl.BarChartData(
            minY: 0,
            maxY: id == 'normalized-stacked-bar' ? 100 : null,
            barGroups: [
              for (var ci = 0; ci < categories.length; ci++)
                fl.BarChartGroupData(
                  x: ci,
                  barsSpace: 3,
                  barRods: id == 'grouped-bar'
                      ? [
                          for (var si = 0; si < series.length; si++)
                            fl.BarChartRodData(
                              toY: _value(data, categories[ci], series[si]),
                              color: _seriesColors[si % _seriesColors.length],
                              width: 10,
                            ),
                        ]
                      : [_stackedRod(data, categories[ci], series)],
                ),
            ],
            titlesData: _flCategoryTitles(categories),
            barTouchData: fl.BarTouchData(enabled: true),
            gridData: const fl.FlGridData(show: true, drawVerticalLine: false),
          ),
        ),
      ),
      _legend(series),
    ],
  );
}

fl.BarChartRodData _stackedRod(
  List<BarDatum> data,
  String category,
  List<String> series,
) {
  var cumulative = 0.0;
  final segments = <fl.BarChartRodStackItem>[];
  for (var i = 0; i < series.length; i++) {
    final value = _value(data, category, series[i]);
    segments.add(
      fl.BarChartRodStackItem(
        cumulative,
        cumulative + value,
        _seriesColors[i % _seriesColors.length],
      ),
    );
    cumulative += value;
  }
  return fl.BarChartRodData(
    toY: cumulative,
    rodStackItems: segments,
    width: 24,
  );
}

double _value(List<BarDatum> data, String category, String series) =>
    data.firstWhere((r) => r.category == category && r.series == series).value;

fl.FlTitlesData _flCategoryTitles(List<String> categories) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: 34,
      getTitlesWidget: (value, meta) {
        final i = value.toInt();
        return i >= 0 && i < categories.length && value == i
            ? Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(categories[i], style: const TextStyle(fontSize: 9)),
              )
            : const SizedBox.shrink();
      },
    ),
  ),
);

class _SfMulti extends StatelessWidget {
  const _SfMulti({
    required this.id,
    required this.data,
    required this.categories,
    required this.series,
  });
  final String id;
  final List<BarDatum> data;
  final List<String> categories;
  final List<String> series;

  @override
  Widget build(BuildContext context) {
    final chartSeries = <sf.CartesianSeries<BarDatum, String>>[
      for (var i = 0; i < series.length; i++)
        if (id == 'normalized-stacked-bar')
          sf.StackedColumn100Series<BarDatum, String>(
            dataSource: data.where((r) => r.series == series[i]).toList(),
            name: series[i],
            color: _seriesColors[i % _seriesColors.length],
            animationDuration: 0,
            xValueMapper: (r, _) => r.category,
            yValueMapper: (r, _) => r.value,
          )
        else if (id == 'stacked-bar')
          sf.StackedColumnSeries<BarDatum, String>(
            dataSource: data.where((r) => r.series == series[i]).toList(),
            name: series[i],
            color: _seriesColors[i % _seriesColors.length],
            animationDuration: 0,
            xValueMapper: (r, _) => r.category,
            yValueMapper: (r, _) => r.value,
          )
        else
          sf.ColumnSeries<BarDatum, String>(
            dataSource: data.where((r) => r.series == series[i]).toList(),
            name: series[i],
            color: _seriesColors[i % _seriesColors.length],
            animationDuration: 0,
            xValueMapper: (r, _) => r.category,
            yValueMapper: (r, _) => r.value,
          ),
    ];
    return sf.SfCartesianChart(
      primaryXAxis: const sf.CategoryAxis(),
      primaryYAxis: sf.NumericAxis(
        minimum: 0,
        maximum: id == 'normalized-stacked-bar' ? 100 : null,
      ),
      tooltipBehavior: sf.TooltipBehavior(enable: true),
      legend: const sf.Legend(
        isVisible: true,
        overflowMode: sf.LegendItemOverflowMode.wrap,
      ),
      series: chartSeries,
    );
  }
}

typedef _GraphicDatum = ({String category, String series, double value});

class _GraphicMulti extends StatelessWidget {
  const _GraphicMulti({
    required this.id,
    required this.data,
    required this.categories,
    required this.series,
  });
  final String id;
  final List<BarDatum> data;
  final List<String> categories;
  final List<String> series;

  @override
  Widget build(BuildContext context) {
    final chartData = [
      for (final r in data)
        (category: r.category, series: r.series, value: r.value),
    ];
    final maxY = id == 'normalized-stacked-bar'
        ? 100.0
        : data.fold<double>(0, (m, r) => m + r.value);
    return Column(
      children: [
        Expanded(
          child: gr.Chart<_GraphicDatum>(
            data: chartData,
            variables: {
              'category': gr.Variable(
                accessor: (_GraphicDatum r) => r.category,
              ),
              'series': gr.Variable(accessor: (_GraphicDatum r) => r.series),
              'value': gr.Variable(
                accessor: (_GraphicDatum r) => r.value,
                scale: gr.LinearScale(min: 0, max: maxY),
              ),
            },
            marks: [
              gr.IntervalMark(
                position: gr.Varset('category') * gr.Varset('value'),
                color: gr.ColorEncode(
                  variable: 'series',
                  values: _seriesColors,
                ),
                modifiers: [
                  if (id == 'grouped-bar')
                    gr.DodgeModifier()
                  else
                    gr.StackModifier(),
                ],
              ),
            ],
            axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
            selections: {
              'point': gr.PointSelection(
                on: {gr.GestureType.hover, gr.GestureType.tap},
                dim: gr.Dim.x,
              ),
            },
            tooltip: gr.TooltipGuide(
              variables: ['category', 'series', 'value'],
            ),
          ),
        ),
        _legend(series),
      ],
    );
  }
}

class _DivergingDatum {
  const _DivergingDatum(this.label, this.value);
  final String label;
  final double value;
}

List<_DivergingDatum> _diverging(List<ChartPoint> points) => [
  for (final p in points) _DivergingDatum(p.label, p.value),
];

class _FlDiverging extends StatelessWidget {
  const _FlDiverging({required this.points});
  final List<ChartPoint> points;
  @override
  Widget build(BuildContext context) {
    final data = _diverging(points);
    return fl.BarChart(
      fl.BarChartData(
        minY: -12,
        maxY: 10,
        barGroups: [
          for (var i = 0; i < data.length; i++)
            fl.BarChartGroupData(
              x: i,
              barRods: [
                fl.BarChartRodData(
                  toY: data[i].value,
                  color: data[i].value >= 0
                      ? _seriesColors[2]
                      : const Color(0xffc62828),
                  width: 18,
                ),
              ],
            ),
        ],
        titlesData: _flCategoryTitles(points.map((p) => p.label).toList()),
        gridData: const fl.FlGridData(show: true, drawVerticalLine: false),
        barTouchData: fl.BarTouchData(enabled: true),
      ),
    );
  }
}

class _SfDiverging extends StatelessWidget {
  const _SfDiverging({required this.points});
  final List<ChartPoint> points;
  @override
  Widget build(BuildContext context) => sf.SfCartesianChart(
    primaryXAxis: const sf.CategoryAxis(),
    primaryYAxis: const sf.NumericAxis(minimum: -12, maximum: 10, interval: 5),
    tooltipBehavior: sf.TooltipBehavior(enable: true),
    series: <sf.CartesianSeries<ChartPoint, String>>[
      sf.ColumnSeries<ChartPoint, String>(
        dataSource: points,
        animationDuration: 0,
        pointColorMapper: (p, _) =>
            p.value >= 0 ? _seriesColors[2] : const Color(0xffc62828),
        xValueMapper: (p, _) => p.label,
        yValueMapper: (p, _) => p.value,
      ),
    ],
  );
}

class _GraphicDiverging extends StatelessWidget {
  const _GraphicDiverging({required this.points});
  final List<ChartPoint> points;
  @override
  Widget build(BuildContext context) {
    final data = _diverging(points);
    return gr.Chart<_DivergingDatum>(
      data: data,
      variables: {
        'label': gr.Variable(accessor: (_DivergingDatum r) => r.label),
        'value': gr.Variable(
          accessor: (_DivergingDatum r) => r.value,
          scale: gr.LinearScale(min: -12, max: 10),
        ),
        'color': gr.Variable(
          accessor: (_DivergingDatum r) =>
              r.value >= 0 ? 'Sobre meta' : 'Bajo meta',
        ),
      },
      marks: [
        gr.IntervalMark(
          position: gr.Varset('label') * gr.Varset('value'),
          color: gr.ColorEncode(
            variable: 'color',
            values: [_seriesColors[2], const Color(0xffc62828)],
          ),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      tooltip: gr.TooltipGuide(variables: ['label', 'value']),
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
    );
  }
}

class _GraphifyChart extends StatefulWidget {
  const _GraphifyChart({required this.options});
  final Map<String, dynamic> options;
  @override
  State<_GraphifyChart> createState() => _GraphifyChartState();
}

class _GraphifyChartState extends State<_GraphifyChart> {
  final controller = GraphifyController();
  @override
  Widget build(BuildContext context) => GraphifyView(
    controller: controller,
    onConsoleMessage: (message) => debugPrint('Graphify ECharts: $message'),
    initialOptions: widget.options,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// JSON-only ECharts options; all values are serializable and no JS callbacks are used.
Map<String, dynamic> graphifyOptions(String id) {
  final isDiverging = id == 'diverging-bar';
  if (isDiverging) {
    final points = ChartDatasetRegistry.pointsFor(id);
    return {
      'tooltip': {
        'trigger': 'axis',
        'axisPointer': {'type': 'shadow'},
      },
      'xAxis': {
        'type': 'category',
        'data': [for (final p in points) p.label],
        'axisLine': {'onZero': true},
      },
      'yAxis': {'type': 'value', 'min': -12, 'max': 10},
      'series': [
        {
          'type': 'bar',
          'data': [
            for (final p in points)
              {
                'value': p.value,
                'itemStyle': {'color': p.value >= 0 ? '#2e7d32' : '#c62828'},
              },
          ],
        },
      ],
    };
  }
  final raw = ChartDatasetRegistry.barDataFor(id);
  final data = id == 'normalized-stacked-bar' ? normalizeBars(raw) : raw;
  final categories = raw.map((r) => r.category).toSet().toList();
  final series = raw.map((r) => r.series).toSet().toList();
  final stacked = id != 'grouped-bar';
  return {
    'tooltip': {
      'trigger': 'axis',
      'axisPointer': {'type': 'shadow'},
    },
    'legend': {'data': series, 'type': 'scroll'},
    'xAxis': {'type': 'category', 'data': categories},
    'yAxis': {'type': 'value', if (id == 'normalized-stacked-bar') 'max': 100},
    'series': [
      for (var si = 0; si < series.length; si++)
        {
          'name': series[si],
          'type': 'bar',
          if (stacked) 'stack': 'total',
          'itemStyle': {
            'color':
                '#${_seriesColors[si % _seriesColors.length].toARGB32().toRadixString(16).substring(2)}',
          },
          'data': [
            for (final category in categories)
              _value(data, category, series[si]),
          ],
        },
    ],
  };
}

String encodeGraphifyOptions(String id) => jsonEncode(graphifyOptions(id));
