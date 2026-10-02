import 'dart:math' as math;

import 'advanced_distribution_data.dart';
import 'distribution_basics_data.dart';
import 'financial_planning_data.dart';
import 'networks_diagnostics_spatial_data.dart';
import 'relationships_intervals_data.dart';
import 'analytical_structures_data.dart';
import 'performance_process_data.dart';
import 'composite_compact_data.dart';
import 'time_series_data.dart';
import 'analytical_time_series.dart';
import 'radial_composition_data.dart';

class LinearFit {
  const LinearFit(this.slope, this.intercept);
  final double slope, intercept;
  double at(double x) => slope * x + intercept;
}

LinearFit fitLinearTrend(List<ScatterObservation> observations) {
  if (observations.length < 2) {
    throw ArgumentError('At least two points required');
  }
  if (observations.any(
    (p) => !p.nights.isFinite || !p.spendThousands.isFinite,
  )) {
    throw ArgumentError('Regression values must be finite');
  }
  final mx =
      observations.map((p) => p.nights).reduce((a, b) => a + b) /
      observations.length;
  final my =
      observations.map((p) => p.spendThousands).reduce((a, b) => a + b) /
      observations.length;
  final denominator = observations.fold<double>(
    0,
    (s, p) => s + math.pow(p.nights - mx, 2),
  );
  if (denominator == 0) throw ArgumentError('X values must vary');
  final slope =
      observations.fold<double>(
        0,
        (s, p) => s + (p.nights - mx) * (p.spendThousands - my),
      ) /
      denominator;
  return LinearFit(slope, my - slope * mx);
}

final scatterTrendFit = fitLinearTrend(scatterObservations);

final combinationHistogramBins = buildHistogramBins(
  touristServiceSample.values,
  binCount: 6,
);
final combinationDensity = buildGaussianKde(
  touristServiceSample.values,
  bandwidth: 1.8,
);

/// Density integrates to one; n × bin width converts it to expected bin frequency.
final combinationDensityAsFrequency = List<DistributionPoint>.unmodifiable([
  for (final point in combinationDensity)
    DistributionPoint(
      point.x,
      point.y *
          touristServiceSample.values.length *
          (combinationHistogramBins.first.upperBound -
              combinationHistogramBins.first.lowerBound),
    ),
]);

class SessionVolume {
  const SessionVolume(this.period, this.ohlc, this.volume);
  final String period;
  final OhlcPoint ohlc;
  final double volume;
}

final educationalSessions = List<SessionVolume>.unmodifiable([
  for (var i = 0; i < educationalOhlc.length; i++)
    SessionVolume(
      educationalOhlc[i].period,
      educationalOhlc[i],
      (105 + (i * 37) % 92).toDouble(),
    ),
]);

class ChannelSales {
  const ChannelSales(
    this.period,
    this.direct,
    this.agency,
    this.online,
    this.marginPercent,
  );
  final String period;
  final double direct, agency, online, marginPercent;
  double get total => direct + agency + online;
}

const channelSales = <ChannelSales>[
  ChannelSales('Ene', 15, 10, 7, 18),
  ChannelSales('Feb', 17, 12, 8, 21),
  ChannelSales('Mar', 16, 11, 8, 19),
  ChannelSales('Abr', 20, 14, 10, 23),
  ChannelSales('May', 22, 16, 11, 25),
  ChannelSales('Jun', 21, 15, 10, 24),
];

final boxStripData = List.unmodifiable([
  for (final group in boxPlotGroups)
    (
      group: group,
      stats: calculateBoxPlotStats(group.values),
      strip: buildStripPoints(group.values),
    ),
]);
final violinBoxGeometry = buildViolinGeometry(violinGroups, bandwidth: 1.35);
final violinBoxStats = List.unmodifiable([
  for (final group in violinGroups) calculateBoxPlotStats(group.values),
]);
final combinationErrorEstimates = buildMeanConfidenceIntervals(waitingSamples);
final combinationContour = touristContour;

class NetworkRank {
  const NetworkRank(this.node, this.degree);
  final NetworkNode node;
  final int degree;
}

