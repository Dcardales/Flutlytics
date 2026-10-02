import 'package:flutter/widgets.dart';

import '../../domain/chart_concept.dart';

typedef DemoBuilder = Widget Function();

class ChartDemoRegistration {
  const ChartDemoRegistration(this.conceptId, this.library, this.builder);

  final String conceptId;
  final ChartLibrary library;
  final DemoBuilder builder;
}
