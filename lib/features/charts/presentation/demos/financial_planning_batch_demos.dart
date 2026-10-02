import 'package:flutter/material.dart';

import '../../domain/chart_concept.dart';
import 'demo_registration.dart';
import 'financial_planning_fl_chart.dart';
import 'financial_planning_syncfusion.dart';
import 'financial_planning_graphic.dart';
import 'financial_planning_graphify.dart';

export 'financial_planning_graphify.dart' show financialPlanningOptions;

class FinancialPlanningBatchDemos {
  FinancialPlanningBatchDemos._();
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in const [
      'range-area',
      'candlestick',
      'ohlc',
      'waterfall',
      'gantt',
    ])
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => FinancialPlanningChart(id: id, library: library),
        ),
  ]);
}

class FinancialPlanningChart extends StatelessWidget {
  const FinancialPlanningChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlFinancialPlanning(id),
    ChartLibrary.syncfusion => buildSyncfusionFinancialPlanning(id),
    ChartLibrary.graphic => buildGraphicFinancialPlanning(id),
    ChartLibrary.graphify => FinancialPlanningGraphifyChart(
      options: financialPlanningOptions(id),
    ),
  };
}
