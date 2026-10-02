import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/advanced_distribution_data.dart';

Widget buildSyncfusionAdvancedDistribution(String id) => switch (id) {
  'box-plot' => _boxPlot(),
  'violin' => _violin(),
  'ridgeline' => _ridgeline(),
  'hexbin' => _hexbin(),
  _ => _heatmap(),
};

Widget _boxPlot() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(title: sf.AxisTitle(text: 'Sucursal')),
  primaryYAxis: const sf.NumericAxis(title: sf.AxisTitle(text: 'Minutos')),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder:
        (
          dynamic data,
          dynamic point,
          dynamic series,
          int pointIndex,
          int seriesIndex,
        ) {
          final group = data as DistributionGroup;
          final s = calculateBoxPlotStats(group.values);
          return _tip(
            '${group.label}\nQ1 ${s.q1.toStringAsFixed(1)} · Mediana ${s.median.toStringAsFixed(1)} · Q3 ${s.q3.toStringAsFixed(1)}\nWhiskers ${s.minWhisker.toStringAsFixed(1)}–${s.maxWhisker.toStringAsFixed(1)} · Outliers ${s.outliers.length}',
          );
        },
  ),
  series: <sf.CartesianSeries<DistributionGroup, String>>[
    sf.BoxAndWhiskerSeries<DistributionGroup, String>(
      dataSource: boxPlotGroups,
      animationDuration: 0,
      boxPlotMode: sf.BoxPlotMode.inclusive,
      showMean: false,
      xValueMapper: (group, _) => group.label,
      yValueMapper: (group, _) => group.values,
    ),
  ],
);

class _BandPoint {
  const _BandPoint(this.x, this.low, this.high, this.label, this.density);
  final double x;
  final double low;
  final double high;
  final String label;
  final double density;
}

Widget _violin() {
  final geometry = buildViolinGeometry(violinGroups, bandwidth: 1.5);
  final series = <sf.CartesianSeries<_BandPoint, double>>[];
  for (var i = 0; i < violinGroups.length; i++) {
    final points = geometry
        .where((p) => p.groupIndex == i)
        .map(
          (p) => _BandPoint(
            p.value,
            i - p.halfWidth,
            i + p.halfWidth,
            p.group,
            p.density,
          ),
        )
        .toList();
    series.add(
      sf.RangeAreaSeries<_BandPoint, double>(
        name: violinGroups[i].label,
        dataSource: points,
        color: _palette[i].withValues(alpha: 0.45),
        borderColor: _palette[i],
        borderWidth: 1.3,
        animationDuration: 0,
        xValueMapper: (p, _) => p.x,
        lowValueMapper: (p, _) => p.low,
        highValueMapper: (p, _) => p.high,
      ),
    );
  }
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(
      title: sf.AxisTitle(text: 'Tiempo (minutos)'),
    ),
    primaryYAxis: const sf.NumericAxis(
      minimum: -0.5,
      maximum: 2.5,
      interval: 1,
      isVisible: false,
    ),
    legend: const sf.Legend(
      isVisible: true,
      position: sf.LegendPosition.bottom,
    ),
    tooltipBehavior: sf.TooltipBehavior(
      enable: true,
      builder:
          (
            dynamic data,
            dynamic point,
            dynamic series,
            int pointIndex,
            int seriesIndex,
          ) {
            final sample = data as _BandPoint;
            return _tip(
              '${sample.label} · ${sample.x.toStringAsFixed(1)} min\nDensidad ${sample.density.toStringAsFixed(4)}',
            );
          },
    ),
    series: series,
  );
}

const _palette = [
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
];

class _RidgePoint {
  const _RidgePoint(this.x, this.low, this.high, this.group, this.density);
  final double x, low, high, density;
  final String group;
}

Widget _ridgeline() {
  final ridges = buildRidgeline(ridgelineGroups, bandwidth: 2.0);
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(
      title: sf.AxisTitle(text: 'Tiempo (minutos)'),
    ),
    primaryYAxis: sf.NumericAxis(
      minimum: -0.35,
      maximum: ridges.length.toDouble(),
      isVisible: false,
    ),
    legend: const sf.Legend(
      isVisible: true,
      position: sf.LegendPosition.bottom,
    ),
    tooltipBehavior: sf.TooltipBehavior(
      enable: true,
      builder:
          (
            dynamic data,
            dynamic point,
            dynamic series,
            int pointIndex,
            int seriesIndex,
          ) {
            final sample = data as _RidgePoint;
            return _tip(
              '${sample.group} · ${sample.x.toStringAsFixed(1)} min\nDensidad ${sample.density.toStringAsFixed(4)}',
            );
          },
    ),
    series: <sf.CartesianSeries<_RidgePoint, double>>[
      for (var i = 0; i < ridges.length; i++)
        sf.RangeAreaSeries<_RidgePoint, double>(
          name: ridges[i].label,
          dataSource: [
            for (final p in ridges[i].points)
              _RidgePoint(
                p.x,
                p.baseline,
                p.baseline + p.height,
                p.group,
                p.density,
              ),
          ],
          color: _palette[i].withValues(alpha: 0.3),
          borderColor: _palette[i],
          animationDuration: 0,
          xValueMapper: (p, _) => p.x,
          lowValueMapper: (p, _) => p.low,
          highValueMapper: (p, _) => p.high,
        ),
    ],
  );
}

