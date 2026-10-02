import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/analytical_structures_data.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/analytical_structures_batch_demos.dart';

void main() {
  const ids = [
    'diverging-stacked-bar',
    'scatterplot-matrix',
    'ternary-plot',
    'fan-chart',
    'calibration-plot',
  ];

  test('Likert normalizes counts and splits neutral around zero', () {
    expect(touristLikert, hasLength(5));
    for (final row in touristLikert) {
      final parts = divergingLikert(row);
      expect(parts, hasLength(6));
      expect(
        parts.map((s) => s.percentage).reduce((a, b) => a + b),
        closeTo(100, 1e-10),
      );
      expect(
        parts
                .where((s) => s.side == 'left')
                .map((s) => s.percentage)
                .reduce((a, b) => a + b) +
            parts
                .where((s) => s.side == 'right')
                .map((s) => s.percentage)
                .reduce((a, b) => a + b),
        closeTo(100, 1e-10),
      );
      expect(parts[0].percentage, closeTo(parts[3].percentage, 1e-12));
      expect(parts[0].start, 0);
      expect(parts[3].start, 0);
      expect(parts.take(3).every((s) => s.end <= s.start), isTrue);
      expect(parts.skip(3).every((s) => s.end >= s.start), isTrue);
    }
    final normalized = divergingLikert(
      LikertRow(
        label: 'Escala',
        stronglyNegative: 1,
        negative: 1,
        neutral: 2,
        positive: 3,
        stronglyPositive: 3,
      ),
    );
    expect(normalized[0].percentage, 10);
    expect(normalized[3].percentage, 10);
    expect(normalized.last.percentage, 30);
    expect(
      () => LikertRow(
        label: 'X',
        stronglyNegative: -1,
        negative: 0,
        neutral: 1,
        positive: 0,
        stronglyPositive: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => LikertRow(
        label: 'X',
        stronglyNegative: 0,
        negative: 0,
        neutral: 0,
        positive: 0,
        stronglyPositive: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => LikertRow(
        label: 'X',
        stronglyNegative: double.nan,
        negative: 0,
        neutral: 0,
        positive: 0,
        stronglyPositive: 0,
      ),
      throwsArgumentError,
    );
  });

  test('matrix has all 16 pairs, four global variable scales and real observations', () {
    expect(touristMatrix.variables, hasLength(4));
    expect(touristMatrix.observations, hasLength(24));
    expect(touristMatrix.cells, hasLength(16));
    expect(touristMatrix.cells.where((c) => c.isDiagonal), hasLength(4));
    expect(touristMatrix.cells.where((c) => !c.isDiagonal), hasLength(12));
    for (final cell in touristMatrix.cells) {
      expect(touristMatrix.scales[cell.x.id], isNotNull);
      expect(touristMatrix.scales[cell.y.id], isNotNull);
      final inverse = touristMatrix.cells.singleWhere(
        (c) => c.row == cell.column && c.column == cell.row,
      );
      expect(inverse.x.id, cell.y.id);
      expect(inverse.y.id, cell.x.id);
    }
    expect(
      () => ScatterplotMatrixData(touristMatrix.variables, [
        MultivariateObservation('bad', {'visitors': 1}),
      ]),
      throwsArgumentError,
    );
    expect(
      () => MultivariateObservation('bad', {'x': double.infinity}),
      throwsArgumentError,
    );
  });

  test(
    'ternary barycentric coordinates conserve 100 percent and hit vertices',
    () {
      final a = TernaryPoint('A', 100, 0, 0);
      final b = TernaryPoint('B', 0, 100, 0);
      final c = TernaryPoint('C', 0, 0, 100);
      expect((a.x, a.y), (.5, ternaryHeight));
      expect((b.x, b.y), (0, 0));
      expect((c.x, c.y), (1, 0));
      final center = TernaryPoint('center', 33.33, 33.33, 33.34);
      expect(center.x, closeTo(.5, .001));
      expect(center.y, closeTo(ternaryHeight / 3, .001));
      expect(touristBudgetMix, hasLength(12));
      expect(
        touristBudgetMix.every(
          (p) => p.x >= 0 && p.x <= 1 && p.y >= 0 && p.y <= ternaryHeight,
        ),
        isTrue,
      );
      expect(() => TernaryPoint('bad', -1, 50, 51), throwsArgumentError);
      expect(() => TernaryPoint('bad', 20, 30, 40), throwsArgumentError);
    },
  );

  test('fan has ordered periods, nested bands and widening uncertainty', () {
    expect(hotelForecastFan, hasLength(12));
    expect(
      hotelForecastFan.map((p) => p.period),
      orderedEquals([...hotelForecastFan.map((p) => p.period)]..sort()),
    );
    for (final p in hotelForecastFan) {
      expect(
        p.lower95 <= p.lower80 &&
            p.lower80 <= p.lower50 &&
            p.lower50 <= p.median,
        isTrue,
      );
      expect(
        p.median <= p.upper50 &&
            p.upper50 <= p.upper80 &&
            p.upper80 <= p.upper95,
        isTrue,
      );
      expect(p.span50 <= p.span80 && p.span80 <= p.span95, isTrue);
    }
    expect(
      hotelForecastFan.last.span95,
      greaterThan(hotelForecastFan.first.span95),
    );
    expect(
      () => ForecastPoint(
        period: 'bad',
        median: 50,
        lower50: 40,
        upper50: 60,
        lower80: 35,
        upper80: 65,
        lower95: 38,
        upper95: 70,
      ),
      throwsArgumentError,
    );
    expect(
      () =>
          orderForecastPoints([hotelForecastFan.first, hotelForecastFan.first]),
      throwsArgumentError,
    );
  });

  test(
    'calibration bins preserve counts, means, rates and probability 1.0',
    () {
      expect(cancellationPredictions, hasLength(100));
      expect(cancellationCalibration, hasLength(5));
      expect(
        cancellationCalibration.map((b) => b.count).reduce((a, b) => a + b),
        100,
      );
      expect(cancellationCalibration.last.upper, 1);
      final sample = buildCalibrationBins([
        PredictionObservation(0, 0),
        PredictionObservation(.1, 1),
        PredictionObservation(.2, 1),
        PredictionObservation(1, 1),
      ]);
      expect(sample.first.count, 2);
      expect(sample.first.avgPredicted, closeTo(.05, 1e-12));
      expect(sample.first.observedRate, .5);
      expect(sample[1].count, 1);
      expect(sample.last.index, 4);
      expect(sample.last.count, 1);
      expect(() => PredictionObservation(1.1, 0), throwsArgumentError);
      expect(() => PredictionObservation(.2, 2), throwsArgumentError);
      expect(() => buildCalibrationBins([]), throwsArgumentError);
    },
  );

  test('Batch 11 registers exactly 20 demos and five datasets', () {
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

  test('Graphify options preserve all five analytical structures in JSON', () {
    for (final id in ids) {
      final options = analyticalStructuresOptions(id);
      final encoded = jsonEncode(options);
      expect(jsonDecode(encoded), isA<Map<String, dynamic>>());
      expect(encoded.contains('renderItem'), isFalse);
      expect(GraphifyView(initialOptions: options).initialOptions, options);
    }
    final matrix = analyticalStructuresOptions('scatterplot-matrix');
    expect(matrix['grid'], hasLength(16));
    expect(matrix['xAxis'], hasLength(16));
    expect(matrix['yAxis'], hasLength(16));
    expect(matrix['series'], hasLength(12));
    final diverging =
        analyticalStructuresOptions('diverging-stacked-bar')['series'] as List;
    expect(diverging, hasLength(6));
    expect(diverging.take(3).every((s) => s['stack'] == 'left'), isTrue);
    expect(diverging.skip(3).every((s) => s['stack'] == 'right'), isTrue);
    expect(
      (diverging.first['data'] as List).every((d) => (d['value'] as num) <= 0),
      isTrue,
    );
    expect(
      (diverging.last['data'] as List).every((d) => (d['value'] as num) >= 0),
      isTrue,
    );
    expect(
      (analyticalStructuresOptions('fan-chart')['series'] as List),
      hasLength(7),
    );
    expect(
      (analyticalStructuresOptions('ternary-plot')['series'] as List).map(
        (s) => s['type'],
      ),
      ['line', 'scatter'],
    );
    expect(
      (analyticalStructuresOptions('calibration-plot')['series'] as List).map(
        (s) => s['type'],
      ),
      ['line', 'scatter'],
    );
    expect(
      (analyticalStructuresOptions('calibration-plot')['series'] as List)
          .first['data'],
      [
        [0, 0],
        [1, 1],
      ],
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
