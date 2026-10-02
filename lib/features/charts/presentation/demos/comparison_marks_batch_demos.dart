import 'package:flutter/material.dart';

import '../../domain/chart_concept.dart';
import 'demo_registration.dart';
import 'comparison_marks_fl_chart.dart';
import 'comparison_marks_syncfusion.dart';
import 'comparison_marks_graphic.dart';
import 'comparison_marks_graphify.dart';

export 'comparison_marks_graphify.dart'
    show graphifyComparisonOptions, encodeGraphifyComparisonOptions;

class ComparisonMarksBatchDemos {
  ComparisonMarksBatchDemos._();
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in const [
      'dot-plot',
      'lollipop',
      'dumbbell',
      'slope',
      'pareto',
    ])
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => ComparisonMarksChart(id: id, library: library),
        ),
  ]);
}

class ComparisonMarksChart extends StatelessWidget {
  const ComparisonMarksChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;
  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlComparisonChart(id),
    ChartLibrary.syncfusion => buildSyncfusionComparisonChart(id),
    ChartLibrary.graphic => buildGraphicComparisonChart(id),
    ChartLibrary.graphify => GraphifyComparisonChart(
      options: graphifyComparisonOptions(id),
    ),
  };
}
