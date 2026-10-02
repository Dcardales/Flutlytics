import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/data/time_series_data.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/core_time_series_batch_demos.dart';

void main() {
  const ids = ['line', 'multi-line', 'area', 'stacked-area', 'step-line'];
  const newIds = ['multi-line', 'area', 'stacked-area', 'step-line'];

  test('line audit has one ordered year of monthly sales and four demos', () {
    final points = ChartDatasetRegistry.pointsFor('line');
    final temporalPoints = singleTimeSeriesFor('line');
    expect(points, hasLength(12));
    expect(
      temporalPoints.map((p) => p.period),
      orderedEquals(List.generate(12, (i) => i + 1)),
    );
    expect(points.last.label, 'Dic');
    expect(points.every((p) => p.value >= 0), isTrue);
    for (final library in ChartLibrary.values) {
      expect(ChartRenderer.registrationCount('line', library), 1);
    }
  });

  test('multi-line data shares six periods, labels, and comparable units', () {
    final rows = multiTimeSeriesFor('multi-line');
    final names = rows.map((p) => p.series).toSet();
    expect(names, {'Bogotá', 'Medellín', 'Cartagena'});
    final domains = [
      for (final name in names)
        rows.where((p) => p.series == name).map((p) => p.period).toSet(),
    ];
    expect(
      domains.every(
        (domain) =>
            domain.length == 6 &&
            domain.containsAll(domains.first) &&
            domains.first.containsAll(domain),
      ),
      isTrue,
    );
    expect(
      ChartDatasetRegistry.forConcept('multi-line')!.unit,
      '% de habitaciones ocupadas',
    );
    expect(rows.map((p) => p.value), everyElement(inInclusiveRange(0, 100)));
  });

  test('single area data uses one non-negative series and zero baseline', () {
    final points = singleTimeSeriesFor('area');
    expect(points, hasLength(7));
    expect(points.map((p) => p.period), orderedEquals([1, 2, 3, 4, 5, 6, 7]));
    expect(points.every((p) => p.value.isFinite && p.value >= 0), isTrue);
    expect(
      ChartDatasetRegistry.forConcept('area')!.invariants,
      contains('baseline cero explícita'),
    );
    expect(
      ChartDatasetRegistry.forConcept('area')!.rows
          .every((row) => !row.containsKey('series')),
      isTrue,
    );
  });

  test('stacked area computes absolute lower, upper and per-period totals', () {
    final points = stackedAreaFor('stacked-area');
    final names = points.map((p) => p.series).toSet();
    expect(names, {'Agencia', 'Teléfono', 'Web'});
    for (final period in points.map((p) => p.period).toSet()) {
      final rows = points.where((p) => p.period == period).toList();
      final total = rows.fold<double>(0, (sum, p) => sum + p.value);
      expect(rows.last.upper, total);
      expect(rows.last.total, total);
      expect(rows.first.lower, 0);
      for (var i = 1; i < rows.length; i++) {
        expect(rows[i].lower, rows[i - 1].upper);
      }
    }
    expect(points.first.total, 75);
    expect(points.any((p) => p.total != 100), isTrue);
  });

  test('step-after sorts events and duplicates exact transition vertices', () {
    const shuffled = [
      SingleTimeSeriesPoint(period: 3, label: 'Mar', value: 15),
      SingleTimeSeriesPoint(period: 1, label: 'Ene', value: 10),
      SingleTimeSeriesPoint(period: 2, label: 'Feb', value: 20),
    ];
    final output = stepAfter(shuffled);
    expect(output.map((p) => (p.period, p.value)), [
      (1, 10),
      (2, 10),
      (2, 20),
      (3, 20),
      (3, 15),
    ]);
    expect(
      () => stepAfter(const [
        SingleTimeSeriesPoint(period: 1, label: 'A', value: 1),
        SingleTimeSeriesPoint(period: 1, label: 'B', value: 2),
      ]),
      throwsArgumentError,
    );
  });

  test('all Batch 3 keys are unique and exactly twenty', () {
    final batch = ChartRenderer.registrations
        .where((r) => ids.contains(r.conceptId))
        .toList();
    expect(batch, hasLength(20));
    expect(batch.map((r) => (r.conceptId, r.library)).toSet(), hasLength(20));
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
    expect(
      newIds.expand(
        (id) => ChartLibrary.values.map((library) => (id, library)),
      ),
      hasLength(16),
    );
  });

  test(
    'Graphify options serialize as ECharts line series and construct views',
    () {
      for (final id in newIds) {
        final options = graphifyTimeSeriesOptions(id);
        final encoded = jsonEncode(options);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        final series = (decoded['series'] as List).cast<Map<String, dynamic>>();
        expect(series, isNotEmpty);
        expect(series.every((row) => row['type'] == 'line'), isTrue);
        expect(encoded, isNot(contains('renderItem')));
        expect(GraphifyView(initialOptions: options).initialOptions, options);
      }
      expect(
        (graphifyTimeSeriesOptions('multi-line')['series'] as List),
        hasLength(3),
      );
      final stacked =
          (graphifyTimeSeriesOptions('stacked-area')['series'] as List)
              .cast<Map>();
      expect(
        stacked.every(
          (s) => s['stack'] == 'reservations' && s.containsKey('areaStyle'),
        ),
        isTrue,
      );
      expect(
        (graphifyTimeSeriesOptions('step-line')['series'] as List)
            .first['step'],
        'end',
      );
      expect(
        (graphifyTimeSeriesOptions('area')['series'] as List)
            .first['areaStyle'],
        isNotNull,
      );
    },
  );

  for (final width in [320.0, 500.0]) {
    for (final id in ids) {
      for (final library in ChartLibrary.values.where(
        (l) => l != ChartLibrary.graphify,
      )) {
        testWidgets(
          '$id ${library.label} monta sin overflow a ${width.toInt()} px',
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

  testWidgets(
    'Graphify time-series widget builds without claiming WebView render',
    (tester) async {
      final widget = ChartRenderer.buildChart(
        concept: ChartCatalog.byId('step-line'),
        library: ChartLibrary.graphify,
      );
      expect(widget, isA<CoreTimeSeriesChart>());
      expect(widget, isNotNull);
    },
  );
}
