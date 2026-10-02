import 'package:flutter/material.dart';

import '../../domain/chart_concept.dart';
import 'demo_registration.dart';
import 'transformed_time_series_fl_chart.dart';
import 'transformed_time_series_graphic.dart';
import 'transformed_time_series_graphify.dart';
import 'transformed_time_series_syncfusion.dart';

export 'transformed_time_series_graphify.dart'
    show graphifyAnalyticalOptions, encodeGraphifyAnalyticalOptions;

class TransformedTimeSeriesBatchDemos {
  TransformedTimeSeriesBatchDemos._();

  static const newConcepts = [
    'cumulative-line',
    'indexed-line',
    'normalized-stacked-area',
    'streamgraph',
    'control-chart',
  ];

  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in newConcepts)
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => TransformedTimeSeriesChart(id: id, library: library),
        ),
  ]);
}

class TransformedTimeSeriesChart extends StatelessWidget {
  const TransformedTimeSeriesChart({
    super.key,
    required this.id,
    required this.library,
  });

  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlAnalyticalChart(id),
    ChartLibrary.syncfusion => buildSyncfusionAnalyticalChart(id),
    ChartLibrary.graphic => buildGraphicAnalyticalChart(id),
    ChartLibrary.graphify => GraphifyAnalyticalChart(
      id: id,
      options: graphifyAnalyticalOptions(id),
    ),
  };
}
