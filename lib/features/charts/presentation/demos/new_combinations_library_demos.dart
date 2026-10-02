import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;
import 'package:syncfusion_flutter_charts/sparkcharts.dart' as sf_spark;

import '../../data/advanced_distribution_data.dart';
import '../../data/chart_catalog.dart';
import '../../data/combination_data.dart';
import '../../data/composite_compact_data.dart';
import '../../data/distribution_basics_data.dart';
import '../../data/financial_planning_data.dart';
import '../../data/networks_diagnostics_spatial_data.dart';
import '../../data/performance_process_data.dart';
import '../../data/relationships_intervals_data.dart';
import '../../data/time_series_data.dart';
import '../../domain/chart_concept.dart';
import '../chart_renderer.dart';

/// Library-native views for combinations 11–20. Layout widgets are shared;
/// every plot is built from the selected charting library.
Widget buildNewLibraryCombination(String id, ChartLibrary library) {
  return switch (library) {
    ChartLibrary.flChart => _flCombination(id),
    ChartLibrary.syncfusion => _syncfusionCombination(id),
    ChartLibrary.graphic => _graphicCombination(id),
    ChartLibrary.graphify => throw ArgumentError(
      'Graphify uses ECharts options',
    ),
  };
}

Widget _flCombination(String id) => switch (id) {
  'scatter-marginals' => _flScatterMarginals(),
  'actual-forecast-fan' => _flForecastFan(),
  'range-area-center-line' => _flRangeCenter(),
  'histogram-box' => _flHistogramBox(),
  'distribution-diagnostics' => _flDistributionDiagnostics(),
  'candlestick-moving-average' => _flCandleAverage(),
  'stacked-area-total-line' => _flStackedArea(),
  'bullet-sparkline' => _flBulletSparkline(),
  'gantt-milestones' => _flGanttMilestones(),
  'calendar-monthly-trend' => _flCalendarTrend(),
  _ => throw ArgumentError.value(id, 'id'),
};

Widget _syncfusionCombination(String id) => switch (id) {
  'scatter-marginals' => _sfScatterMarginals(),
  'actual-forecast-fan' => _sfForecastFan(),
  'range-area-center-line' => _sfRangeCenter(),
  'histogram-box' => _sfHistogramBox(),
  'distribution-diagnostics' => _sfDistributionDiagnostics(),
  'candlestick-moving-average' => _sfCandleAverage(),
  'stacked-area-total-line' => _sfStackedArea(),
  'bullet-sparkline' => _sfBulletSparkline(),
  'gantt-milestones' => _sfGanttMilestones(),
  'calendar-monthly-trend' => _sfCalendarTrend(),
  _ => throw ArgumentError.value(id, 'id'),
};

Widget _graphicCombination(String id) => switch (id) {
  'scatter-marginals' => _graphicScatterMarginals(),
  'actual-forecast-fan' => _graphicForecastFan(),
  'range-area-center-line' => _graphicRangeCenter(),
  'histogram-box' => _graphicHistogramBox(),
  'distribution-diagnostics' => _graphicDistributionDiagnostics(),
  'candlestick-moving-average' => _graphicCandleAverage(),
  'stacked-area-total-line' => _graphicStackedArea(),
  'bullet-sparkline' => _graphicBulletSparkline(),
  'gantt-milestones' => _graphicGanttMilestones(),
  'calendar-monthly-trend' => _graphicCalendarTrend(),
  _ => throw ArgumentError.value(id, 'id'),
};

const _blue = Color(0xff2563eb);
const _orange = Color(0xffea580c);
const _green = Color(0xff16a34a);
const _purple = Color(0xff9333ea);
const _colors = [_blue, _orange, _green, _purple];

