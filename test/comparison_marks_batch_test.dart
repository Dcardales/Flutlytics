import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/comparison_marks_batch_demos.dart';

void main() {
  const ids = ['dot-plot', 'lollipop', 'dumbbell', 'slope', 'pareto'];

  test('dot plot has one position mark per unique category', () {
    final data = ChartDatasetRegistry.pointsFor('dot-plot');
    expect(data, hasLength(5));
    expect(data.map((r) => r.label).toSet(), hasLength(data.length));
    expect(data.every((r) => r.value >= 0 && r.value <= 10), isTrue);
  });

  test(
    'lollipop has one positive endpoint and a zero based stem per category',
    () {
      final data = ChartDatasetRegistry.pointsFor('lollipop');
      expect(data, hasLength(5));
      expect(data.every((r) => r.value > 0), isTrue);
      final stems = [for (final row in data) (0.0, row.value)];
      expect(stems, hasLength(data.length));
      expect(stems.every((stem) => stem.$1 == 0 && stem.$2 > stem.$1), isTrue);
      expect(
        ChartCatalog.byId('dot-plot').description,
        isNot(ChartCatalog.byId('lollipop').description),
      );
    },
  );

  test('dumbbell provides exactly two endpoints and a shared delta', () {
    final data = ChartDatasetRegistry.dumbbellData();
    expect(data, hasLength(4));
    expect(data.every((r) => r.startValue >= 0 && r.endValue <= 10), isTrue);
    expect(data.first.delta, closeTo(1.9, 1e-9));
    expect(
      data
          .map((r) => (r.startValue, r.endValue))
          .every((pair) => pair.$1 != pair.$2),
      isTrue,
    );
  });

  test('slope dataset contains exactly two labeled periods per category', () {
    final data = ChartDatasetRegistry.slopeData();
    expect(data, hasLength(5));
    expect(data.map((r) => r.startPeriod).toSet(), {'2025'});
    expect(data.map((r) => r.endPeriod).toSet(), {'2026'});
    expect(data.every((r) => r.startValue >= 0 && r.endValue >= 0), isTrue);
    expect(data.first.delta, 6);
  });

  test(
    'Pareto sorts, accumulates frequencies and calculates cumulative percent',
    () {
      const input = [
        ParetoSource(category: 'B', frequency: 20),
        ParetoSource(category: 'C', frequency: 10),
        ParetoSource(category: 'A', frequency: 70),
      ];
      final actual = calculatePareto(input);
      expect(actual.map((r) => r.category), ['A', 'B', 'C']);
      expect(actual.map((r) => r.cumulative), [70, 90, 100]);
      expect(actual.map((r) => r.cumulativePercent), [70, 90, 100]);
      expect(actual.last.cumulative, 100);
      expect(actual.last.cumulativePercent, closeTo(100, 1e-9));
      expect(
        calculatePareto(input)
            .map((r) => (r.category, r.cumulative, r.cumulativePercent)),
        actual.map((r) => (r.category, r.cumulative, r.cumulativePercent)),
      );
    },
  );

  test(
    'Pareto defines empty and zero totals and rejects invalid frequencies',
    () {
      expect(calculatePareto(const []), isEmpty);
      final zero = calculatePareto(const [
        ParetoSource(category: 'Z', frequency: 0),
        ParetoSource(category: 'A', frequency: 0),
      ]);
      expect(zero.map((r) => r.category), ['A', 'Z']);
      expect(
        zero.every((r) => r.cumulative == 0 && r.cumulativePercent == 0),
        isTrue,
      );
      expect(
        () => calculatePareto(const [
          ParetoSource(category: 'Bad', frequency: -1),
        ]),
        throwsArgumentError,
      );
      expect(
        () => calculatePareto(const [
          ParetoSource(category: 'Bad', frequency: double.infinity),
        ]),
        throwsArgumentError,
      );
    },
  );

  test('Pareto educational dataset has cumulative line inputs and 80 percent crossing', () {
    final data = calculatePareto(ChartDatasetRegistry.paretoSources());
    expect(data.map((r) => r.frequency), [42, 27, 18, 8, 4, 1]);
    expect(data.last.cumulative, 100);
    expect(data.last.cumulativePercent, closeTo(100, 1e-9));
    expect(data.any((r) => r.cumulativePercent >= 80), isTrue);
  });

  test(
    'Batch 2 has twenty unique registrations and every concept is valid',
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
        expect(ChartCatalog.concepts.any((c) => c.id == id), isTrue);
        for (final library in ChartLibrary.values) {
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

  test('Graphify comparison configs serialize, construct views and use ECharts marks', () {
    final expected = {
      'dot-plot': ['scatter'],
      'lollipop': ['bar', 'scatter'],
      'dumbbell': ['line', 'line', 'line', 'line', 'scatter', 'scatter'],
      'slope': ['line', 'line', 'line', 'line', 'line'],
      'pareto': ['bar', 'line'],
    };
    for (final id in ids) {
      final options = graphifyComparisonOptions(id);
      final encoded = jsonEncode(options);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      expect((decoded['series'] as List).map((r) => r['type']), expected[id]);
      expect(encoded, isNot(contains('renderItem')));
      expect(GraphifyView(initialOptions: options).initialOptions, options);
    }
    final pareto = graphifyComparisonOptions('pareto');
    expect((pareto['yAxis'] as List).last['max'], 100);
    expect(pareto['series'].last['markLine']['data'].first['yAxis'], 80);
  });

  for (final width in [320.0, 500.0]) {
    for (final id in ids) {
      for (final library in ChartLibrary.values.where(
        (l) => l != ChartLibrary.graphify,
      )) {
        testWidgets('$id ${library.label} monta a ${width.toInt()} px', (
          tester,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  key: const Key('batch2-size'),
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
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byKey(const Key('batch2-size'))).width,
            width,
          );
        });
      }
    }
  }

  testWidgets('Graphify comparison builds its view widget configuration', (
    tester,
  ) async {
    for (final id in ids) {
      final view = GraphifyView(initialOptions: graphifyComparisonOptions(id));
      expect(view.initialOptions, isNotEmpty);
      expect(
        ChartRenderer.buildChart(
          concept: ChartCatalog.byId(id),
          library: ChartLibrary.graphify,
        ),
        isA<ComparisonMarksChart>(),
      );
    }
  });
}
