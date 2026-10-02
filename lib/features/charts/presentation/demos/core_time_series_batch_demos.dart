import 'package:flutter/material.dart';

import '../../domain/chart_concept.dart';
import 'core_time_series_fl_chart.dart';
import 'core_time_series_graphic.dart';
import 'core_time_series_graphify.dart';
import 'core_time_series_syncfusion.dart';
import 'demo_registration.dart';

export 'core_time_series_graphify.dart'
    show graphifyTimeSeriesOptions, encodeGraphifyTimeSeriesOptions;

class CoreTimeSeriesBatchDemos {
  CoreTimeSeriesBatchDemos._();

  static const newConcepts = [
    'multi-line',
    'area',
    'stacked-area',
    'step-line',
  ];
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in newConcepts)
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => CoreTimeSeriesChart(id: id, library: library),
        ),
  ]);
}

class CoreTimeSeriesChart extends StatelessWidget {
  const CoreTimeSeriesChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlTimeSeriesChart(id),
    ChartLibrary.syncfusion => buildSyncfusionTimeSeriesChart(id),
    ChartLibrary.graphic => buildGraphicTimeSeriesChart(id),
    ChartLibrary.graphify => GraphifyTimeSeriesChart(
      options: graphifyTimeSeriesOptions(id),
    ),
  };
}
