import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/financial_planning_batch_demos.dart';

void main() {
  test('export Batch 10 options for bundled ECharts SVG SSR', () {
    const ids = ['range-area', 'candlestick', 'ohlc', 'waterfall', 'gantt'];
    final output = Directory('.dart_tool/batch10-ssr')
      ..createSync(recursive: true);
    final options = {for (final id in ids) id: financialPlanningOptions(id)};
    File('${output.path}/options.json').writeAsStringSync(jsonEncode(options));
    expect(options, hasLength(5));
  });
}
