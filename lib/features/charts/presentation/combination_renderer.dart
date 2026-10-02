import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphify/graphify.dart';

import '../data/chart_catalog.dart';
import '../data/chart_combinations.dart';
import '../data/combination_data.dart';
import '../data/advanced_distribution_data.dart';
import '../data/relationships_intervals_data.dart';
import '../domain/chart_concept.dart';
import 'chart_renderer.dart';
import 'demos/composite_compact_batch_demos.dart';
import 'demos/scatter_trend_combination.dart';
import 'demos/histogram_density_combination.dart';
import 'demos/candlestick_volume_combination.dart';
import 'demos/stacked_column_line_combination.dart';
import 'demos/bar_error_combination.dart';
import 'demos/box_strip_combination.dart';
import 'demos/violin_box_combination.dart';
import 'demos/heatmap_contour_combination.dart';
import 'demos/new_combinations_library_demos.dart';
import 'demos/supplemental_combinations.dart';
import '../data/networks_diagnostics_spatial_data.dart';
import '../data/financial_planning_data.dart';
import '../data/time_series_data.dart';
import '../data/performance_process_data.dart';
import 'demos/gallery_3b_combinations.dart';

typedef CombinationBuilder = Widget Function();

enum CombinationRendererKind {
  realLibraryRenderer,
  sharedCanvasFallback,
  delegatedBaseRenderer,
  graphifyEcharts,
}

class CombinationRoute {
  const CombinationRoute(this.combinationId, this.library, this.builder)
    : rendererKind = library == ChartLibrary.graphify
          ? CombinationRendererKind.graphifyEcharts
          : combinationId == 'bar-line' || combinationId == 'area-line'
          ? CombinationRendererKind.delegatedBaseRenderer
          : CombinationRendererKind.realLibraryRenderer;
  final String combinationId;
  final ChartLibrary library;
  final CombinationBuilder builder;
  final CombinationRendererKind rendererKind;
}

class ChartCombinationRegistry {
  static final routes = List<CombinationRoute>.unmodifiable([
    for (final id in ChartCombinations.all.keys)
      for (final library in ChartLibrary.values)
        CombinationRoute(
          id,
          library,
          () => ChartCombinationRenderer(id: id, library: library),
        ),
  ]);
  static bool hasRoute(String id, ChartLibrary library) =>
      routes.any((r) => r.combinationId == id && r.library == library);
  static Widget build(String id, ChartLibrary library) => routes
      .firstWhere((r) => r.combinationId == id && r.library == library)
      .builder();
}

