import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/financial_planning_data.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/financial_planning_batch_demos.dart';

void main() {
  const ids = ['range-area', 'candlestick', 'ohlc', 'waterfall', 'gantt'];

  test('range area validates and orders real lower/upper bounds', () {
    expect(hotelOccupancyRange, hasLength(8));
    expect(
      hotelOccupancyRange.map((p) => p.period),
      orderedEquals([...hotelOccupancyRange.map((p) => p.period)]..sort()),
    );
    expect(
      hotelOccupancyRange.every(
        (p) => p.low <= p.high && p.span == p.high - p.low,
      ),
      isTrue,
    );
    expect(
      () => RangeTimePoint(period: 'X', low: 4, high: 3),
      throwsArgumentError,
    );
    expect(
      () => RangeTimePoint(period: 'X', low: double.nan, high: 3),
      throwsArgumentError,
    );
    expect(
      () => orderRangeTimePoints([
        RangeTimePoint(period: 'X', low: 1, high: 2),
        RangeTimePoint(period: 'X', low: 2, high: 3),
      ]),
      throwsArgumentError,
    );
  });

  test('OHLC validates bounds and exposes shared body geometry', () {
    expect(educationalOhlc, hasLength(12));
    expect(educationalOhlc.any((p) => p.isBullish), isTrue);
    expect(educationalOhlc.any((p) => p.isBearish), isTrue);
    expect(educationalOhlc.any((p) => (p.open - p.close).abs() < .2), isTrue);
    for (final p in educationalOhlc) {
      expect(p.bodyLow, p.open < p.close ? p.open : p.close);
      expect(p.bodyHigh, p.open > p.close ? p.open : p.close);
      expect(p.low <= p.bodyLow && p.bodyHigh <= p.high, isTrue);
    }
    expect(
      () => OhlcPoint(period: 'X', open: 5, high: 4, low: 1, close: 3),
      throwsArgumentError,
    );
    expect(
      () => OhlcPoint(period: 'X', open: 2, high: 4, low: 3, close: 2),
      throwsArgumentError,
    );
    expect(
      () => OhlcPoint(
        period: 'X',
        open: double.infinity,
        high: 4,
        low: 1,
        close: 3,
      ),
      throwsArgumentError,
    );
    expect(
      () => orderOhlcPoints([educationalOhlc.first, educationalOhlc.first]),
      throwsArgumentError,
    );
    expect(
      ChartDatasetRegistry.forConcept('candlestick')!.rows,
      ChartDatasetRegistry.forConcept('ohlc')!.rows,
    );
  });

  test('waterfall bars carry previous totals and calculate final total', () {
    expect(hotelWaterfall.first.endY, 100);
    var expected = hotelWaterfall.first.endY;
    for (final b in hotelWaterfall.skip(1).take(hotelWaterfall.length - 2)) {
      expect(b.startY, expected);
      expected += b.contribution;
      expect(b.endY, expected);
    }
    expect(hotelWaterfall.last.endY, expected);
    expect(expected, 85);
    final subtotal = transformWaterfall([
      WaterfallStep('Start', 100, WaterfallType.start),
      WaterfallStep('Up', 20, WaterfallType.increase),
      WaterfallStep('Mid', 0, WaterfallType.subtotal),
      WaterfallStep('Down', 15, WaterfallType.decrease),
      WaterfallStep('End', 0, WaterfallType.total),
    ]);
    expect(subtotal[2].endY, 120);
    expect(subtotal[3].startY, 120);
    expect(subtotal.last.endY, 105);
    expect(() => transformWaterfall([]), throwsArgumentError);
    expect(
      () => WaterfallStep('bad', -1, WaterfallType.decrease),
      throwsArgumentError,
    );
    expect(
      () => WaterfallStep('bad', double.nan, WaterfallType.start),
      throwsArgumentError,
    );
  });

  test('Gantt tasks have durations, unique IDs, order and overlaps', () {
    expect(flutterFeatureTasks, hasLength(6));
    expect(flutterFeatureTasks.map((t) => t.id).toSet(), hasLength(6));
    expect(
      flutterFeatureTasks.map((t) => t.start),
      orderedEquals([...flutterFeatureTasks.map((t) => t.start)]..sort()),
    );
    expect(
      flutterFeatureTasks.every(
        (t) => t.duration.inHours > 0 && t.progress >= 0 && t.progress <= 1,
      ),
      isTrue,
    );
    expect(
      flutterFeatureTasks[0].end.isAfter(flutterFeatureTasks[1].start),
      isTrue,
    );
    expect(ganttDate(ganttDay(flutterFeatureTasks.first.start)), '1/10');
    expect(
      () => GanttTask(
        id: 'x',
        label: 'X',
        start: DateTime(2026, 1, 2),
        end: DateTime(2026, 1, 2),
      ),
      throwsArgumentError,
    );
    expect(
      () => GanttTask(
        id: 'x',
        label: 'X',
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 2),
        progress: 1.1,
      ),
      throwsArgumentError,
    );
    expect(
      () => orderGanttTasks([
        flutterFeatureTasks.first,
        flutterFeatureTasks.first,
      ]),
      throwsArgumentError,
    );
  });

  test('registers 20 genuine demos and five catalog datasets', () {
    expect(ChartRenderer.registrations, hasLength(260));
    for (final id in ids) {
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
  });

  test('Graphify uses serializable ECharts geometry without callbacks', () {
    for (final id in ids) {
      final options = financialPlanningOptions(id);
      expect(jsonDecode(jsonEncode(options)), isA<Map<String, dynamic>>());
      expect(jsonEncode(options).contains('renderItem'), isFalse);
      expect(GraphifyView(initialOptions: options).initialOptions, options);
    }
    expect(
      (financialPlanningOptions('candlestick')['series'] as List).first['type'],
      'candlestick',
    );
    expect((financialPlanningOptions('ohlc')['series'] as List), hasLength(36));
    expect(
      (financialPlanningOptions('range-area')['series'] as List)[0]['stack'],
      (financialPlanningOptions('range-area')['series'] as List)[1]['stack'],
    );
    expect(
      (financialPlanningOptions('waterfall')['series'] as List)[0]['stack'],
      (financialPlanningOptions('waterfall')['series'] as List)[1]['stack'],
    );
    expect(
      (financialPlanningOptions('gantt')['series'] as List)[0]['stack'],
      (financialPlanningOptions('gantt')['series'] as List)[1]['stack'],
    );
  });

  for (final width in [320.0, 500.0]) {
    for (final id in ids) {
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
