import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/performance_process_batch_demos.dart';

void main() {
  test('export Batch 13 options for bundled ECharts SVG SSR', () {
    final output = Directory('.dart_tool/batch13-ssr')
      ..createSync(recursive: true);
    final options = {
      for (final id in batch13Ids) id: performanceProcessOptions(id),
    };
    File('${output.path}/options.json').writeAsStringSync(jsonEncode(options));
    expect(options, hasLength(5));
  });
}