class ChartCombinationRenderer extends StatelessWidget {
  const ChartCombinationRenderer({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) {
    if (id == 'bar-line' || id == 'area-line') {
      return ChartRenderer.buildChart(
        concept: ChartCatalog.byId(id),
        library: library,
      );
    }
    if (library == ChartLibrary.graphify) {
      return _GraphifyCombination(options: graphifyCombinationOptions(id));
    }
    if (id == 'scatter-trend') return buildScatterTrendCombination(library);
    if (const {
      'network-node-ranking',
      'absolute-normalized-stacks',
      'radar-bars',
      'bubble-quadrants',
      'timeline-cumulative',
    }.contains(id)) {
      return buildGallery3bCombination(id, library);
    }
    if (id == 'histogram-density') {
      return buildHistogramDensityCombination(library);
    }
    if (id == 'candlestick-volume') {
      return buildCandlestickVolumeCombination(library);
    }
    if (id == 'stacked-column-line') {
      return buildStackedColumnLineCombination(library);
    }
    if (id == 'bar-error') return buildBarErrorCombination(library);
    if (id == 'box-strip') return buildBoxStripCombination(library);
    if (id == 'violin-box') return buildViolinBoxCombination(library);
    if (id == 'heatmap-contour') return buildHeatmapContourCombination(library);
    if (const {
      'control-distribution',
      'waterfall-cumulative',
      'funnel-conversion',
      'error-strip',
      'contour-observations',
    }.contains(id)) {
      return buildSupplementalCombination(id, library);
    }
    if (ChartCombinations.all[id] == null) {
      throw ArgumentError.value(id, 'id', 'Unknown combination');
    }
    return buildNewLibraryCombination(id, library);
  }
}

class _GraphifyCombination extends StatefulWidget {
  const _GraphifyCombination({required this.options});
  final Map<String, dynamic> options;
  @override
  State<_GraphifyCombination> createState() => _GraphifyCombinationState();
}

class _GraphifyCombinationState extends State<_GraphifyCombination> {
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

Map<String, dynamic> graphifyCombinationOptions(String id) {
  final options = switch (id) {
    'bar-line' || 'area-line' => graphifyCompositeCompactOptions(id),
    'scatter-trend' => _scatterOptions(),
    'network-node-ranking' ||
    'absolute-normalized-stacks' ||
    'radar-bars' ||
    'bubble-quadrants' ||
    'timeline-cumulative' => gallery3bGraphifyOptions(id),
    'histogram-density' => _histogramOptions(),
    'candlestick-volume' => _candleOptions(),
    'stacked-column-line' => _stackedOptions(),
    'box-strip' => _boxStripOptions(),
    'violin-box' => _violinBoxOptions(),
    'bar-error' => _barErrorOptions(),
    'heatmap-contour' => _heatContourOptions(),
    'scatter-marginals' => _scatterMarginalOptions(),
    'actual-forecast-fan' => _actualForecastOptions(),
    'range-area-center-line' => _rangeCenterOptions(),
    'histogram-box' => _histogramBoxOptions(),
    'distribution-diagnostics' => _distributionDiagnosticsOptions(),
    'candlestick-moving-average' => _candlestickAverageOptions(),
    'stacked-area-total-line' => _stackedAreaTotalOptions(),
    'bullet-sparkline' => _bulletSparklineOptions(),
    'gantt-milestones' => _ganttMilestonesOptions(),
    'calendar-monthly-trend' => _calendarMonthlyOptions(),
    'control-distribution' ||
    'waterfall-cumulative' ||
    'funnel-conversion' ||
    'error-strip' ||
    'contour-observations' => supplementalGraphifyOptions(id),
    _ => throw ArgumentError.value(id, 'id'),
  };
  jsonEncode(options);
  return options;
}

Map<String, dynamic> _scatterOptions() {
  final xs = scatterObservations.map((p) => p.nights).toList();
  return {
    'tooltip': {'trigger': 'item'},
    'legend': {},
    'xAxis': {'type': 'value', 'name': 'Noches'},
    'yAxis': {'type': 'value', 'name': 'Gasto (mil COP)'},
    'series': [
      {
        'name': 'Observaciones',
        'type': 'scatter',
        'symbolSize': 9,
        'data': [
          for (final p in scatterObservations)
            [p.nights, p.spendThousands, p.label],
        ],
      },
      {
        'name': 'Regresión lineal',
        'type': 'line',
        'symbol': 'none',
        'data': [
          [xs.reduce(math.min), scatterTrendFit.at(xs.reduce(math.min))],
          [xs.reduce(math.max), scatterTrendFit.at(xs.reduce(math.max))],
        ],
      },
    ],
  };
}

Map<String, dynamic> _histogramOptions() => {
  'tooltip': {'trigger': 'axis'},
  'legend': {},
  'xAxis': {
    'type': 'category',
    'name': 'Minutos',
    'data': [for (final b in combinationHistogramBins) b.label],
  },
  'yAxis': {'type': 'value', 'name': 'Frecuencia'},
  'series': [
    {
      'name': 'Frecuencia',
      'type': 'bar',
      'barWidth': 24,
      'data': [for (final b in combinationHistogramBins) b.frequency],
    },
    {
      'name': 'KDE en frecuencia esperada',
      'type': 'line',
      'symbol': 'none',
      'smooth': true,
      'data': [
        for (final b in combinationHistogramBins)
          combinationDensityAsFrequency
              .reduce(
                (a, c) =>
                    (a.x - b.midpoint).abs() < (c.x - b.midpoint).abs() ? a : c,
              )
              .y,
      ],
    },
  ],
};

Map<String, dynamic> _scatterMarginalOptions() => {
  'tooltip': {'trigger': 'item'},
  'grid': [
    {'left': '12%', 'right': '24%', 'top': '8%', 'height': '22%'},
    {'left': '12%', 'right': '24%', 'top': '38%', 'height': '52%'},
    {'left': '78%', 'right': '4%', 'top': '38%', 'height': '52%'},
  ],
  'xAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Noches'},
    {'type': 'value', 'gridIndex': 1, 'name': 'Noches'},
    {'type': 'value', 'gridIndex': 2, 'name': 'Frecuencia'},
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Frecuencia'},
    {'type': 'value', 'gridIndex': 1, 'name': 'Gasto'},
    {'type': 'value', 'gridIndex': 2, 'name': 'Gasto'},
  ],
  'series': [
    {
      'name': 'Duración',
      'type': 'bar',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [
        for (final b in scatterMarginalXBins) [b.midpoint, b.frequency],
      ],
    },
    {
      'name': 'Observaciones',
      'type': 'scatter',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'symbolSize': 7,
      'data': [
        for (final p in scatterObservations) [p.nights, p.spendThousands],
      ],
    },
    {
      'name': 'Gasto',
      'type': 'bar',
      'xAxisIndex': 2,
      'yAxisIndex': 2,
      'data': [
        for (final b in scatterMarginalYBins) [b.frequency, b.midpoint],
      ],
    },
  ],
};

