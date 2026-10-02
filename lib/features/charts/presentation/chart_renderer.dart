import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as graphic;
import 'package:graphify/graphify.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../data/sample_datasets.dart';
import '../domain/chart_concept.dart';
import 'demos/bar_batch_demos.dart';
import 'demos/comparison_marks_batch_demos.dart';
import 'demos/composite_compact_batch_demos.dart';
import 'demos/core_time_series_batch_demos.dart';
import 'demos/transformed_time_series_batch_demos.dart';
import 'demos/radial_composition_batch_demos.dart';
import 'demos/distribution_basics_batch_demos.dart';
import 'demos/advanced_distribution_batch_demos.dart';
import 'demos/relationships_intervals_batch_demos.dart';
import 'demos/financial_planning_batch_demos.dart';
import 'demos/analytical_structures_batch_demos.dart';
import 'demos/networks_diagnostics_spatial_batch_demos.dart';
import 'demos/performance_process_batch_demos.dart';
import 'demos/demo_registration.dart';

class ChartRenderer {
  static final List<ChartDemoRegistration> registrations = List.unmodifiable([
    ChartDemoRegistration(
      'line',
      ChartLibrary.flChart,
      () => const _FlDemo(isLine: true),
    ),
    ChartDemoRegistration(
      'bar',
      ChartLibrary.flChart,
      () => const _FlDemo(isLine: false),
    ),
    ChartDemoRegistration(
      'line',
      ChartLibrary.syncfusion,
      () => const _SyncfusionDemo(isLine: true),
    ),
    ChartDemoRegistration(
      'bar',
      ChartLibrary.syncfusion,
      () => const _SyncfusionDemo(isLine: false),
    ),
    ChartDemoRegistration(
      'line',
      ChartLibrary.graphic,
      () => const _GraphicDemo(isLine: true),
    ),
    ChartDemoRegistration(
      'bar',
      ChartLibrary.graphic,
      () => const _GraphicDemo(isLine: false),
    ),
    ChartDemoRegistration(
      'line',
      ChartLibrary.graphify,
      () => const _GraphifyDemo(isLine: true),
    ),
    ChartDemoRegistration(
      'bar',
      ChartLibrary.graphify,
      () => const _GraphifyDemo(isLine: false),
    ),
    ...BarBatchDemos.registrations,
    ...ComparisonMarksBatchDemos.registrations,
    ...CoreTimeSeriesBatchDemos.registrations,
    ...TransformedTimeSeriesBatchDemos.registrations,
    ...CompositeCompactBatchDemos.registrations,
    ...RadialCompositionBatchDemos.registrations,
    ...DistributionBasicsBatchDemos.registrations,
    ...AdvancedDistributionBatchDemos.registrations,
    ...RelationshipsIntervalsBatchDemos.registrations,
    ...FinancialPlanningBatchDemos.registrations,
    ...AnalyticalStructuresBatchDemos.registrations,
    ...NetworksDiagnosticsSpatialBatchDemos.registrations,
    ...PerformanceProcessBatchDemos.registrations,
  ]);

  static int registrationCount(String conceptId, ChartLibrary library) =>
      registrations
          .where((r) => r.conceptId == conceptId && r.library == library)
          .length;

  static final Map<(String, ChartLibrary), DemoBuilder> _builders = {
    for (final registration in registrations)
      (registration.conceptId, registration.library): registration.builder,
  };

  static bool hasDemo(String conceptId, ChartLibrary library) =>
      _builders.containsKey((conceptId, library));

  static Widget buildChart({
    required ChartConcept concept,
    required ChartLibrary library,
  }) {
    final builder = _builders[(concept.id, library)];
    if (builder == null) {
      return const Center(child: Text('Demo pendiente para esta combinación.'));
    }
    return builder();
  }
}

class _FlDemo extends StatelessWidget {
  const _FlDemo({required this.isLine});
  final bool isLine;