Widget _hexbin() {
  final bins = buildHexBins(
    hexbinObservations,
    hexSize: 0.11,
    minX: 0,
    maxX: 10,
    minY: 0,
    maxY: 2000,
  );
  final maxCount = bins.fold<int>(0, (m, bin) => bin.count > m ? bin.count : m);
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(
      minimum: 0,
      maximum: 10,
      title: sf.AxisTitle(text: 'Duracion de visita (h)'),
    ),
    primaryYAxis: const sf.NumericAxis(
      minimum: 0,
      maximum: 2000.0,
      title: sf.AxisTitle(text: 'Gasto (mil COP)'),
    ),
    tooltipBehavior: sf.TooltipBehavior(
      enable: true,
      builder:
          (
            dynamic data,
            dynamic point,
            dynamic series,
            int pointIndex,
            int seriesIndex,
          ) {
            final bin = data as HexBin;
            return _tip(
              'Centro ${bin.centerX.toStringAsFixed(1)} h · ${bin.centerY.toStringAsFixed(0)} mil COP\nVisitas: ${bin.count}',
            );
          },
    ),
    annotations: [
      for (final bin in bins)
        sf.CartesianChartAnnotation(
          coordinateUnit: sf.CoordinateUnit.point,
          x: bin.centerX,
          y: bin.centerY,
          widget: _HexCell(
            color: distributionIntensityColor(
              bin.count.toDouble(),
              1,
              maxCount.toDouble(),
            ),
            size: 37,
          ),
        ),
    ],
    series: <sf.CartesianSeries<HexBin, double>>[
      sf.ScatterSeries<HexBin, double>(
        dataSource: bins,
        xValueMapper: (b, _) => b.centerX,
        yValueMapper: (b, _) => b.centerY,
        markerSettings: const sf.MarkerSettings(
          isVisible: true,
          shape: sf.DataMarkerType.circle,
          width: 34,
          height: 34,
          color: Colors.transparent,
        ),
      ),
    ],
  );
}

class _HexCell extends StatelessWidget {
  const _HexCell({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: _HexClipper(),
    child: Container(width: size, height: size * 0.88, color: color),
  );
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -0.5 * 3.141592653589793 + i * 3.141592653589793 / 3;
      final point = Offset(
        size.width / 2 + size.width / 2 * math.cos(angle),
        size.height / 2 + size.height / 2 * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

Widget _heatmap() {
  final matrix = heatmapMatrix;
  return sf.SfCartesianChart(
    primaryXAxis: sf.NumericAxis(
      minimum: -0.5,
      maximum: matrix.xCategories.length - 0.5,
      interval: 1,
      labelRotation: -40,
      axisLabelFormatter: (args) {
        final index = num.tryParse(args.text)?.toInt() ?? -1;
        return sf.ChartAxisLabel(
          index >= 0 && index < matrix.xCategories.length
              ? matrix.xCategories[index]
              : '',
          args.textStyle,
        );
      },
    ),
    primaryYAxis: sf.NumericAxis(
      minimum: -0.5,
      maximum: matrix.yCategories.length - 0.5,
      interval: 1,
      axisLabelFormatter: (args) {
        final index = num.tryParse(args.text)?.toInt() ?? -1;
        return sf.ChartAxisLabel(
          index >= 0 && index < matrix.yCategories.length
              ? matrix.yCategories[index]
              : '',
          args.textStyle,
        );
      },
    ),
    tooltipBehavior: sf.TooltipBehavior(
      enable: true,
      builder:
          (
            dynamic data,
            dynamic point,
            dynamic series,
            int pointIndex,
            int seriesIndex,
          ) {
            final cell = data as HeatmapCell;
            return _tip(
              '${cell.yCategory} · ${cell.xCategory}: ${cell.value.toInt()} visits',
            );
          },
    ),
    series: <sf.CartesianSeries<HeatmapCell, int>>[
      sf.ScatterSeries<HeatmapCell, int>(
        dataSource: matrix.orderedCells,
        markerSettings: const sf.MarkerSettings(
          isVisible: true,
          shape: sf.DataMarkerType.rectangle,
          width: 28,
          height: 25,
        ),
        pointColorMapper: (c, _) => distributionIntensityColor(
          c.value,
          matrix.minValue,
          matrix.maxValue,
        ),
        xValueMapper: (c, _) => matrix.xCategories.indexOf(c.xCategory),
        yValueMapper: (c, _) => matrix.yCategories.indexOf(c.yCategory),
      ),
    ],
  );
}

Widget _tip(String text) => Container(
  padding: const EdgeInsets.all(8),
  color: Colors.white,
  child: Text(text, style: const TextStyle(color: Colors.black)),
);
