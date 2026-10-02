import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/chart_catalog.dart';
import '../../data/combination_data.dart';
import '../../data/networks_diagnostics_spatial_data.dart';
import '../../data/radial_composition_data.dart';
import '../../data/relationships_intervals_data.dart';
import '../../domain/chart_concept.dart';
import '../chart_renderer.dart';

const _c = [Color(0xff2563eb), Color(0xffea580c), Color(0xff16a34a)];

fl.FlTitlesData _flCategoryTitles(List<String> labels) => fl.FlTitlesData(
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: 32,
      getTitlesWidget: (value, _) {
        final index = value.toInt();
        if (index < 0 || index >= labels.length) {
          return const SizedBox.shrink();
        }
        return Text(labels[index], style: const TextStyle(fontSize: 7));
      },
    ),
  ),
  leftTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: true, reservedSize: 30),
  ),
  topTitles: const fl.AxisTitles(),
  rightTitles: const fl.AxisTitles(),
);

Widget buildGallery3bCombination(String id, ChartLibrary library) =>
    switch (library) {
      ChartLibrary.flChart => _layout(id, library),
      ChartLibrary.syncfusion => _layout(id, library),
      ChartLibrary.graphic => _layout(id, library),
      ChartLibrary.graphify => throw ArgumentError('Graphify usa ECharts.'),
    };

