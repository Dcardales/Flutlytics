import 'dart:convert';

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:flutlytics_v1/features/charts/data/advanced_distribution_data.dart';
import 'package:flutlytics_v1/features/charts/data/analytical_structures_data.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/chart_combinations.dart';
import 'package:flutlytics_v1/features/charts/data/combination_data.dart';
import 'package:flutlytics_v1/features/charts/data/distribution_basics_data.dart';
import 'package:flutlytics_v1/features/charts/data/financial_planning_data.dart';
import 'package:flutlytics_v1/features/charts/data/relationships_intervals_data.dart';
import 'package:flutlytics_v1/features/charts/data/radial_composition_data.dart';
import 'package:flutlytics_v1/features/charts/data/networks_diagnostics_spatial_data.dart';
import 'package:flutlytics_v1/features/charts/data/performance_process_data.dart';
import 'package:flutlytics_v1/features/charts/data/time_series_data.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/combination_detail_page.dart';
import 'package:flutlytics_v1/features/charts/presentation/combination_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/combinations_page.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_detail_page.dart';
import 'package:flutlytics_v1/features/home/home_page.dart';
import 'package:graphify/graphify.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;
import 'package:syncfusion_flutter_charts/sparkcharts.dart' as sf_spark;

const newCombinationIds = [
  'network-node-ranking',
  'absolute-normalized-stacks',
  'radar-bars',
  'bubble-quadrants',
  'timeline-cumulative',
];

