import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/distribution_basics_data.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/distribution_basics_batch_demos.dart';

void main() {
  const ids = [
    'histogram',
    'frequency-polygon',
    'ogive',
    'strip-plot',
    'density',
  ];

  test(
    'sample is immutable, finite, preserves input order, and has a useful span',
    () {
      expect(touristServiceSample.unit, 'minutos');
      expect(touristServiceSample.values.length, inInclusiveRange(30, 60));
      expect(touristServiceSample.values.first, 6.2);
      expect(touristServiceSample.values.last, 27.0);
      expect(() => touristServiceSample.values.add(1), throwsUnsupportedError);
      for (final id in ids) {
        final dataset = ChartDatasetRegistry.forConcept(id)!;
        expect(dataset.unit, 'minutos');
        expect(dataset.rows, hasLength(touristServiceSample.values.length));
        expect(
          dataset.rows.map((row) => row['observation']),
          touristServiceSample.values,
        );
      }
    },
  );

  test(
    'bins use shared deterministic edges, half-open intervals, and include max',
    () {
      final bins = buildHistogramBins([0, 1, 2, 3, 4], binCount: 2);
      expect(bins.map((b) => b.frequency), [2, 3]);
      expect(bins.map((b) => b.lowerBound), [0, 2]);
      expect(bins.map((b) => b.upperBound), [2, 4]);
      expect(bins.map((b) => b.midpoint), [1, 3]);
      expect(bins.fold<int>(0, (sum, b) => sum + b.frequency), 5);
      final equal = buildHistogramBins([4, 4, 4], binCount: 3);
      expect(equal, hasLength(1));
      expect(equal.single.frequency, 3);
      expect(equal.single.midpoint, 4);
      expect(equal.single.lowerBound, 3.5);
      expect(equal.single.upperBound, 4.5);
      expect(() => buildHistogramBins([], binCount: 2), throwsArgumentError);
      expect(
        () => buildHistogramBins([1, double.nan], binCount: 2),
        throwsArgumentError,
      );
      expect(() => buildHistogramBins([1], binCount: 0), throwsArgumentError);
    },
  );

  test('frequency polygon maps each shared bin to midpoint and frequency', () {
    final bins = buildHistogramBins([0, 1, 2, 3, 4], binCount: 2);
    final polygon = buildFrequencyPolygon(bins);
    expect(polygon, hasLength(bins.length));
    for (var i = 0; i < bins.length; i++) {
      expect(polygon[i].x, bins[i].midpoint);
      expect(polygon[i].y, bins[i].frequency.toDouble());
    }
  });

  test('ogive is monotonic and finishes at n and 100 percent', () {
    final bins = buildHistogramBins([0, 1, 2, 3, 4], binCount: 2);
    final ogive = buildOgive(bins);
    expect(ogive.map((p) => p.cumulativeFrequency), [2, 5]);
    expect(ogive.map((p) => p.cumulativePercentage), [40, 100]);
    expect(ogive.last.cumulativeFrequency, 5);
    expect(ogive.last.cumulativePercentage, closeTo(100, 1e-12));
    expect(buildOgive([]), isEmpty);
  });

  test(
    'strip jitter is deterministic, bounded, and leaves original x intact',
    () {
      final values = [8.0, 8.0, 9.0, 10.0, 11.0, 12.0];
      final first = buildStripPoints(values);
      final second = buildStripPoints(values);
      expect(first.map((p) => p.value), values);
      expect(first.map((p) => p.jitter), second.map((p) => p.jitter));
      expect(first.every((p) => p.jitter.abs() <= 0.12), isTrue);
      expect(first[0].jitter, isNot(first[1].jitter));
      final duplicates = buildStripPoints(List<double>.filled(12, 8.0));
      expect(duplicates.map((p) => p.jitter).toSet(), hasLength(12));
      expect(
        duplicates.every((p) => p.value == 8 && p.jitter.abs() <= 0.12),
        isTrue,
      );
    },
  );

  test('Gaussian KDE is deterministic, finite, non-negative and integrates near one', () {
    final a = buildGaussianKde(touristServiceSample.values, bandwidth: 2.4);
    final b = buildGaussianKde(touristServiceSample.values, bandwidth: 2.4);
    expect(a, hasLength(100));
    expect(a.map((p) => (p.x, p.y)), b.map((p) => (p.x, p.y)));
    expect(a.every((p) => p.x.isFinite && p.y.isFinite && p.y >= 0), isTrue);
    var area = 0.0;
    for (var i = 1; i < a.length; i++) {
      area += (a[i].x - a[i - 1].x) * (a[i].y + a[i - 1].y) / 2;
    }
    expect(area, closeTo(1, 0.01));
    expect(buildGaussianKde([2], bandwidth: 1), isNotEmpty);
    expect(() => buildGaussianKde([], bandwidth: 1), throwsArgumentError);
    expect(() => buildGaussianKde([1], bandwidth: 0), throwsArgumentError);
    expect(
      () => buildGaussianKde([double.infinity], bandwidth: 1),
      throwsArgumentError,
    );
  });

  test('Batch 7 keeps twenty unique demos in the 180-demo catalog', () {
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
  });

  test('Graphify distribution options are JSON serializable and use distinct marks', () {
    final expected = {
      'histogram': 'bar',
      'frequency-polygon': 'line',
      'ogive': 'line',
      'strip-plot': 'scatter',
      'density': 'line',
    };
    for (final id in ids) {
      final options = graphifyDistributionOptions(id);
      final decoded = jsonDecode(jsonEncode(options)) as Map<String, dynamic>;
      expect((decoded['series'] as List).single['type'], expected[id]);
      expect(GraphifyView(initialOptions: options).initialOptions, options);
    }
    expect(
      (graphifyDistributionOptions('histogram')['series'] as List)
          .single['data'],
      hasLength(6),
    );
    expect(
      (graphifyDistributionOptions('strip-plot')['series'] as List)
          .single['data'],
      hasLength(touristServiceSample.values.length),
    );
    expect(
      (graphifyDistributionOptions('density')['series'] as List).single['data'],
      hasLength(100),
    );
  });

  for (final width in [320.0, 500.0]) {
    for (final id in ids) {
      for (final library in ChartLibrary.values.where(
        (l) => l != ChartLibrary.graphify,
      )) {
        testWidgets(
          '$id ${library.label} monta a ${width.toInt()} px sin excepción',
          (tester) async {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    key: const Key('distribution-size'),
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
              tester.getSize(find.byKey(const Key('distribution-size'))).width,
              width,
            );
          },
        );
      }
    }
  }

  testWidgets('Graphify distribution constructs widget configuration', (
    tester,
  ) async {
    for (final id in ids) {
      expect(
        ChartRenderer.buildChart(
          concept: ChartCatalog.byId(id),
          library: ChartLibrary.graphify,
        ),
        isA<DistributionBasicsChart>(),
      );
    }
  });
}