Widget _layout(String id, ChartLibrary library) {
  final panels = switch (id) {
    'network-node-ranking' => [
      ('Red', _basePlot('network-graph', library)),
      ('Grado por nodo', _rank(library)),
    ],
    'absolute-normalized-stacks' => [
      ('Valores absolutos', _stack(library, false)),
      ('Participación porcentual', _stack(library, true)),
    ],
    'radar-bars' => [
      ('Perfil · escala 0–10', _basePlot('radar', library)),
      ('Comparación por dimensión · 0–10', _radarBars(library)),
    ],
    'bubble-quadrants' => [
      ('Burbujas y referencias (media)', _bubble(library)),
      ('Observaciones por cuadrante', _quadrants(library)),
    ],
    'timeline-cumulative' => [
      ('Eventos educativos ficticios', _timeline(library)),
      ('Métrica acumulada', _cumulative(library)),
    ],
    _ => throw ArgumentError.value(id, 'id'),
  };
  return Column(
    children: [
      for (var i = 0; i < panels.length; i++) ...[
        if (i > 0) const SizedBox(height: 3),
        Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 18,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    panels[i].$1,
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
}

Widget _basePlot(String id, ChartLibrary library) =>
    ChartRenderer.buildChart(concept: ChartCatalog.byId(id), library: library);

Widget _rank(ChartLibrary library) {
  if (library == ChartLibrary.flChart) {
    // Rotate a native FL Chart bar plot to present the descending ranking horizontally.
    return fl.BarChart(
      fl.BarChartData(
        rotationQuarterTurns: 1,
        maxY: 5,
        barGroups: [
          for (var i = 0; i < networkNodeRanking.length; i++)
            fl.BarChartGroupData(
              x: i,
              barRods: [
                fl.BarChartRodData(
                  toY: networkNodeRanking[i].degree.toDouble(),
                  color: _c[0],
                  width: 10,
                ),
              ],
            ),
        ],
        titlesData: fl.FlTitlesData(
          bottomTitles: fl.AxisTitles(
            sideTitles: fl.SideTitles(
              showTitles: true,
              reservedSize: 54,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= networkNodeRanking.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  networkNodeRanking[index].node.label,
                  style: const TextStyle(fontSize: 7),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          leftTitles: const fl.AxisTitles(
            sideTitles: fl.SideTitles(showTitles: true, reservedSize: 20),
          ),
          topTitles: const fl.AxisTitles(),
          rightTitles: const fl.AxisTitles(),
        ),
        gridData: const fl.FlGridData(show: true),
      ),
    );
  }
  if (library == ChartLibrary.syncfusion) {
    return sf.SfCartesianChart(
      primaryXAxis: const sf.CategoryAxis(),
      primaryYAxis: const sf.NumericAxis(minimum: 0),
      series: <sf.CartesianSeries<NetworkRank, String>>[
        sf.BarSeries<NetworkRank, String>(
          dataSource: networkNodeRanking,
          xValueMapper: (p, _) => p.node.label,
          yValueMapper: (p, _) => p.degree,
          color: _c[0],
          animationDuration: 0,
        ),
      ],
    );
  }
  return gr.Chart<NetworkRank>(
    data: networkNodeRanking,
    variables: {
      'node': gr.Variable(accessor: (p) => p.node.label),
      'degree': gr.Variable(accessor: (p) => p.degree),
    },
    marks: [
      gr.IntervalMark(
        position: gr.Varset('degree') * gr.Varset('node'),
        color: gr.ColorEncode(value: _c[0]),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

Widget _stack(ChartLibrary library, bool normalized) {
  final rows = normalized ? normalizedComposition : absoluteComposition;
  final maxTotal = normalized
      ? 100.0
      : channelSales.map((r) => r.total).reduce(math.max) * 1.1;
  if (library == ChartLibrary.flChart) {
    return fl.BarChart(
      fl.BarChartData(
        maxY: maxTotal,
        barGroups: [
          for (var i = 0; i < compositionCategories.length; i++)
            fl.BarChartGroupData(
              x: i,
              barRods: [
                fl.BarChartRodData(
                  toY: rows
                      .where((p) => p.category == compositionCategories[i])
                      .fold<double>(0, (s, p) => s + p.value),
                  rodStackItems: () {
                    var base = 0.0;
                    return [
                      for (var si = 0; si < compositionSeriesOrder.length; si++)
                        (() {
                          final value = rows
                              .singleWhere(
                                (p) =>
                                    p.category == compositionCategories[i] &&
                                    p.series == compositionSeriesOrder[si],
                              )
                              .value;
                          final item = fl.BarChartRodStackItem(
                            base,
                            base + value,
                            _c[si],
                          );
                          base += value;
                          return item;
                        })(),
                    ];
                  }(),
                ),
              ],
            ),
        ],
        titlesData: _flCategoryTitles(compositionCategories),
        barTouchData: fl.BarTouchData(enabled: true),
        gridData: const fl.FlGridData(show: true),
      ),
    );
  }
  if (library == ChartLibrary.syncfusion) {
    return sf.SfCartesianChart(
      primaryXAxis: const sf.CategoryAxis(),
      primaryYAxis: sf.NumericAxis(minimum: 0, maximum: maxTotal),
      series: <sf.CartesianSeries<CompositionPair, String>>[
        for (final s in compositionSeriesOrder)
          sf.StackedColumnSeries<CompositionPair, String>(
            name: s,
            dataSource: rows.where((p) => p.series == s).toList(),
            xValueMapper: (p, _) => p.category,
            yValueMapper: (p, _) => p.value,
            color: _c[compositionSeriesOrder.indexOf(s)],
            animationDuration: 0,
          ),
      ],
    );
  }
  return gr.Chart<CompositionPair>(
    data: rows,
    variables: {
      'category': gr.Variable(accessor: (p) => p.category),
      'series': gr.Variable(accessor: (p) => p.series),
      'value': gr.Variable(accessor: (p) => p.value),
    },
    marks: [
      gr.IntervalMark(
        position:
            gr.Varset('category') * gr.Varset('value') / gr.Varset('series'),
        color: gr.ColorEncode(variable: 'series', values: _c),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

Widget _radarBars(ChartLibrary library) {
  final data = radarBarObservations;
  if (library == ChartLibrary.flChart) {
    return fl.BarChart(
      fl.BarChartData(
        minY: 0,
        maxY: 10,
        titlesData: _flCategoryTitles(tourismDimensions),
        gridData: const fl.FlGridData(show: true),
        barGroups: [
          for (var i = 0; i < tourismDimensions.length; i++)
            fl.BarChartGroupData(
              x: i,
              barsSpace: 2,
              barRods: [
                for (var j = 0; j < tourismProfiles.length; j++)
                  fl.BarChartRodData(
                    toY: tourismProfiles[j].values[i],
                    color: _c[j],
                    width: 8,
                  ),
              ],
            ),
        ],
      ),
    );
  }
  if (library == ChartLibrary.syncfusion) {
    return sf.SfCartesianChart(
      primaryXAxis: const sf.CategoryAxis(),
      primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 10),
      series: <sf.CartesianSeries<(String, String, double), String>>[
        for (var j = 0; j < tourismProfiles.length; j++)
          sf.ColumnSeries<(String, String, double), String>(
            name: tourismProfiles[j].label,
            dataSource: data
                .where((p) => p.$1 == tourismProfiles[j].label)
                .toList(),
            xValueMapper: (p, _) => p.$2,
            yValueMapper: (p, _) => p.$3,
            color: _c[j],
            animationDuration: 0,
          ),
      ],
    );
  }
  return gr.Chart<(String, String, double)>(
    data: data,
    variables: {
      'profile': gr.Variable(accessor: (p) => p.$1),
      'dimension': gr.Variable(accessor: (p) => p.$2),
      'value': gr.Variable(
        accessor: (p) => p.$3,
        scale: gr.LinearScale(min: 0, max: 10),
      ),
    },
    marks: [
      gr.IntervalMark(
        position:
            gr.Varset('dimension') * gr.Varset('value') / gr.Varset('profile'),
        color: gr.ColorEncode(variable: 'profile', values: _c),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

Widget _bubble(ChartLibrary library) {
  final xValues = bubbleDestinations.map((p) => p.visitorsThousands);
  final yValues = bubbleDestinations.map((p) => p.spendPerVisitorThousands);
  final xmin = xValues.reduce(math.min), xmax = xValues.reduce(math.max);
  final ymin = yValues.reduce(math.min), ymax = yValues.reduce(math.max);
  if (library == ChartLibrary.flChart) {
    return Stack(
      children: [
        Positioned.fill(
          child: fl.ScatterChart(
            fl.ScatterChartData(
              minX: xmin - 80,
              maxX: xmax + 80,
              minY: ymin - 100,
              maxY: ymax + 100,
              titlesData: const fl.FlTitlesData(show: false),
              scatterSpots: [
                for (final p in bubbleDestinations)
                  fl.ScatterSpot(
                    p.visitorsThousands,
                    p.spendPerVisitorThousands,
                    dotPainter: fl.FlDotCirclePainter(
                      color: _c[0].withValues(alpha: .55),
                      radius: 4 + p.establishments / 220,
                    ),
                  ),
              ],
              showingTooltipIndicators: [],
              scatterTouchData: fl.ScatterTouchData(enabled: true),
              gridData: fl.FlGridData(
                show: true,
                getDrawingHorizontalLine: (y) => fl.FlLine(
                  color: y == bubbleHorizontalThreshold
                      ? _c[1]
                      : Colors.black12,
                  strokeWidth: y == bubbleHorizontalThreshold ? 2 : .5,
                ),
                getDrawingVerticalLine: (x) => fl.FlLine(
                  color: x == bubbleVerticalThreshold ? _c[1] : Colors.black12,
                  strokeWidth: x == bubbleVerticalThreshold ? 2 : .5,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: fl.LineChart(
              fl.LineChartData(
                minX: xmin - 80,
                maxX: xmax + 80,
                minY: ymin - 100,
                maxY: ymax + 100,
                titlesData: const fl.FlTitlesData(show: false),
                gridData: const fl.FlGridData(show: false),
                borderData: fl.FlBorderData(show: false),
                lineBarsData: [
                  fl.LineChartBarData(
                    spots: [
                      fl.FlSpot(bubbleVerticalThreshold, ymin - 100),
                      fl.FlSpot(bubbleVerticalThreshold, ymax + 100),
                    ],
                    color: _c[1],
                    barWidth: 1.5,
                    dotData: const fl.FlDotData(show: false),
                  ),
                  fl.LineChartBarData(
                    spots: [
                      fl.FlSpot(xmin - 80, bubbleHorizontalThreshold),
                      fl.FlSpot(xmax + 80, bubbleHorizontalThreshold),
                    ],
                    color: _c[1],
                    barWidth: 1.5,
                    dotData: const fl.FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  if (library == ChartLibrary.syncfusion) {
    return sf.SfCartesianChart(
      primaryXAxis: sf.NumericAxis(
        minimum: xmin - 80,
        maximum: xmax + 80,
        plotBands: [
          sf.PlotBand(
            start: bubbleVerticalThreshold,
            end: bubbleVerticalThreshold + .01,
            color: _c[1],
            opacity: .7,
          ),
        ],
      ),
      primaryYAxis: sf.NumericAxis(
        minimum: ymin - 100,
        maximum: ymax + 100,
        plotBands: [
          sf.PlotBand(
            start: bubbleHorizontalThreshold,
            end: bubbleHorizontalThreshold + .01,
            color: _c[1],
            opacity: .7,
          ),
        ],
      ),
      series: <sf.BubbleSeries<BubbleObservation, double>>[
        sf.BubbleSeries(
          dataSource: bubbleDestinations,
          xValueMapper: (p, _) => p.visitorsThousands,
          yValueMapper: (p, _) => p.spendPerVisitorThousands,
          sizeValueMapper: (p, _) => p.establishments,
          animationDuration: 0,
        ),
      ],
    );
  }
  return Stack(
    children: [
      Positioned.fill(
        child: gr.Chart<BubbleObservation>(
          data: bubbleDestinations,
          variables: {
            'x': gr.Variable(
              accessor: (p) => p.visitorsThousands,
              scale: gr.LinearScale(min: xmin - 80, max: xmax + 80),
            ),
            'y': gr.Variable(
              accessor: (p) => p.spendPerVisitorThousands,
              scale: gr.LinearScale(min: ymin - 100, max: ymax + 100),
            ),
            'size': gr.Variable(accessor: (p) => p.establishments),
          },
          marks: [
            gr.PointMark(
              position: gr.Varset('x') * gr.Varset('y'),
              size: gr.SizeEncode(
                variable: 'size',
                values: bubbleDestinationRadii,
              ),
              color: gr.ColorEncode(value: _c[0]),
            ),
          ],
          axes: [],
          padding: (_) => EdgeInsets.zero,
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: gr.Chart<_BubbleReference>(
            data: [
              _BubbleReference('x', bubbleVerticalThreshold, ymin - 100),
              _BubbleReference('x', bubbleVerticalThreshold, ymax + 100),
              _BubbleReference('y', xmin - 80, bubbleHorizontalThreshold),
              _BubbleReference('y', xmax + 80, bubbleHorizontalThreshold),
            ],
            variables: {
              'axis': gr.Variable(accessor: (p) => p.axis),
              'x': gr.Variable(
                accessor: (p) => p.x,
                scale: gr.LinearScale(min: xmin - 80, max: xmax + 80),
              ),
              'y': gr.Variable(
                accessor: (p) => p.y,
                scale: gr.LinearScale(min: ymin - 100, max: ymax + 100),
              ),
            },
            marks: [
              gr.LineMark(
                position: gr.Varset('x') * gr.Varset('y') / gr.Varset('axis'),
                color: gr.ColorEncode(value: _c[1]),
                size: gr.SizeEncode(value: 1.5),
              ),
            ],
            axes: [],
            padding: (_) => EdgeInsets.zero,
          ),
        ),
      ),
    ],
  );
}

class _BubbleReference {
  const _BubbleReference(this.axis, this.x, this.y);
  final String axis;
  final double x, y;
}

Widget _quadrants(ChartLibrary library) {
  if (library == ChartLibrary.syncfusion) {
    return sf.SfCartesianChart(
      primaryXAxis: const sf.CategoryAxis(),
      primaryYAxis: const sf.NumericAxis(minimum: 0),
      series: <sf.CartesianSeries<BubbleQuadrantPoint, String>>[
        sf.BarSeries(
          dataSource: bubbleQuadrantPoints,
          xValueMapper: (p, _) => p.quadrant,
          yValueMapper: (p, _) => 1,
          pointColorMapper: (p, _) => _c[p.quadrant.contains('Alto X') ? 0 : 1],
          animationDuration: 0,
        ),
      ],
    );
  }
  if (library == ChartLibrary.flChart) {
    return fl.BarChart(
      fl.BarChartData(
        barGroups: [
          for (var i = 0; i < 4; i++)
            fl.BarChartGroupData(
              x: i,
              barRods: [
                fl.BarChartRodData(
                  toY: bubbleQuadrantPoints
                      .where(
                        (p) =>
                            p.quadrant ==
                            [
                              'Alto X / Alto Y',
                              'Alto X / Bajo Y',
                              'Bajo X / Alto Y',
                              'Bajo X / Bajo Y',
                            ][i],
                      )
                      .length
                      .toDouble(),
                  color: _c[i % 2],
                ),
              ],
            ),
        ],
        titlesData: _flCategoryTitles(const [
          'Alto X / Alto Y',
          'Alto X / Bajo Y',
          'Bajo X / Alto Y',
          'Bajo X / Bajo Y',
        ]),
        gridData: const fl.FlGridData(show: true),
      ),
    );
  }
  return gr.Chart<BubbleQuadrantPoint>(
    data: bubbleQuadrantPoints,
    variables: {
      'quadrant': gr.Variable(accessor: (p) => p.quadrant),
      'count': gr.Variable(accessor: (p) => 1),
    },
    marks: [
      gr.IntervalMark(
        position: gr.Varset('quadrant') * gr.Varset('count'),
        color: gr.ColorEncode(value: _c[0]),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

Widget _timeline(ChartLibrary library) {
  if (library == ChartLibrary.syncfusion) {
    return sf.SfCartesianChart(
      primaryXAxis: const sf.DateTimeAxis(),
      primaryYAxis: const sf.NumericAxis(minimum: -1, maximum: 1),
      series: <sf.CartesianSeries<CumulativeEvent, DateTime>>[
        sf.ScatterSeries(
          dataSource: timelineCumulativeEvents,
          xValueMapper: (p, _) => p.date,
          yValueMapper: (p, i) => i.isEven ? .5 : -.5,
          dataLabelMapper: (p, _) => p.label,
          dataLabelSettings: const sf.DataLabelSettings(isVisible: true),
          animationDuration: 0,
        ),
      ],
    );
  }
  if (library == ChartLibrary.flChart) {
    return fl.ScatterChart(
      fl.ScatterChartData(
        minX: timelineCumulativeEvents.first.date.millisecondsSinceEpoch
            .toDouble(),
        maxX: timelineCumulativeEvents.last.date.millisecondsSinceEpoch
            .toDouble(),
        minY: -1,
        maxY: 1,
        scatterSpots: [
          for (var i = 0; i < timelineCumulativeEvents.length; i++)
            fl.ScatterSpot(
              timelineCumulativeEvents[i].date.millisecondsSinceEpoch
                  .toDouble(),
              i.isEven ? .5 : -.5,
              dotPainter: fl.FlDotCirclePainter(color: _c[0], radius: 4),
            ),
        ],
        scatterTouchData: fl.ScatterTouchData(enabled: true),
        gridData: const fl.FlGridData(show: true),
      ),
    );
  }
  return gr.Chart<CumulativeEvent>(
    data: timelineCumulativeEvents,
    variables: {
      'date': gr.Variable(accessor: (p) => p.date, scale: gr.TimeScale()),
      'lane': gr.Variable(
        accessor: (p) => timelineCumulativeEvents.indexOf(p).isEven ? .5 : -.5,
      ),
    },
    marks: [
      gr.PointMark(
        position: gr.Varset('date') * gr.Varset('lane'),
        color: gr.ColorEncode(value: _c[0]),
        size: gr.SizeEncode(value: 6),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

Widget _cumulative(ChartLibrary library) {
  if (library == ChartLibrary.syncfusion) {
    return sf.SfCartesianChart(
      primaryXAxis: const sf.DateTimeAxis(),
      primaryYAxis: const sf.NumericAxis(minimum: 0),
      series: <sf.CartesianSeries<CumulativeEvent, DateTime>>[
        sf.LineSeries(
          dataSource: timelineCumulativeEvents,
          xValueMapper: (p, _) => p.date,
          yValueMapper: (p, _) => p.cumulativeMetric,
          markerSettings: const sf.MarkerSettings(isVisible: true),
          animationDuration: 0,
        ),
      ],
    );
  }
  if (library == ChartLibrary.flChart) {
    return fl.LineChart(
      fl.LineChartData(
        minY: 0,
        maxY: timelineCumulativeEvents.last.cumulativeMetric * 1.1,
        lineBarsData: [
          fl.LineChartBarData(
            spots: [
              for (final p in timelineCumulativeEvents)
                fl.FlSpot(
                  p.date.millisecondsSinceEpoch.toDouble(),
                  p.cumulativeMetric,
                ),
            ],
            isCurved: false,
            color: _c[1],
            barWidth: 2,
            dotData: const fl.FlDotData(show: true),
          ),
        ],
        gridData: const fl.FlGridData(show: true),
      ),
    );
  }
  return gr.Chart<CumulativeEvent>(
    data: timelineCumulativeEvents,
    variables: {
      'date': gr.Variable(accessor: (p) => p.date, scale: gr.TimeScale()),
      'metric': gr.Variable(accessor: (p) => p.cumulativeMetric),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('date') * gr.Varset('metric'),
        color: gr.ColorEncode(value: _c[1]),
        size: gr.SizeEncode(value: 2),
      ),
      gr.PointMark(
        position: gr.Varset('date') * gr.Varset('metric'),
        color: gr.ColorEncode(value: _c[1]),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  );
}

Map<String, dynamic> gallery3bGraphifyOptions(String id) => switch (id) {
  'network-node-ranking' => {
    'tooltip': {'trigger': 'item'},
    'grid': [
      {'left': 20, 'right': 12, 'top': 12, 'height': '43%'},
      {'left': 95, 'right': 15, 'top': '57%', 'height': '35%'},
    ],
    'xAxis': [
      {'type': 'value', 'gridIndex': 0, 'show': false},
      {'type': 'value', 'gridIndex': 1, 'name': 'Grado'},
    ],
    'yAxis': [
      {'type': 'value', 'gridIndex': 0, 'show': false},
      {
        'type': 'category',
        'gridIndex': 1,
        'inverse': true,
        'data': [for (final p in networkNodeRanking) p.node.label],
      },
    ],
    'series': [
      {
        'type': 'graph',
        'layout': 'none',
        'xAxisIndex': 0,
        'yAxisIndex': 0,
        'data': [
          for (final p in touristNetwork.positions)
            {
              'name': p.node.label,
              'x': (p.x + 1) * 100,
              'y': (p.y + 1) * 70,
              'symbolSize': 14,
            },
        ],
        'links': [
          for (final e in touristNetwork.edges)
            {
              'source': touristNetwork.byId[e.sourceId]!.node.label,
              'target': touristNetwork.byId[e.targetId]!.node.label,
            },
        ],
        'roam': false,
        'label': {'show': true},
      },
      {
        'type': 'bar',
        'xAxisIndex': 1,
        'yAxisIndex': 1,
        'data': [for (final p in networkNodeRanking) p.degree],
      },
    ],
  },
  'absolute-normalized-stacks' => _graphifyStacks(),
  'radar-bars' => _graphifyRadarBars(),
  'bubble-quadrants' => _graphifyBubble(),
  'timeline-cumulative' => _graphifyTimeline(),
  _ => throw ArgumentError.value(id, 'id'),
};

Map<String, dynamic> _graphifyStacks() => {
  'tooltip': {'trigger': 'axis'},
  'legend': {},
  'grid': [
    {'left': 40, 'right': 12, 'top': 28, 'height': '40%'},
    {'left': 40, 'right': 12, 'top': '58%', 'height': '34%'},
  ],
  'xAxis': [
    for (var i = 0; i < 2; i++)
      {'type': 'category', 'gridIndex': i, 'data': compositionCategories},
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Ventas'},
    {'type': 'value', 'gridIndex': 1, 'name': '%', 'max': 100},
  ],
  'series': [
    for (var panel = 0; panel < 2; panel++)
      for (var s = 0; s < compositionSeriesOrder.length; s++)
        {
          'name': compositionSeriesOrder[s],
          'type': 'bar',
          'stack': 'ventas$panel',
          'xAxisIndex': panel,
          'yAxisIndex': panel,
          'data': [
            for (final category in compositionCategories)
              (panel == 0 ? absoluteComposition : normalizedComposition)
                  .singleWhere(
                    (p) =>
                        p.category == category &&
                        p.series == compositionSeriesOrder[s],
                  )
                  .value,
          ],
        },
  ],
};

Map<String, dynamic> _graphifyRadarBars() => {
  'tooltip': {'trigger': 'item'},
  'legend': {},
  'grid': {'left': 45, 'right': 10, 'top': '58%', 'height': '34%'},
  'radar': {
    'center': ['50%', '28%'],
    'radius': '25%',
    'indicator': [
      for (final d in tourismDimensions) {'name': d, 'min': 0, 'max': 10},
    ],
  },
  'xAxis': {'type': 'category', 'data': tourismDimensions},
  'yAxis': {'type': 'value', 'min': 0, 'max': 10},
  'series': [
    {
      'type': 'radar',
      'data': [
        for (final p in tourismProfiles) {'name': p.label, 'value': p.values},
      ],
    },
    for (final p in tourismProfiles)
      {
        'name': p.label,
        'type': 'bar',
        'coordinateSystem': 'cartesian2d',
        'xAxisIndex': 0,
        'yAxisIndex': 0,
        'data': p.values,
      },
  ],
};

Map<String, dynamic> _graphifyBubble() => {
  'tooltip': {'trigger': 'item'},
  'grid': [
    {'left': 50, 'right': 10, 'top': 15, 'height': '60%'},
    {'left': 50, 'right': 10, 'top': '78%', 'height': '16%'},
  ],
  'xAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Visitantes (miles)'},
    {
      'type': 'category',
      'gridIndex': 1,
      'data': [
        'Alto X / Alto Y',
        'Alto X / Bajo Y',
        'Bajo X / Alto Y',
        'Bajo X / Bajo Y',
      ],
    },
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Gasto por visitante'},
    {'type': 'value', 'gridIndex': 1, 'show': false},
  ],
  'series': [
    {
      'type': 'scatter',
      'name': 'Destinos',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [
        for (var i = 0; i < bubbleDestinations.length; i++)
          {
            'name': bubbleDestinations[i].label,
            'value': [
              bubbleDestinations[i].visitorsThousands,
              bubbleDestinations[i].spendPerVisitorThousands,
            ],
            'symbolSize': 8 + bubbleDestinations[i].establishments / 100,
          },
      ],
      'markLine': {
        'symbol': 'none',
        'data': [
          {'xAxis': bubbleVerticalThreshold},
          {'yAxis': bubbleHorizontalThreshold},
        ],
      },
    },
    {
      'type': 'bar',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [
        for (final q in [
          'Alto X / Alto Y',
          'Alto X / Bajo Y',
          'Bajo X / Alto Y',
          'Bajo X / Bajo Y',
        ])
          bubbleQuadrantPoints.where((p) => p.quadrant == q).length,
      ],
    },
  ],
};

Map<String, dynamic> _graphifyTimeline() => {
  'tooltip': {'trigger': 'axis'},
  'grid': [
    {'left': 60, 'right': 12, 'top': 18, 'height': '38%'},
    {'left': 60, 'right': 12, 'top': '59%', 'height': '33%'},
  ],
  'xAxis': [
    {
      'type': 'time',
      'gridIndex': 0,
      'min': timelineCumulativeEvents.first.date.toIso8601String(),
      'max': timelineCumulativeEvents.last.date.toIso8601String(),
    },
    {
      'type': 'time',
      'gridIndex': 1,
      'min': timelineCumulativeEvents.first.date.toIso8601String(),
      'max': timelineCumulativeEvents.last.date.toIso8601String(),
    },
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'min': -1, 'max': 1, 'show': false},
    {'type': 'value', 'gridIndex': 1, 'name': 'Acumulado', 'min': 0},
  ],
  'series': [
    {
      'type': 'scatter',
      'name': 'Eventos ficticios',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [
        for (var i = 0; i < timelineCumulativeEvents.length; i++)
          {
            'name': timelineCumulativeEvents[i].label,
            'value': [
              timelineCumulativeEvents[i].date.toIso8601String(),
              i.isEven ? .5 : -.5,
            ],
          },
      ],
    },
    {
      'type': 'line',
      'name': 'Métrica acumulada',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [
        for (final p in timelineCumulativeEvents)
          [p.date.toIso8601String(), p.cumulativeMetric],
      ],
    },
  ],
};