void main() {
  test('base matrix and combination routes stay separate', () {
    expect(ChartCatalog.concepts, hasLength(65));
    expect(
      ChartCatalog.concepts.where((c) => c.level == ChartLevel.basic),
      hasLength(40),
    );
    expect(
      ChartCatalog.concepts.where((c) => c.level == ChartLevel.advanced),
      hasLength(25),
    );
    expect(ChartRenderer.registrations, hasLength(260));
    expect(ChartCombinations.all, hasLength(30));
    expect(ChartCombinations.all.keys.toSet(), hasLength(30));
    expect(ChartCombinationRegistry.routes, hasLength(120));
    expect(
      ChartCombinationRegistry.routes
          .map((r) => (r.combinationId, r.library))
          .toSet(),
      hasLength(120),
    );
    expect(
      ChartCombinationRegistry.routes.where(
        (r) => r.rendererKind == CombinationRendererKind.sharedCanvasFallback,
      ),
      isEmpty,
    );
    expect(
      ChartCombinationRegistry.routes.where(
        (r) => r.rendererKind == CombinationRendererKind.delegatedBaseRenderer,
      ),
      hasLength(6),
    );
    expect(
      ChartCombinationRegistry.routes.where(
        (r) => r.rendererKind == CombinationRendererKind.graphifyEcharts,
      ),
      hasLength(30),
    );
    expect(
      ChartCombinationRegistry.routes.where(
        (r) => r.rendererKind == CombinationRendererKind.realLibraryRenderer,
      ),
      hasLength(84),
    );
    for (final combination in ChartCombinations.all.values) {
      expect(combination.supportedLibraries, ChartLibrary.values);
      expect(
        combination.componentConceptIds.every(
          (id) => ChartCatalog.concepts.any((c) => c.id == id),
        ),
        isTrue,
      );
      for (final library in ChartLibrary.values) {
        expect(
          ChartCombinationRegistry.hasRoute(combination.id, library),
          isTrue,
        );
        expect(
          ChartCombinationRegistry.build(combination.id, library),
          isA<Widget>(),
        );
      }
    }
    for (final library in ChartLibrary.values) {
      expect(
        ChartCombinationRegistry.routes.where((r) => r.library == library),
        hasLength(30),
      );
    }
  });

  test('regression comes from observations', () {
    final fit = fitLinearTrend([
      const ScatterObservation(label: 'a', nights: 1, spendThousands: 3),
      const ScatterObservation(label: 'b', nights: 2, spendThousands: 5),
      const ScatterObservation(label: 'c', nights: 3, spendThousands: 7),
    ]);
    expect(fit.slope, closeTo(2, 1e-10));
    expect(fit.intercept, closeTo(1, 1e-10));
    expect(scatterTrendFit.slope, isPositive);
    expect(
      () => fitLinearTrend([
        const ScatterObservation(label: 'a', nights: 1, spendThousands: 2),
        const ScatterObservation(label: 'b', nights: 1, spendThousands: 4),
      ]),
      throwsArgumentError,
    );
  });

  test('histogram and KDE share sample and frequency scale', () {
    expect(
      combinationHistogramBins.fold<int>(0, (n, b) => n + b.frequency),
      touristServiceSample.values.length,
    );
    expect(combinationDensityAsFrequency.length, combinationDensity.length);
    final width =
        combinationHistogramBins.first.upperBound -
        combinationHistogramBins.first.lowerBound;
    expect(
      combinationDensityAsFrequency[20].y,
      closeTo(
        combinationDensity[20].y * touristServiceSample.values.length * width,
        1e-10,
      ),
    );
  });

  test('OHLC and volume align, stacked channels share periods', () {
    expect(
      educationalSessions.map((s) => s.period),
      educationalOhlc.map((p) => p.period),
    );
    expect(educationalSessions.every((s) => s.volume > 0), isTrue);
    expect(
      channelSales.map((s) => s.period).toSet(),
      hasLength(channelSales.length),
    );
    expect(
      channelSales.every(
        (s) =>
            s.total == s.direct + s.agency + s.online &&
            s.marginPercent >= 0 &&
            s.marginPercent <= 100,
      ),
      isTrue,
    );
  });

  test('box-strip and violin-box reuse the same observations', () {
    for (final e in boxStripData) {
      expect(e.strip.map((p) => p.value).toList(), e.group.values);
      expect(e.stats.median, calculateBoxPlotStats(e.group.values).median);
    }
    for (var i = 0; i < violinGroups.length; i++) {
      expect(
        violinBoxStats[i].median,
        calculateBoxPlotStats(violinGroups[i].values).median,
      );
      expect(violinBoxGeometry.where((p) => p.groupIndex == i), isNotEmpty);
    }
  });

  test('bar-error calculates intervals and contours share heat field', () {
    for (final e in combinationErrorEstimates) {
      final recalculated = calculateMeanConfidenceInterval(
        e.label,
        waitingSamples[e.label]!,
      );
      expect(e.estimate, recalculated.estimate);
      expect(e.lower, recalculated.lower);
      expect(e.upper, recalculated.upper);
    }
    expect(combinationContour.segments, isNotEmpty);
    for (final s in combinationContour.segments) {
      expect(s.a.z, s.level);
      expect(s.b.z, s.level);
    }
  });

  test('new combination data reuses coherent observations and domains', () {
    expect(
      scatterMarginalXBins.fold<int>(0, (sum, bin) => sum + bin.frequency),
      scatterObservations.length,
    );
    expect(
      scatterMarginalYBins.fold<int>(0, (sum, bin) => sum + bin.frequency),
      scatterObservations.length,
    );
    expect(
      actualForecastOccupancy.where((p) => p.forecast == null),
      hasLength(6),
    );
    expect(
      actualForecastOccupancy.where((p) => p.forecast != null),
      hasLength(hotelForecastFan.length),
    );
    expect(
      actualForecastOccupancy.map((p) => p.period).toSet(),
      hasLength(actualForecastOccupancy.length),
    );
    expect(actualForecastOccupancy.first.period, '01');
    expect(actualForecastOccupancy.last.period, '18');
    expect(
      actualForecastOccupancy[5].value,
      actualForecastOccupancy[6].forecast!.median,
    );
    expect(
      rangeAreaCenterPoints.every(
        (p) => p.low <= p.center && p.center <= p.high,
      ),
      isTrue,
    );
    expect(
      histogramBoxBins.fold<int>(0, (sum, bin) => sum + bin.frequency),
      histogramBoxSample.length,
    );
    expect(
      histogramBoxStats.median,
      calculateBoxPlotStats(histogramBoxSample).median,
    );
    expect(distributionDiagnosticQq, serviceQq);
    expect(
      distributionDiagnosticBins.fold<int>(
        0,
        (sum, bin) => sum + bin.frequency,
      ),
      distributionDiagnosticSample.length,
    );
    final sma = simpleMovingAverage([1, 2, 3, 4, 5], window: 3);
    expect(sma, [2, 3, 4]);
    expect(
      simpleMovingAverage([
        for (final p in educationalOhlc) p.close,
      ], window: 3),
      hasLength(educationalOhlc.length - 2),
    );
    expect(() => simpleMovingAverage([1, 2], window: 0), throwsArgumentError);
    expect(() => simpleMovingAverage([1, 2], window: 3), throwsArgumentError);
    expect(
      () => simpleMovingAverage([1, double.infinity], window: 1),
      throwsArgumentError,
    );
    final candleSeries =
        graphifyCombinationOptions('candlestick-moving-average')['series']
            as List;
    final averageData =
        candleSeries.singleWhere(
              (series) => series['name'] == 'SMA 3 · cierre',
            )['data']
            as List;
    expect(averageData.take(2), [null, null]);
    expect(
      averageData.skip(2),
      simpleMovingAverage([
        for (final p in educationalOhlc) p.close,
      ], window: 3),
    );
    expect(stackedAreaTotalLine, isNotEmpty);
    final stackedSource = stackedAreaFor('stacked-area');
    for (final total in stackedAreaTotalLine) {
      expect(
        total.value,
        closeTo(
          stackedSource
              .where((point) => point.period == total.period)
              .fold<double>(0, (sum, point) => sum + point.value),
          1e-9,
        ),
      );
    }
    expect(bulletSparklinePoints.last.value, monthlyRevenueBullet.value);
    expect(
      ganttCombinationMilestones.events.every(
        (event) =>
            !event.date.isBefore(flutterFeatureTasks.first.start) &&
            !event.date.isAfter(flutterFeatureTasks.last.end),
      ),
      isTrue,
    );
    expect(
      calendarMonthlyTotals.fold<double>(0, (sum, month) => sum + month.total),
      closeTo(
        bookingCalendar.days.fold<double>(0, (sum, day) => sum + day.value),
        1e-9,
      ),
    );
  });

  test('the five new combinations reuse their existing transforms', () {
    expect(
      controlDistributionChart.points.map((point) => point.value),
      controlDistributionSample,
    );
    expect(
      controlDistributionBins.fold<int>(0, (sum, bin) => sum + bin.frequency),
      controlDistributionSample.length,
    );
    expect(controlDistributionKde, isNotEmpty);
    expect(
      controlDistributionKdeAsFrequency,
      hasLength(controlDistributionKde.length),
    );
    expect(
      controlDistributionChart.stats.upperControlLimit,
      closeTo(
        controlDistributionChart.stats.mean +
            3 * controlDistributionChart.stats.standardDeviation,
        1e-12,
      ),
    );
    expect(
      waterfallCumulativeBars.map((bar) => bar.runningTotal),
      hotelWaterfall.map((bar) => bar.endY),
    );
    final waterfallLine =
        graphifyCombinationOptions('waterfall-cumulative')['series']
            .cast<Map<String, dynamic>>()
            .singleWhere((series) => series['name'] == 'Running total');
    expect(
      waterfallLine['data'],
      hotelWaterfall.map((bar) => bar.runningTotal).toList(),
    );
    expect(funnelConversionSteps, bookingFunnel.steps);
    for (var i = 1; i < bookingFunnel.steps.length; i++) {
      final previous = bookingFunnel.steps[i];
      expect(
        previous.conversionFromPrevious,
        closeTo(
          previous.stage.value / bookingFunnel.steps[i - 1].stage.value,
          1e-12,
        ),
      );
      expect(
        previous.dropOff,
        bookingFunnel.steps[i - 1].stage.value - previous.stage.value,
      );
    }
    final graphifyFunnel = graphifyCombinationOptions('funnel-conversion');
    final funnelSeries = (graphifyFunnel['series'] as List)
        .cast<Map<String, dynamic>>();
    for (final series in funnelSeries.skip(1)) {
      expect(
        (series['data'] as List).every(
          (point) => (point as Map)['name'].toString().contains('drop-off'),
        ),
        isTrue,
      );
    }
    expect(
      errorStripObservations.map((point) => point.value),
      errorStripSample,
    );
    expect(errorStripEstimate.sampleSize, errorStripSample.length);
    final recalculatedErrorStrip = calculateMeanConfidenceInterval(
      'Recepcion',
      errorStripSample,
    );
    expect(errorStripEstimate.estimate, recalculatedErrorStrip.estimate);
    expect(errorStripEstimate.lower, recalculatedErrorStrip.lower);
    expect(errorStripEstimate.upper, recalculatedErrorStrip.upper);
    expect(
      errorStripEstimate.lower,
      lessThanOrEqualTo(errorStripEstimate.estimate),
    );
    expect(
      errorStripEstimate.estimate,
      lessThanOrEqualTo(errorStripEstimate.upper),
    );
    expect(contourObservations, isNotEmpty);
    expect(
      contourObservations.every(
        (point) =>
            point.x >= 0 &&
            point.x <= 24 &&
            point.y >= 0 &&
            point.y <= 19 &&
            point.z == touristIntensity(point.x, point.y),
      ),
      isTrue,
    );
    expect(
      touristContour.segments.every(
        (segment) =>
            segment.a.x >= 0 &&
            segment.a.x <= 24 &&
            segment.a.y >= 0 &&
            segment.a.y <= 19 &&
            segment.b.x >= 0 &&
            segment.b.x <= 24 &&
            segment.b.y >= 0 &&
            segment.b.y <= 19,
      ),
      isTrue,
    );
    expect(
      ChartCatalog.byId('control-chart').compatibleCombinations,
      contains('control-distribution'),
    );
    expect(
      ChartCatalog.byId('waterfall').compatibleCombinations,
      contains('waterfall-cumulative'),
    );
    expect(
      ChartCatalog.byId('funnel').compatibleCombinations,
      contains('funnel-conversion'),
    );
    expect(
      ChartCatalog.byId('strip-plot').compatibleCombinations,
      contains('error-strip'),
    );
    expect(
      ChartCatalog.byId('contour').compatibleCombinations,
      contains('contour-observations'),
    );
  });

  test('Graphify options are JSON and construct views', () {
    for (final id in ChartCombinations.all.keys) {
      final options = graphifyCombinationOptions(id);
      expect(jsonDecode(jsonEncode(options)), isA<Map>());
      expect(GraphifyView(initialOptions: options).initialOptions, options);
    }
  });

  test('Gallery 3B transformations preserve their source observations', () {
    expect(touristNetwork.edges.length, 8);
    expect(networkNodeRanking.fold<int>(0, (sum, row) => sum + row.degree), 16);
    expect(
      networkNodeRanking,
      orderedEquals(
        [...networkNodeRanking]..sort((a, b) {
          final degree = b.degree.compareTo(a.degree);
          if (degree != 0) return degree;
          final id = a.node.id.compareTo(b.node.id);
          return id != 0 ? id : a.node.label.compareTo(b.node.label);
        }),
      ),
    );
    expect(absoluteComposition, hasLength(normalizedComposition.length));
    expect(
      absoluteComposition.map((p) => (p.category, p.series)),
      normalizedComposition.map((p) => (p.category, p.series)),
    );
    for (final category in compositionCategories) {
      final absolute = absoluteComposition
          .where((p) => p.category == category)
          .fold<double>(0, (sum, p) => sum + p.value);
      final normalized = normalizedComposition
          .where((p) => p.category == category)
          .fold<double>(0, (sum, p) => sum + p.value);
      expect(
        absolute,
        channelSales.singleWhere((row) => row.period == category).total,
      );
      expect(normalized, closeTo(100, 1e-10));
    }
    for (var p = 0; p < tourismProfiles.length; p++) {
      for (var d = 0; d < tourismDimensions.length; d++) {
        expect(tourismProfiles[p].values[d], inInclusiveRange(0, 10));
        expect(
          radarBarObservations
              .singleWhere(
                (point) =>
                    point.$1 == tourismProfiles[p].label &&
                    point.$2 == tourismDimensions[d],
              )
              .$3,
          tourismProfiles[p].values[d],
        );
      }
    }
    expect(radarBarsValuesMatch, isTrue);
    expect(bubbleVerticalThreshold, closeTo(546.25, 1e-10));
    expect(bubbleHorizontalThreshold, closeTo(688.75, 1e-10));
    expect(bubbleQuadrantPoints, hasLength(bubbleDestinations.length));
    expect(
      bubbleQuadrantPoints.every(
        (p) => const {
          'Alto X / Alto Y',
          'Alto X / Bajo Y',
          'Bajo X / Alto Y',
          'Bajo X / Bajo Y',
        }.contains(p.quadrant),
      ),
      isTrue,
    );
    expect(
      bubbleQuadrantPoints.map((p) => p.observation.establishments),
      bubbleDestinations.map((p) => p.establishments),
    );
    expect(
      timelineCumulativeEvents.map((p) => p.date),
      orderedEquals([...timelineCumulativeEvents.map((p) => p.date)]..sort()),
    );
    var cumulative = 0.0;
    for (final event in timelineCumulativeEvents) {
      cumulative += event.metricDelta;
      expect(event.cumulativeMetric, cumulative);
    }
    expect(
      timelineCumulativeEvents.last.cumulativeMetric,
      timelineCumulativeEvents.fold<double>(0, (sum, p) => sum + p.metricDelta),
    );
  });

  testWidgets('Home and chart detail open the combination gallery', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.ensureVisible(find.text('Explorar combinaciones'));
    await tester.tap(find.text('Explorar combinaciones'));
    await tester.pumpAndSettle();
    expect(find.byType(CombinationsPage), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(home: ChartDetailPage(concept: ChartCatalog.byId('bar'))),
    );
    final barLineName = find.text(ChartCombinations.all['bar-line']!.name);
    await tester.dragFrom(const Offset(180, 740), const Offset(0, -640));
    await tester.pumpAndSettle();
    expect(barLineName, findsWidgets);
    await tester.tap(barLineName.first);
    await tester.pumpAndSettle();
    expect(find.byType(CombinationDetailPage), findsOneWidget);
  });

  for (final width in [320.0, 500.0]) {
    testWidgets('gallery and detail navigate at ${width.toInt()} px', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: CombinationsPage()));
      expect(tester.takeException(), isNull);
      expect(find.text('30 combinaciones avanzadas'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('combination-timeline-cumulative')),
        500,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(
        find.byKey(const Key('combination-timeline-cumulative')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CombinationDetailPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'each combination detail shows a usable plot at ${width.toInt()} px',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(width, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        for (final id in newCombinationIds) {
          final combination = ChartCombinations.all[id]!;
          await tester.pumpWidget(
            MaterialApp(home: CombinationDetailPage(combination: combination)),
          );
          await tester.scrollUntilVisible(
            find.byKey(const Key('combination-library-selector')),
            250,
            scrollable: find.byType(Scrollable).last,
          );
          await tester.pump();
          expect(
            find.byKey(const Key('combination-library-selector')),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull, reason: id);
        }
      },
    );

    for (final id in newCombinationIds) {
      for (final library in [
        ChartLibrary.flChart,
        ChartLibrary.syncfusion,
        ChartLibrary.graphic,
      ]) {
        testWidgets('$id ${library.label} mounts at ${width.toInt()} px', (
          tester,
        ) async {
          await tester.binding.setSurfaceSize(Size(width, 800));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  height: 360,
                  width: width,
                  child: ChartCombinationRegistry.build(id, library),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          switch (library) {
            case ChartLibrary.flChart:
              expect(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is fl.BarChart ||
                      widget is fl.LineChart ||
                      widget is fl.ScatterChart ||
                      widget is fl.CandlestickChart ||
                      widget is fl.PieChart ||
                      widget is fl.RadarChart,
                ),
                findsWidgets,
              );
            case ChartLibrary.syncfusion:
              expect(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is sf.SfCartesianChart ||
                      widget is sf_spark.SfSparkLineChart,
                ),
                findsWidgets,
              );
            case ChartLibrary.graphic:
              expect(
                find.byWidgetPredicate((widget) => widget is gr.Chart),
                findsWidgets,
              );
            case ChartLibrary.graphify:
              fail('Graphify has a separate ECharts route assertion.');
          }
        });
      }
    }
  }
}