  @override
  Widget build(BuildContext context) {
    final points = ChartDatasetRegistry.pointsFor(isLine ? 'line' : 'bar');
    if (isLine) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
        child: fl.LineChart(
          fl.LineChartData(
            minY: 0,
            maxY: 60,
            lineBarsData: [
              fl.LineChartBarData(
                spots: [
                  for (var i = 0; i < points.length; i++)
                    fl.FlSpot(i.toDouble(), points[i].value),
                ],
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isCurved: false,
                dotData: const fl.FlDotData(show: true),
              ),
            ],
            titlesData: _flTitles(points),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: fl.BarChart(
        fl.BarChartData(
          minY: 0,
          maxY: 60,
          barGroups: [
            for (var i = 0; i < points.length; i++)
              fl.BarChartGroupData(
                x: i,
                barRods: [
                  fl.BarChartRodData(
                    toY: points[i].value,
                    color: Theme.of(context).colorScheme.primary,
                    width: 22,
                  ),
                ],
              ),
          ],
          titlesData: _flTitles(points),
        ),
      ),
    );
  }

  fl.FlTitlesData _flTitles(List<ChartPoint> points) => fl.FlTitlesData(
    topTitles: const fl.AxisTitles(
      sideTitles: fl.SideTitles(showTitles: false),
    ),
    rightTitles: const fl.AxisTitles(
      sideTitles: fl.SideTitles(showTitles: false),
    ),
    bottomTitles: fl.AxisTitles(
      sideTitles: fl.SideTitles(
        showTitles: true,
        reservedSize: 34,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          return index >= 0 && index < points.length && value == index
              ? Text(points[index].label, style: const TextStyle(fontSize: 10))
              : const SizedBox.shrink();
        },
      ),
    ),
  );
}

class _SyncfusionDemo extends StatelessWidget {
  const _SyncfusionDemo({required this.isLine});
  final bool isLine;

  @override
  Widget build(BuildContext context) {
    final points = ChartDatasetRegistry.pointsFor(isLine ? 'line' : 'bar');
    return sf.SfCartesianChart(
      primaryXAxis: const sf.CategoryAxis(),
      primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 60),
      tooltipBehavior: sf.TooltipBehavior(enable: true),
      series: isLine
          ? <sf.CartesianSeries<ChartPoint, String>>[
              sf.LineSeries<ChartPoint, String>(
                dataSource: points,
                animationDuration: 0,
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => p.value,
                markerSettings: const sf.MarkerSettings(isVisible: true),
              ),
            ]
          : <sf.CartesianSeries<ChartPoint, String>>[
              sf.ColumnSeries<ChartPoint, String>(
                dataSource: points,
                animationDuration: 0,
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => p.value,
              ),
            ],
    );
  }
}

class _GraphicDemo extends StatelessWidget {
  const _GraphicDemo({required this.isLine});
  final bool isLine;

  @override
  Widget build(BuildContext context) {
    final points = ChartDatasetRegistry.pointsFor(isLine ? 'line' : 'bar');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: graphic.Chart(
        data: points,
        variables: {
          'label': graphic.Variable(accessor: (ChartPoint p) => p.label),
          'value': graphic.Variable(accessor: (ChartPoint p) => p.value),
        },
        marks: isLine
            ? [graphic.LineMark(), graphic.PointMark()]
            : [graphic.IntervalMark()],
        axes: [graphic.Defaults.horizontalAxis, graphic.Defaults.verticalAxis],
        selections: {
          'point': graphic.PointSelection(
            on: {graphic.GestureType.hover, graphic.GestureType.tap},
            dim: graphic.Dim.x,
          ),
        },
        tooltip: graphic.TooltipGuide(variables: ['label', 'value']),
      ),
    );
  }
}

class _GraphifyDemo extends StatefulWidget {
  const _GraphifyDemo({required this.isLine});
  final bool isLine;

  @override
  State<_GraphifyDemo> createState() => _GraphifyDemoState();
}

class _GraphifyDemoState extends State<_GraphifyDemo> {
  final controller = GraphifyController();

  @override
  Widget build(BuildContext context) {
    final points = ChartDatasetRegistry.pointsFor(
      widget.isLine ? 'line' : 'bar',
    );
    return GraphifyView(
      controller: controller,
      onConsoleMessage: (message) => debugPrint('Graphify WebView: $message'),
      initialOptions: {
        'tooltip': {'trigger': 'axis'},
        'xAxis': {
          'type': 'category',
          'data': [for (final p in points) p.label],
        },
        'yAxis': {'type': 'value'},
        'series': [
          {
            'type': widget.isLine ? 'line' : 'bar',
            'data': [for (final p in points) p.value],
          },
        ],
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