/// The sample graph is undirected: each edge contributes one incident degree
/// to each endpoint, so the sum of degrees is twice the edge count.
final networkNodeRanking = List<NetworkRank>.unmodifiable(() {
  final rows =
      [
        for (final node in touristNetwork.nodes)
          NetworkRank(node, touristNetwork.connections(node.id).length),
      ]..sort((a, b) {
        final byDegree = b.degree.compareTo(a.degree);
        if (byDegree != 0) return byDegree;
        final byId = a.node.id.compareTo(b.node.id);
        return byId != 0 ? byId : a.node.label.compareTo(b.node.label);
      });
  assert(
    rows.fold<int>(0, (sum, row) => sum + row.degree) ==
        2 * touristNetwork.edges.length,
  );
  return rows;
}());

class CompositionPair {
  const CompositionPair(this.category, this.series, this.value);
  final String category, series;
  final double value;
}

const compositionSeriesOrder = ['Directo', 'Agencia', 'En línea'];
const compositionCategories = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
final absoluteComposition = List<CompositionPair>.unmodifiable([
  for (final row in channelSales) ...[
    CompositionPair(row.period, compositionSeriesOrder[0], row.direct),
    CompositionPair(row.period, compositionSeriesOrder[1], row.agency),
    CompositionPair(row.period, compositionSeriesOrder[2], row.online),
  ],
]);

/// Percentages are calculated category by category from the exact absolute rows.
final normalizedComposition = List<CompositionPair>.unmodifiable([
  for (final category in compositionCategories)
    for (final series in compositionSeriesOrder)
      CompositionPair(
        category,
        series,
        100 *
            absoluteComposition
                .singleWhere(
                  (p) => p.category == category && p.series == series,
                )
                .value /
            absoluteComposition
                .where((p) => p.category == category)
                .fold<double>(0, (sum, p) => sum + p.value),
      ),
]);

final radarBarObservations = List<(String, String, double)>.unmodifiable([
  for (final profile in tourismProfiles)
    for (var i = 0; i < tourismDimensions.length; i++)
      (profile.label, tourismDimensions[i], profile.values[i]),
]);

bool get radarBarsValuesMatch => radarBarObservations.every((point) {
  final profile = tourismProfiles.singleWhere((p) => p.label == point.$1);
  final dimension = tourismDimensions.indexOf(point.$2);
  return dimension >= 0 && point.$3 == profile.values[dimension];
});

class BubbleQuadrantPoint {
  const BubbleQuadrantPoint(this.observation, this.quadrant);
  final BubbleObservation observation;
  final String quadrant;
}

double get bubbleVerticalThreshold =>
    bubbleDestinations.map((p) => p.visitorsThousands).reduce((a, b) => a + b) /
    bubbleDestinations.length;
double get bubbleHorizontalThreshold =>
    bubbleDestinations
        .map((p) => p.spendPerVisitorThousands)
        .reduce((a, b) => a + b) /
    bubbleDestinations.length;
final bubbleQuadrantPoints = List<BubbleQuadrantPoint>.unmodifiable([
  for (final point in bubbleDestinations)
    BubbleQuadrantPoint(
      point,
      '${point.visitorsThousands >= bubbleVerticalThreshold ? 'Alto X' : 'Bajo X'} / '
      '${point.spendPerVisitorThousands >= bubbleHorizontalThreshold ? 'Alto Y' : 'Bajo Y'}',
    ),
]);

class CumulativeEvent {
  const CumulativeEvent(
    this.date,
    this.label,
    this.metricDelta,
    this.cumulativeMetric,
  );
  final DateTime date;
  final String label;
  final double metricDelta, cumulativeMetric;
}