Widget _panels(List<(String, Widget)> panels) => Column(
  children: [
    for (var i = 0; i < panels.length; i++) ...[
      if (i > 0) const SizedBox(height: 3),
      Expanded(
        flex: panels.length == 3 ? 1 : 2,
        child: Column(
          children: [
            SizedBox(
              height: 18,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  panels[i].$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(child: panels[i].$2),
          ],
        ),
      ),
    ],
  ],
);

Widget _flScatterMarginals() => _panels([
  ('Histograma X · duración', _flHistogram(scatterMarginalXBins)),
  ('Dispersión · mismas observaciones', _flScatter()),
  ('Histograma Y · gasto', _flHistogram(scatterMarginalYBins)),
]);

Widget _flHistogram(List<HistogramBin> bins) => fl.BarChart(
  fl.BarChartData(
    minY: 0,
    barGroups: [
      for (var i = 0; i < bins.length; i++)
        fl.BarChartGroupData(
          x: i,
          barRods: [
            fl.BarChartRodData(
              toY: bins[i].frequency.toDouble(),
              color: _blue,
              width: 14,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
    ],
    titlesData: const fl.FlTitlesData(show: false),
    gridData: const fl.FlGridData(show: false),
    borderData: fl.FlBorderData(show: false),
  ),
);

Widget _flScatter() => fl.ScatterChart(
  fl.ScatterChartData(
    minX: 0,
    maxX: 8,
    minY: 0,
    maxY: 6000,
    titlesData: const fl.FlTitlesData(show: false),
    scatterSpots: [
      for (final point in scatterObservations)
        fl.ScatterSpot(
          point.nights,
          point.spendThousands,
          dotPainter: fl.FlDotCirclePainter(radius: 3.2, color: _blue),
        ),
    ],
  ),
);

Widget _flForecastFan() {
  final rows = actualForecastOccupancy;
  final bars = <fl.LineChartBarData>[
    fl.LineChartBarData(
      spots: [
        for (final p in rows.take(7))
          fl.FlSpot(rows.indexOf(p).toDouble(), p.value),
      ],
      color: _blue,
      barWidth: 2.6,
      dotData: const fl.FlDotData(show: true),
    ),
    for (final band in [
      (95, (Color(0x227c3aed))),
      (80, (Color(0x337c3aed))),
      (50, (Color(0x557c3aed))),
    ]) ...[
      fl.LineChartBarData(
        spots: [
          for (var i = 0; i < rows.length; i++)
            fl.FlSpot(
              i.toDouble(),
              rows[i].forecast == null
                  ? rows[5].value
                  : switch (band.$1) {
                      95 => rows[i].forecast!.lower95,
                      80 => rows[i].forecast!.lower80,
                      _ => rows[i].forecast!.lower50,
                    },
            ),
        ],
        color: Colors.transparent,
        barWidth: 0,
        dotData: const fl.FlDotData(show: false),
      ),
      fl.LineChartBarData(
        spots: [
          for (var i = 0; i < rows.length; i++)
            fl.FlSpot(
              i.toDouble(),
              rows[i].forecast == null
                  ? rows[5].value
                  : switch (band.$1) {
                      95 => rows[i].forecast!.upper95,
                      80 => rows[i].forecast!.upper80,
                      _ => rows[i].forecast!.upper50,
                    },
            ),
        ],
        color: Colors.transparent,
        barWidth: 0,
        dotData: const fl.FlDotData(show: false),
      ),
    ],
    fl.LineChartBarData(
      spots: [
        for (var i = 5; i < rows.length; i++)
          fl.FlSpot(i.toDouble(), rows[i].forecast?.median ?? rows[i].value),
      ],
      color: _purple,
      barWidth: 2,
      dotData: const fl.FlDotData(show: true),
    ),
  ];
  final fills = <fl.BetweenBarsData>[
    for (var i = 0; i < 3; i++)
      fl.BetweenBarsData(
        fromIndex: 1 + i * 2,
        toIndex: 2 + i * 2,
        color: [Color(0x227c3aed), Color(0x337c3aed), Color(0x557c3aed)][i],
      ),
  ];
  return Column(
    children: [
      const Text(
        'Histórico  ·  corte  ·  pronóstico 50 / 80 / 95 %',
        style: TextStyle(fontSize: 10),
      ),
      Expanded(
        child: fl.LineChart(
          fl.LineChartData(
            minX: 0,
            maxX: (rows.length - 1).toDouble(),
            minY: 40,
            maxY: 100,
            lineBarsData: bars,
            betweenBarsData: fills,
            extraLinesData: fl.ExtraLinesData(
              verticalLines: [
                fl.VerticalLine(x: 5.5, color: _orange, strokeWidth: 1.5),
              ],
            ),
            titlesData: const fl.FlTitlesData(show: false),
          ),
        ),
      ),
    ],
  );
}

Widget _flRangeCenter() {
  final low = fl.LineChartBarData(
    spots: [
      for (var i = 0; i < rangeAreaCenterPoints.length; i++)
        fl.FlSpot(i.toDouble(), rangeAreaCenterPoints[i].low),
    ],
    color: Colors.transparent,
    barWidth: 0,
    dotData: const fl.FlDotData(show: false),
  );
  final high = fl.LineChartBarData(
    spots: [
      for (var i = 0; i < rangeAreaCenterPoints.length; i++)
        fl.FlSpot(i.toDouble(), rangeAreaCenterPoints[i].high),
    ],
    color: Colors.transparent,
    barWidth: 0,
    dotData: const fl.FlDotData(show: false),
  );
  final center = fl.LineChartBarData(
    spots: [
      for (var i = 0; i < rangeAreaCenterPoints.length; i++)
        fl.FlSpot(i.toDouble(), rangeAreaCenterPoints[i].center),
    ],
    color: _orange,
    barWidth: 2.5,
    dotData: const fl.FlDotData(show: true),
  );
  return fl.LineChart(
    fl.LineChartData(
      minY: 45,
      maxY: 95,
      lineBarsData: [low, high, center],
      betweenBarsData: [
        fl.BetweenBarsData(
          fromIndex: 0,
          toIndex: 1,
          color: const Color(0x5560a5fa),
        ),
      ],
      titlesData: const fl.FlTitlesData(show: false),
    ),
  );
}

Widget _flHistogramBox() => _panels([
  ('Histograma · muestra completa', _flHistogram(histogramBoxBins)),
  ('Box plot · misma muestra', _flBoxPlot()),
]);

Widget _flBoxPlot() {
  final s = histogramBoxStats;
  final lines = [
    [fl.FlSpot(s.minWhisker, .5), fl.FlSpot(s.maxWhisker, .5)],
    [
      fl.FlSpot(s.q1, .3),
      fl.FlSpot(s.q1, .7),
      fl.FlSpot(s.q3, .7),
      fl.FlSpot(s.q3, .3),
      fl.FlSpot(s.q1, .3),
    ],
    [fl.FlSpot(s.median, .3), fl.FlSpot(s.median, .7)],
    [fl.FlSpot(s.minWhisker, .4), fl.FlSpot(s.minWhisker, .6)],
    [fl.FlSpot(s.maxWhisker, .4), fl.FlSpot(s.maxWhisker, .6)],
  ];
  return fl.LineChart(
    fl.LineChartData(
      minX: histogramBoxBins.first.lowerBound,
      maxX: histogramBoxBins.last.upperBound,
      minY: 0,
      maxY: 1,
      lineBarsData: [
        for (var i = 0; i < lines.length; i++)
          fl.LineChartBarData(
            spots: lines[i],
            color: i == 2 ? _orange : _blue,
            barWidth: i == 1 ? 7 : 2,
            dotData: const fl.FlDotData(show: false),
          ),
        for (final outlier in s.outliers)
          fl.LineChartBarData(
            spots: [fl.FlSpot(outlier, .5)],
            color: _orange,
            barWidth: 0,
            dotData: fl.FlDotData(
              show: true,
              getDotPainter: (_, _, _, _) =>
                  fl.FlDotCirclePainter(radius: 3, color: _orange),
            ),
          ),
      ],
      titlesData: const fl.FlTitlesData(show: false),
      gridData: const fl.FlGridData(show: false),
    ),
  );
}

Widget _flDistributionDiagnostics() => _panels([
  ('Histograma + KDE · misma muestra', _flHistogramKde()),
  ('Q-Q · muestra frente a normal', _flQq()),
]);

Widget _flHistogramKde() {
  final maxFrequency = distributionDiagnosticBins
      .map((b) => b.frequency)
      .reduce((a, b) => a > b ? a : b)
      .toDouble();
  final width =
      distributionDiagnosticBins.first.upperBound -
      distributionDiagnosticBins.first.lowerBound;
  return Stack(
    children: [
      fl.BarChart(
        fl.BarChartData(
          minY: 0,
          maxY: maxFrequency * 1.2,
          barGroups: [
            for (var i = 0; i < distributionDiagnosticBins.length; i++)
              fl.BarChartGroupData(
                x: i,
                barRods: [
                  fl.BarChartRodData(
                    toY: distributionDiagnosticBins[i].frequency.toDouble(),
                    color: const Color(0x884f83cc),
                    width: 14,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              ),
          ],
          titlesData: const fl.FlTitlesData(show: false),
          gridData: const fl.FlGridData(show: false),
          borderData: fl.FlBorderData(show: false),
        ),
      ),
      IgnorePointer(
        child: fl.LineChart(
          fl.LineChartData(
            minX: 0,
            maxX: (distributionDiagnosticBins.length - 1).toDouble(),
            minY: 0,
            maxY: maxFrequency * 1.2,
            lineBarsData: [
              fl.LineChartBarData(
                spots: [
                  for (var i = 0; i < distributionDiagnosticBins.length; i++)
                    () {
                      final x = distributionDiagnosticBins[i].midpoint;
                      final nearest = distributionDiagnosticKde.reduce(
                        (a, b) => (a.x - x).abs() < (b.x - x).abs() ? a : b,
                      );
                      return fl.FlSpot(
                        i.toDouble(),
                        nearest.y * distributionDiagnosticSample.length * width,
                      );
                    }(),
                ],
                color: _orange,
                barWidth: 2.5,
                dotData: const fl.FlDotData(show: false),
                belowBarData: fl.BarAreaData(show: false),
              ),
            ],
            titlesData: const fl.FlTitlesData(show: false),
            gridData: const fl.FlGridData(show: false),
            borderData: fl.FlBorderData(show: false),
          ),
        ),
      ),
    ],
  );
}

Widget _flQq() => fl.ScatterChart(
  fl.ScatterChartData(
    minX: -3,
    maxX: 3,
    minY: -3,
    maxY: 3,
    scatterSpots: [
      for (final p in distributionDiagnosticQq)
        fl.ScatterSpot(
          p.theoretical,
          p.observed,
          dotPainter: fl.FlDotCirclePainter(radius: 3, color: _blue),
        ),
    ],
    titlesData: const fl.FlTitlesData(show: false),
  ),
);

Widget _flCandleAverage() {
  final sma = simpleMovingAverage([
    for (final p in educationalOhlc) p.close,
  ], window: 3);
  final minX = -.5;
  final maxX = educationalOhlc.length - .5;
  const minY = 96.0, maxY = 114.0;
  final labels = fl.FlTitlesData(
    topTitles: const fl.AxisTitles(
      sideTitles: fl.SideTitles(showTitles: false),
    ),
    rightTitles: const fl.AxisTitles(
      sideTitles: fl.SideTitles(showTitles: false),
    ),
    leftTitles: const fl.AxisTitles(
      sideTitles: fl.SideTitles(showTitles: true, reservedSize: 34),
    ),
    bottomTitles: fl.AxisTitles(
      sideTitles: fl.SideTitles(
        showTitles: true,
        reservedSize: 22,
        getTitlesWidget: (v, meta) => v == v.round() && v.toInt() % 2 == 0
            ? Text(
                educationalOhlc[v.toInt()].period,
                style: const TextStyle(fontSize: 9),
              )
            : const SizedBox.shrink(),
      ),
    ),
  );
  return Stack(
    children: [
      fl.CandlestickChart(
        fl.CandlestickChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          candlestickSpots: [
            for (var i = 0; i < educationalOhlc.length; i++)
              fl.CandlestickSpot(
                x: i.toDouble(),
                open: educationalOhlc[i].open,
                high: educationalOhlc[i].high,
                low: educationalOhlc[i].low,
                close: educationalOhlc[i].close,
              ),
          ],
          titlesData: labels,
        ),
      ),
      IgnorePointer(
        child: fl.LineChart(
          fl.LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            titlesData: labels,
            gridData: const fl.FlGridData(show: false),
            borderData: fl.FlBorderData(show: false),
            lineBarsData: [
              fl.LineChartBarData(
                spots: [
                  for (var i = 2; i < educationalOhlc.length; i++)
                    fl.FlSpot(i.toDouble(), sma[i - 2]),
                ],
                color: _orange,
                barWidth: 2.5,
                dotData: const fl.FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _flStackedArea() {
  final rows = stackedAreaFor('stacked-area');
  final names = rows.map((p) => p.series).toSet().toList();
  final lines = <fl.LineChartBarData>[];
  final fills = <fl.BetweenBarsData>[];
  for (final name in names) {
    final series = rows.where((p) => p.series == name).toList()
      ..sort((a, b) => a.period.compareTo(b.period));
    final lowerIndex = lines.length;
    lines.add(
      fl.LineChartBarData(
        spots: [
          for (final p in series) fl.FlSpot(p.period.toDouble(), p.lower),
        ],
        color: Colors.transparent,
        barWidth: 0,
        dotData: const fl.FlDotData(show: false),
      ),
    );
    lines.add(
      fl.LineChartBarData(
        spots: [
          for (final p in series) fl.FlSpot(p.period.toDouble(), p.upper),
        ],
        color: Colors.transparent,
        barWidth: 0,
        dotData: const fl.FlDotData(show: false),
      ),
    );
    fills.add(
      fl.BetweenBarsData(
        fromIndex: lowerIndex,
        toIndex: lowerIndex + 1,
        color: _colors[fills.length % _colors.length].withValues(alpha: .3),
      ),
    );
  }
  lines.add(
    fl.LineChartBarData(
      spots: [
        for (final p in stackedAreaTotalLine)
          fl.FlSpot(p.period.toDouble(), p.value),
      ],
      color: Colors.black87,
      barWidth: 2.5,
      dotData: const fl.FlDotData(show: false),
    ),
  );
  return fl.LineChart(
    fl.LineChartData(
      lineBarsData: lines,
      betweenBarsData: fills,
      titlesData: const fl.FlTitlesData(show: false),
    ),
  );
}

Widget _flBulletSparkline() => _panels([
  ('Ingresos · bullet actual y meta', _flBullet()),
  ('Sparkline · últimos periodos', _flSparkline()),
]);

Widget _flBullet() {
  final metric = monthlyRevenueBullet;
  final bandColors = [
    const Color(0xffe2e8f0),
    const Color(0xff94a3b8),
    const Color(0xff64748b),
  ];
  return fl.BarChart(
    fl.BarChartData(
      rotationQuarterTurns: 1,
      minY: metric.min,
      maxY: metric.max,
      barGroups: [
        fl.BarChartGroupData(
          x: 0,
          barRods: [
            fl.BarChartRodData(
              toY: metric.max,
              width: 22,
              borderRadius: BorderRadius.zero,
              color: Colors.transparent,
              rodStackItems: [
                for (var i = 0; i < metric.bands.length; i++)
                  fl.BarChartRodStackItem(
                    metric.bands[i].start,
                    metric.bands[i].end,
                    bandColors[i % bandColors.length],
                  ),
              ],
            ),
            fl.BarChartRodData(
              fromY: 0,
              toY: metric.value,
              width: 9,
              color: _blue,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      ],
      extraLinesData: fl.ExtraLinesData(
        horizontalLines: [
          fl.HorizontalLine(y: metric.target, color: _orange, strokeWidth: 2),
        ],
      ),
      titlesData: const fl.FlTitlesData(show: false),
    ),
  );
}

Widget _flSparkline() => fl.LineChart(
  fl.LineChartData(
    minY: 0,
    titlesData: const fl.FlTitlesData(show: false),
    gridData: const fl.FlGridData(show: false),
    borderData: fl.FlBorderData(show: false),
    lineBarsData: [
      fl.LineChartBarData(
        spots: [
          for (var i = 0; i < bulletSparklinePoints.length; i++)
            fl.FlSpot(i.toDouble(), bulletSparklinePoints[i].value),
        ],
        color: _blue,
        barWidth: 2.5,
        dotData: const fl.FlDotData(show: true),
      ),
    ],
  ),
);

Widget _flGanttMilestones() {
  final origin = flutterFeatureTasks.first.start;
  double day(DateTime date) => date.difference(origin).inDays.toDouble();
  final dates = [
    ...flutterFeatureTasks.map((task) => task.start),
    ...flutterFeatureTasks.map((task) => task.end),
    ...ganttCombinationMilestones.events.map((event) => event.date),
  ];
  final minDay = dates.map(day).reduce((a, b) => a < b ? a : b);
  final maxDay = dates.map(day).reduce((a, b) => a > b ? a : b);
  final lanes = <String, double>{
    for (var i = 0; i < flutterFeatureTasks.length; i++)
      flutterFeatureTasks[i].label: i.toDouble(),
    for (var i = 0; i < ganttCombinationMilestones.events.length; i++)
      ganttCombinationMilestones.events[i].title:
          (flutterFeatureTasks.length + i).toDouble(),
  };
  final laneLabels = lanes.keys.toList();
  return Column(
    children: [
      const SizedBox(
        height: 18,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Tareas (azul) e hitos (naranja); fecha en el eje X',
            style: TextStyle(fontSize: 10),
          ),
        ),
      ),
      Expanded(
        child: fl.LineChart(
          fl.LineChartData(
            minX: minDay,
            maxX: maxDay,
            minY: -.5,
            maxY: lanes.length - .5,
            titlesData: fl.FlTitlesData(
              topTitles: const fl.AxisTitles(
                sideTitles: fl.SideTitles(showTitles: false),
              ),
              rightTitles: const fl.AxisTitles(
                sideTitles: fl.SideTitles(showTitles: false),
              ),
              leftTitles: fl.AxisTitles(
                sideTitles: fl.SideTitles(
                  showTitles: true,
                  reservedSize: 74,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    if (value != index ||
                        index < 0 ||
                        index >= laneLabels.length) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      laneLabels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8),
                    );
                  },
                ),
              ),
              bottomTitles: fl.AxisTitles(
                sideTitles: fl.SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: 4,
                  getTitlesWidget: (value, meta) => Text(
                    ganttDate(value),
                    style: const TextStyle(fontSize: 8),
                  ),
                ),
              ),
            ),
            lineBarsData: [
              for (final task in flutterFeatureTasks)
                fl.LineChartBarData(
                  spots: [
                    fl.FlSpot(day(task.start), lanes[task.label]!),
                    fl.FlSpot(day(task.end), lanes[task.label]!),
                  ],
                  color: _blue,
                  barWidth: 11,
                  dotData: const fl.FlDotData(show: false),
                ),
              for (final event in ganttCombinationMilestones.events)
                fl.LineChartBarData(
                  spots: [fl.FlSpot(day(event.date), lanes[event.title]!)],
                  color: _orange,
                  barWidth: 0,
                  dotData: fl.FlDotData(
                    show: true,
                    getDotPainter: (_, _, _, _) =>
                        fl.FlDotSquarePainter(size: 9, color: _orange),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _flCalendarTrend() => _panels([
  (
    'Calendario diario · renderer FL Chart',
    ChartRenderer.buildChart(
      concept: ChartCatalog.byId('calendar-heatmap'),
      library: ChartLibrary.flChart,
    ),
  ),
  ('Reservas mensuales · suma derivada', _flMonthlyLine()),
]);

Widget _flMonthlyLine() => fl.LineChart(
  fl.LineChartData(
    titlesData: const fl.FlTitlesData(show: false),
    lineBarsData: [
      fl.LineChartBarData(
        spots: [
          for (var i = 0; i < calendarMonthlyTotals.length; i++)
            fl.FlSpot(i.toDouble(), calendarMonthlyTotals[i].total),
        ],
        color: _blue,
        barWidth: 2.5,
        dotData: const fl.FlDotData(show: true),
      ),
    ],
  ),
);

// Syncfusion chart compositions.

Widget _sfScatterMarginals() => _panels([
  ('Histograma X · duración', _sfHistogram(scatterMarginalXBins)),
  ('Dispersión · mismas observaciones', _sfScatter()),
  ('Histograma Y · gasto', _sfHistogram(scatterMarginalYBins)),
]);

Widget _sfHistogram(List<HistogramBin> bins) => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(isVisible: false),
  primaryYAxis: const sf.NumericAxis(isVisible: false),
  margin: EdgeInsets.zero,
  series: <sf.CartesianSeries<HistogramBin, double>>[
    sf.ColumnSeries<HistogramBin, double>(
      dataSource: bins,
      xValueMapper: (b, _) => b.midpoint,
      yValueMapper: (b, _) => b.frequency,
      color: _blue,
      animationDuration: 0,
    ),
  ],
);

Widget _sfScatter() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(minimum: 0, maximum: 8, isVisible: false),
  primaryYAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 6000,
    isVisible: false,
  ),
  margin: EdgeInsets.zero,
  series: <sf.CartesianSeries<ScatterObservation, double>>[
    sf.ScatterSeries<ScatterObservation, double>(
      dataSource: scatterObservations,
      xValueMapper: (p, _) => p.nights,
      yValueMapper: (p, _) => p.spendThousands,
      markerSettings: const sf.MarkerSettings(width: 7, height: 7),
      animationDuration: 0,
    ),
  ],
);

Widget _sfForecastFan() {
  final forecast = actualForecastOccupancy
      .where((p) => p.forecast != null)
      .toList();
  return sf.SfCartesianChart(
    primaryXAxis: const sf.CategoryAxis(),
    primaryYAxis: const sf.NumericAxis(minimum: 40, maximum: 100),
    legend: const sf.Legend(isVisible: false),
    series: <sf.CartesianSeries<dynamic, String>>[
      for (final bounds in [
        (95, Color(0x227c3aed)),
        (80, Color(0x337c3aed)),
        (50, Color(0x557c3aed)),
      ])
        sf.RangeAreaSeries<OccupancyPeriod, String>(
          dataSource: forecast,
          xValueMapper: (p, _) => p.period,
          lowValueMapper: (p, _) => switch (bounds.$1) {
            95 => p.forecast!.lower95,
            80 => p.forecast!.lower80,
            _ => p.forecast!.lower50,
          },
          highValueMapper: (p, _) => switch (bounds.$1) {
            95 => p.forecast!.upper95,
            80 => p.forecast!.upper80,
            _ => p.forecast!.upper50,
          },
          color: bounds.$2,
          borderWidth: 0,
          animationDuration: 0,
        ),
      sf.LineSeries<OccupancyPeriod, String>(
        name: 'Histórico',
        dataSource: actualForecastOccupancy.take(7).toList(),
        xValueMapper: (p, _) => p.period,
        yValueMapper: (p, _) => p.value,
        color: _blue,
        markerSettings: const sf.MarkerSettings(isVisible: true),
        animationDuration: 0,
      ),
      sf.LineSeries<OccupancyPeriod, String>(
        name: 'Mediana prevista',
        dataSource: actualForecastOccupancy.skip(5).toList(),
        xValueMapper: (p, _) => p.period,
        yValueMapper: (p, _) => p.forecast?.median ?? p.value,
        color: _purple,
        markerSettings: const sf.MarkerSettings(isVisible: true),
        animationDuration: 0,
      ),
    ],
  );
}

Widget _sfRangeCenter() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(minimum: 45, maximum: 95),
  series: <sf.CartesianSeries<RangeCenterPoint, String>>[
    sf.RangeAreaSeries<RangeCenterPoint, String>(
      dataSource: rangeAreaCenterPoints,
      xValueMapper: (p, _) => p.period,
      lowValueMapper: (p, _) => p.low,
      highValueMapper: (p, _) => p.high,
      color: const Color(0x5560a5fa),
      animationDuration: 0,
    ),
    sf.LineSeries<RangeCenterPoint, String>(
      dataSource: rangeAreaCenterPoints,
      xValueMapper: (p, _) => p.period,
      yValueMapper: (p, _) => p.center,
      color: _orange,
      markerSettings: const sf.MarkerSettings(isVisible: true),
      animationDuration: 0,
    ),
  ],
);

final _boxSampleGroup = DistributionGroup(
  label: 'Muestra',
  values: histogramBoxSample,
);

Widget _sfHistogramBox() => _panels([
  ('Histograma · muestra completa', _sfHistogram(histogramBoxBins)),
  (
    'Box plot · misma muestra',
    sf.SfCartesianChart(
      primaryXAxis: const sf.CategoryAxis(),
      primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 30),
      series: <sf.CartesianSeries<DistributionGroup, String>>[
        sf.BoxAndWhiskerSeries<DistributionGroup, String>(
          dataSource: [_boxSampleGroup],
          xValueMapper: (g, _) => g.label,
          yValueMapper: (g, _) => g.values,
          boxPlotMode: sf.BoxPlotMode.inclusive,
          animationDuration: 0,
        ),
      ],
    ),
  ),
]);

Widget _sfDistributionDiagnostics() => _panels([
  ('Histograma + KDE · misma muestra', _sfHistogramKde()),
  ('Q-Q · muestra frente a normal', _sfQq()),
]);

Widget _sfHistogramKde() {
  final width =
      distributionDiagnosticBins.first.upperBound -
      distributionDiagnosticBins.first.lowerBound;
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(isVisible: false),
    primaryYAxis: const sf.NumericAxis(minimum: 0),
    margin: EdgeInsets.zero,
    series: <sf.CartesianSeries<dynamic, double>>[
      sf.ColumnSeries<HistogramBin, double>(
        dataSource: distributionDiagnosticBins,
        xValueMapper: (b, _) => b.midpoint,
        yValueMapper: (b, _) => b.frequency,
        color: const Color(0x884f83cc),
        animationDuration: 0,
      ),
      sf.SplineSeries<DistributionPoint, double>(
        dataSource: distributionDiagnosticKde,
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) =>
            p.y * distributionDiagnosticSample.length * width,
        color: _orange,
        animationDuration: 0,
      ),
    ],
  );
}

class _QqRow {
  const _QqRow(this.theoretical, this.observed);
  final double theoretical, observed;
}

Widget _sfQq() {
  final rows = [
    for (final p in distributionDiagnosticQq) _QqRow(p.theoretical, p.observed),
  ];
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(
      minimum: -3,
      maximum: 3,
      isVisible: false,
    ),
    primaryYAxis: const sf.NumericAxis(
      minimum: -3,
      maximum: 3,
      isVisible: false,
    ),
    series: <sf.CartesianSeries<_QqRow, double>>[
      sf.ScatterSeries<_QqRow, double>(
        dataSource: rows,
        xValueMapper: (p, _) => p.theoretical,
        yValueMapper: (p, _) => p.observed,
        markerSettings: const sf.MarkerSettings(width: 6, height: 6),
        animationDuration: 0,
      ),
    ],
  );
}

class _CandleAveragePoint {
  const _CandleAveragePoint(this.period, this.sma);
  final String period;
  final double sma;
}

final _candleAveragePoints = (() {
  final values = simpleMovingAverage([
    for (final p in educationalOhlc) p.close,
  ], window: 3);
  return [
    for (var i = 2; i < educationalOhlc.length; i++)
      _CandleAveragePoint(educationalOhlc[i].period, values[i - 2]),
  ];
})();

Widget _sfCandleAverage() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(minimum: 96, maximum: 114),
  series: <sf.CartesianSeries<dynamic, String>>[
    sf.CandleSeries<OhlcPoint, String>(
      dataSource: educationalOhlc,
      xValueMapper: (p, _) => p.period,
      openValueMapper: (p, _) => p.open,
      highValueMapper: (p, _) => p.high,
      lowValueMapper: (p, _) => p.low,
      closeValueMapper: (p, _) => p.close,
      animationDuration: 0,
    ),
    sf.LineSeries<_CandleAveragePoint, String>(
      dataSource: _candleAveragePoints,
      xValueMapper: (p, _) => p.period,
      yValueMapper: (p, _) => p.sma,
      color: _orange,
      markerSettings: const sf.MarkerSettings(isVisible: true),
      animationDuration: 0,
    ),
  ],
);

Widget _sfStackedArea() {
  final rows = stackedAreaFor('stacked-area');
  final names = rows.map((p) => p.series).toSet().toList();
  final series = <sf.CartesianSeries<dynamic, int>>[
    for (final name in names)
      sf.StackedAreaSeries<StackedAreaPoint, int>(
        dataSource: rows.where((p) => p.series == name).toList(),
        xValueMapper: (p, _) => p.period,
        yValueMapper: (p, _) => p.value,
        name: name,
        color: _colors[names.indexOf(name) % _colors.length].withValues(
          alpha: .65,
        ),
        animationDuration: 0,
      ),
    sf.LineSeries<PeriodValue, int>(
      dataSource: stackedAreaTotalLine,
      xValueMapper: (p, _) => p.period,
      yValueMapper: (p, _) => p.value,
      color: Colors.black87,
      width: 2.5,
      animationDuration: 0,
    ),
  ];
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(),
    series: series,
  );
}

Widget _sfBulletSparkline() => _panels([
  ('Ingresos · bullet actual y meta', _sfBullet()),
  (
    'Sparkline · últimos periodos',
    sf_spark.SfSparkLineChart(
      data: [for (final p in bulletSparklinePoints) p.value],
      color: _blue,
      width: 2,
      lastPointColor: _orange,
    ),
  ),
]);

class _BulletPoint {
  const _BulletPoint(this.label, this.amount, this.kind);
  final String label, kind;
  final double amount;
}

Widget _sfBullet() {
  final metric = monthlyRevenueBullet;
  final rows = [
    for (var i = 0; i < metric.bands.length; i++)
      _BulletPoint(
        metric.label,
        metric.bands[i].end - metric.bands[i].start,
        'rango$i',
      ),
  ];
  final actual = _BulletPoint(metric.label, metric.value, 'actual');
  final target = _BulletPoint(metric.label, metric.target, 'meta');
  return sf.SfCartesianChart(
    isTransposed: true,
    primaryXAxis: const sf.CategoryAxis(),
    primaryYAxis: sf.NumericAxis(minimum: metric.min, maximum: metric.max),
    series: <sf.CartesianSeries<dynamic, String>>[
      for (var i = 0; i < rows.length; i++)
        sf.StackedBarSeries<_BulletPoint, String>(
          dataSource: [rows[i]],
          xValueMapper: (p, _) => p.label,
          yValueMapper: (p, _) => p.amount,
          color: [
            const Color(0xffe2e8f0),
            const Color(0xff94a3b8),
            const Color(0xff64748b),
          ][i],
          groupName: 'qualitative-ranges',
          animationDuration: 0,
        ),
      sf.BarSeries<_BulletPoint, String>(
        dataSource: [actual],
        xValueMapper: (p, _) => p.label,
        yValueMapper: (p, _) => p.amount,
        color: _blue,
        animationDuration: 0,
      ),
      sf.ScatterSeries<_BulletPoint, String>(
        dataSource: [target],
        xValueMapper: (p, _) => p.label,
        yValueMapper: (p, _) => p.amount,
        color: _orange,
        markerSettings: const sf.MarkerSettings(
          width: 10,
          height: 10,
          shape: sf.DataMarkerType.verticalLine,
        ),
        animationDuration: 0,
      ),
    ],
  );
}

Widget _sfGanttMilestones() => sf.SfCartesianChart(
  isTransposed: true,
  primaryXAxis: const sf.CategoryAxis(isInversed: true),
  primaryYAxis: const sf.NumericAxis(minimum: 1, maximum: 21, interval: 4),
  series: <sf.CartesianSeries<dynamic, String>>[
    sf.RangeColumnSeries<_GanttPlotRow, String>(
      dataSource: [
        for (final task in flutterFeatureTasks)
          _GanttPlotRow(task.label, ganttDay(task.start), ganttDay(task.end)),
      ],
      xValueMapper: (p, _) => p.label,
      lowValueMapper: (p, _) => p.start,
      highValueMapper: (p, _) => p.end,
      color: _blue,
      animationDuration: 0,
    ),
    sf.ScatterSeries<_GanttPlotRow, String>(
      dataSource: [
        for (final event in ganttCombinationMilestones.events)
          _GanttPlotRow(
            '◆ ${event.title}',
            ganttDay(event.date),
            ganttDay(event.date),
          ),
      ],
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => p.start,
      markerSettings: const sf.MarkerSettings(
        width: 9,
        height: 9,
        shape: sf.DataMarkerType.diamond,
        color: _orange,
      ),
      animationDuration: 0,
    ),
  ],
);

class _GanttPlotRow {
  const _GanttPlotRow(this.label, this.start, this.end);
  final String label;
  final double start, end;
}

Widget _sfCalendarTrend() => _panels([
  (
    'Calendario diario · renderer Syncfusion',
    ChartRenderer.buildChart(
      concept: ChartCatalog.byId('calendar-heatmap'),
      library: ChartLibrary.syncfusion,
    ),
  ),
  (
    'Reservas mensuales · suma derivada',
    sf.SfCartesianChart(
      primaryXAxis: const sf.CategoryAxis(),
      primaryYAxis: const sf.NumericAxis(),
      series: <sf.CartesianSeries<MonthlyCalendarTotal, String>>[
        sf.LineSeries<MonthlyCalendarTotal, String>(
          dataSource: calendarMonthlyTotals,
          xValueMapper: (p, _) => '${p.month}/${p.year}',
          yValueMapper: (p, _) => p.total,
          color: _blue,
          markerSettings: const sf.MarkerSettings(isVisible: true),
          animationDuration: 0,
        ),
      ],
    ),
  ),
]);

// Graphic charts use the package's data encodings and marks.

Widget _graphicScatterMarginals() => _panels([
  ('Histograma X · duración', _grHistogram(scatterMarginalXBins)),
  (
    'Dispersión · mismas observaciones',
    gr.Chart<ScatterObservation>(
      data: scatterObservations,
      variables: {
        'x': gr.Variable(
          accessor: (p) => p.nights,
          scale: gr.LinearScale(min: 0, max: 8),
        ),
        'y': gr.Variable(
          accessor: (p) => p.spendThousands,
          scale: gr.LinearScale(min: 0, max: 6000),
        ),
      },
      marks: [
        gr.PointMark(
          position: gr.Varset('x') * gr.Varset('y'),
          color: gr.ColorEncode(value: _blue),
          size: gr.SizeEncode(value: 7),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    ),
  ),
  ('Histograma Y · gasto', _grHorizontalHistogram(scatterMarginalYBins)),
]);

Widget _grHistogram(List<HistogramBin> bins) {
  final maxFrequency = bins
      .map((bin) => bin.frequency)
      .reduce((a, b) => a > b ? a : b)
      .toDouble();
  final countScale = gr.LinearScale(
    min: 0,
    max: maxFrequency == 0 ? 1 : maxFrequency,
  );
  return gr.Chart<HistogramBin>(
    data: bins,
    variables: {
      'x': gr.Variable(accessor: (b) => b.midpoint),
      'lo': gr.Variable(accessor: (b) => 0.0, scale: countScale),
      'hi': gr.Variable(
        accessor: (b) => b.frequency.toDouble(),
        scale: countScale,
      ),
    },
    marks: [
      gr.IntervalMark(
        position: gr.Varset('x') * (gr.Varset('lo') + gr.Varset('hi')),
        color: gr.ColorEncode(value: _blue),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

Widget _grHorizontalHistogram(List<HistogramBin> bins) {
  final maxFrequency = bins
      .map((bin) => bin.frequency)
      .reduce((a, b) => a > b ? a : b)
      .toDouble();
  final countScale = gr.LinearScale(
    min: 0,
    max: maxFrequency == 0 ? 1 : maxFrequency,
  );
  return gr.Chart<HistogramBin>(
    data: bins,
    variables: {
      'lo': gr.Variable(accessor: (b) => 0.0, scale: countScale),
      'hi': gr.Variable(
        accessor: (b) => b.frequency.toDouble(),
        scale: countScale,
      ),
      'mid': gr.Variable(accessor: (b) => b.midpoint),
    },
    marks: [
      gr.IntervalMark(
        position: (gr.Varset('lo') + gr.Varset('hi')) * gr.Varset('mid'),
        color: gr.ColorEncode(value: _blue),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

class _ForecastGraphicRow {
  const _ForecastGraphicRow(
    this.period,
    this.value,
    this.phase,
    this.low95,
    this.high95,
    this.low80,
    this.high80,
    this.low50,
    this.high50,
  );
  final String period, phase;
  final double value, low95, high95, low80, high80, low50, high50;
}

final _forecastGraphicRows = [
  for (final p in actualForecastOccupancy)
    _ForecastGraphicRow(
      p.period,
      p.forecast?.median ?? p.value,
      p.forecast == null ? 'Histórico' : 'Pronóstico',
      p.forecast?.lower95 ?? p.value,
      p.forecast?.upper95 ?? p.value,
      p.forecast?.lower80 ?? p.value,
      p.forecast?.upper80 ?? p.value,
      p.forecast?.lower50 ?? p.value,
      p.forecast?.upper50 ?? p.value,
    ),
];

Widget _graphicForecastFan() {
  final occupancyScale = gr.LinearScale(min: 40, max: 100);
  return Column(
    children: [
      const Text(
        'Histórico  ·  corte  ·  mediana y bandas',
        style: TextStyle(fontSize: 10),
      ),
      Expanded(
        child: gr.Chart<_ForecastGraphicRow>(
          data: _forecastGraphicRows,
          variables: {
            'period': gr.Variable(accessor: (p) => p.period),
            'phase': gr.Variable(accessor: (p) => p.phase),
            'value': gr.Variable(
              accessor: (p) => p.value,
              scale: occupancyScale,
            ),
            'low95': gr.Variable(
              accessor: (p) => p.low95,
              scale: occupancyScale,
            ),
            'high95': gr.Variable(
              accessor: (p) => p.high95,
              scale: occupancyScale,
            ),
            'low80': gr.Variable(
              accessor: (p) => p.low80,
              scale: occupancyScale,
            ),
            'high80': gr.Variable(
              accessor: (p) => p.high80,
              scale: occupancyScale,
            ),
            'low50': gr.Variable(
              accessor: (p) => p.low50,
              scale: occupancyScale,
            ),
            'high50': gr.Variable(
              accessor: (p) => p.high50,
              scale: occupancyScale,
            ),
          },
          marks: [
            gr.AreaMark(
              position:
                  gr.Varset('period') *
                  (gr.Varset('low95') + gr.Varset('high95')),
              color: gr.ColorEncode(value: const Color(0x227c3aed)),
            ),
            gr.AreaMark(
              position:
                  gr.Varset('period') *
                  (gr.Varset('low80') + gr.Varset('high80')),
              color: gr.ColorEncode(value: const Color(0x337c3aed)),
            ),
            gr.AreaMark(
              position:
                  gr.Varset('period') *
                  (gr.Varset('low50') + gr.Varset('high50')),
              color: gr.ColorEncode(value: const Color(0x557c3aed)),
            ),
            gr.LineMark(
              position:
                  gr.Varset('period') * gr.Varset('value') / gr.Varset('phase'),
              color: gr.ColorEncode(
                variable: 'phase',
                values: [_blue, _purple],
              ),
            ),
          ],
          axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
        ),
      ),
    ],
  );
}

Widget _graphicRangeCenter() {
  final occupancyScale = gr.LinearScale(min: 45, max: 95);
  return gr.Chart<RangeCenterPoint>(
    data: rangeAreaCenterPoints,
    variables: {
      'period': gr.Variable(accessor: (p) => p.period),
      'low': gr.Variable(accessor: (p) => p.low, scale: occupancyScale),
      'high': gr.Variable(accessor: (p) => p.high, scale: occupancyScale),
      'center': gr.Variable(accessor: (p) => p.center, scale: occupancyScale),
    },
    marks: [
      gr.AreaMark(
        position: gr.Varset('period') * (gr.Varset('low') + gr.Varset('high')),
        color: gr.ColorEncode(value: const Color(0x5560a5fa)),
      ),
      gr.LineMark(
        position: gr.Varset('period') * gr.Varset('center'),
        color: gr.ColorEncode(value: _orange),
        size: gr.SizeEncode(value: 2.5),
      ),
      gr.PointMark(
        position: gr.Varset('period') * gr.Varset('center'),
        color: gr.ColorEncode(value: _orange),
        size: gr.SizeEncode(value: 4),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

class _BoxSegment {
  const _BoxSegment(this.group, this.low, this.high, this.kind);
  final String group, kind;
  final double low, high;
}

final _boxSegments = [
  _BoxSegment(
    'Muestra',
    histogramBoxStats.minWhisker,
    histogramBoxStats.maxWhisker,
    'bigotes',
  ),
  _BoxSegment('Muestra', histogramBoxStats.q1, histogramBoxStats.q3, 'caja'),
  _BoxSegment(
    'Muestra',
    histogramBoxStats.median,
    histogramBoxStats.median,
    'mediana',
  ),
  for (final outlier in histogramBoxStats.outliers)
    _BoxSegment('Muestra', outlier, outlier, 'atipico'),
];

Widget _graphicHistogramBox() {
  final sampleScale = gr.LinearScale(
    min: histogramBoxBins.first.lowerBound,
    max: histogramBoxBins.last.upperBound,
  );
  return _panels([
    ('Histograma - muestra completa', _grHistogram(histogramBoxBins)),
    (
      'Box plot - misma muestra',
      gr.Chart<_BoxSegment>(
        data: _boxSegments,
        variables: {
          'group': gr.Variable(accessor: (p) => p.group),
          'low': gr.Variable(accessor: (p) => p.low, scale: sampleScale),
          'high': gr.Variable(accessor: (p) => p.high, scale: sampleScale),
          'kind': gr.Variable(accessor: (p) => p.kind),
        },
        marks: [
          gr.IntervalMark(
            position:
                gr.Varset('group') * (gr.Varset('low') + gr.Varset('high')),
            color: gr.ColorEncode(
              variable: 'kind',
              values: [_blue, const Color(0x8860a5fa), _orange, _orange],
            ),
          ),
          gr.PointMark(
            position: gr.Varset('group') * gr.Varset('low'),
            color: gr.ColorEncode(value: _orange),
            size: gr.SizeEncode(variable: 'kind', values: [0, 0, 0, 5]),
          ),
        ],
        coord: gr.RectCoord(transposed: true),
        axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      ),
    ),
  ]);
}

Widget _graphicDistributionDiagnostics() => _panels([
  (
    'Histograma + KDE · misma muestra',
    Column(
      children: [
        Expanded(child: _grHistogram(distributionDiagnosticBins)),
        Expanded(
          child: gr.Chart<DistributionPoint>(
            data: distributionDiagnosticKde,
            variables: {
              'x': gr.Variable(accessor: (p) => p.x),
              'density': gr.Variable(accessor: (p) => p.y),
            },
            marks: [
              gr.LineMark(
                position: gr.Varset('x') * gr.Varset('density'),
                color: gr.ColorEncode(value: _orange),
              ),
            ],
            axes: [],
          ),
        ),
      ],
    ),
  ),
  (
    'Q-Q · muestra frente a normal',
    gr.Chart<QqPoint>(
      data: distributionDiagnosticQq,
      variables: {
        'theoretical': gr.Variable(accessor: (p) => p.theoretical),
        'observed': gr.Variable(accessor: (p) => p.observed),
      },
      marks: [
        gr.PointMark(
          position: gr.Varset('theoretical') * gr.Varset('observed'),
          color: gr.ColorEncode(value: _blue),
          size: gr.SizeEncode(value: 6),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    ),
  ),
]);

Widget _graphicCandleAverage() => _panels([
  (
    'Velas · OHLC educativo',
    ChartRenderer.buildChart(
      concept: ChartCatalog.byId('candlestick'),
      library: ChartLibrary.graphic,
    ),
  ),
  (
    'SMA(3) · cierres',
    gr.Chart<_CandleAveragePoint>(
      data: _candleAveragePoints,
      variables: {
        'period': gr.Variable(accessor: (p) => p.period),
        'sma': gr.Variable(accessor: (p) => p.sma),
      },
      marks: [
        gr.LineMark(
          position: gr.Varset('period') * gr.Varset('sma'),
          color: gr.ColorEncode(value: _orange),
        ),
        gr.PointMark(
          position: gr.Varset('period') * gr.Varset('sma'),
          color: gr.ColorEncode(value: _orange),
          size: gr.SizeEncode(value: 4),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    ),
  ),
]);

Widget _graphicStackedArea() {
  final rows = stackedAreaFor('stacked-area');
  final areaMax = stackedAreaTotalLine
      .map((point) => point.value)
      .reduce((a, b) => a > b ? a : b);
  final areaScale = gr.LinearScale(min: 0, max: areaMax);
  return gr.Chart<StackedAreaPoint>(
    data: rows,
    variables: {
      'period': gr.Variable(accessor: (p) => p.label),
      'series': gr.Variable(accessor: (p) => p.series),
      'lower': gr.Variable(accessor: (p) => p.lower, scale: areaScale),
      'upper': gr.Variable(accessor: (p) => p.upper, scale: areaScale),
      'total': gr.Variable(accessor: (p) => p.total, scale: areaScale),
    },
    marks: [
      gr.AreaMark(
        position:
            gr.Varset('period') *
            (gr.Varset('lower') + gr.Varset('upper')) /
            gr.Varset('series'),
        color: gr.ColorEncode(variable: 'series', values: _colors),
      ),
      gr.LineMark(
        position: gr.Varset('period') * gr.Varset('total'),
        color: gr.ColorEncode(value: Colors.black87),
        size: gr.SizeEncode(value: 2.5),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

class _BulletMarkRow {
  const _BulletMarkRow(
    this.category,
    this.start,
    this.end,
    this.position,
    this.kind,
  );
  final String category, kind;
  final double start, end, position;
}

final _bulletMarkRows = [
  for (var i = 0; i < monthlyRevenueBullet.bands.length; i++)
    _BulletMarkRow(
      monthlyRevenueBullet.label,
      monthlyRevenueBullet.bands[i].start,
      monthlyRevenueBullet.bands[i].end,
      monthlyRevenueBullet.value,
      'rango$i',
    ),
  _BulletMarkRow(
    monthlyRevenueBullet.label,
    0,
    0,
    monthlyRevenueBullet.value,
    'actual',
  ),
  _BulletMarkRow(
    monthlyRevenueBullet.label,
    0,
    0,
    monthlyRevenueBullet.target,
    'meta',
  ),
];

final _graphicBulletScale = gr.LinearScale(min: 0, max: 100);

Widget _graphicBulletSparkline() => _panels([
  (
    'Ingresos: actual y meta',
    gr.Chart<_BulletMarkRow>(
      data: _bulletMarkRows,
      variables: {
        'category': gr.Variable(accessor: (p) => p.category),
        'start': gr.Variable(
          accessor: (p) => p.start,
          scale: _graphicBulletScale,
        ),
        'end': gr.Variable(accessor: (p) => p.end, scale: _graphicBulletScale),
        'position': gr.Variable(
          accessor: (p) => p.position,
          scale: _graphicBulletScale,
        ),
        'kind': gr.Variable(accessor: (p) => p.kind),
      },
      marks: [
        gr.IntervalMark(
          position:
              (gr.Varset('start') + gr.Varset('end')) * gr.Varset('category'),
          color: gr.ColorEncode(value: const Color(0xffcbd5e1)),
        ),
        gr.PointMark(
          position: gr.Varset('position') * gr.Varset('category'),
          color: gr.ColorEncode(
            variable: 'kind',
            values: [_blue, _blue, _blue, _blue, _orange],
          ),
          size: gr.SizeEncode(variable: 'kind', values: [0, 0, 0, 8, 8]),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    ),
  ),
  (
    'Tendencia reciente',
    gr.Chart<SparklinePoint>(
      data: bulletSparklinePoints,
      variables: {
        'period': gr.Variable(accessor: (p) => p.period),
        'value': gr.Variable(accessor: (p) => p.value),
      },
      marks: [
        gr.LineMark(
          position: gr.Varset('period') * gr.Varset('value'),
          color: gr.ColorEncode(value: _blue),
        ),
        gr.PointMark(
          position: gr.Varset('period') * gr.Varset('value'),
          color: gr.ColorEncode(value: _blue),
          size: gr.SizeEncode(value: 3),
        ),
      ],
      axes: [],
    ),
  ),
]);

class _GraphicGanttRow {
  const _GraphicGanttRow(
    this.label,
    this.start,
    this.end,
    this.date,
    this.kind,
  );
  final String label, kind;
  final double start, end, date;
}

final _graphicGanttTimeScale = gr.LinearScale(min: 1, max: 21);

Widget _graphicGanttMilestones() => Column(
  children: [
    const SizedBox(
      height: 18,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Intervalos de tareas y hitos · mismo eje temporal',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    Expanded(
      child: gr.Chart<_GraphicGanttRow>(
        data: [
          for (final task in flutterFeatureTasks)
            _GraphicGanttRow(
              task.label,
              ganttDay(task.start),
              ganttDay(task.end),
              ganttDay(task.start),
              'Tarea',
            ),
          for (final event in ganttCombinationMilestones.events)
            _GraphicGanttRow(
              '◆ ${event.title}',
              ganttDay(event.date),
              ganttDay(event.date),
              ganttDay(event.date),
              'Hito',
            ),
        ],
        variables: {
          'label': gr.Variable(accessor: (p) => p.label),
          'start': gr.Variable(
            accessor: (p) => p.start,
            scale: _graphicGanttTimeScale,
          ),
          'end': gr.Variable(
            accessor: (p) => p.end,
            scale: _graphicGanttTimeScale,
          ),
          'date': gr.Variable(
            accessor: (p) => p.date,
            scale: _graphicGanttTimeScale,
          ),
          'kind': gr.Variable(accessor: (p) => p.kind),
        },
        marks: [
          gr.IntervalMark(
            position:
                gr.Varset('label') * (gr.Varset('start') + gr.Varset('end')),
            color: gr.ColorEncode(variable: 'kind', values: [_blue, _orange]),
          ),
          gr.PointMark(
            position: gr.Varset('label') * gr.Varset('date'),
            shape: gr.ShapeEncode(value: gr.SquareShape()),
            color: gr.ColorEncode(variable: 'kind', values: [_blue, _orange]),
            size: gr.SizeEncode(variable: 'kind', values: [0, 9]),
          ),
        ],
        coord: gr.RectCoord(transposed: true),
        axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      ),
    ),
  ],
);

Widget _graphicCalendarTrend() => _panels([
  (
    'Calendario diario · renderer Graphic',
    ChartRenderer.buildChart(
      concept: ChartCatalog.byId('calendar-heatmap'),
      library: ChartLibrary.graphic,
    ),
  ),
  (
    'Reservas mensuales · suma derivada',
    gr.Chart<MonthlyCalendarTotal>(
      data: calendarMonthlyTotals,
      variables: {
        'month': gr.Variable(accessor: (p) => '${p.month}/${p.year}'),
        'total': gr.Variable(accessor: (p) => p.total),
      },
      marks: [
        gr.LineMark(
          position: gr.Varset('month') * gr.Varset('total'),
          color: gr.ColorEncode(value: _blue),
        ),
        gr.PointMark(
          position: gr.Varset('month') * gr.Varset('total'),
          color: gr.ColorEncode(value: _blue),
          size: gr.SizeEncode(value: 4),
        ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    ),
  ),
]);