Map<String, dynamic> _actualForecastOptions() => {
  'tooltip': {'trigger': 'axis'},
  'legend': {},
  'xAxis': {
    'type': 'category',
    'data': [for (final p in actualForecastOccupancy) p.period],
  },
  'yAxis': {'type': 'value', 'name': 'Ocupación %', 'min': 40, 'max': 100},
  'series': [
    {
      'name': 'Histórico',
      'type': 'line',
      'connectNulls': false,
      'data': [
        for (final p in actualForecastOccupancy)
          p.forecast == null ? p.value : null,
      ],
    },
    {
      'name': 'Límite inferior 95 %',
      'type': 'line',
      'stack': 'fan',
      'symbol': 'none',
      'areaStyle': {'opacity': 0},
      'lineStyle': {'opacity': 0},
      'data': [for (final p in actualForecastOccupancy) p.forecast?.lower95],
      'markLine': {
        'symbol': ['none', 'none'],
        'label': {'formatter': 'Inicio del pronóstico'},
        'data': [
          {'xAxis': actualForecastOccupancy[6].period},
        ],
      },
    },
    for (final (name, key) in [
      ('Banda 80 % inferior', 'lower80'),
      ('Banda 50 % inferior', 'lower50'),
      ('Banda 50 % superior', 'upper50'),
      ('Banda 80 % superior', 'upper80'),
      ('Banda 95 % superior', 'upper95'),
    ])
      {
        'name': name,
        'type': 'line',
        'stack': 'fan',
        'symbol': 'none',
        'areaStyle': {'opacity': key.contains('50') ? .20 : .10},
        'lineStyle': {'opacity': .18},
        'data': [
          for (final p in actualForecastOccupancy)
            p.forecast == null
                ? null
                : switch (key) {
                    'lower80' => p.forecast!.lower80 - p.forecast!.lower95,
                    'lower50' => p.forecast!.lower50 - p.forecast!.lower80,
                    'upper50' => p.forecast!.upper50 - p.forecast!.lower50,
                    'upper80' => p.forecast!.upper80 - p.forecast!.upper50,
                    _ => p.forecast!.upper95 - p.forecast!.upper80,
                  },
        ],
      },
    {
      'name': 'Mediana pronosticada',
      'type': 'line',
      'data': [for (final p in actualForecastOccupancy) p.forecast?.median],
    },
  ],
};

Map<String, dynamic> _rangeCenterOptions() => {
  'tooltip': {'trigger': 'axis'},
  'legend': {},
  'xAxis': {
    'type': 'category',
    'data': [for (final p in rangeAreaCenterPoints) p.period],
  },
  'yAxis': {'type': 'value', 'name': 'Ocupación %'},
  'series': [
    {
      'name': 'Límite inferior',
      'type': 'line',
      'stack': 'intervalo',
      'symbol': 'none',
      'lineStyle': {'opacity': 0},
      'data': [for (final p in rangeAreaCenterPoints) p.low],
    },
    {
      'name': 'Intervalo bajo-alto',
      'type': 'line',
      'stack': 'intervalo',
      'symbol': 'none',
      'areaStyle': {'opacity': .24},
      'data': [for (final p in rangeAreaCenterPoints) p.high - p.low],
    },
    {
      'name': 'Centro',
      'type': 'line',
      'symbol': 'circle',
      'data': [for (final p in rangeAreaCenterPoints) p.center],
    },
  ],
};

