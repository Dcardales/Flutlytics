import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/chart_support_matrix.dart';
import 'package:flutlytics_v1/features/charts/data/performance_process_data.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/performance_process_batch_demos.dart';

void main() {
  test('funnel preserves ordered stages and derives conversions/drop-off', () {
    expect(bookingFunnel.steps, hasLength(5));
    expect(bookingFunnel.steps.map((s) => s.stage.id), [
      'visits',
      'searches',
      'selections',
      'checkout',
      'confirmed',
    ]);
    expect(bookingFunnel.steps.first.stage.value, 10000);
    expect(bookingFunnel.steps.last.stage.value, 1450);
    for (var i = 1; i < bookingFunnel.steps.length; i++) {
      expect(
        bookingFunnel.steps[i].stage.value,
        lessThan(bookingFunnel.steps[i - 1].stage.value),
      );
      expect(
        bookingFunnel.steps[i].dropOff,
        bookingFunnel.steps[i - 1].stage.value -
            bookingFunnel.steps[i].stage.value,
      );
    }
    expect(bookingFunnel.steps[1].conversionFromPrevious, closeTo(.62, 1e-12));
    expect(bookingFunnel.steps[2].conversionFromStart, closeTo(.39, 1e-12));
    expect(bookingFunnel.steps.first.dropOff, isNull);
    final zero = FunnelData([
      FunnelStage('a', 'A', 0),
      FunnelStage('b', 'B', 0),
    ]);
    expect(zero.steps.first.conversionFromStart, isNull);
    expect(zero.steps.last.conversionFromPrevious, isNull);
    expect(zero.steps.last.conversionFromStart, isNull);
    expect(zero.steps.last.dropOff, 0);
    expect(() => FunnelStage('x', '', 1), throwsArgumentError);
    expect(() => FunnelStage('x', 'X', double.infinity), throwsArgumentError);
    expect(
      () => FunnelData([FunnelStage('x', 'X', 1), FunnelStage('x', 'Y', 2)]),
      throwsArgumentError,
    );
  });

  test(
    'population pyramid keeps positive data with symmetric visual scale',
    () {
      expect(touristAgePyramid.rows, hasLength(6));
      expect(touristAgePyramid.maxMagnitude, 245);
      expect(touristAgePyramid.minAxis, -touristAgePyramid.maxAxis);
      for (final r in touristAgePyramid.rows) {
        expect(r.leftValue, greaterThanOrEqualTo(0));
        expect(r.rightValue, greaterThanOrEqualTo(0));
        expect(r.leftCoordinate, -r.leftValue);
        expect(r.rightCoordinate, r.rightValue);
      }
      expect(() => PopulationPyramidRow('x', -1, 2), throwsArgumentError);
      expect(
        () => PopulationPyramidRow('x', 1, double.nan),
        throwsArgumentError,
      );
      expect(
        () => PopulationPyramidData([
          PopulationPyramidRow('x', 1, 2),
          PopulationPyramidRow('x', 2, 3),
        ]),
        throwsArgumentError,
      );
    },
  );

  test('gauge validates finite range, target and normalization', () {
    expect(hotelOccupancyGauge.normalizedValue, .78);
    expect(hotelOccupancyGauge.normalizedTarget, .8);
    final mid = GaugeMetric('Mid', 5, 0, 10, target: 8);
    expect(mid.normalize(mid.min), 0);
    expect(mid.normalize(mid.max), 1);
    expect(mid.normalizedValue, .5);
    expect(() => mid.normalize(double.nan), throwsArgumentError);
    expect(() => mid.normalize(11), throwsArgumentError);
    expect(() => GaugeMetric('x', 5, 10, 10), throwsArgumentError);
    expect(() => GaugeMetric('x', 5, 0, double.infinity), throwsArgumentError);
    expect(() => GaugeMetric('x', 11, 0, 10), throwsArgumentError);
    expect(() => GaugeMetric('x', 5, 0, 10, target: 11), throwsArgumentError);
  });

  test('bullet has one linear scale with ordered qualitative bands', () {
    expect(monthlyRevenueBullet.value, 82);
    expect(monthlyRevenueBullet.target, 90);
    expect(monthlyRevenueBullet.bands.map((b) => (b.start, b.end)), [
      (0.0, 60.0),
      (60.0, 80.0),
      (80.0, 100.0),
    ]);
    expect(monthlyRevenueBullet.currentBand!.label, 'Bueno');
    expect(
      () => BulletMetric('x', 82, 90, 0, 100, [
        BulletRange(80, 'A'),
        BulletRange(60, 'B'),
      ]),
      throwsArgumentError,
    );
    expect(
      () => BulletMetric('x', 82, 90, 0, 100, [BulletRange(120, 'A')]),
      throwsArgumentError,
    );
    expect(
      () => BulletMetric('x', double.nan, 90, 0, 100, [BulletRange(100, 'A')]),
      throwsArgumentError,
    );
  });

  test(
    'timeline sorts real dates, supports same day and deterministic lanes',
    () {
      expect(flutterMilestones.events, hasLength(6));
      expect(flutterMilestones.events.first.id, 'start');
      expect(flutterMilestones.events.last.id, 'delivery');
      expect(flutterMilestones.points.first.dayOffset, 0);
      expect(flutterMilestones.points.last.dayOffset, greaterThan(200));
      for (var i = 1; i < flutterMilestones.points.length; i++) {
        expect(
          flutterMilestones.points[i].event.date.isBefore(
            flutterMilestones.points[i - 1].event.date,
          ),
          isFalse,
        );
        expect(
          flutterMilestones.points[i].dayOffset,
          greaterThanOrEqualTo(flutterMilestones.points[i - 1].dayOffset),
        );
        expect(
          flutterMilestones.points[i].lane,
          -flutterMilestones.points[i - 1].lane,
        );
      }
      final same = TimelineData([
        TimelineEvent('b', DateTime.utc(2026, 1, 1), 'B', 'second', 'test'),
        TimelineEvent('a', DateTime.utc(2026, 1, 1), 'A', 'first', 'test'),
      ]);
      expect(same.events.map((e) => e.id), ['a', 'b']);
      expect(same.points.map((p) => p.dayOffset), [0, 0]);
      expect(
        () => TimelineData([same.events.first, same.events.first]),
        throwsArgumentError,
      );
      expect(
        () => TimelineEvent(
          'x',
          DateTime.utc(2026),
          '',
          'description',
          'category',
        ),
        throwsArgumentError,
      );
    },
  );

  test('Batch 13 registers 20 demos and distinct datasets', () {
    for (final id in batch13Ids) {
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
    expect(ChartSupportMatrix.codes['timeline'], 'CCCC');
    expect(ChartSupportMatrix.codes['pyramid'], 'CCCC');
    expect(ChartSupportMatrix.codes['gauge'], 'CCCN');
    expect(ChartSupportMatrix.codes['bullet'], 'CCCC');
    expect(ChartSupportMatrix.codes['funnel'], 'CNNN');
  });

  test('final 65×4 Cartesian coverage is exact, unique and supported', () {
    final concepts = ChartCatalog.concepts;
    final libraries = ChartLibrary.values;
    final registrations = ChartRenderer.registrations;
    expect(concepts, hasLength(65));
    expect(concepts.where((c) => c.level == ChartLevel.basic), hasLength(40));
    expect(
      concepts.where((c) => c.level == ChartLevel.advanced),
      hasLength(25),
    );
    expect(libraries, hasLength(4));
    expect(registrations, hasLength(260));
    final expected = {
      for (final concept in concepts)
        for (final library in libraries) (concept.id, library),
    };
    final actual = registrations.map((r) => (r.conceptId, r.library)).toList();
    expect(expected, hasLength(260));
    expect(actual.toSet(), hasLength(actual.length));
    expect(actual.toSet(), expected);
    for (final concept in concepts) {
      expect(
        registrations.where((r) => r.conceptId == concept.id),
        hasLength(4),
      );
      for (final library in libraries) {
        expect(ChartRenderer.registrationCount(concept.id, library), 1);
        expect(concept.support[library], isNot(ChartSupportType.unsupported));
      }
    }
    for (final library in libraries) {
      expect(registrations.where((r) => r.library == library), hasLength(65));
    }
    expect(
      concepts
          .expand((c) => c.support.values)
          .where((s) => s == ChartSupportType.unsupported),
      isEmpty,
    );
  });

  test('Graphify Batch 13 options are JSON-only and preserve semantics', () {
    for (final id in batch13Ids) {
      final options = performanceProcessOptions(id);
      final encoded = jsonEncode(options);
      expect(jsonDecode(encoded), isA<Map<String, dynamic>>());
      expect(encoded.contains('renderItem'), isFalse);
      expect(GraphifyView(initialOptions: options).initialOptions, options);
    }
    expect(performanceProcessOptions('funnel')['series'][0]['type'], 'funnel');
    expect(
      performanceProcessOptions('pyramid')['series'].map((s) => s['type']),
      ['bar', 'bar'],
    );
    expect(performanceProcessOptions('gauge')['series'][0]['type'], 'gauge');
    expect(
      performanceProcessOptions('bullet')['series'][0]['markLine'],
      isNotNull,
    );
    expect(
      performanceProcessOptions('bullet')['series'][0]['markArea'],
      isNotNull,
    );
    expect(performanceProcessOptions('timeline')['xAxis']['type'], 'time');
  });

  for (final width in [320.0, 500.0]) {
    for (final id in batch13Ids) {
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
