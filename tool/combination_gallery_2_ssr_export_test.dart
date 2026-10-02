import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/features/charts/data/chart_combinations.dart';
import 'package:flutlytics_v1/features/charts/presentation/combination_renderer.dart';

void main() {
  test('exports all twenty Graphify options for bundled ECharts SVG SSR', () {
    final ids = ChartCombinations.all.keys.toList();
    expect(ids, hasLength(20));
    final output = Directory('.dart_tool/combination-gallery-2-ssr')
      ..createSync(recursive: true);
    final options = {for (final id in ids) id: graphifyCombinationOptions(id)};
    File('${output.path}/options.json').writeAsStringSync(jsonEncode(options));
  });
}
