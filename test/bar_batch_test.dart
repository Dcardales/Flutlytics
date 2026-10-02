import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/bar_batch_demos.dart';

void main() {
  const batch = [
    'bar',
    'grouped-bar',
    'stacked-bar',
    'normalized-stacked-bar',
    'diverging-bar',
  ];
  const libs = ChartLibrary.values;

  test('grouped data has several series and coherent categories', () {
    final rows = ChartDatasetRegistry.barDataFor('grouped-bar');
    final categories = rows.map((r) => r.category).toSet();
    final series = rows.map((r) => r.series).toSet();
    expect(series, hasLength(3));
    expect(categories, hasLength(3));
    for (final name in series) {
      expect(
        rows.where((r) => r.series == name).map((r) => r.category).toSet(),
        categories,
      );
    }
  });

  test('stacked segments are valid and totals remain absolute', () {
    final rows = ChartDatasetRegistry.barDataFor('stacked-bar');
    expect(rows.every((r) => r.value >= 0), isTrue);
    final totals = {
      for (final c in rows.map((r) => r.category).toSet())
        c: rows
            .where((r) => r.category == c)
            .fold<double>(0, (a, r) => a + r.value),
    };
    expect(totals.values.toSet().length, greaterThan(1));
    expect(totals.values, everyElement(greaterThan(0)));
  });

  test(
    'normalization is deterministic, totals 100%, and defines zero totals',
    () {
      final raw = ChartDatasetRegistry.barDataFor('normalized-stacked-bar');
      final first = normalizeBars(raw);
      expect(
        normalizeBars(raw).map((r) => (r.category, r.series, r.value)),
        first.map((r) => (r.category, r.series, r.value)),
      );
      for (final category in first.map((r) => r.category).toSet()) {
        expect(
          first
              .where((r) => r.category == category)
              .fold<double>(0, (a, r) => a + r.value),
          closeTo(100, 1e-9),
        );
      }
      const zero = [
        BarDatum(category: 'Vacía', series: 'A', value: 0),
        BarDatum(category: 'Vacía', series: 'B', value: 0),
      ];
      expect(normalizeBars(zero).map((r) => r.value), [0, 0]);
    },
  );

  test('diverging dataset has both signs and zero is the stated reference', () {
    final values = ChartDatasetRegistry.pointsFor('diverging-bar')
        .map((p) => p.value);
    expect(values.any((v) => v > 0), isTrue);
    expect(values.any((v) => v < 0), isTrue);
    expect(
      ChartDatasetRegistry.forConcept('diverging-bar')!.invariants,
      contains('cero es la referencia'),
    );
  });

  test('Batch 1 has exactly twenty unique valid registrations', () {
    final batchKeys = ChartRenderer.registrations
        .where((r) => batch.contains(r.conceptId))
        .toList();
    expect(batchKeys, hasLength(20));
    expect(
      batchKeys.map((r) => (r.conceptId, r.library)).toSet(),
      hasLength(20),
    );
    for (final id in batch) {
      expect(ChartCatalog.concepts.any((c) => c.id == id), isTrue);
      for (final library in libs) {
        expect(ChartRenderer.registrationCount(id, library), 1);
        final widget = ChartRenderer.buildChart(
          concept: ChartCatalog.byId(id),
          library: library,
        );
        expect(widget, isNot(isA<Text>()));
      }
    }
  });

  test(
    'Graphify options remain JSON-only ECharts bar options and construct views',
    () {
      for (final id in batch.skip(1)) {
        final options = graphifyOptions(id);
        final encoded = jsonEncode(options);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        expect(decoded['series'], isNotEmpty);
        expect(encoded, isNot(contains('renderItem')));
        expect(
          (decoded['series'] as List).every((s) => s['type'] == 'bar'),
          isTrue,
        );
        expect(GraphifyView(initialOptions: options).initialOptions, options);
      }
      expect(
        (graphifyOptions('grouped-bar')['series'] as List).every(
          (s) => !s.containsKey('stack'),
        ),
        isTrue,
      );
      expect(
        (graphifyOptions('stacked-bar')['series'] as List).every(
          (s) => s['stack'] == 'total',
        ),
        isTrue,
      );
      final normalized = graphifyOptions('normalized-stacked-bar');
      expect(normalized['yAxis']['max'], 100);
    },
  );

  for (final width in [320.0, 500.0]) {
    for (final id in batch) {
      for (final library in libs.where((l) => l != ChartLibrary.graphify)) {
        testWidgets('$id ${library.label} builds at ${width.toInt()} px', (
          tester,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  key: const Key('demo-width'),
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
            tester.getSize(find.byKey(const Key('demo-width'))).width,
            width,
          );
        });
      }
    }
  }

  testWidgets(
    'Graphify widget constructs without claiming web engine execution',
    (tester) async {
      final widget = ChartRenderer.buildChart(
        concept: ChartCatalog.byId('normalized-stacked-bar'),
        library: ChartLibrary.graphify,
      );
      expect(widget, isA<BarBatchChart>());
      // GraphifyView itself is constructed deterministically by the renderer; actual
      // WebView execution is covered only by the existing explicitly skipped web test.
    },
  );
}
