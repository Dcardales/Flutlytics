import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/features/charts/presentation/demos/networks_diagnostics_spatial_batch_demos.dart';

void main() {
  test('export Batch 12 options for bundled ECharts SVG SSR', () {
    final output = Directory('.dart_tool/batch12-ssr')
      ..createSync(recursive: true);
    final options = {
      for (final id in batch12Ids) id: networksDiagnosticsSpatialOptions(id),
    };
    File('${output.path}/options.json').writeAsStringSync(jsonEncode(options));
    expect(options, hasLength(5));
  });
}
