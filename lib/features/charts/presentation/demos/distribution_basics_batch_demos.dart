import 'package:flutter/material.dart';

import '../../domain/chart_concept.dart';
import 'demo_registration.dart';
import 'distribution_basics_fl_chart.dart';
import 'distribution_basics_graphic.dart';
import 'distribution_basics_graphify.dart';
import 'distribution_basics_syncfusion.dart';

export 'distribution_basics_graphify.dart'
    show graphifyDistributionOptions, encodeGraphifyDistributionOptions;

class DistributionBasicsBatchDemos {
  DistributionBasicsBatchDemos._();
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in const [
      'histogram',
      'frequency-polygon',
      'ogive',
      'strip-plot',
      'density',
    ])
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => DistributionBasicsChart(id: id, library: library),
        ),
  ]);
}

class DistributionBasicsChart extends StatelessWidget {
  const DistributionBasicsChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlDistributionChart(id),
    ChartLibrary.syncfusion => buildSyncfusionDistributionChart(id),
    ChartLibrary.graphic => buildGraphicDistributionChart(id),
    ChartLibrary.graphify => GraphifyDistributionChart(
      options: graphifyDistributionOptions(id),
    ),
  };
}