/// Educational fictional events, with cumulative values derived from deltas.
final timelineCumulativeEvents = List<CumulativeEvent>.unmodifiable(() {
  final source = [
    (DateTime.utc(2026, 1, 12), 'Inicio del proyecto', 8.0),
    (DateTime.utc(2026, 2, 16), 'Diseño aprobado', 13.0),
    (DateTime.utc(2026, 5, 18), 'Catálogo consolidado', 21.0),
    (DateTime.utc(2026, 7, 8), 'Prototipo navegable', 17.0),
    (DateTime.utc(2026, 9, 25), 'Validación', 24.0),
    (DateTime.utc(2026, 10, 22), 'Entrega funcional', 17.0),
  ]..sort((a, b) => a.$1.compareTo(b.$1));
  var total = 0.0;
  return [
    for (final row in source)
      CumulativeEvent(row.$1, row.$2, row.$3, total += row.$3),
  ];
}());

final scatterMarginalXBins = buildHistogramBins([
  for (final point in scatterObservations) point.nights,
], binCount: 6);
final scatterMarginalYBins = buildHistogramBins([
  for (final point in scatterObservations) point.spendThousands,
], binCount: 6);

class OccupancyPeriod {
  const OccupancyPeriod(this.period, this.value, {this.forecast});
  final String period;
  final double value;
  final ForecastPoint? forecast;
}

final actualForecastOccupancy = (() {
  const historyCount = 6;
  final history = [for (var i = 0; i < historyCount; i++) 64 + i * .9];
  final offset = history.last - hotelForecastFan.first.median;
  return List<OccupancyPeriod>.unmodifiable([
    for (var i = 0; i < history.length; i++)
      OccupancyPeriod((i + 1).toString().padLeft(2, '0'), history[i]),
    for (var i = 0; i < hotelForecastFan.length; i++)
      () {
        final source = hotelForecastFan[i];
        final adjusted = ForecastPoint(
          period: source.period,
          median: source.median + offset,
          lower50: source.lower50 + offset,
          upper50: source.upper50 + offset,
          lower80: source.lower80 + offset,
          upper80: source.upper80 + offset,
          lower95: source.lower95 + offset,
          upper95: source.upper95 + offset,
        );
        return OccupancyPeriod(
          (i + historyCount + 1).toString().padLeft(2, '0'),
          adjusted.median,
          forecast: adjusted,
        );
      }(),
  ]);
})();

class RangeCenterPoint {
  const RangeCenterPoint(this.period, this.low, this.center, this.high);
  final String period;
  final double low, center, high;
}

final rangeAreaCenterPoints = List<RangeCenterPoint>.unmodifiable([
  for (final point in hotelOccupancyRange)
    RangeCenterPoint(
      point.period,
      point.low,
      (point.low + point.high) / 2,
      point.high,
    ),
]);

final histogramBoxSample = List<double>.unmodifiable(
  touristServiceSample.values,
);
final histogramBoxBins = buildHistogramBins(histogramBoxSample, binCount: 7);
final histogramBoxStats = calculateBoxPlotStats(histogramBoxSample);

final distributionDiagnosticSample = serviceMinutes;
final distributionDiagnosticBins = buildHistogramBins(
  distributionDiagnosticSample,
  binCount: 7,
);
final distributionDiagnosticKde = buildGaussianKde(
  distributionDiagnosticSample,
  bandwidth: 4.0,
);
final distributionDiagnosticQq = serviceQq;

List<double> simpleMovingAverage(List<double> values, {required int window}) {
  if (window <= 0 || window > values.length) {
    throw ArgumentError('Window must be positive and no longer than data.');
  }
  if (values.any((value) => !value.isFinite)) {
    throw ArgumentError('Moving average values must be finite.');
  }
  return List.unmodifiable([
    for (var i = window - 1; i < values.length; i++)
      values.skip(i - window + 1).take(window).reduce((a, b) => a + b) / window,
  ]);
}

class PeriodValue {
  const PeriodValue(this.period, this.value);
  final int period;
  final double value;
}

List<PeriodValue> calculateStackedAreaTotals(List<StackedAreaPoint> points) {
  final grouped = <int, double>{};
  for (final point in points) {
    grouped.update(
      point.period,
      (sum) => sum + point.value,
      ifAbsent: () => point.value,
    );
  }
  return List.unmodifiable([
    for (final period in grouped.keys.toList()..sort())
      PeriodValue(period, grouped[period]!),
  ]);
}

