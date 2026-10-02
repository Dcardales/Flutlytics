import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/chart_catalog.dart';
import '../../data/combination_data.dart';
import '../../data/analytical_time_series.dart';
import '../../data/distribution_basics_data.dart';
import '../../data/financial_planning_data.dart';
import '../../data/networks_diagnostics_spatial_data.dart';
import '../../data/performance_process_data.dart';
import '../../domain/chart_concept.dart';
import '../chart_renderer.dart';

const _blue = Color(0xff2563eb);
const _teal = Color(0xff0f766e);
const _orange = Color(0xffea580c);

Widget buildSupplementalCombination(String id, ChartLibrary library) {
  if (library == ChartLibrary.graphify) {
    throw ArgumentError('Graphify combinations use ECharts options.');
  }
  return switch (id) {
    'control-distribution' => _twoPanels(
      'Control chart · mismas observaciones',
      _controlPanel(library),
      'Histograma + KDE',
      _controlDistribution(library),
    ),
    'waterfall-cumulative' => _twoPanels(
      'Cascada · contribuciones por etapa',
      _base('waterfall', library),
      'Running total · derivado de la transformación Waterfall',
      _waterfallTotal(library),
    ),
    'funnel-conversion' => _twoPanels(
      'Embudo · personas por etapa',
      _base('funnel', library),
      'Conversión desde la etapa anterior y desde el inicio',
      _funnelConversions(library),
    ),
    'error-strip' => _errorStrip(library),
    'contour-observations' => _contourObservations(library),
    _ => throw ArgumentError.value(id, 'id'),
  };
}

Widget _base(String id, ChartLibrary library) =>
    ChartRenderer.buildChart(concept: ChartCatalog.byId(id), library: library);

Widget _twoPanels(
  String firstLabel,
  Widget first,
  String secondLabel,
  Widget second,
) => Column(
  children: [
    _panelLabel(firstLabel),
    Expanded(child: first),
    const SizedBox(height: 4),
    _panelLabel(secondLabel),
    Expanded(child: second),
  ],
);

Widget _panelLabel(String value) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  child: Align(
    alignment: Alignment.centerLeft,
    child: Text(value, style: const TextStyle(fontSize: 10)),
  ),
);

class _ControlBandPoint {
  const _ControlBandPoint(this.period, this.value);
  final int period;
  final double value;
}

class _ControlDatum {
  const _ControlDatum(this.kind, this.period, this.value);
  final String kind;
  final double period, value;
}

