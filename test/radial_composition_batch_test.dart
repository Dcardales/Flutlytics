import 'dart:convert';

import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/chart_support_matrix.dart';
import 'package:flutlytics_v1/features/charts/data/radial_composition_data.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/radial_composition_batch_demos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';

void main() {
  const ids = RadialCompositionBatchDemos.newConcepts;

  test('composition validates totals, shares, labels and finite nonnegative slices', () {
    final pie = compositionPercentages(reservationSlices);
    expect(pie.total, 100);
    expect(pie.shares.map((s) => s.percent), [48, 27, 15, 10]);
    final centralKpi = compositionPercentages(revenueSlices).total;
    expect(centralKpi, 100);
    expect(
      centralKpi,
      revenueSlices.fold<double>(0, (sum, slice) => sum + slice.value),
    );
    expect(
      () => compositionPercentages(const [CompositionSlice('', 1)]),
      throwsArgumentError,
    );
    expect(
      () => compositionPercentages(const [CompositionSlice('A', -1)]),
      throwsArgumentError,
    );
    expect(
      () => compositionPercentages(const [CompositionSlice('A', double.nan)]),
      throwsArgumentError,
    );
    expect(
      () => compositionPercentages(const [CompositionSlice('A', 0)]),
      throwsArgumentError,
    );
    expect(
      () => compositionPercentages(const [
        CompositionSlice('A', 1),
        CompositionSlice('A', 2),
      ]),
      throwsArgumentError,
    );
  });

  test(
    'waffle maps a bounded percent into exactly 100 discrete unit cells',
    () {
      final cells = waffleCells(73);
      expect(cells, hasLength(100));
      expect(cells.where((c) => c.active), hasLength(73));
      expect(cells.where((c) => !c.active), hasLength(27));
      expect(waffleCells(0).where((c) => c.active), isEmpty);
      expect(waffleCells(100).where((c) => c.active), hasLength(100));
      expect(waffleCells(72.6).where((c) => c.active), hasLength(73));
      expect(waffleCells(72.4).where((c) => c.active), hasLength(72));
      expect(waffleCells(50, rows: 2, columns: 4), hasLength(8));
      expect(() => waffleCells(double.nan), throwsArgumentError);
      expect(() => waffleCells(101), throwsArgumentError);
      expect(() => waffleCells(50, rows: 0), throwsArgumentError);
    },
  );

  test('polar magnitudes are unique finite nonnegative values without a 100 total rule', () {
    expect(validatePolarArea(tourismDemand), hasLength(5));
    expect(
      tourismDemand.map((p) => p.value).reduce((a, b) => a + b),
      isNot(100),
    );
    expect(maxAcrossPolarPanels([tourismDemand]), 2100);
    expect(
      () => validatePolarArea(const [
        PolarDatum('A', 1),
        PolarDatum('A', 2),
        PolarDatum('C', 3),
      ]),
      throwsArgumentError,
    );
    expect(
      () => validatePolarArea(const [
        PolarDatum('A', 1),
        PolarDatum('B', -1),
        PolarDatum('C', 3),
      ]),
      throwsArgumentError,
    );
    expect(
      () => validatePolarArea(const [PolarDatum('A', 1), PolarDatum('B', 2)]),
      throwsArgumentError,
    );
    expect(() => maxAcrossPolarPanels(const []), throwsArgumentError);
  });

  test('radar enforces at least three shared dimensions and scores within common bounds', () {
    expect(
      validateRadarProfiles(tourismDimensions, tourismProfiles),
      hasLength(2),
    );
    expect(
      () => validateRadarProfiles(['A', 'A', 'C'], tourismProfiles),
      throwsArgumentError,
    );
    expect(
      () => validateRadarProfiles(tourismDimensions, const [
        RadarProfile('X', [1, 2]),
      ]),
      throwsArgumentError,
    );
    expect(
      () => validateRadarProfiles(tourismDimensions, const [
        RadarProfile('Repeated', [1, 2, 3, 4, 5, 6]),
        RadarProfile('Repeated', [2, 3, 4, 5, 6, 7]),
      ]),
      throwsArgumentError,
    );
    expect(
      () => validateRadarProfiles(tourismDimensions, const [
        RadarProfile('X', [1, 2, 3, 4, 5, 11]),
      ]),
      throwsArgumentError,
    );
    expect(
      () => validateRadarProfiles(tourismDimensions, const [
        RadarProfile('X', [1, 2, double.infinity, 4, 5, 6]),
      ]),
      throwsArgumentError,
    );
  });

  test('twenty Batch 6 demos and all five datasets are registered', () {
    expect(RadialCompositionBatchDemos.registrations, hasLength(20));
    for (final id in ids) {
      expect(ChartCatalog.concepts.any((c) => c.id == id), isTrue);
      expect(ChartDatasetRegistry.forConcept(id)!.rows, isNotEmpty);
      for (final library in ChartLibrary.values) {
        expect(
          ChartRenderer.registrationCount(id, library),
          1,
          reason: '$id / ${library.name}',
        );
        expect(ChartRenderer.hasDemo(id, library), isTrue);
      }
    }
    expect(ChartRenderer.registrations, hasLength(260));
    expect(ChartSupportMatrix.codes['waffle'], 'CCCC');
  });

  test(
    'Graphify uses JSON ECharts primitives with semantic radial encodings',
    () {
      for (final id in ids) {
        final encoded = encodeGraphifyRadialOptions(id);
        final options = jsonDecode(encoded) as Map<String, dynamic>;
        expect(options['series'], isNotEmpty, reason: id);
        expect(encoded, isNot(contains('renderItem')));
        expect(GraphifyView(initialOptions: options).initialOptions, options);
        expect(
          ChartRenderer.buildChart(
            concept: ChartCatalog.byId(id),
            library: ChartLibrary.graphify,
          ),
          isA<RadialCompositionChart>(),
        );
      }
      expect(graphifyRadialOptions('pie')['series'][0]['type'], 'pie');
      expect(graphifyRadialOptions('donut')['series'][0]['radius'], [
        '42%',
        '68%',
      ]);
      expect(
        graphifyRadialOptions('waffle')['series'][0]['data'],
        hasLength(100),
      );
      expect(
        graphifyRadialOptions('polar-area')['series'][0]['coordinateSystem'],
        'polar',
      );
      expect(graphifyRadialOptions('radar')['series'][0]['type'], 'radar');
    },
  );

  for (final width in [320.0, 500.0]) {
    testWidgets(
      'FL Chart, Syncfusion and Graphic fit Batch 6 at ${width.toInt()} px',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final library in [
          ChartLibrary.flChart,
          ChartLibrary.syncfusion,
          ChartLibrary.graphic,
        ]) {
          for (final id in ids) {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: width,
                    height: width < 420 ? 390 : 330,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ChartRenderer.buildChart(
                        concept: ChartCatalog.byId(id),
                        library: library,
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$id / ${library.name} / ${width.toInt()} px',
            );
          }
        }
      },
    );
  }
}
