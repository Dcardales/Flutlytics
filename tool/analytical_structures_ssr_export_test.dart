import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/analytical_structures_batch_demos.dart';

void main() {
  test('export Batch 11 options for bundled ECharts SVG SSR', () {
    const ids = [
      'diverging-stacked-bar',
      'scatterplot-matrix',
      'ternary-plot',
      'fan-chart',
      'calibration-plot',
    ];
    final output = Directory('.dart_tool/batch11-ssr')
      ..createSync(recursive: true);
    final options = {for (final id in ids) id: analyticalStructuresOptions(id)};
    File('${output.path}/options.json').writeAsStringSync(jsonEncode(options));
    expect(options, hasLength(5));
  });
}
