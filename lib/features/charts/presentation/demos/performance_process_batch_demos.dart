import 'package:flutter/material.dart';

import '../../data/performance_process_data.dart';
import '../../domain/chart_concept.dart';
import 'demo_registration.dart';
import 'performance_process_fl_chart.dart';
import 'performance_process_syncfusion.dart';
import 'performance_process_graphic.dart';
import 'performance_process_graphify.dart';

export 'performance_process_graphify.dart' show performanceProcessOptions;

const batch13Ids = ['funnel', 'pyramid', 'gauge', 'bullet', 'timeline'];
const funnelShortLabels = [
  'Visitas',
  'Búsquedas',
  'Selección',
  'Inicio',
  'Confirmadas',
];

class PerformanceProcessBatchDemos {
  PerformanceProcessBatchDemos._();
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in batch13Ids)
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => PerformanceProcessChart(id: id, library: library),
        ),
  ]);
}

class PerformanceProcessChart extends StatelessWidget {
  const PerformanceProcessChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;
  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlPerformanceProcess(id),
    ChartLibrary.syncfusion => buildSyncfusionPerformanceProcess(id),
    ChartLibrary.graphic => buildGraphicPerformanceProcess(id),
    ChartLibrary.graphify => PerformanceProcessGraphifyChart(id: id),
  };
}

String formatConversion(double? ratio) =>
    ratio == null ? 'no calculable' : '${(100 * ratio).toStringAsFixed(1)}%';

String funnelTip(FunnelStep step) =>
    '${step.stage.label}\n'
    '${step.stage.value.toStringAsFixed(0)} personas\n'
    'De anterior: ${formatConversion(step.conversionFromPrevious)}\n'
    'Desde inicio: ${formatConversion(step.conversionFromStart)}';

String pyramidTip(PopulationPyramidRow row) =>
    '${row.category}\n'
    'Nacionales: ${row.leftValue.toStringAsFixed(0)}\n'
    'Internacionales: ${row.rightValue.toStringAsFixed(0)}';

String gaugeTip() =>
    '${hotelOccupancyGauge.label}\n'
    'Actual: ${hotelOccupancyGauge.value.toStringAsFixed(0)}%\n'
    'Meta: ${hotelOccupancyGauge.target!.toStringAsFixed(0)}%\n'
    'Escala: ${hotelOccupancyGauge.min.toStringAsFixed(0)}–${hotelOccupancyGauge.max.toStringAsFixed(0)}%';

String bulletTip() =>
    '${monthlyRevenueBullet.label}\n'
    'Actual: ${monthlyRevenueBullet.value.toStringAsFixed(0)} M COP\n'
    'Meta: ${monthlyRevenueBullet.target.toStringAsFixed(0)} M COP\n'
    'Rango: ${monthlyRevenueBullet.currentBand?.label ?? 'fuera de bandas'}';

String timelineTip(TimelinePoint point) =>
    '${isoDate(point.event.date)} · ${point.event.title}\n'
    '${point.event.description}';

Widget timelineFrame(Widget chart) => LayoutBuilder(
  builder: (context, constraints) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: constraints.maxWidth < 720 ? 720 : constraints.maxWidth,
      child: chart,
    ),
  ),
);

Widget gaugeCaption() => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '${hotelOccupancyGauge.value.toStringAsFixed(0)}% actual · meta ${hotelOccupancyGauge.target!.toStringAsFixed(0)}%',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      const Text(
        'Escala 0–100% · bajo <60 · objetivo 60–85 · alto >85',
        style: TextStyle(fontSize: 10),
      ),
    ],
  ),
);