final stackedAreaTotalLine = calculateStackedAreaTotals(
  stackedAreaFor('stacked-area'),
);

final bulletSparkline = sparklineKpis.firstWhere(
  (kpi) => kpi.label == 'Ingresos',
);
final bulletSparklinePoints = List<SparklinePoint>.unmodifiable([
  for (final point in bulletSparkline.points)
    SparklinePoint(
      point.period,
      point.value * monthlyRevenueBullet.value / bulletSparkline.currentValue,
    ),
]);

final ganttCombinationMilestones = TimelineData([
  TimelineEvent(
    'design-approved',
    DateTime.utc(2026, 10, 5),
    'Diseño aprobado',
    'Aprobación de diseño.',
    'Hito',
  ),
  TimelineEvent(
    'feature-complete',
    DateTime.utc(2026, 10, 13),
    'Feature complete',
    'Fin de implementación.',
    'Hito',
  ),
  TimelineEvent(
    'qa-complete',
    DateTime.utc(2026, 10, 19),
    'QA complete',
    'Validación completa.',
    'Hito',
  ),
  TimelineEvent(
    'delivery',
    DateTime.utc(2026, 10, 21),
    'Entrega',
    'Entrega del proyecto.',
    'Hito',
  ),
]);

class MonthlyCalendarTotal {
  const MonthlyCalendarTotal(this.year, this.month, this.total);
  final int year, month;
  final double total;
}

List<MonthlyCalendarTotal> aggregateCalendarByMonth(
  CalendarHeatmapData calendar,
) {
  final totals = <(int, int), double>{};
  for (final day in calendar.days) {
    final key = (day.date.year, day.date.month);
    totals.update(key, (sum) => sum + day.value, ifAbsent: () => day.value);
  }
  final keys = totals.keys.toList()
    ..sort(
      (a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2),
    );
  return List.unmodifiable([
    for (final key in keys) MonthlyCalendarTotal(key.$1, key.$2, totals[key]!),
  ]);
}

final calendarMonthlyTotals = aggregateCalendarByMonth(bookingCalendar);

final controlDistributionChart = controlChartFor('control-chart');
final controlDistributionSample = List<double>.unmodifiable([
  for (final point in controlDistributionChart.points) point.value,
]);
final controlDistributionBins = buildHistogramBins(
  controlDistributionSample,
  binCount: 6,
);
final controlDistributionKde = buildGaussianKde(
  controlDistributionSample,
  bandwidth: 4,
);
final controlDistributionKdeAsFrequency = List<DistributionPoint>.unmodifiable([
  for (final point in controlDistributionKde)
    DistributionPoint(
      point.x,
      point.y *
          controlDistributionSample.length *
          (controlDistributionBins.first.upperBound -
              controlDistributionBins.first.lowerBound),
    ),
]);

final waterfallCumulativeBars = List<WaterfallBar>.unmodifiable(hotelWaterfall);
final funnelConversionSteps = List<FunnelStep>.unmodifiable(
  bookingFunnel.steps,
);

final errorStripSample = List<double>.unmodifiable(
  waitingSamples['Recepcion']!,
);
final errorStripObservations = buildStripPoints(errorStripSample);
final errorStripEstimate = calculateMeanConfidenceInterval(
  'Recepcion',
  errorStripSample,
);

final contourObservations = List<FieldPoint>.unmodifiable([
  for (final (x, y) in const [
    (1.5, 2.0),
    (3.2, 8.4),
    (5.6, 5.3),
    (7.1, 12.8),
    (9.5, 9.1),
    (11.8, 3.4),
    (13.2, 14.6),
    (15.4, 7.8),
    (17.6, 12.2),
    (19.4, 4.6),
    (21.7, 15.1),
    (23.0, 9.2),
    (4.1, 17.2),
    (8.8, 1.4),
    (15.8, 17.8),
    (20.6, 18.0),
  ])
    FieldPoint(x, y, touristIntensity(x, y)),
]);
