import 'package:flutter/material.dart';

import '../../data/networks_diagnostics_spatial_data.dart';
import '../../domain/chart_concept.dart';
import 'demo_registration.dart';
import 'networks_diagnostics_spatial_fl_chart.dart';
import 'networks_diagnostics_spatial_syncfusion.dart';
import 'networks_diagnostics_spatial_graphic.dart';
import 'networks_diagnostics_spatial_graphify.dart';

export 'networks_diagnostics_spatial_graphify.dart'
    show networksDiagnosticsSpatialOptions;

const batch12Ids = [
  'network-graph',
  'qq-plot',
  'parallel-coordinates',
  'contour',
  'calendar-heatmap',
];

class NetworksDiagnosticsSpatialBatchDemos {
  NetworksDiagnosticsSpatialBatchDemos._();
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in batch12Ids)
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => NetworksDiagnosticsSpatialChart(id: id, library: library),
        ),
  ]);
}

class NetworksDiagnosticsSpatialChart extends StatelessWidget {
  const NetworksDiagnosticsSpatialChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlNetworksDiagnosticsSpatial(id),
    ChartLibrary.syncfusion => buildSyncfusionNetworksDiagnosticsSpatial(id),
    ChartLibrary.graphic => buildGraphicNetworksDiagnosticsSpatial(id),
    ChartLibrary.graphify => NetworksDiagnosticsSpatialGraphifyChart(id: id),
  };
}

const weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

Widget calendarFrame(Widget chart) => LayoutBuilder(
  builder: (context, constraints) {
    final width = bookingCalendar.cells.last.week * 17.0 + 75;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width > constraints.maxWidth ? width : constraints.maxWidth,
        child: Column(
          children: [
            SizedBox(
              height: 20,
              child: Stack(
                children: [
                  for (final cell in bookingCalendar.cells.where(
                    (c) => c.day.date.day == 1,
                  ))
                    Positioned(
                      left: 25 + cell.week * 17.0,
                      top: 2,
                      child: Text(
                        monthLabel(cell.week),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: chart),
          ],
        ),
      ),
    );
  },
);

Widget parallelFrame(Widget chart) => LayoutBuilder(
  builder: (context, constraints) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: constraints.maxWidth < 480 ? 480 : constraints.maxWidth,
      child: chart,
    ),
  ),
);

String networkTooltip(NetworkPosition p) {
  final links = touristNetwork
      .connections(p.node.id)
      .map((e) {
        final other = e.sourceId == p.node.id ? e.targetId : e.sourceId;
        return touristNetwork.byId[other]!.node.label;
      })
      .join(', ');
  return '${p.node.label}\n${p.node.group} · peso ${p.node.weight.toStringAsFixed(0)}\nConecta: $links';
}

String monthLabel(int week) {
  final starts = bookingCalendar.cells.where(
    (c) => c.day.date.day == 1 && c.week == week,
  );
  if (starts.isEmpty) return '';
  final date = starts.first.day.date;
  return const [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ][date.month - 1];
}