Widget _controlPanel(ChartLibrary library) {
  final chart = controlDistributionChart;
  final periods = chart.points.map((point) => point.period).toList();
  List<_ControlBandPoint> band(double value) => [
    for (final period in periods) _ControlBandPoint(period, value),
  ];
  final data = [
    for (final point in chart.points)
      _ControlDatum('Observaciones', point.period.toDouble(), point.value),
    for (final point in band(chart.stats.mean))
      _ControlDatum('Media', point.period.toDouble(), point.value),
    for (final point in band(chart.stats.upperControlLimit))
      _ControlDatum('UCL', point.period.toDouble(), point.value),
    for (final point in band(chart.stats.lowerControlLimit))
      _ControlDatum('LCL', point.period.toDouble(), point.value),
  ];
  return switch (library) {
    ChartLibrary.flChart => fl.LineChart(
      fl.LineChartData(
        minX: periods.first.toDouble(),
        maxX: periods.last.toDouble(),
        minY: chart.stats.lowerControlLimit,
        maxY: chart.stats.upperControlLimit,
        titlesData: fl.FlTitlesData(
          topTitles: const fl.AxisTitles(
            sideTitles: fl.SideTitles(showTitles: false),
          ),
          rightTitles: const fl.AxisTitles(
            sideTitles: fl.SideTitles(showTitles: false),
          ),
          leftTitles: const fl.AxisTitles(
            sideTitles: fl.SideTitles(showTitles: false),
          ),
          bottomTitles: fl.AxisTitles(
            sideTitles: fl.SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 20,
              getTitlesWidget: (value, meta) => Text(
                value.round().toString(),
                style: const TextStyle(fontSize: 8),
              ),
            ),
          ),
        ),
        lineBarsData: [
          fl.LineChartBarData(
            spots: [
              for (final point in chart.points)
                fl.FlSpot(point.period.toDouble(), point.value),
            ],
            color: _blue,
            dotData: const fl.FlDotData(show: true),
          ),
          for (final (value, color) in [
            (chart.stats.mean, _teal),
            (chart.stats.upperControlLimit, _orange),
            (chart.stats.lowerControlLimit, _orange),
          ])
            fl.LineChartBarData(
              spots: [
                for (final period in periods)
                  fl.FlSpot(period.toDouble(), value),
              ],
              color: color,
              barWidth: 1.5,
              dotData: const fl.FlDotData(show: false),
            ),
        ],
      ),
    ),
    ChartLibrary.syncfusion => sf.SfCartesianChart(
      primaryXAxis: const sf.NumericAxis(interval: 2),
      primaryYAxis: sf.NumericAxis(
        minimum: chart.stats.lowerControlLimit,
        maximum: chart.stats.upperControlLimit,
      ),
      series: <sf.CartesianSeries<dynamic, dynamic>>[
        sf.LineSeries<ControlChartPoint, int>(
          name: 'Observaciones',
          dataSource: chart.points,
          xValueMapper: (point, _) => point.period,
          yValueMapper: (point, _) => point.value,
          markerSettings: const sf.MarkerSettings(
            isVisible: true,
            width: 4,
            height: 4,
          ),
          animationDuration: 0,
        ),
        for (final (label, value, color) in [
          ('Media', chart.stats.mean, _teal),
          ('UCL', chart.stats.upperControlLimit, _orange),
          ('LCL', chart.stats.lowerControlLimit, _orange),
        ])
          sf.LineSeries<_ControlBandPoint, int>(
            name: label,
            dataSource: band(value),
            xValueMapper: (point, _) => point.period,
            yValueMapper: (point, _) => point.value,
            color: color,
            animationDuration: 0,
          ),
      ],
    ),
    ChartLibrary.graphic => gr.Chart<_ControlDatum>(
      data: data,
      variables: {
        'kind': gr.Variable(accessor: (point) => point.kind),
        'period': gr.Variable(
          accessor: (point) => point.period,
          scale: gr.LinearScale(
            min: periods.first.toDouble(),
            max: periods.last.toDouble(),
          ),
        ),
        'value': gr.Variable(
          accessor: (point) => point.value,
          scale: gr.LinearScale(
            min: chart.stats.lowerControlLimit,
            max: chart.stats.upperControlLimit,
          ),
        ),
      },
      marks: [
        gr.LineMark(
          position:
              gr.Varset('period') * gr.Varset('value') / gr.Varset('kind'),
          color: gr.ColorEncode(
            variable: 'kind',
            values: const [_blue, _teal, _orange, _orange],
          ),
          size: gr.SizeEncode(value: 1.5),
        ),
        gr.PointMark(
          position: gr.Varset('period') * gr.Varset('value'),
          color: gr.ColorEncode(value: _blue),
          size: gr.SizeEncode(value: 3),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
    ),
    ChartLibrary.graphify => throw StateError(
      'Graphify is handled separately.',
    ),
  };
}

Widget _controlDistribution(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => _flControlDistribution(),
  ChartLibrary.syncfusion => _sfControlDistribution(),
  ChartLibrary.graphic => _graphicControlDistribution(),
  ChartLibrary.graphify => throw StateError('Graphify is handled separately.'),
};

Widget _flControlDistribution() {
  final bins = controlDistributionBins;
  final kde = controlDistributionKdeAsFrequency;
  final kdeDomain =
      controlDistributionKde.last.x - controlDistributionKde.first.x;
  final maxY = math.max(
    1.0,
    [
          ...bins.map((bin) => bin.frequency.toDouble()),
          ...kde.map((point) => point.y),
        ].reduce((a, b) => math.max(a, b).toDouble()) *
        1.2,
  );
  return Column(
    children: [
      Expanded(
        child: Stack(
          children: [
            fl.BarChart(
              fl.BarChartData(
                minY: 0,
                maxY: maxY,
                titlesData: const fl.FlTitlesData(show: false),
                barGroups: [
                  for (var i = 0; i < bins.length; i++)
                    fl.BarChartGroupData(
                      x: i,
                      barRods: [
                        fl.BarChartRodData(
                          toY: bins[i].frequency.toDouble(),
                          color: const Color(0x8842a5f5),
                          width: 20,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            IgnorePointer(
              child: fl.LineChart(
                fl.LineChartData(
                  minX: -.5,
                  maxX: bins.length - .5,
                  minY: 0,
                  maxY: maxY,
                  titlesData: const fl.FlTitlesData(show: false),
                  gridData: const fl.FlGridData(show: false),
                  borderData: fl.FlBorderData(show: false),
                  lineBarsData: [
                    fl.LineChartBarData(
                      spots: [
                        for (final point in kde)
                          fl.FlSpot(
                            (point.x - controlDistributionKde.first.x) /
                                kdeDomain *
                                (bins.length - 1),
                            point.y,
                          ),
                      ],
                      color: _orange,
                      barWidth: 2,
                      dotData: const fl.FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      _binLabels([for (final bin in bins) bin.label]),
    ],
  );
}

Widget _sfControlDistribution() => sf.SfCartesianChart(
  primaryXAxis: sf.NumericAxis(
    minimum: controlDistributionBins.first.lowerBound,
    maximum: controlDistributionBins.last.upperBound,
  ),
  primaryYAxis: const sf.NumericAxis(minimum: 0),
  series: <sf.CartesianSeries<dynamic, dynamic>>[
    sf.ColumnSeries<HistogramBin, double>(
      dataSource: controlDistributionBins,
      xValueMapper: (bin, _) => bin.midpoint,
      yValueMapper: (bin, _) => bin.frequency,
      color: const Color(0x8842a5f5),
      spacing: 0,
      animationDuration: 0,
    ),
    sf.LineSeries<DistributionPoint, double>(
      dataSource: controlDistributionKdeAsFrequency,
      xValueMapper: (point, _) => point.x,
      yValueMapper: (point, _) => point.y,
      color: _orange,
      width: 2,
      animationDuration: 0,
    ),
  ],
);

Widget _graphicControlDistribution() {
  final xMin = controlDistributionBins.first.lowerBound;
  final xMax = controlDistributionBins.last.upperBound;
  final maxY =
      [
        ...controlDistributionBins.map((bin) => bin.frequency.toDouble()),
        ...controlDistributionKdeAsFrequency.map((point) => point.y),
      ].reduce((a, b) => math.max(a, b).toDouble()) *
      1.2;
  return Column(
    children: [
      Expanded(
        child: Stack(
          children: [
            Positioned.fill(
              child: gr.Chart<HistogramBin>(
                data: controlDistributionBins,
                variables: {
                  'x': gr.Variable(
                    accessor: (bin) => bin.midpoint,
                    scale: gr.LinearScale(min: xMin, max: xMax),
                  ),
                  'baseline': gr.Variable(
                    accessor: (bin) => 0.0,
                    scale: gr.LinearScale(min: 0, max: maxY),
                  ),
                  'frequency': gr.Variable(
                    accessor: (bin) => bin.frequency.toDouble(),
                    scale: gr.LinearScale(min: 0, max: maxY),
                  ),
                },
                marks: [
                  gr.IntervalMark(
                    position:
                        gr.Varset('x') *
                        (gr.Varset('baseline') + gr.Varset('frequency')),
                    color: gr.ColorEncode(value: const Color(0x8842a5f5)),
                  ),
                ],
                axes: [],
                padding: (_) => EdgeInsets.zero,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: gr.Chart<DistributionPoint>(
                  data: controlDistributionKdeAsFrequency,
                  variables: {
                    'x': gr.Variable(
                      accessor: (point) => point.x,
                      scale: gr.LinearScale(min: xMin, max: xMax),
                    ),
                    'density': gr.Variable(
                      accessor: (point) => point.y,
                      scale: gr.LinearScale(min: 0, max: maxY),
                    ),
                  },
                  marks: [
                    gr.LineMark(
                      position: gr.Varset('x') * gr.Varset('density'),
                      color: gr.ColorEncode(value: _orange),
                      size: gr.SizeEncode(value: 2),
                    ),
                  ],
                  axes: [],
                  padding: (_) => EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
      _binLabels([for (final bin in controlDistributionBins) bin.label]),
    ],
  );
}

Widget _binLabels(List<String> labels) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 4),
  child: Row(
    children: [
      for (final label in labels)
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontSize: 8),
          ),
        ),
    ],
  ),
);

Widget _waterfallTotal(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => fl.LineChart(
    fl.LineChartData(
      minX: -.5,
      maxX: waterfallCumulativeBars.length - .5,
      minY: 0,
      maxY:
          waterfallCumulativeBars
              .map((bar) => bar.runningTotal)
              .reduce(math.max) *
          1.15,
      titlesData: _flCategoryTitles([
        for (final bar in waterfallCumulativeBars) bar.step.label,
      ]),
      lineBarsData: [
        fl.LineChartBarData(
          spots: [
            for (var i = 0; i < waterfallCumulativeBars.length; i++)
              fl.FlSpot(i.toDouble(), waterfallCumulativeBars[i].runningTotal),
          ],
          color: _teal,
          barWidth: 2.5,
          dotData: const fl.FlDotData(show: true),
        ),
      ],
    ),
  ),
  ChartLibrary.syncfusion => sf.SfCartesianChart(
    primaryXAxis: const sf.CategoryAxis(labelRotation: -25),
    primaryYAxis: const sf.NumericAxis(minimum: 0),
    series: [
      sf.LineSeries<WaterfallBar, String>(
        dataSource: waterfallCumulativeBars,
        xValueMapper: (bar, _) => bar.step.label,
        yValueMapper: (bar, _) => bar.runningTotal,
        color: _teal,
        markerSettings: const sf.MarkerSettings(isVisible: true),
        animationDuration: 0,
      ),
    ],
  ),
  ChartLibrary.graphic => gr.Chart<WaterfallBar>(
    data: waterfallCumulativeBars,
    variables: {
      'step': gr.Variable(accessor: (bar) => bar.step.label),
      'total': gr.Variable(accessor: (bar) => bar.runningTotal),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('step') * gr.Varset('total'),
        color: gr.ColorEncode(value: _teal),
        size: gr.SizeEncode(value: 2.5),
      ),
      gr.PointMark(
        position: gr.Varset('step') * gr.Varset('total'),
        color: gr.ColorEncode(value: _teal),
        size: gr.SizeEncode(value: 5),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  ),
  ChartLibrary.graphify => throw StateError('Graphify is handled separately.'),
};

fl.FlTitlesData _flCategoryTitles(List<String> labels) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  leftTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      interval: 1,
      reservedSize: 28,
      getTitlesWidget: (value, meta) {
        final index = value.round();
        return value == index && index >= 0 && index < labels.length
            ? fl.SideTitleWidget(
                meta: meta,
                child: Text(labels[index], style: const TextStyle(fontSize: 8)),
              )
            : const SizedBox.shrink();
      },
    ),
  ),
);

class _FunnelRatePoint {
  const _FunnelRatePoint(this.step, this.kind, this.rate);
  final FunnelStep step;
  final String kind;
  final double rate;
}

final _funnelPreviousRates = [
  for (final step in funnelConversionSteps.skip(1))
    _FunnelRatePoint(
      step,
      'Anterior',
      (step.conversionFromPrevious ?? 0) * 100,
    ),
];
final _funnelStartRates = [
  for (final step in funnelConversionSteps)
    _FunnelRatePoint(
      step,
      'Desde inicio',
      (step.conversionFromStart ?? 0) * 100,
    ),
];
final _funnelRatePoints = [..._funnelPreviousRates, ..._funnelStartRates];

Widget _funnelConversions(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => fl.LineChart(
    fl.LineChartData(
      minX: -.5,
      maxX: funnelConversionSteps.length - .5,
      minY: 0,
      maxY: 110,
      titlesData: _flCategoryTitles([
        for (final step in funnelConversionSteps) step.stage.label,
      ]),
      lineBarsData: [
        for (final (points, color) in [
          (_funnelPreviousRates, _orange),
          (_funnelStartRates, _blue),
        ])
          fl.LineChartBarData(
            spots: [
              for (final point in points)
                fl.FlSpot(point.step.index.toDouble(), point.rate),
            ],
            color: color,
            barWidth: 2,
            dotData: const fl.FlDotData(show: true),
          ),
      ],
      lineTouchData: fl.LineTouchData(
        touchTooltipData: fl.LineTouchTooltipData(
          getTooltipItems: (spots) => [
            for (final spot in spots)
              () {
                final step =
                    funnelConversionSteps[spot.spotIndex +
                        (spot.barIndex == 0 ? 1 : 0)];
                return fl.LineTooltipItem(
                  '${step.stage.label}\nAnterior: ${_percent(step.conversionFromPrevious)}\nDesde inicio: ${_percent(step.conversionFromStart)}\nDrop-off: ${step.dropOff?.toStringAsFixed(0) ?? '—'}',
                  const TextStyle(color: Colors.white, fontSize: 9),
                );
              }(),
          ],
        ),
      ),
    ),
  ),
  ChartLibrary.syncfusion => sf.SfCartesianChart(
    primaryXAxis: const sf.CategoryAxis(labelRotation: -25),
    primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 110),
    tooltipBehavior: sf.TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        final step = (data as _FunnelRatePoint).step;
        return _tip(
          '${step.stage.label}\nAnterior: ${_percent(step.conversionFromPrevious)}\nDesde inicio: ${_percent(step.conversionFromStart)}\nDrop-off: ${step.dropOff?.toStringAsFixed(0) ?? '—'}',
        );
      },
    ),
    series: [
      for (final kind in const ['Anterior', 'Desde inicio'])
        sf.LineSeries<_FunnelRatePoint, String>(
          name: kind,
          dataSource: _funnelRatePoints
              .where((point) => point.kind == kind)
              .toList(),
          xValueMapper: (point, _) => point.step.stage.label,
          yValueMapper: (point, _) => point.rate,
          markerSettings: const sf.MarkerSettings(isVisible: true),
          animationDuration: 0,
        ),
    ],
  ),
  ChartLibrary.graphic => gr.Chart<_FunnelRatePoint>(
    data: _funnelRatePoints,
    variables: {
      'kind': gr.Variable(accessor: (point) => point.kind),
      'stage': gr.Variable(accessor: (point) => point.step.stage.label),
      'rate': gr.Variable(accessor: (point) => point.rate),
      'drop': gr.Variable(
        accessor: (point) => point.step.dropOff?.toStringAsFixed(0) ?? '—',
      ),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('stage') * gr.Varset('rate') / gr.Varset('kind'),
        color: gr.ColorEncode(variable: 'kind', values: const [_orange, _blue]),
        size: gr.SizeEncode(value: 2),
      ),
      gr.PointMark(
        position: gr.Varset('stage') * gr.Varset('rate'),
        color: gr.ColorEncode(variable: 'kind', values: const [_orange, _blue]),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['stage', 'rate', 'drop']),
    selections: {
      'point': gr.PointSelection(
        on: {gr.GestureType.hover, gr.GestureType.tap},
        dim: gr.Dim.x,
      ),
    },
  ),
  ChartLibrary.graphify => throw StateError('Graphify is handled separately.'),
};

String _percent(double? rate) =>
    rate == null ? '—' : '${(rate * 100).toStringAsFixed(1)} %';

Widget _tip(String value) => Container(
  padding: const EdgeInsets.all(6),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4),
    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
  ),
  child: Text(value, style: const TextStyle(fontSize: 10)),
);

class _ErrorLinePoint {
  const _ErrorLinePoint(this.segment, this.x, this.y);
  final String segment;
  final double x, y;
}

final _errorIntervalPoints = [
  _ErrorLinePoint('CI 95 %', -.08, errorStripEstimate.lower),
  _ErrorLinePoint('CI 95 %', -.08, errorStripEstimate.upper),
  _ErrorLinePoint('Media', -.16, errorStripEstimate.estimate),
  _ErrorLinePoint('Media', 0, errorStripEstimate.estimate),
];

Widget _errorStrip(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => fl.LineChart(
    fl.LineChartData(
      minX: -.25,
      maxX: .25,
      minY: errorStripEstimate.lower - .5,
      maxY: errorStripEstimate.upper + .5,
      titlesData: const fl.FlTitlesData(show: false),
      gridData: const fl.FlGridData(show: false),
      lineBarsData: [
        fl.LineChartBarData(
          spots: [
            for (final point in errorStripObservations)
              fl.FlSpot(point.jitter, point.value),
          ],
          color: Colors.transparent,
          barWidth: 0,
          dotData: fl.FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) =>
                fl.FlDotCirclePainter(color: _blue, radius: 4),
          ),
        ),
        fl.LineChartBarData(
          spots: [
            fl.FlSpot(-.08, errorStripEstimate.lower),
            fl.FlSpot(-.08, errorStripEstimate.upper),
          ],
          color: _orange,
          barWidth: 3,
          dotData: const fl.FlDotData(show: false),
        ),
        fl.LineChartBarData(
          spots: [
            fl.FlSpot(-.16, errorStripEstimate.estimate),
            fl.FlSpot(0, errorStripEstimate.estimate),
          ],
          color: _teal,
          barWidth: 3,
          dotData: const fl.FlDotData(show: false),
        ),
      ],
    ),
  ),
  ChartLibrary.syncfusion => sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(minimum: -.25, maximum: .25),
    primaryYAxis: sf.NumericAxis(
      minimum: errorStripEstimate.lower - .5,
      maximum: errorStripEstimate.upper + .5,
      title: const sf.AxisTitle(text: 'Minutos'),
    ),
    series: <sf.CartesianSeries<dynamic, dynamic>>[
      sf.ScatterSeries(
        dataSource: errorStripObservations,
        xValueMapper: (point, _) => point.jitter,
        yValueMapper: (point, _) => point.value,
        markerSettings: const sf.MarkerSettings(
          isVisible: true,
          width: 8,
          height: 8,
        ),
        animationDuration: 0,
      ),
      sf.LineSeries<_ErrorLinePoint, double>(
        dataSource: _errorIntervalPoints.take(2).toList(),
        xValueMapper: (point, _) => point.x,
        yValueMapper: (point, _) => point.y,
        color: _orange,
        animationDuration: 0,
      ),
      sf.LineSeries<_ErrorLinePoint, double>(
        dataSource: _errorIntervalPoints.skip(2).toList(),
        xValueMapper: (point, _) => point.x,
        yValueMapper: (point, _) => point.y,
        color: _teal,
        width: 2,
        animationDuration: 0,
      ),
    ],
  ),
  ChartLibrary.graphic => Stack(
    children: [
      Positioned.fill(
        child: gr.Chart<StripPoint>(
          data: errorStripObservations,
          variables: {
            'x': gr.Variable(
              accessor: (point) => point.jitter,
              scale: gr.LinearScale(min: -.25, max: .25),
            ),
            'y': gr.Variable(
              accessor: (point) => point.value,
              scale: gr.LinearScale(
                min: errorStripEstimate.lower - .5,
                max: errorStripEstimate.upper + .5,
              ),
            ),
          },
          marks: [
            gr.PointMark(
              position: gr.Varset('x') * gr.Varset('y'),
              color: gr.ColorEncode(value: _blue),
              size: gr.SizeEncode(value: 5),
            ),
          ],
          axes: [],
          padding: (_) => EdgeInsets.zero,
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: gr.Chart<_ErrorLinePoint>(
            data: _errorIntervalPoints,
            variables: {
              'segment': gr.Variable(accessor: (point) => point.segment),
              'x': gr.Variable(
                accessor: (point) => point.x,
                scale: gr.LinearScale(min: -.25, max: .25),
              ),
              'y': gr.Variable(
                accessor: (point) => point.y,
                scale: gr.LinearScale(
                  min: errorStripEstimate.lower - .5,
                  max: errorStripEstimate.upper + .5,
                ),
              ),
            },
            marks: [
              gr.LineMark(
                position:
                    gr.Varset('x') * gr.Varset('y') / gr.Varset('segment'),
                color: gr.ColorEncode(
                  variable: 'segment',
                  values: const [_orange, _teal],
                ),
                size: gr.SizeEncode(value: 2),
              ),
            ],
            axes: [],
            padding: (_) => EdgeInsets.zero,
          ),
        ),
      ),
    ],
  ),
  ChartLibrary.graphify => throw StateError('Graphify is handled separately.'),
};

class _ContourLinePoint {
  const _ContourLinePoint(this.group, this.x, this.y, this.level);
  final String group;
  final double x, y, level;
}

final _contourLinePoints = [
  for (var i = 0; i < touristContour.segments.length; i++) ...[
    _ContourLinePoint(
      '$i',
      touristContour.segments[i].a.x,
      touristContour.segments[i].a.y,
      touristContour.segments[i].level,
    ),
    _ContourLinePoint(
      '$i',
      touristContour.segments[i].b.x,
      touristContour.segments[i].b.y,
      touristContour.segments[i].level,
    ),
  ],
];

Widget _contourObservations(ChartLibrary library) => switch (library) {
  ChartLibrary.flChart => fl.LineChart(
    fl.LineChartData(
      minX: 0,
      maxX: 24,
      minY: 0,
      maxY: 19,
      lineBarsData: [
        for (final segment in touristContour.segments)
          fl.LineChartBarData(
            spots: [
              fl.FlSpot(segment.a.x, segment.a.y),
              fl.FlSpot(segment.b.x, segment.b.y),
            ],
            color:
                Colors.primaries[touristContour.levels.indexOf(segment.level) %
                    Colors.primaries.length],
            barWidth: 1.5,
            dotData: const fl.FlDotData(show: false),
          ),
        fl.LineChartBarData(
          spots: [
            for (final point in contourObservations)
              fl.FlSpot(point.x, point.y),
          ],
          color: Colors.transparent,
          barWidth: 0,
          dotData: fl.FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => fl.FlDotCirclePainter(
              color: _orange,
              radius: 4,
              strokeWidth: 1,
            ),
          ),
        ),
      ],
    ),
  ),
  ChartLibrary.syncfusion => sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(minimum: 0, maximum: 24),
    primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 19),
    series: <sf.CartesianSeries<dynamic, dynamic>>[
      sf.ScatterSeries(
        dataSource: contourObservations,
        xValueMapper: (point, _) => point.x,
        yValueMapper: (point, _) => point.y,
        color: _orange,
        markerSettings: const sf.MarkerSettings(
          isVisible: true,
          width: 8,
          height: 8,
        ),
        animationDuration: 0,
      ),
      for (final segment in touristContour.segments)
        sf.LineSeries<FieldPoint, double>(
          dataSource: [segment.a, segment.b],
          xValueMapper: (point, _) => point.x,
          yValueMapper: (point, _) => point.y,
          color:
              Colors.primaries[touristContour.levels.indexOf(segment.level) %
                  Colors.primaries.length],
          width: 1.4,
          animationDuration: 0,
        ),
    ],
  ),
  ChartLibrary.graphic => Stack(
    children: [
      Positioned.fill(
        child: gr.Chart<_ContourLinePoint>(
          data: _contourLinePoints,
          variables: {
            'group': gr.Variable(accessor: (point) => point.group),
            'x': gr.Variable(
              accessor: (point) => point.x,
              scale: gr.LinearScale(min: 0, max: 24),
            ),
            'y': gr.Variable(
              accessor: (point) => point.y,
              scale: gr.LinearScale(min: 0, max: 19),
            ),
            'level': gr.Variable(accessor: (point) => point.level),
          },
          marks: [
            gr.LineMark(
              position: gr.Varset('x') * gr.Varset('y') / gr.Varset('group'),
              color: gr.ColorEncode(value: const Color(0xff2563eb)),
              size: gr.SizeEncode(value: 1.5),
            ),
          ],
          axes: [],
          padding: (_) => EdgeInsets.zero,
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: gr.Chart<FieldPoint>(
            data: contourObservations,
            variables: {
              'x': gr.Variable(
                accessor: (point) => point.x,
                scale: gr.LinearScale(min: 0, max: 24),
              ),
              'y': gr.Variable(
                accessor: (point) => point.y,
                scale: gr.LinearScale(min: 0, max: 19),
              ),
            },
            marks: [
              gr.PointMark(
                position: gr.Varset('x') * gr.Varset('y'),
                color: gr.ColorEncode(value: _orange),
                size: gr.SizeEncode(value: 5),
              ),
            ],
            axes: [],
            padding: (_) => EdgeInsets.zero,
          ),
        ),
      ),
    ],
  ),
  ChartLibrary.graphify => throw StateError('Graphify is handled separately.'),
};

Map<String, dynamic> supplementalGraphifyOptions(String id) => switch (id) {
  'control-distribution' => _graphifyControlDistribution(),
  'waterfall-cumulative' => _graphifyWaterfallCumulative(),
  'funnel-conversion' => _graphifyFunnelConversion(),
  'error-strip' => _graphifyErrorStrip(),
  'contour-observations' => _graphifyContourObservations(),
  _ => throw ArgumentError.value(id, 'id'),
};

Map<String, dynamic> _graphifyControlDistribution() => {
  'tooltip': {'trigger': 'axis'},
  'grid': [
    {'left': 48, 'right': 15, 'top': 22, 'height': '39%'},
    {'left': 48, 'right': 15, 'top': '61%', 'height': '29%'},
  ],
  'xAxis': [
    {
      'type': 'category',
      'gridIndex': 0,
      'data': [
        for (final point in controlDistributionChart.points) point.label,
      ],
    },
    {
      'type': 'category',
      'gridIndex': 1,
      'data': [for (final bin in controlDistributionBins) bin.label],
    },
    {
      'type': 'value',
      'gridIndex': 1,
      'min': controlDistributionBins.first.lowerBound,
      'max': controlDistributionBins.last.upperBound,
      'show': false,
    },
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Minutos'},
    {'type': 'value', 'gridIndex': 1, 'name': 'Frecuencia'},
  ],
  'series': [
    {
      'name': 'Observaciones',
      'type': 'line',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [
        for (final point in controlDistributionChart.points) point.value,
      ],
      'markLine': {
        'silent': true,
        'data': [
          {'yAxis': controlDistributionChart.stats.mean, 'name': 'Media'},
          {
            'yAxis': controlDistributionChart.stats.upperControlLimit,
            'name': 'UCL',
          },
          {
            'yAxis': controlDistributionChart.stats.lowerControlLimit,
            'name': 'LCL',
          },
        ],
      },
    },
    {
      'name': 'Frecuencia',
      'type': 'bar',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [for (final bin in controlDistributionBins) bin.frequency],
    },
    {
      'name': 'KDE · frecuencia esperada',
      'type': 'line',
      'xAxisIndex': 2,
      'yAxisIndex': 1,
      'showSymbol': false,
      'data': [
        for (final point in controlDistributionKdeAsFrequency)
          [point.x, point.y],
      ],
    },
  ],
};

Map<String, dynamic> _graphifyWaterfallCumulative() => {
  'tooltip': {'trigger': 'axis'},
  'legend': {},
  'xAxis': {
    'type': 'category',
    'data': [for (final bar in waterfallCumulativeBars) bar.step.label],
  },
  'yAxis': {'type': 'value', 'name': 'Millones COP', 'min': 0},
  'series': [
    {
      'name': 'Inicio de barra',
      'type': 'bar',
      'stack': 'waterfall',
      'silent': true,
      'itemStyle': {'color': 'rgba(0,0,0,0)'},
      'data': [
        for (final bar in waterfallCumulativeBars)
          bar.step.type == WaterfallType.decrease ? bar.endY : bar.startY,
      ],
    },
    {
      'name': 'Contribuciones',
      'type': 'bar',
      'stack': 'waterfall',
      'data': [
        for (final bar in waterfallCumulativeBars)
          {
            'name': '${bar.step.label} · acumulado ${bar.runningTotal}',
            'value': (bar.endY - bar.startY).abs(),
            'itemStyle': {
              'color': bar.contribution < 0 ? '#dc2626' : '#2563eb',
            },
          },
      ],
    },
    {
      'name': 'Running total',
      'type': 'line',
      'symbol': 'circle',
      'data': [for (final bar in waterfallCumulativeBars) bar.runningTotal],
    },
  ],
};

Map<String, dynamic> _graphifyFunnelConversion() => {
  'tooltip': {'trigger': 'item'},
  'grid': [
    {'left': '12%', 'right': '12%', 'top': 18, 'height': '40%'},
    {'left': 48, 'right': 18, 'top': '61%', 'height': '28%'},
  ],
  'xAxis': [
    {'type': 'value', 'gridIndex': 0, 'show': false},
    {
      'type': 'category',
      'gridIndex': 1,
      'data': [for (final step in funnelConversionSteps) step.stage.label],
    },
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'show': false},
    {
      'type': 'value',
      'gridIndex': 1,
      'name': 'Conversión %',
      'min': 0,
      'max': 110,
    },
  ],
  'series': [
    {
      'type': 'funnel',
      'name': 'Personas',
      'left': '12%',
      'top': 18,
      'bottom': '57%',
      'width': '76%',
      'min': 0,
      'max': bookingFunnel.maxValue,
      'sort': 'none',
      'data': [
        for (final step in funnelConversionSteps)
          {'name': step.stage.label, 'value': step.stage.value},
      ],
    },
    {
      'name': 'Desde anterior',
      'type': 'line',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'connectNulls': false,
      'data': [
        for (final step in funnelConversionSteps)
          {
            'name':
                '${step.stage.label} · drop-off ${step.dropOff?.toStringAsFixed(0) ?? '—'}',
            'value': step.conversionFromPrevious == null
                ? null
                : step.conversionFromPrevious! * 100,
          },
      ],
    },
    {
      'name': 'Desde inicio',
      'type': 'line',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [
        for (final step in funnelConversionSteps)
          {
            'name':
                '${step.stage.label} · drop-off ${step.dropOff?.toStringAsFixed(0) ?? '—'}',
            'value': (step.conversionFromStart ?? 0) * 100,
          },
      ],
    },
  ],
};

Map<String, dynamic> _graphifyErrorStrip() => {
  'tooltip': {'trigger': 'item'},
  'xAxis': {'type': 'value', 'min': -.25, 'max': .25, 'show': false},
  'yAxis': {
    'type': 'value',
    'name': 'Minutos',
    'min': errorStripEstimate.lower - .5,
    'max': errorStripEstimate.upper + .5,
  },
  'series': [
    {
      'name': 'Observaciones',
      'type': 'scatter',
      'symbolSize': 9,
      'data': [
        for (final point in errorStripObservations) [point.jitter, point.value],
      ],
    },
    {
      'name': 'IC 95 %',
      'type': 'line',
      'symbol': 'none',
      'lineStyle': {'color': '#ea580c', 'width': 3},
      'data': [
        [-.08, errorStripEstimate.lower],
        [-.08, errorStripEstimate.upper],
      ],
    },
    {
      'name': 'Media',
      'type': 'line',
      'symbol': 'none',
      'lineStyle': {'color': '#0f766e', 'width': 3},
      'data': [
        [-.16, errorStripEstimate.estimate],
        [0, errorStripEstimate.estimate],
      ],
    },
  ],
};

Map<String, dynamic> _graphifyContourObservations() => {
  'tooltip': {'trigger': 'item'},
  'xAxis': {'type': 'value', 'min': 0, 'max': 24, 'name': 'Este-oeste'},
  'yAxis': {'type': 'value', 'min': 0, 'max': 19, 'name': 'Norte-sur'},
  'series': [
    for (final segment in touristContour.segments)
      {
        'name': 'Isolínea ${segment.level.toStringAsFixed(1)}',
        'type': 'line',
        'showSymbol': false,
        'data': [
          [segment.a.x, segment.a.y],
          [segment.b.x, segment.b.y],
        ],
      },
    {
      'name': 'Observaciones',
      'type': 'scatter',
      'symbolSize': 10,
      'itemStyle': {
        'color': '#ea580c',
        'borderColor': '#fff',
        'borderWidth': 1,
      },
      'data': [
        for (final point in contourObservations)
          {
            'name': 'Intensidad ${point.z.toStringAsFixed(1)}',
            'value': [point.x, point.y],
          },
      ],
    },
  ],
};