Map<String, dynamic> _histogramBoxOptions() => {
  'tooltip': {'trigger': 'axis'},
  'grid': [
    {'left': 48, 'right': 18, 'top': 24, 'height': '58%'},
    {'left': 48, 'right': 18, 'top': '74%', 'height': '14%'},
  ],
  'xAxis': [
    {
      'type': 'category',
      'gridIndex': 0,
      'data': [for (final b in histogramBoxBins) b.label],
    },
    {
      'type': 'value',
      'gridIndex': 1,
      'min': histogramBoxBins.first.lowerBound,
      'max': histogramBoxBins.last.upperBound,
      'name': 'Minutos',
    },
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Frecuencia'},
    {'type': 'value', 'gridIndex': 1, 'show': false, 'min': 0, 'max': 1},
  ],
  'series': [
    {
      'name': 'Frecuencia',
      'type': 'bar',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [for (final b in histogramBoxBins) b.frequency],
    },
    {
      'name': 'Box plot · misma muestra',
      'type': 'boxplot',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [
        [
          histogramBoxStats.minWhisker,
          histogramBoxStats.q1,
          histogramBoxStats.median,
          histogramBoxStats.q3,
          histogramBoxStats.maxWhisker,
        ],
      ],
    },
    {
      'name': 'Atípicos',
      'type': 'scatter',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [
        for (final outlier in histogramBoxStats.outliers) [outlier, .5],
      ],
    },
  ],
};

Map<String, dynamic> _distributionDiagnosticsOptions() => {
  'tooltip': {'trigger': 'item'},
  'grid': [
    {'left': 48, 'right': '54%', 'top': 30, 'bottom': 48},
    {'left': '58%', 'right': 24, 'top': 30, 'bottom': 48},
  ],
  'xAxis': [
    {
      'type': 'category',
      'gridIndex': 0,
      'data': [for (final b in distributionDiagnosticBins) b.label],
      'name': 'Minutos',
    },
    {'type': 'value', 'gridIndex': 1, 'name': 'Normal teórica'},
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Frecuencia / densidad'},
    {'type': 'value', 'gridIndex': 1, 'name': 'Observado estandarizado'},
  ],
  'series': [
    {
      'name': 'Frecuencia',
      'type': 'bar',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [for (final b in distributionDiagnosticBins) b.frequency],
    },
    {
      'name': 'KDE',
      'type': 'line',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'smooth': true,
      'data': [
        for (final b in distributionDiagnosticBins)
          distributionDiagnosticKde
                  .reduce(
                    (a, c) =>
                        (a.x - b.midpoint).abs() < (c.x - b.midpoint).abs()
                        ? a
                        : c,
                  )
                  .y *
              distributionDiagnosticSample.length *
              (distributionDiagnosticBins.first.upperBound -
                  distributionDiagnosticBins.first.lowerBound),
      ],
    },
    {
      'name': 'Q-Q',
      'type': 'scatter',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [
        for (final p in distributionDiagnosticQq) [p.theoretical, p.observed],
      ],
    },
  ],
};

Map<String, dynamic> _candlestickAverageOptions() {
  final sma = simpleMovingAverage([
    for (final p in educationalOhlc) p.close,
  ], window: 3);
  return {
    'tooltip': {'trigger': 'axis'},
    'legend': {},
    'xAxis': {
      'type': 'category',
      'data': [for (final p in educationalOhlc) p.period],
    },
    'yAxis': {'type': 'value', 'scale': true},
    'series': [
      {
        'name': 'OHLC',
        'type': 'candlestick',
        'data': [
          for (final p in educationalOhlc) [p.open, p.close, p.low, p.high],
        ],
      },
      {
        'name': 'SMA 3 · cierre',
        'type': 'line',
        'connectNulls': false,
        'data': [null, null, ...sma],
      },
    ],
  };
}

