import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphify/graphify.dart';
import 'package:flutlytics_v1/features/charts/data/advanced_distribution_data.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/distribution_basics_data.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/advanced_distribution_batch_demos.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/advanced_distribution_graphify.dart';

void main() {
  const ids = ['box-plot', 'violin', 'ridgeline', 'hexbin', 'heatmap'];

  group('Box Plot statistics', () {
    test('linear interpolated quantiles are order-independent and IQR fences find outliers', () {
      final a = calculateBoxPlotStats([1, 2, 3, 4, 5, 6, 7, 8, 100]);
      final b = calculateBoxPlotStats([100, 4, 1, 8, 3, 7, 2, 6, 5]);
      expect(a.q1, 3);
      expect(a.median, 5);
      expect(a.q3, 7);
      expect(a.iqr, 4);
      expect(a.lowerFence, -3);
      expect(a.upperFence, 13);
      expect(a.minWhisker, 1);
      expect(a.maxWhisker, 8);
      expect(a.outliers, [100]);
      expect(b.q1, a.q1);
      expect(b.median, a.median);
      expect(b.q3, a.q3);
      expect(b.minWhisker, a.minWhisker);
      expect(b.maxWhisker, a.maxWhisker);
      expect(b.outliers, a.outliers);
    });

    test('even, repeated, and singleton samples have defined quartiles', () {
      final even = calculateBoxPlotStats([1, 2, 3, 4]);
      expect([even.q1, even.median, even.q3], [1.75, 2.5, 3.25]);
      final repeated = calculateBoxPlotStats([2, 2, 2, 2]);
      expect(
        [
          repeated.minWhisker,
          repeated.q1,
          repeated.median,
          repeated.q3,
          repeated.maxWhisker,
        ],
        [2, 2, 2, 2, 2],
      );
      expect(repeated.outliers, isEmpty);
      final one = calculateBoxPlotStats([9]);
      expect(
        [one.q1, one.median, one.q3, one.minWhisker, one.maxWhisker],
        [9, 9, 9, 9, 9],
      );
      expect(() => calculateBoxPlotStats([]), throwsArgumentError);
      expect(() => calculateBoxPlotStats([1, double.nan]), throwsArgumentError);
      expect(
        () => calculateBoxPlotStats([double.infinity]),
        throwsArgumentError,
      );
    });
  });

  test('violin reuses Gaussian KDE on a shared X grid and symmetric nonnegative width', () {
    final geometry = buildViolinGeometry(violinGroups, bandwidth: 1.5);
    expect(geometry.length, violinGroups.length * 80);
    for (final group in violinGroups) {
      final points = geometry
          .where((point) => point.group == group.label)
          .toList();
      final kde = buildGaussianKde(
        group.values,
        bandwidth: 1.5,
        gridCount: 80,
        gridMin: geometry.first.value,
        gridMax: geometry[79].value,
      );
      expect(points.map((p) => p.value), kde.map((p) => p.x));
      expect(points.map((p) => p.density), kde.map((p) => p.y));
      expect(
        points.every((p) => p.halfWidth >= 0 && p.halfWidth.isFinite),
        isTrue,
      );
      expect(
        points.map((p) => p.halfWidth).reduce((a, b) => a > b ? a : b),
        closeTo(.38, 1e-12),
      );
      for (final point in points) {
        final left = point.groupIndex - point.halfWidth;
        final right = point.groupIndex + point.halfWidth;
        expect(
          (point.groupIndex - left),
          closeTo(right - point.groupIndex, 1e-12),
        );
      }
    }
  });

  test(
    'ridgeline shares domain and density scale with stable category offsets',
    () {
      final first = buildRidgeline(ridgelineGroups, bandwidth: 2);
      final second = buildRidgeline(ridgelineGroups, bandwidth: 2);
      expect(first.map((r) => r.label), ridgelineGroups.map((g) => g.label));
      for (var i = 0; i < first.length; i++) {
        final row = first[i];
        expect(row.points.map((p) => p.x), first.first.points.map((p) => p.x));
        expect(row.points.map((p) => p.x), second[i].points.map((p) => p.x));
        expect(
          row.points.every((p) => p.density.isFinite && p.height.isFinite),
          isTrue,
        );
        expect(row.points.every((p) => p.baseline == i.toDouble()), isTrue);
        expect(
          row.points.map((p) => p.height).reduce((a, b) => a > b ? a : b),
          lessThanOrEqualTo(.82),
        );
      }
    },
  );

  group('Hexbin aggregation', () {
    List<HexBin> binsFor(double size) => buildHexBins(
      hexbinObservations,
      hexSize: size,
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 2000,
    );
    test('axial hex assignment is deterministic, unique, and conserves observations', () {
      final bins = binsFor(.11);
      final again = binsFor(.11);
      expect(bins.map((b) => b.id).toSet(), hasLength(bins.length));
      expect(
        bins.map((b) => (b.id, b.count, b.centerX, b.centerY)),
        again.map((b) => (b.id, b.count, b.centerX, b.centerY)),
      );
      expect(
        bins.fold<int>(0, (sum, b) => sum + b.count),
        hexbinObservations.length,
      );
      expect(
        bins.every(
          (b) => b.count > 0 && b.centerX.isFinite && b.centerY.isFinite,
        ),
        isTrue,
      );
      expect(bins.length, lessThan(hexbinObservations.length));
    });

    test('invalid hex size and domains are rejected', () {
      expect(() => binsFor(0), throwsArgumentError);
      expect(() => binsFor(double.nan), throwsArgumentError);
    });
  });

  test(
    'heatmap is a complete unique finite matrix with shared intensity range',
    () {
      expect(heatmapMatrix.orderedCells, hasLength(42));
      expect(
        heatmapMatrix.cells.map((c) => '${c.xCategory}/${c.yCategory}').toSet(),
        hasLength(42),
      );
      expect(
        heatmapMatrix.minValue,
        heatmapMatrix.cells.map((c) => c.value).reduce((a, b) => a < b ? a : b),
      );
      expect(
        heatmapMatrix.maxValue,
        heatmapMatrix.cells.map((c) => c.value).reduce((a, b) => a > b ? a : b),
      );
      expect(
        () => HeatmapMatrix(
          xCategories: ['A'],
          yCategories: ['B'],
          cells: [
            const HeatmapCell(xCategory: 'A', yCategory: 'B', value: 1),
            const HeatmapCell(xCategory: 'A', yCategory: 'B', value: 2),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => HeatmapMatrix(
          xCategories: ['A', 'B'],
          yCategories: ['B'],
          cells: [const HeatmapCell(xCategory: 'A', yCategory: 'B', value: 1)],
        ),
        throwsArgumentError,
      );
      expect(
        () => HeatmapMatrix(
          xCategories: ['A'],
          yCategories: ['B'],
          cells: [
            HeatmapCell(xCategory: 'A', yCategory: 'B', value: double.infinity),
          ],
        ),
        throwsArgumentError,
      );
    },
  );

  test('Batch 8 contributes 20 unique real demos and five datasets', () {
    final registrations = ChartRenderer.registrations
        .where((r) => ids.contains(r.conceptId))
        .toList();
    expect(registrations, hasLength(20));
    expect(ChartRenderer.registrations, hasLength(260));
    expect(
      registrations.map((r) => (r.conceptId, r.library)).toSet(),
      hasLength(20),
    );
    for (final id in ids) {
      expect(ChartCatalog.concepts.any((c) => c.id == id), isTrue);
      expect(ChartDatasetRegistry.forConcept(id), isNotNull);
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

  test('Graphify options encode concept-specific serializable series', () {
    const expected = {
      'box-plot': 'boxplot',
      'violin': 'line',
      'ridgeline': 'line',
      'hexbin': 'scatter',
      'heatmap': 'heatmap',
    };
    for (final id in ids) {
      final options = graphifyAdvancedDistributionOptions(id);
      final decoded = jsonDecode(jsonEncode(options)) as Map<String, dynamic>;
      expect((decoded['series'] as List).first['type'], expected[id]);
      expect(GraphifyView(initialOptions: options).initialOptions, options);
    }
    expect(
      (graphifyAdvancedDistributionOptions('hexbin')['series'] as List)
          .single['data'],
      hasLength(greaterThan(10)),
    );
    expect(
      (graphifyAdvancedDistributionOptions('heatmap')['series'] as List)
          .single['data'],
      hasLength(42),
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
                  key: const Key('distribution-size'),
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
          final exception = tester.takeException();
          if (exception != null) {
            // Print renderer-side stack while diagnosing library API failures.
            debugPrint(
              '$exception ${exception is Error ? exception.stackTrace : ''}',
            );
          }
          expect(exception, isNull);
          expect(
            tester.getSize(find.byKey(const Key('distribution-size'))).width,
            width,
          );
        });
      }
    }
  }

  testWidgets('Graphify demo builders produce GraphifyView widgets', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    for (final id in ids) {
      final demo = ChartRenderer.buildChart(
        concept: ChartCatalog.byId(id),
        library: ChartLibrary.graphify,
      ) as AdvancedDistributionChart;
      final graphify = demo.build(context) as GraphifyAdvancedDistributionChart;
      expect(
        graphify.buildGraphifyView(GraphifyController()),
        isA<GraphifyView>(),
      );
    }
  });
}
