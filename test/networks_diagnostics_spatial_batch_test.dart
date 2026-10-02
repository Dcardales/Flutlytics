import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/analytical_structures_data.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/chart_support_matrix.dart';
import 'package:flutlytics_v1/features/charts/data/networks_diagnostics_spatial_data.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/networks_diagnostics_spatial_batch_demos.dart';

void main() {
  test(
    'network validates nodes and endpoints; stable circle retains edges',
    () {
      expect(touristNetwork.nodes, hasLength(7));
      expect(touristNetwork.edges, hasLength(8));
      expect(
        touristNetwork.positions.every((p) => p.x.isFinite && p.y.isFinite),
        isTrue,
      );
      expect(
        touristNetwork.positions.map((p) => p.node.id).toSet(),
        touristNetwork.nodes.map((n) => n.id).toSet(),
      );
      final copy = NetworkGraphData(touristNetwork.nodes, touristNetwork.edges);
      for (var i = 0; i < copy.positions.length; i++) {
        expect(copy.positions[i].x, touristNetwork.positions[i].x);
        expect(copy.positions[i].y, touristNetwork.positions[i].y);
      }
      expect(touristNetwork.connections('centro'), hasLength(4));
      expect(() => NetworkNode('', 'bad', 'group', 1), throwsArgumentError);
      expect(
        () => NetworkNode('x', 'X', 'group', double.nan),
        throwsArgumentError,
      );
      expect(() => NetworkEdge('x', 'x', 1), throwsArgumentError);
      expect(() => NetworkEdge('x', 'y', double.infinity), throwsArgumentError);
      expect(
        () => NetworkGraphData(
          [NetworkNode('x', 'X', 'g', 1), NetworkNode('x', 'Y', 'g', 1)],
          [NetworkEdge('x', 'y', 1)],
        ),
        throwsArgumentError,
      );
      expect(
        () => NetworkGraphData(touristNetwork.nodes, [
          NetworkEdge('centro', 'missing', 1),
        ]),
        throwsArgumentError,
      );
    },
  );

  test('normal Q-Q uses real quantiles, sample standardization and order', () {
    expect(serviceMinutes, hasLength(48));
    expect(serviceQq, hasLength(serviceMinutes.length));
    expect(inverseNormalCdf(.5), closeTo(0, 1e-7));
    expect(inverseNormalCdf(.975), closeTo(1.96, .01));
    expect(inverseNormalCdf(.025), closeTo(-1.96, .01));
    expect(inverseNormalCdf(.1), closeTo(-inverseNormalCdf(.9), 1e-8));
    expect(() => inverseNormalCdf(0), throwsArgumentError);
    expect(() => inverseNormalCdf(1), throwsArgumentError);
    expect(() => inverseNormalCdf(double.nan), throwsArgumentError);
    expect(() => normalQq([1, 2]), throwsArgumentError);
    expect(() => normalQq([1, 2, double.infinity]), throwsArgumentError);
    expect(() => normalQq([1, 1, 1]), throwsArgumentError);
    for (var i = 0; i < serviceQq.length; i++) {
      final p = serviceQq[i];
      expect(p.probability, closeTo((i + .5) / serviceQq.length, 1e-12));
      expect(p.theoretical.isFinite && p.observed.isFinite, isTrue);
      if (i > 0) {
        expect(p.theoretical, greaterThan(serviceQq[i - 1].theoretical));
        expect(p.observed, greaterThanOrEqualTo(serviceQq[i - 1].observed));
      }
    }
    final mean =
        serviceQq.map((p) => p.observed).reduce((a, b) => a + b) /
        serviceQq.length;
    final sd = math.sqrt(
      serviceQq
              .map((p) => math.pow(p.observed - mean, 2))
              .reduce((a, b) => a + b) /
          (serviceQq.length - 1),
    );
    expect(mean, closeTo(0, 1e-12));
    expect(sd, closeTo(1, 1e-12));
    expect(
      serviceQq.last.observed,
      isNot(closeTo(serviceQq.last.theoretical, .05)),
    );
  });

  test('parallel preserves dimensions and normalizes each independently', () {
    expect(touristParallel.variables, hasLength(5));
    expect(touristParallel.observations, hasLength(10));
    expect(touristParallel.points, hasLength(50));
    for (final o in touristParallel.observations) {
      final points = touristParallel.forObservation(o);
      expect(points.map((p) => p.axis), [0, 1, 2, 3, 4]);
      expect(
        points.every((p) => p.normalized >= 0 && p.normalized <= 1),
        isTrue,
      );
    }
    expect(ParallelCoordinatesData.normalize(7, 7, 7), .5);
    expect(ParallelCoordinatesData.normalize(1, 1, 3), 0);
    expect(ParallelCoordinatesData.normalize(3, 1, 3), 1);
    expect(
      () => ParallelCoordinatesData.normalize(double.nan, 0, 1),
      throwsArgumentError,
    );
    expect(
      () => ParallelCoordinatesData(
        [MatrixVariable('a', 'A', 'u'), MatrixVariable('b', 'B', 'u')],
        [
          MultivariateObservation('x', {'a': 1, 'b': 2}),
        ],
      ),
      throwsArgumentError,
    );
  });

  test(
    'contour is a deterministic interpolated 25x20 Marching Squares field',
    () {
      expect(touristContour.grid, hasLength(20));
      expect(touristContour.grid.every((r) => r.length == 25), isTrue);
      expect(touristContour.minZ, lessThan(touristContour.maxZ));
      expect(touristContour.levels, hasLength(6));
      for (final level in touristContour.levels) {
        expect(
          level,
          inExclusiveRange(touristContour.minZ, touristContour.maxZ),
        );
        expect(
          touristContour.segments.where((s) => s.level == level),
          isNotEmpty,
        );
      }
      for (final s in touristContour.segments) {
        expect([s.a.x, s.a.y, s.b.x, s.b.y].every((v) => v.isFinite), isTrue);
        expect((s.a.x - s.b.x).abs(), lessThanOrEqualTo(1.000001));
        expect((s.a.y - s.b.y).abs(), lessThanOrEqualTo(1.000001));
        expect(s.a.z, s.level);
        expect(s.b.z, s.level);
      }
      final clone = ContourData(touristContour.grid, touristContour.levels);
      expect(clone.segments.length, touristContour.segments.length);
      for (var i = 0; i < clone.segments.length; i++) {
        expect(clone.segments[i].a.x, touristContour.segments[i].a.x);
        expect(clone.segments[i].b.y, touristContour.segments[i].b.y);
      }
      final one = ContourData(
        [
          const [FieldPoint(0, 0, 0), FieldPoint(1, 0, 10)],
          const [FieldPoint(0, 1, 0), FieldPoint(1, 1, 10)],
        ],
        const [2],
      );
      expect(one.segments, hasLength(1));
      expect(one.segments.single.a.x, closeTo(.2, 1e-12));
      expect(one.segments.single.b.x, closeTo(.2, 1e-12));
      final saddle = ContourData(
        [
          const [FieldPoint(0, 0, 0), FieldPoint(1, 0, 10)],
          const [FieldPoint(0, 1, 10), FieldPoint(1, 1, 0)],
        ],
        const [4],
      );
      expect(saddle.segments, hasLength(2));
      expect(saddle.segments.first.a.x, closeTo(.4, 1e-12));
      expect(saddle.segments.first.b.x, 0); // Low corner A is isolated.
      expect(
        () => ContourData(
          [
            [const FieldPoint(0, 0, 1)],
            [],
          ],
          [.5],
        ),
        throwsArgumentError,
      );
    },
  );

  test('calendar aligns Monday and survives month/year boundaries', () {
    expect(bookingCalendar.cells, hasLength(181));
    expect(
      bookingCalendar.cells.map((c) => isoDay(c.day.date)).toSet(),
      hasLength(181),
    );
    expect(bookingCalendar.cells.first.weekday, 2); // 2025-10-01 Wednesday.
    expect(bookingCalendar.cells.first.week, 0);
    expect(bookingCalendar.cells[4].weekday, 6);
    expect(bookingCalendar.cells[5].weekday, 0);
    expect(bookingCalendar.cells[5].week, 1);
    expect(
      bookingCalendar.cells
          .singleWhere((c) => isoDay(c.day.date) == '2026-01-01')
          .weekday,
      3,
    );
    expect(
      bookingCalendar.cells.every(
        (c) => c.week >= 0 && c.weekday >= 0 && c.weekday < 7,
      ),
      isTrue,
    );
    expect(bookingCalendar.minValue, lessThan(bookingCalendar.maxValue));
    expect(
      bookingCalendar.cells.every(
        (c) =>
            bookingCalendar.intensity(c.day) >= 0 &&
            bookingCalendar.intensity(c.day) <= 1,
      ),
      isTrue,
    );
    expect(
      () => CalendarHeatmapData([
        CalendarDay(DateTime.utc(2025, 1, 1), 2),
        CalendarDay(DateTime.utc(2025, 1, 1), 3),
      ]),
      throwsArgumentError,
    );
    expect(
      () => CalendarDay(DateTime.utc(2025, 1, 1), double.infinity),
      throwsArgumentError,
    );
  });

  test('Batch 12 registers 20 demos and distinct datasets', () {
    expect(ChartRenderer.registrations, hasLength(260));
    for (final id in batch12Ids) {
      expect(ChartDatasetRegistry.forConcept(id)!.rows, isNotEmpty);
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
    expect(ChartSupportMatrix.codes['calendar-heatmap'], 'CCCN');
  });

  test(
    'Graphify uses graph, parallel and calendar natively with JSON options',
    () {
      for (final id in batch12Ids) {
        final options = networksDiagnosticsSpatialOptions(id);
        final encoded = jsonEncode(options);
        expect(jsonDecode(encoded), isA<Map<String, dynamic>>());
        expect(encoded.contains('renderItem'), isFalse);
        expect(GraphifyView(initialOptions: options).initialOptions, options);
      }
      final network = networksDiagnosticsSpatialOptions(
        'network-graph',
      )['series'][0];
      expect(network['type'], 'graph');
      expect(network['data'], hasLength(7));
      expect(network['links'], hasLength(8));
      expect(network['layout'], 'none');
      expect(
        networksDiagnosticsSpatialOptions(
          'parallel-coordinates',
        )['parallelAxis'],
        hasLength(5),
      );
      expect(
        networksDiagnosticsSpatialOptions('calendar-heatmap')['calendar'],
        isNotNull,
      );
      expect(
        networksDiagnosticsSpatialOptions(
          'calendar-heatmap',
        )['series'][0]['data'],
        hasLength(181),
      );
      expect(
        networksDiagnosticsSpatialOptions('contour')['series'],
        hasLength(touristContour.segments.length),
      );
    },
  );

  for (final width in [320.0, 500.0]) {
    for (final id in batch12Ids) {
      for (final library in ChartLibrary.values.where(
        (l) => l != ChartLibrary.graphify,
      )) {
        testWidgets('$id ${library.label} mounts at ${width.toInt()} px', (
          tester,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: width,
                  height: 320,
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
        });
      }
    }
  }
}
