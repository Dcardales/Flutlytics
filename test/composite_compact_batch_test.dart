import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/composite_compact_data.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/composite_compact_batch_demos.dart';

void main() {
  const ids = CompositeCompactBatchDemos.newConcepts;

  test('Batch 5 contracts validate shared domains, units, panel structure and sparkline tails', () {
    validateBatchFiveData();
    expect(barLinePeriods.map((p) => p.period).toList(), [1, 2, 3, 4, 5, 6]);
    expect(barLineBarUnit, contains('COP'));
    expect(barLineUnit, contains('%'));
    expect(
      barLinePeriods.every((p) => p.barValue.isFinite && p.lineValue.isFinite),
      isTrue,
    );
    expect(
      areaLinePeriods.map((p) => p.period).toSet(),
      hasLength(areaLinePeriods.length),
    );
    expect(
      areaLinePeriods.every(
        (p) => p.areaValue.isFinite && p.lineValue.isFinite,
      ),
      isTrue,
    );
    expect(
      areaLinePeriods.map((p) => p.areaValue - p.lineValue),
      containsAll(<double>[-40, 12, -2, 50, 25, 75]),
    );

    for (final panels in [smallMultiplesLinePanels, smallMultiplesBarPanels]) {
      expect(panels.map((p) => p.id).toSet(), hasLength(panels.length));
      expect(
        panels,
        everyElement(
          predicate<SmallMultiplePanel<Object>>(
            (p) => p.label.trim().isNotEmpty && p.points.isNotEmpty,
          ),
        ),
      );
    }
    expect(smallMultiplesLinePanels.map((p) => p.points.length).toSet(), {6});
    expect(
      smallMultiplesBarPanels
          .map((p) => p.points.map((v) => v.category).toList().toString())
          .toSet(),
      hasLength(1),
    );
    expect(maxAcrossPanels(smallMultiplesBarPanels, (p) => p.value), 95);
    expect(maxAcrossPanels(smallMultiplesLinePanels, (p) => p.value), 81);
    expect(
      () => maxAcrossPanels(
        const <SmallMultiplePanel<SmallLinePoint>>[],
        (p) => p.value,
      ),
      throwsArgumentError,
    );
    expect(
      () => maxAcrossPanels([
        const SmallMultiplePanel(
          id: 'bad',
          label: 'Bad',
          points: [SmallLinePoint(1, 'Ene', double.nan)],
        ),
      ], (p) => p.value),
      throwsArgumentError,
    );

    expect(sparklineKpis, hasLength(4));
    for (final kpi in sparklineKpis) {
      expect(kpi.points.length, greaterThanOrEqualTo(2));
      expect(kpi.currentValue, kpi.points.last.value);
      expect(kpi.points.every((p) => p.value.isFinite), isTrue);
    }
    for (final id in ids) {
      expect(ChartDatasetRegistry.forConcept(id), isNotNull, reason: id);
      expect(ChartDatasetRegistry.forConcept(id)!.rows, isNotEmpty, reason: id);
    }
  });

  test('global small-multiple scale includes the largest panel instead of autoscaling each', () {
    const panels = [
      SmallMultiplePanel(
        id: 'large',
        label: 'A',
        points: [SmallBarPoint('x', 100)],
      ),
      SmallMultiplePanel(
        id: 'small',
        label: 'B',
        points: [SmallBarPoint('x', 20)],
      ),
    ];
    expect(maxAcrossPanels(panels, (p) => p.value), 100);
    expect(
      graphifyCompositeCompactOptions(
        'small-multiples-bar',
        panelIndex: 0,
      )['yAxis']['max'],
      95,
    );
    expect(
      graphifyCompositeCompactOptions(
        'small-multiples-bar',
        panelIndex: 3,
      )['yAxis']['max'],
      95,
    );
  });

  test(
    'exactly twenty Batch 5 demos are registered, one per library and concept',
    () {
      for (final id in ids) {
        expect(
          ChartCatalog.concepts.any((c) => c.id == id),
          isTrue,
          reason: id,
        );
        for (final library in ChartLibrary.values) {
          expect(
            ChartRenderer.registrationCount(id, library),
            1,
            reason: '$id · ${library.name}',
          );
          expect(ChartRenderer.hasDemo(id, library), isTrue);
        }
      }
      expect(CompositeCompactBatchDemos.registrations, hasLength(20));
    },
  );

  test('Graphify options encode composite axes, real area fill, shared facet scales and sparklines', () {
    final barLine = graphifyCompositeCompactOptions('bar-line');
    expect(barLine['series'].map((s) => s['type']), ['bar', 'line']);
    expect(barLine['yAxis'], hasLength(2));
    expect(barLine['series'][0]['yAxisIndex'], 0);
    expect(barLine['series'][1]['yAxisIndex'], 1);
    expect(barLine['yAxis'][0]['name'], barLineBarUnit);
    expect(barLine['yAxis'][1]['name'], barLineUnit);

    final areaLine = graphifyCompositeCompactOptions('area-line');
    expect(areaLine['series'][0]['areaStyle'], isNotEmpty);
    expect(
      areaLine['series'][0]['data'],
      isNot(equals(areaLine['series'][1]['data'])),
    );
    for (final id in ['small-multiples-line', 'small-multiples-bar']) {
      for (var panel = 0; panel < 4; panel++) {
        final options = graphifyCompositeCompactOptions(id, panelIndex: panel);
        expect(jsonDecode(jsonEncode(options)), isA<Map<String, dynamic>>());
      }
    }
    final spark = graphifyCompositeCompactOptions(
      'sparkline',
      sparkLabel: 'Reservas',
    );
    expect(spark['xAxis']['show'], isFalse);
    expect(spark['yAxis']['show'], isFalse);
    expect(spark['grid']['left'], lessThanOrEqualTo(2));
    expect(
      jsonDecode(encodeGraphifyCompositeCompactOptions('bar-line')),
      isA<Map<String, dynamic>>(),
    );
    expect(
      ChartRenderer.buildChart(
        concept: ChartCatalog.byId('bar-line'),
        library: ChartLibrary.graphify,
      ),
      isA<CompositeCompactChart>(),
    );
    expect(GraphifyView(initialOptions: barLine).initialOptions, barLine);
  });

  for (final width in [320.0, 500.0]) {
    testWidgets(
      'FL Chart, Syncfusion and Graphic Batch 5 demos fit at ${width.toInt()} px',
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
            final chartHeight =
                (id == 'small-multiples-line' || id == 'small-multiples-bar')
                ? (width < 420 ? 500.0 : 280.0)
                : id == 'sparkline'
                ? (width < 420 ? 440.0 : 220.0)
                : 270.0;
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: SizedBox(
                    width: width,
                    height: chartHeight,
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
              reason: '$id · ${library.name} · ${width.toInt()}px',
            );
          }
        }
      },
    );
  }
}
