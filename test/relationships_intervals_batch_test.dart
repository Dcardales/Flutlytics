import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/relationships_intervals_data.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/relationships_intervals_batch_demos.dart';

void main() {
  const ids = [
    'scatter',
    'bubble',
    'connected-scatter',
    'error-bar',
    'range-column',
  ];

  group('Bubble size scaling', () {
    test('maps area monotonically to bounded deterministic radii', () {
      const magnitudes = <double>[0, 5, 20, 50];
      final radii = scaleBubbleRadii(magnitudes, minRadius: 4, maxRadius: 20);
      expect(radii, scaleBubbleRadii(magnitudes, minRadius: 4, maxRadius: 20));
      expect(radii.first, 4);
      expect(radii.last, 20);
      expect(radii, orderedEquals([...radii]..sort()));
      expect(radii.every((r) => r >= 4 && r <= 20), isTrue);
      final areaRatios = [for (final r in radii) r * r];
      expect(areaRatios, orderedEquals([...areaRatios]..sort()));
      expect(scaleBubbleRadii([3.0, 3, 3]), [7.0, 7, 7]);
      expect(scaleBubbleRadii([0]).single, 7);
      expect(() => scaleBubbleRadii([-1]), throwsArgumentError);
      expect(() => scaleBubbleRadii([double.infinity]), throwsArgumentError);
      expect(() => scaleBubbleRadii([1], minRadius: 0), throwsArgumentError);
      expect(
        () => scaleBubbleRadii([1], minRadius: 8, maxRadius: 7),
        throwsArgumentError,
      );
    });
  });

  group('Connected Scatter order', () {
    test('sorts by unique order without changing the numeric coordinates', () {
      final ordered = orderConnectedScatterPoints([
        ConnectedScatterPoint(order: 2, label: 'C', x: 7, y: 9),
        ConnectedScatterPoint(order: 0, label: 'A', x: 2, y: 3),
        ConnectedScatterPoint(order: 1, label: 'B', x: 5, y: 6),
      ]);
      expect(ordered.map((p) => p.label), ['A', 'B', 'C']);
      expect(ordered.map((p) => (p.x, p.y)), [(2, 3), (5, 6), (7, 9)]);
      expect(
        () => orderConnectedScatterPoints([
          ConnectedScatterPoint(order: 1, label: 'A', x: 1, y: 2),
          ConnectedScatterPoint(order: 1, label: 'B', x: 2, y: 3),
        ]),
        throwsArgumentError,
      );
      expect(
        () => ConnectedScatterPoint(order: 0, label: '', x: 0, y: 1),
        throwsArgumentError,
      );
      expect(
        () => ConnectedScatterPoint(order: 0, label: 'X', x: double.nan, y: 1),
        throwsArgumentError,
      );
    });
  });

  group('Error and range intervals', () {
    test('computes mean, sample SD, SE, and approximate 95 percent bounds', () {
      final result = calculateMeanConfidenceInterval('Test', [2, 4, 6]);
      expect(result.estimate, 4);
      expect(result.sampleSize, 3);
      expect(result.sampleStandardDeviation, 2);
      expect(result.standardError, closeTo(2 / math.sqrt(3), 1e-12));
      expect(result.lower, closeTo(4 - 1.96 * 2 / math.sqrt(3), 1e-12));
      expect(result.upper, closeTo(4 + 1.96 * 2 / math.sqrt(3), 1e-12));
      expect(result.lower, lessThanOrEqualTo(result.estimate));
      expect(result.upper, greaterThanOrEqualTo(result.estimate));
      expect(
        () => calculateMeanConfidenceInterval('one', [2]),
        throwsArgumentError,
      );
      expect(
        () => calculateMeanConfidenceInterval('bad', [2, double.nan]),
        throwsArgumentError,
      );
      expect(
        () => IntervalEstimate(
          label: 'bad',
          estimate: 5,
          lower: 7,
          upper: 9,
          sampleSize: 10,
          sampleStandardDeviation: 1,
          standardError: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => IntervalEstimate(
          label: 'bad',
          estimate: double.infinity,
          lower: 1,
          upper: 2,
          sampleSize: 10,
          sampleStandardDeviation: 1,
          standardError: 1,
        ),
        throwsArgumentError,
      );
      expect(errorBarEstimates, hasLength(5));
      expect(errorBarEstimates.every((e) => e.sampleSize == 10), isTrue);
    });

    test('range columns preserve ordered low/high and derive span', () {
      expect(dailyTemperatureRanges, hasLength(7));
      expect(
        dailyTemperatureRanges.every(
          (range) => range.span == range.high - range.low,
        ),
        isTrue,
      );
      expect(
        () => RangeValue(label: 'bad', low: 3, high: 2),
        throwsArgumentError,
      );
      expect(
        () => RangeValue(label: 'bad', low: double.nan, high: 2),
        throwsArgumentError,
      );
      expect(
        () => RangeValue(label: ' ', low: 1, high: 2),
        throwsArgumentError,
      );
    });
  });

  test('datasets keep the five semantic contracts distinct', () {
    expect(scatterObservations, hasLength(32));
    expect(
      scatterObservations.map((p) => p.nights).toSet().length,
      greaterThan(10),
    );
    expect(bubbleDestinations, hasLength(8));
    expect(
      bubbleDestinations.map((p) => p.establishments).toSet().length,
      greaterThan(5),
    );
    expect(connectedScatterPoints, hasLength(12));
    expect(
      connectedScatterPoints.map((p) => p.order),
      List.generate(12, (i) => i),
    );
    expect(errorBarEstimates.map((p) => p.label).toSet(), hasLength(5));
    expect(dailyTemperatureRanges.map((p) => p.label).toSet(), hasLength(7));
    for (final id in ids) {
      expect(ChartDatasetRegistry.forConcept(id), isNotNull);
      expect(ChartDatasetRegistry.forConcept(id)!.rows, isNotEmpty);
    }
  });

  test('Batch 9 registers exactly 20 demos in the current catalog', () {
    final registrations = ChartRenderer.registrations
        .where((registration) => ids.contains(registration.conceptId))
        .toList();
    expect(registrations, hasLength(20));
    expect(
      registrations.map((r) => (r.conceptId, r.library)).toSet(),
      hasLength(20),
    );
    expect(ChartRenderer.registrations, hasLength(260));
    for (final id in ids) {
      expect(ChartCatalog.concepts.any((concept) => concept.id == id), isTrue);
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
  });

  test('Graphify options serialize and retain concept-specific data', () {
    const expected = {
      'scatter': 'scatter',
      'bubble': 'scatter',
      'connected-scatter': 'line',
      'error-bar': 'scatter',
      'range-column': 'bar',
    };
    for (final id in ids) {
      final options = relationshipsIntervalsOptions(id);
      final decoded = jsonDecode(jsonEncode(options)) as Map<String, dynamic>;
      expect((decoded['series'] as List).first['type'], expected[id]);
      expect(GraphifyView(initialOptions: options).initialOptions, options);
    }
    final bubble = relationshipsIntervalsOptions('bubble')['series'] as List;
    expect(bubble, hasLength(8));
    expect(
      bubble.map((series) => series['symbolSize']).toSet().length,
      greaterThan(5),
    );
    final connected =
        relationshipsIntervalsOptions('connected-scatter')['series'] as List;
    expect((connected.first['data'] as List), hasLength(12));
    final range =
        relationshipsIntervalsOptions('range-column')['series'] as List;
    expect(range[0]['stack'], range[1]['stack']);
    expect(range[1]['dimensions'], ['day', 'low', 'high', 'span']);
    expect(
      (relationshipsIntervalsOptions('error-bar')['series'] as List).length,
      greaterThan(5),
    );
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
                  key: const Key('relationships-size'),
                  width: width,
                  height: 300,
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
            tester.getSize(find.byKey(const Key('relationships-size'))).width,
            width,
          );
        });
      }
    }
  }

  test('Graphify chart builders return GraphifyView configurations', () {
    for (final id in ids) {
      final demo = RelationshipsIntervalsChart(
        id: id,
        library: ChartLibrary.graphify,
      );
      expect(demo, isA<RelationshipsIntervalsChart>());
      final options = relationshipsIntervalsOptions(id);
      expect(GraphifyView(initialOptions: options), isA<GraphifyView>());
    }
  });
}