Map<String, dynamic> _stackedAreaTotalOptions() {
  final area = stackedAreaFor('stacked-area');
  final periods = area.map((p) => p.period).toSet().toList()..sort();
  final seriesNames = area.map((p) => p.series).toSet().toList()..sort();
  return {
    'tooltip': {'trigger': 'axis'},
    'legend': {},
    'xAxis': {
      'type': 'category',
      'data': [
        for (final period in periods)
          area.firstWhere((p) => p.period == period).label,
      ],
    },
    'yAxis': {'type': 'value'},
    'series': [
      for (final name in seriesNames)
        {
          'name': name,
          'type': 'line',
          'stack': 'total',
          'areaStyle': {},
          'data': [
            for (final period in periods)
              area
                  .singleWhere((p) => p.period == period && p.series == name)
                  .value,
          ],
        },
      {
        'name': 'Total calculado',
        'type': 'line',
        'symbol': 'circle',
        'data': [for (final total in stackedAreaTotalLine) total.value],
      },
    ],
  };
}

Map<String, dynamic> _bulletSparklineOptions() => {
  'tooltip': {'trigger': 'axis'},
  'grid': [
    {'left': 50, 'right': 24, 'top': 34, 'height': '34%'},
    {'left': 50, 'right': 24, 'top': '58%', 'height': '28%'},
  ],
  'xAxis': [
    {
      'type': 'value',
      'gridIndex': 0,
      'min': monthlyRevenueBullet.min,
      'max': monthlyRevenueBullet.max,
    },
    {
      'type': 'category',
      'gridIndex': 1,
      'data': [for (final p in bulletSparkline.points) p.period.toString()],
    },
  ],
  'yAxis': [
    {
      'type': 'category',
      'gridIndex': 0,
      'data': ['Ingresos'],
    },
    {'type': 'value', 'gridIndex': 1, 'show': false},
  ],
  'series': [
    for (final band in monthlyRevenueBullet.bands)
      {
        'name': band.label,
        'type': 'bar',
        'stack': 'rangos',
        'xAxisIndex': 0,
        'yAxisIndex': 0,
        'data': [band.end - band.start],
      },
    {
      'name': 'Actual',
      'type': 'bar',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [monthlyRevenueBullet.value],
      'markPoint': {
        'data': [
          {
            'coord': [monthlyRevenueBullet.value, 0],
            'name': 'Actual',
          },
        ],
      },
    },
    {
      'name': 'Meta',
      'type': 'line',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [
        [monthlyRevenueBullet.target, 0],
      ],
    },
    {
      'name': 'Tendencia reciente',
      'type': 'line',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [for (final p in bulletSparklinePoints) p.value],
    },
  ],
};

Map<String, dynamic> _ganttMilestonesOptions() {
  final origin = flutterFeatureTasks.first.start;
  final dates = [
    ...flutterFeatureTasks.map((t) => t.start),
    ...flutterFeatureTasks.map((t) => t.end),
    ...ganttCombinationMilestones.events.map((e) => e.date),
  ];
  final minDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
  final maxDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
  double day(DateTime date) => date.difference(origin).inDays.toDouble();
  return {
    'tooltip': {'trigger': 'item'},
    'xAxis': {
      'type': 'value',
      'min': day(minDate),
      'max': day(maxDate),
      'name': 'Días de octubre',
    },
    'yAxis': {
      'type': 'category',
      'data': [
        ...flutterFeatureTasks.map((t) => t.label),
        ...ganttCombinationMilestones.events.map((e) => '◆ ${e.title}'),
      ],
      'inverse': true,
    },
    'series': [
      {
        'name': 'Inicio de tarea',
        'type': 'bar',
        'stack': 'duración',
        'itemStyle': {'opacity': 0},
        'data': [for (final task in flutterFeatureTasks) day(task.start)],
      },
      {
        'name': 'Tareas · duración',
        'type': 'bar',
        'stack': 'duración',
        'data': [for (final task in flutterFeatureTasks) task.duration.inDays],
        'markPoint': {'symbol': 'none'},
      },
      {
        'name': 'Hitos · fecha única',
        'type': 'scatter',
        'symbol': 'diamond',
        'data': [
          for (var i = 0; i < ganttCombinationMilestones.events.length; i++)
            [
              day(ganttCombinationMilestones.events[i].date),
              flutterFeatureTasks.length + i,
            ],
        ],
      },
    ],
  };
}

