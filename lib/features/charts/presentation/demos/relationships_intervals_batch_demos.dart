import 'package:flutter/material.dart';

import '../../domain/chart_concept.dart';
import 'relationships_intervals_fl_chart.dart';
import 'relationships_intervals_graphic.dart';
import 'relationships_intervals_graphify.dart';
import 'relationships_intervals_syncfusion.dart';
import 'demo_registration.dart';

export 'relationships_intervals_graphify.dart'
    show relationshipsIntervalsOptions, encodeRelationshipsIntervalsOptions;

class RelationshipsIntervalsBatchDemos {
  RelationshipsIntervalsBatchDemos._();
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in const [
      'scatter',
      'bubble',
      'connected-scatter',
      'error-bar',
      'range-column',
    ])
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => RelationshipsIntervalsChart(id: id, library: library),
        ),
  ]);
}

class RelationshipsIntervalsChart extends StatelessWidget {
  const RelationshipsIntervalsChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlRelationshipsIntervals(id),
    ChartLibrary.syncfusion => buildSyncfusionRelationshipsIntervals(id),
    ChartLibrary.graphic => buildGraphicRelationshipsIntervals(id),
    ChartLibrary.graphify => RelationshipsIntervalsGraphifyChart(
      options: relationshipsIntervalsOptions(id),
    ),
  };
}
