import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/features/charts/presentation/combination_renderer.dart';

void main() {
  test('exports the five Gallery 3A Graphify options for ECharts SSR', () {
    const ids = [
      'control-distribution',
      'waterfall-cumulative',
      'funnel-conversion',
      'error-strip',
      'contour-observations',
    ];
    final options = {for (final id in ids) id: graphifyCombinationOptions(id)};
    expect(options, hasLength(5));
    expect(jsonDecode(jsonEncode(options)), isA<Map>());
    final output = Directory('.dart_tool/combination-gallery-3a-ssr')
      ..createSync(recursive: true);
    File('${output.path}/options.json').writeAsStringSync(jsonEncode(options));
  });
}