Map<String, dynamic> _calendarMonthlyOptions() => {
  'tooltip': {'trigger': 'item'},
  'grid': [
    {'left': 42, 'right': 18, 'top': 25, 'height': '53%'},
    {'left': 42, 'right': 18, 'top': '71%', 'height': '19%'},
  ],
  'xAxis': [
    {
      'type': 'category',
      'gridIndex': 0,
      'data': [
        for (final cell in bookingCalendar.cells)
          '${cell.day.date.month}/${cell.day.date.day}',
      ],
    },
    {
      'type': 'category',
      'gridIndex': 1,
      'data': [for (final m in calendarMonthlyTotals) '${m.month}/${m.year}'],
    },
  ],
  'yAxis': [
    {'type': 'value', 'gridIndex': 0, 'name': 'Reservas diarias'},
    {'type': 'value', 'gridIndex': 1, 'name': 'Total mensual'},
  ],
  'visualMap': {
    'min': bookingCalendar.minValue,
    'max': bookingCalendar.maxValue,
    'show': false,
  },
  'series': [
    {
      'name': 'Calendario · reservas por día',
      'type': 'heatmap',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [
        for (var i = 0; i < bookingCalendar.days.length; i++)
          [i, 0, bookingCalendar.days[i].value],
      ],
    },
    {
      'name': 'Suma mensual',
      'type': 'line',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [for (final m in calendarMonthlyTotals) m.total],
    },
  ],
};

Map<String, dynamic> _candleOptions() => {
  'tooltip': {'trigger': 'axis'},
  'legend': {},
  'grid': [
    {'left': 48, 'right': 20, 'top': 28, 'height': '48%'},
    {'left': 48, 'right': 20, 'top': '72%', 'height': '17%'},
  ],
  'xAxis': [
    {
      'type': 'category',
      'data': [for (final s in educationalSessions) s.period],
      'gridIndex': 0,
    },
    {
      'type': 'category',
      'data': [for (final s in educationalSessions) s.period],
      'gridIndex': 1,
    },
  ],
  'yAxis': [
    {'type': 'value', 'scale': true, 'gridIndex': 0},
    {'type': 'value', 'gridIndex': 1, 'name': 'Volumen'},
  ],
  'series': [
    {
      'name': 'OHLC ficticio',
      'type': 'candlestick',
      'xAxisIndex': 0,
      'yAxisIndex': 0,
      'data': [
        for (final s in educationalSessions)
          [s.ohlc.open, s.ohlc.close, s.ohlc.low, s.ohlc.high],
      ],
    },
    {
      'name': 'Volumen',
      'type': 'bar',
      'xAxisIndex': 1,
      'yAxisIndex': 1,
      'data': [for (final s in educationalSessions) s.volume],
    },
  ],
};

Map<String, dynamic> _stackedOptions() => {
  'tooltip': {'trigger': 'axis'},
  'legend': {},
  'xAxis': {
    'type': 'category',
    'data': [for (final s in channelSales) s.period],
  },
  'yAxis': [
    {'type': 'value', 'name': 'Millones COP'},
    {'type': 'value', 'name': 'Margen %', 'min': 0, 'max': 100},
  ],
  'series': [
    for (final (name, values) in [
      ('Directo', [for (final s in channelSales) s.direct]),
      ('Agencias', [for (final s in channelSales) s.agency]),
      ('En línea', [for (final s in channelSales) s.online]),
    ])
      {'name': name, 'type': 'bar', 'stack': 'ventas', 'data': values},
    {
      'name': 'Margen %',
      'type': 'line',
      'yAxisIndex': 1,
      'data': [for (final s in channelSales) s.marginPercent],
    },
  ],
};

Map<String, dynamic> _boxStripOptions() => {
  'tooltip': {'trigger': 'item'},
  'legend': {},
  'xAxis': {
    'type': 'category',
    'data': [for (final e in boxStripData) e.group.label],
  },
  'yAxis': {'type': 'value', 'name': 'Minutos'},
  'series': [
    {
      'name': 'Box plot',
      'type': 'boxplot',
      'data': [
        for (final e in boxStripData)
          [
            e.stats.minWhisker,
            e.stats.q1,
            e.stats.median,
            e.stats.q3,
            e.stats.maxWhisker,
          ],
      ],
    },
    {
      'name': 'Observaciones',
      'type': 'scatter',
      'data': [
        for (var i = 0; i < boxStripData.length; i++)
          for (final p in boxStripData[i].strip) [i + p.jitter, p.value],
      ],
    },
  ],
};

