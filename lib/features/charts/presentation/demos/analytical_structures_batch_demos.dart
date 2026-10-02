import 'package:flutter/material.dart';

import '../../data/analytical_structures_data.dart';
import '../../domain/chart_concept.dart';
import 'analytical_structures_fl_chart.dart';
import 'analytical_structures_syncfusion.dart';
import 'analytical_structures_graphic.dart';
import 'analytical_structures_graphify.dart';
import 'demo_registration.dart';

export 'analytical_structures_graphify.dart' show analyticalStructuresOptions;

class AnalyticalStructuresBatchDemos {
  AnalyticalStructuresBatchDemos._();
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in const [
      'diverging-stacked-bar',
      'scatterplot-matrix',
      'ternary-plot',
      'fan-chart',
      'calibration-plot',
    ])
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => AnalyticalStructuresChart(id: id, library: library),
        ),
  ]);
}

class AnalyticalStructuresChart extends StatelessWidget {
  const AnalyticalStructuresChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) => switch (library) {
    ChartLibrary.flChart => buildFlAnalyticalStructures(id),
    ChartLibrary.syncfusion => buildSyncfusionAnalyticalStructures(id),
    ChartLibrary.graphic => buildGraphicAnalyticalStructures(id),
    ChartLibrary.graphify => AnalyticalStructuresGraphifyChart(id: id),
  };
}

Widget matrixGrid(Widget Function(MatrixCell) buildCell) => LayoutBuilder(
  builder: (context, constraints) {
    final cell = constraints.maxWidth >= 480 ? 122.0 : 160.0;
    final n = touristMatrix.variables.length;
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: n * cell,
          child: Column(
            children: [
              for (var row = 0; row < n; row++)
                SizedBox(
                  height: cell,
                  child: Row(
                    children: [
                      for (var col = 0; col < n; col++)
                        SizedBox(
                          width: cell,
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: touristMatrix.cells[row * n + col].isDiagonal
                                ? matrixDiagonal(
                                    touristMatrix.cells[row * n + col],
                                  )
                                : buildCell(touristMatrix.cells[row * n + col]),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  },
);

Widget matrixDiagonal(MatrixCell cell) {
  final range = touristMatrix.scales[cell.x.id]!;
  return DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xffe3f2fd),
      border: Border.all(color: const Color(0xff90caf9)),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cell.x.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            '${range.min.toStringAsFixed(1)}–${range.max.toStringAsFixed(1)} ${cell.x.unit}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    ),
  );
}
