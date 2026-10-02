import 'package:flutter/material.dart';

import '../../domain/chart_concept.dart';
import 'advanced_distribution_fl_chart.dart';
import 'advanced_distribution_graphic.dart';
import 'advanced_distribution_graphify.dart';
import 'advanced_distribution_syncfusion.dart';
import 'demo_registration.dart';

export 'advanced_distribution_graphify.dart'
    show
        graphifyAdvancedDistributionOptions,
        encodeGraphifyAdvancedDistributionOptions;

class AdvancedDistributionBatchDemos {
  AdvancedDistributionBatchDemos._();
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in const [
      'box-plot',
      'violin',
      'ridgeline',
      'hexbin',
      'heatmap',
    ])
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => AdvancedDistributionChart(id: id, library: library),
        ),
  ]);
}

class AdvancedDistributionChart extends StatelessWidget {
  const AdvancedDistributionChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlAdvancedDistribution(id),
    ChartLibrary.syncfusion => buildSyncfusionAdvancedDistribution(id),
    ChartLibrary.graphic => buildGraphicAdvancedDistribution(id),
    ChartLibrary.graphify => GraphifyAdvancedDistributionChart(
      options: graphifyAdvancedDistributionOptions(id),
    ),
  };
}