Map<String, dynamic> _violinBoxOptions() => {
  'tooltip': {'trigger': 'item'},
  'legend': {},
  'xAxis': {'type': 'value', 'min': -0.5, 'max': violinGroups.length - 0.5},
  'yAxis': {'type': 'value', 'name': 'Minutos'},
  'series': [
    for (var i = 0; i < violinGroups.length; i++) ...[
      {
        'name': '${violinGroups[i].label} · densidad izquierda',
        'type': 'line',
        'symbol': 'none',
        'data': [
          for (final p in violinBoxGeometry.where((p) => p.groupIndex == i))
            [i - p.halfWidth, p.value],
        ],
      },
      {
        'name': '${violinGroups[i].label} · densidad derecha',
        'type': 'line',
        'symbol': 'none',
        'data': [
          for (final p in violinBoxGeometry.where((p) => p.groupIndex == i))
            [i + p.halfWidth, p.value],
        ],
      },
      {
        'name': '${violinGroups[i].label} · caja Q1–Q3',
        'type': 'line',
        'symbol': 'none',
        'lineStyle': {'width': 2, 'color': '#334155'},
        'data': [
          [i - .08, violinBoxStats[i].q1],
          [i + .08, violinBoxStats[i].q1],
          [i + .08, violinBoxStats[i].q3],
          [i - .08, violinBoxStats[i].q3],
          [i - .08, violinBoxStats[i].q1],
        ],
      },
      {
        'name': '${violinGroups[i].label} · mediana',
        'type': 'line',
        'symbol': 'none',
        'data': [
          [i - .08, violinBoxStats[i].median],
          [i + .08, violinBoxStats[i].median],
        ],
      },
      {
        'name': '${violinGroups[i].label} · bigotes',
        'type': 'line',
        'symbol': 'none',
        'data': [
          [i, violinBoxStats[i].minWhisker],
          [i, violinBoxStats[i].maxWhisker],
        ],
      },
    ],
  ],
};

Map<String, dynamic> _barErrorOptions() => {
  'tooltip': {'trigger': 'axis'},
  'legend': {},
  'xAxis': {
    'type': 'category',
    'data': [for (final e in combinationErrorEstimates) e.label],
  },
  'yAxis': {'type': 'value', 'name': 'Minutos'},
  'series': [
    {
      'name': 'Media',
      'type': 'bar',
      'data': [for (final e in combinationErrorEstimates) e.estimate],
      'markLine': {
        'symbol': ['none', 'none'],
        'label': {'show': false},
        'lineStyle': {'color': '#ea580c', 'width': 2},
        'data': [
          for (final e in combinationErrorEstimates)
            [
              {
                'coord': [e.label, e.lower],
              },
              {
                'coord': [e.label, e.upper],
              },
            ],
        ],
      },
    },
    {
      'name': 'IC 95 % inferior',
      'type': 'scatter',
      'symbol': 'triangle',
      'data': [
        for (var i = 0; i < combinationErrorEstimates.length; i++)
          [i, combinationErrorEstimates[i].lower],
      ],
    },
    {
      'name': 'IC 95 % superior',
      'type': 'scatter',
      'symbol': 'triangle',
      'data': [
        for (var i = 0; i < combinationErrorEstimates.length; i++)
          [i, combinationErrorEstimates[i].upper],
      ],
    },
  ],
};

Map<String, dynamic> _heatContourOptions() => {
  'tooltip': {'trigger': 'item'},
  'visualMap': {
    'min': combinationContour.minZ,
    'max': combinationContour.maxZ,
    'calculable': true,
    'orient': 'horizontal',
    'bottom': 0,
  },
  'xAxis': {'type': 'value', 'min': 0, 'max': 24},
  'yAxis': {'type': 'value', 'min': 0, 'max': 19},
  'series': [
    {
      'name': 'Intensidad',
      'type': 'heatmap',
      'data': [
        for (final row in combinationContour.grid)
          for (final p in row) [p.x, p.y, p.z],
      ],
    },
    for (final segment in combinationContour.segments)
      {
        'name': 'Nivel ${segment.level.toStringAsFixed(0)}',
        'type': 'line',
        'symbol': 'none',
        'lineStyle': {'color': '#172554', 'width': 1},
        'data': [
          [segment.a.x, segment.a.y],
          [segment.b.x, segment.b.y],
        ],
      },
  ],
};
