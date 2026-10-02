import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/analytical_time_series.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/data/time_series_data.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/transformed_time_series_batch_demos.dart';

void main() {
  const ids = [
    'cumulative-line',
    'indexed-line',
    'normalized-stacked-area',
    'streamgraph',
    'control-chart',
  ];
  const libraries = ChartLibrary.values;

  test('cumulative sum sorts periods, preserves period and permits net-flow negatives', () {
    const input = [
      SingleTimeSeriesPoint(period: 3, label: 'Mar', value: 3),
      SingleTimeSeriesPoint(period: 1, label: 'Ene', value: 4),
      SingleTimeSeriesPoint(period: 2, label: 'Feb', value: 7),
    ];
    final result = cumulativeTimeSeries(input);
    expect(result.map((p) => (p.period, p.label, p.value)), [
      (1, 'Ene', 4.0),
      (2, 'Feb', 11.0),
      (3, 'Mar', 14.0),
    ]);
    expect(cumulativeTimeSeries(const []), isEmpty);
    expect(
      cumulativeTimeSeries(const [
        SingleTimeSeriesPoint(period: 1, label: 'A', value: 5),
        SingleTimeSeriesPoint(period: 2, label: 'B', value: -2),
      ]).map((p) => p.value),
      [5, 3],
    );
    expect(
      () => cumulativeTimeSeries(const [
        SingleTimeSeriesPoint(period: 1, label: 'A', value: double.nan),
      ]),
      throwsArgumentError,
    );
    expect(
      cumulativeTimeSeriesFor('cumulative-line').map((p) => p.value),
      orderedEquals([20, 35, 65, 87, 115, 149, 180, 217, 250, 292, 338, 390]),
    );
  });

  test(
    'indexed series start at 100, preserve original values, reject zero base',
    () {
      const input = [
        MultiTimeSeriesPoint(series: 'C', period: 2, label: 'Feb', value: 120),
        MultiTimeSeriesPoint(series: 'A', period: 2, label: 'Feb', value: 55),
        MultiTimeSeriesPoint(series: 'B', period: 2, label: 'Feb', value: 220),
        MultiTimeSeriesPoint(series: 'C', period: 1, label: 'Ene', value: 100),
        MultiTimeSeriesPoint(series: 'A', period: 1, label: 'Ene', value: 50),
        MultiTimeSeriesPoint(series: 'B', period: 1, label: 'Ene', value: 200),
      ];
      final output = indexTimeSeries(input);
      expect(
        output.where((p) => p.period == 1).map((p) => p.value),
        everyElement(100),
      );
      expect(
        output.singleWhere((p) => p.series == 'A' && p.period == 2).value,
        closeTo(110, 1e-12),
      );
      expect(
        output
            .singleWhere((p) => p.series == 'A' && p.period == 2)
            .originalValue,
        55,
      );
      expect(
        indexedTimeSeriesFor('indexed-line')
            .where((p) => p.period == 1)
            .map((p) => p.value),
        everyElement(100),
      );
      expect(
        () => indexTimeSeries(const [
          MultiTimeSeriesPoint(series: 'A', period: 1, label: 'E', value: 0),
          MultiTimeSeriesPoint(series: 'B', period: 1, label: 'E', value: 2),
          MultiTimeSeriesPoint(series: 'C', period: 1, label: 'E', value: 3),
        ]),
        throwsArgumentError,
      );
    },
  );

  test(
    'normalized stacking shares normalizeBars, totals 100 and defines zero',
    () {
      const input = [
        MultiTimeSeriesPoint(series: 'B', period: 1, label: 'Ene', value: 3),
        MultiTimeSeriesPoint(series: 'A', period: 1, label: 'Ene', value: 1),
        MultiTimeSeriesPoint(series: 'A', period: 2, label: 'Feb', value: 0),
        MultiTimeSeriesPoint(series: 'B', period: 2, label: 'Feb', value: 0),
      ];
      final output = normalizeTimeSeriesByPeriod(input);
      expect(output.where((p) => p.period == 1).map((p) => p.value), [25, 75]);
      expect(output.where((p) => p.period == 2).map((p) => p.value), [0, 0]);
      expect(
        normalizedStackedAreaFor('normalized-stacked-area')
            .where((p) => p.period == 1)
            .fold<double>(0, (sum, p) => sum + p.value),
        closeTo(100, 1e-9),
      );
      expect(
        () => normalizeTimeSeriesByPeriod(const [
          MultiTimeSeriesPoint(series: 'A', period: 1, label: 'E', value: -1),
          MultiTimeSeriesPoint(series: 'B', period: 1, label: 'E', value: 2),
        ]),
        throwsArgumentError,
      );
    },
  );

  test(
    'streamgraph bands use centered baseline and preserve absolute thickness',
    () {
      const input = [
        MultiTimeSeriesPoint(series: 'C', period: 1, label: 'Ene', value: 10),
        MultiTimeSeriesPoint(series: 'A', period: 1, label: 'Ene', value: 10),
        MultiTimeSeriesPoint(series: 'B', period: 1, label: 'Ene', value: 20),
      ];
      final output = centerStreamgraph(input);
      expect(output.map((p) => p.series), ['A', 'B', 'C']);
      expect(output.first.baseline, -20);
      expect(output.first.lower, -20);
      expect(output.map((p) => p.thickness), [10, 20, 10]);
      expect(output[1].lower, output[0].upper);
      expect(output[2].lower, output[1].upper);
      expect(output.last.upper, 20);
      final dataset = streamgraphFor('streamgraph');
      for (final period in dataset.map((p) => p.period).toSet()) {
        final rows = dataset.where((p) => p.period == period).toList();
        final total = rows.fold<double>(0, (sum, p) => sum + p.value);
        expect(rows.first.baseline, -total / 2);
        expect(rows.first.lower, -total / 2);
        expect(rows.last.upper, total / 2);
        expect(rows.last.upper - rows.first.lower, total);
        for (var i = 1; i < rows.length; i++) {
          expect(rows[i].lower, rows[i - 1].upper);
        }
        expect(rows.every((p) => p.thickness == p.value), isTrue);
      }
    },
  );

  test('control chart uses population sigma and handles edge cases', () {
    final stats = controlChartStatistics([2, 4, 6]);
    expect(stats.mean, 4);
    expect(stats.standardDeviation, closeTo(math.sqrt(8 / 3), 1e-12));
    expect(stats.upperControlLimit, closeTo(4 + 3 * math.sqrt(8 / 3), 1e-12));
    expect(stats.lowerControlLimit, closeTo(4 - 3 * math.sqrt(8 / 3), 1e-12));
    final singleton = controlChartStatistics([7]);
    expect(singleton.mean, 7);
    expect(singleton.standardDeviation, 0);
    expect(singleton.upperControlLimit, 7);
    expect(singleton.lowerControlLimit, 7);
    expect(() => controlChartStatistics(const []), throwsArgumentError);
    expect(
      () => controlChartStatistics([1, double.infinity]),
      throwsArgumentError,
    );
    final chart = controlChartFor('control-chart');
    expect(chart.stats.standardDeviation, greaterThan(0));
    expect(chart.points.where((p) => p.outOfControl).map((p) => p.label), [
      'D12',
    ]);
    expect(chart.points.last.value, greaterThan(chart.stats.upperControlLimit));
  });

  test(
    'transformed concepts preserve distinct catalog intent and dataset context',
    () {
      for (final id in ids) {
        final dataset = ChartDatasetRegistry.forConcept(id)!;
        expect(dataset.scenario, isNotEmpty);
        expect(dataset.title, isNotEmpty);
        expect(dataset.unit, isNotEmpty);
        expect(dataset.description, isNotEmpty);
        expect(dataset.rows, isNotEmpty);
        expect(dataset.invariants, isNotEmpty);
      }
      expect(
        ChartCatalog.byId('cumulative-line').description,
        contains('Suma cada periodo'),
      );
      expect(
        ChartCatalog.byId('indexed-line').description,
        contains('crecimiento relativo'),
      );
      expect(
        ChartCatalog.byId('normalized-stacked-area').description,
        contains('100 %'),
      );
      expect(
        ChartCatalog.byId('streamgraph').description,
        contains('línea base centrada'),
      );
      expect(
        ChartDatasetRegistry.forConcept('streamgraph')!.invariants,
        contains('offset centrado simple; no ThemeRiver/Wiggle'),
      );
    },
  );

  test(
    'Batch 4 registers exactly twenty keys, one per library and concept',
    () {
      final registrations = ChartRenderer.registrations
          .where((r) => ids.contains(r.conceptId))
          .toList();
      expect(registrations, hasLength(20));
      expect(
        registrations.map((r) => (r.conceptId, r.library)).toSet(),
        hasLength(20),
      );
      expect(ChartRenderer.registrations, hasLength(260));
      for (final id in ids) {
        for (final library in libraries) {
          expect(ChartRenderer.registrationCount(id, library), 1);
          expect(
            ChartRenderer.buildChart(
              concept: ChartCatalog.byId(id),
              library: library,
            ),
            isNot(isA<Text>()),
          );
        }
      }
    },
  );

  test(
    'Graphify configurations are JSON-only ECharts series and build views',
    () {
      for (final id in ids) {
        final options = graphifyAnalyticalOptions(id);
        final encoded = jsonEncode(options);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        expect(decoded['series'], isNotEmpty);
        expect(encoded, isNot(contains('renderItem')));
        expect(GraphifyView(initialOptions: options).initialOptions, options);
      }
      expect(
        (graphifyAnalyticalOptions('indexed-line')['series'] as List),
        hasLength(3),
      );
      final normalized =
          (graphifyAnalyticalOptions('normalized-stacked-area')['series']
                  as List)
              .cast<Map>();
      expect(normalized.every((row) => row['stack'] == 'composition'), isTrue);
      expect(
        graphifyAnalyticalOptions('normalized-stacked-area')['yAxis']['max'],
        100,
      );
      final stream =
          (graphifyAnalyticalOptions('streamgraph')['series'] as List)
              .cast<Map>();
      expect(stream.first['stackStrategy'], 'all');
      expect(
        stream.first['data'].first,
        streamgraphFor('streamgraph').first.baseline,
      );
      final control =
          (graphifyAnalyticalOptions('control-chart')['series'] as List).first
              as Map;
      expect(control['markLine']['data'], hasLength(3));
      expect(control['markPoint']['data'], hasLength(1));
    },
  );

  for (final width in [320.0, 500.0]) {
    for (final id in ids) {
      for (final library in libraries.where(
        (library) => library != ChartLibrary.graphify,
      )) {
        testWidgets(
          '$id ${library.label} mounts at ${width.toInt()} px without overflow',
          (tester) async {
            tester.view.physicalSize = Size(width, 300);
            tester.view.devicePixelRatio = 1;
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: width,
                    height: 270,
                    child: ChartRenderer.buildChart(
                      concept: ChartCatalog.byId(id),
                      library: library,
                    ),
                  ),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 120));
            expect(tester.takeException(), isNull);
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          },
        );
      }
    }
  }

  testWidgets('Graphify registered demo constructs its widget wrapper', (
    tester,
  ) async {
    for (final id in ids) {
      expect(
        ChartRenderer.buildChart(
          concept: ChartCatalog.byId(id),
          library: ChartLibrary.graphify,
        ),
        isA<TransformedTimeSeriesChart>(),
      );
    }
  });
}
