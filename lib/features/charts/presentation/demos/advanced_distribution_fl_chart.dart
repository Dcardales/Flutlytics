import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/advanced_distribution_data.dart';

const _colors = [
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
];

Widget buildFlAdvancedDistribution(String id) => switch (id) {
  'box-plot' => _boxPlot(),
  'violin' => _violin(),
  'ridgeline' => _ridgeline(),
  'hexbin' => _hexbin(),
  _ => _heatmap(),
};

Widget _boxPlot() {
  final stats = [
    for (final group in boxPlotGroups) calculateBoxPlotStats(group.values),
  ];
  final lines = <fl.LineChartBarData>[];
  for (var i = 0; i < stats.length; i++) {
    final x = i.toDouble();
    final left = x - 0.23;
    final right = x + 0.23;
    final s = stats[i];
    final color = _colors[i % _colors.length];
    lines.addAll([
      _line(
        [
          fl.FlSpot(left, s.q1),
          fl.FlSpot(left, s.q3),
          fl.FlSpot(right, s.q3),
          fl.FlSpot(right, s.q1),
          fl.FlSpot(left, s.q1),
        ],
        color,
        2,
      ),
      _line(
        [fl.FlSpot(left, s.median), fl.FlSpot(right, s.median)],
        Colors.black,
        2.5,
      ),
      _line([fl.FlSpot(x, s.minWhisker), fl.FlSpot(x, s.q1)], color, 1.5),
      _line([fl.FlSpot(x, s.q3), fl.FlSpot(x, s.maxWhisker)], color, 1.5),
      _line(
        [fl.FlSpot(left, s.minWhisker), fl.FlSpot(right, s.minWhisker)],
        color,
        1.5,
      ),
      _line(
        [fl.FlSpot(left, s.maxWhisker), fl.FlSpot(right, s.maxWhisker)],
        color,
        1.5,
      ),
      _line(
        [for (final outlier in s.outliers) fl.FlSpot(x, outlier)],
        Colors.red,
        0,
        dots: true,
      ),
    ]);
  }
  return Padding(
    padding: const EdgeInsets.all(8),
    child: fl.LineChart(
      fl.LineChartData(
        minX: -0.5,
        maxX: stats.length - 0.5,
        minY: 0,
        lineBarsData: lines,
        titlesData: _titles(
          bottomCount: boxPlotGroups.length,
          bottom: (v) {
            final i = v.toInt();
            return i >= 0 && i < boxPlotGroups.length
                ? boxPlotGroups[i].label
                : '';
          },
        ),
        gridData: const fl.FlGridData(drawVerticalLine: false),
        lineTouchData: fl.LineTouchData(
          enabled: true,
          touchTooltipData: fl.LineTouchTooltipData(
            fitInsideHorizontally: true,
            getTooltipItems: (spots) => [
              for (final touched in spots)
                () {
                  final index = touched.x.round().clamp(
                    0,
                    boxPlotGroups.length - 1,
                  );
                  final group = boxPlotGroups[index];
                  final s = calculateBoxPlotStats(group.values);
                  return fl.LineTooltipItem(
                    '${group.label}\nQ1 ${s.q1.toStringAsFixed(1)} · Mediana ${s.median.toStringAsFixed(1)} · Q3 ${s.q3.toStringAsFixed(1)}\nWhiskers ${s.minWhisker.toStringAsFixed(1)}–${s.maxWhisker.toStringAsFixed(1)} · Outliers ${s.outliers.length}',
                    TextStyle(color: touched.bar.color ?? Colors.black),
                  );
                }(),
            ],
          ),
        ),
      ),
    ),
  );
}

fl.LineChartBarData _line(
  List<fl.FlSpot> spots,
  Color color,
  double width, {
  bool dots = false,
  bool fill = false,
}) => fl.LineChartBarData(
  spots: spots,
  color: color,
  barWidth: width,
  dotData: fl.FlDotData(show: dots),
  belowBarData: fl.BarAreaData(
    show: fill,
    color: color.withValues(alpha: 0.35),
  ),
);

Widget _violin() {
  final geometry = buildViolinGeometry(violinGroups, bandwidth: 1.5);
  final lines = <fl.LineChartBarData>[];
  final fills = <fl.BetweenBarsData>[];
  for (var i = 0; i < violinGroups.length; i++) {
    final rows = geometry.where((p) => p.groupIndex == i).toList();
    final lowerIndex = lines.length;
    lines.add(
      _line(
        [for (final p in rows) fl.FlSpot(p.value, i - p.halfWidth)],
        _colors[i],
        1.5,
      ),
    );
    lines.add(
      _line(
        [for (final p in rows) fl.FlSpot(p.value, i + p.halfWidth)],
        _colors[i],
        1.5,
      ),
    );
    fills.add(
      fl.BetweenBarsData(
        fromIndex: lowerIndex,
        toIndex: lowerIndex + 1,
        color: _colors[i].withValues(alpha: 0.35),
      ),
    );
  }
  return Padding(
    padding: const EdgeInsets.all(8),
    child: fl.LineChart(
      fl.LineChartData(
        minX: geometry.first.value,
        maxX: geometry.last.value,
        minY: -0.5,
        maxY: violinGroups.length - 0.5,
        lineBarsData: lines,
        betweenBarsData: fills,
        titlesData: _titles(
          bottomCount: 5,
          bottom: (v) => v.toInt().toString(),
          leftCount: violinGroups.length,
          left: (v) {
            final i = v.toInt();
            return i >= 0 && i < violinGroups.length
                ? violinGroups[i].label
                : '';
          },
        ),
        gridData: const fl.FlGridData(drawVerticalLine: false),
        lineTouchData: fl.LineTouchData(
          enabled: true,
          touchTooltipData: fl.LineTouchTooltipData(
            fitInsideHorizontally: true,
            getTooltipItems: (spots) => [
              for (final touched in spots)
                () {
                  final index = (touched.barIndex ~/ 2).clamp(
                    0,
                    violinGroups.length - 1,
                  );
                  final point = geometry
                      .where((p) => p.groupIndex == index)
                      .reduce(
                        (a, b) =>
                            (a.value - touched.x).abs() <
                                (b.value - touched.x).abs()
                            ? a
                            : b,
                      );
                  return fl.LineTooltipItem(
                    '${point.group}\n${point.value.toStringAsFixed(1)} min · density ${point.density.toStringAsFixed(4)}',
                    TextStyle(color: touched.bar.color ?? Colors.black),
                  );
                }(),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _ridgeline() {
  final rows = buildRidgeline(ridgelineGroups, bandwidth: 2.0);
  final lines = <fl.LineChartBarData>[];
  final fills = <fl.BetweenBarsData>[];
  for (var i = 0; i < rows.length; i++) {
    final lowerIndex = lines.length;
    final points = rows[i].points;
    lines.add(
      _line(
        [for (final p in points) fl.FlSpot(p.x, p.baseline)],
        Colors.transparent,
        0,
      ),
    );
    lines.add(
      _line(
        [for (final p in points) fl.FlSpot(p.x, p.baseline + p.height)],
        _colors[i],
        1.4,
      ),
    );
    fills.add(
      fl.BetweenBarsData(
        fromIndex: lowerIndex,
        toIndex: lowerIndex + 1,
        color: _colors[i].withValues(alpha: 0.28),
      ),
    );
  }
  return Padding(
    padding: const EdgeInsets.fromLTRB(26, 8, 8, 8),
    child: fl.LineChart(
      fl.LineChartData(
        minX: rows.first.points.first.x,
        maxX: rows.first.points.last.x,
        minY: -0.3,
        maxY: rows.length.toDouble(),
        lineBarsData: lines,
        betweenBarsData: fills,
        titlesData: _titles(
          bottomCount: 5,
          bottom: (v) => v.toInt().toString(),
          leftCount: rows.length,
          left: (v) {
            final i = v.round();
            return i >= 0 && i < rows.length && (v - i).abs() < 0.2
                ? rows[i].label
                : '';
          },
        ),
        gridData: const fl.FlGridData(drawVerticalLine: false),
        lineTouchData: fl.LineTouchData(
          enabled: true,
          touchTooltipData: fl.LineTouchTooltipData(
            fitInsideHorizontally: true,
            getTooltipItems: (spots) => [
              for (final touched in spots)
                () {
                  final index = (touched.barIndex ~/ 2).clamp(
                    0,
                    rows.length - 1,
                  );
                  final point = rows[index].points.reduce(
                    (a, b) => (a.x - touched.x).abs() < (b.x - touched.x).abs()
                        ? a
                        : b,
                  );
                  return fl.LineTooltipItem(
                    '${point.group}\n${point.x.toStringAsFixed(1)} min · density ${point.density.toStringAsFixed(4)}',
                    TextStyle(color: touched.bar.color ?? Colors.black),
                  );
                }(),
            ],
          ),
        ),
      ),
    ),
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
  final maxCount = bins.fold<int>(0, (m, bin) => math.max(m, bin.count));
  return Padding(
    padding: const EdgeInsets.all(8),
    child: fl.ScatterChart(
      fl.ScatterChartData(
        minX: 0,
        maxX: 10,
        minY: 0,
        maxY: 2000,
        scatterSpots: [
          for (final bin in bins)
            fl.ScatterSpot(
              bin.centerX,
              bin.centerY,
              dotPainter: _HexDotPainter(
                _heatColor(bin.count.toDouble(), 1, maxCount.toDouble()),
                15 + 12 * bin.count / maxCount,
              ),
            ),
        ],
        titlesData: _titles(
          bottomCount: 5,
          bottom: (v) => v.toStringAsFixed(0),
          leftCount: 5,
          left: (v) => (v * 500).toInt().toString(),
        ),
        scatterTouchData: fl.ScatterTouchData(
          enabled: true,
          touchTooltipData: fl.ScatterTouchTooltipData(
            getTooltipItems: (spot) {
              final bin = bins.firstWhere(
                (b) => b.centerX == spot.x && b.centerY == spot.y,
              );
              return fl.ScatterTooltipItem(
                'Centro: ${bin.centerX.toStringAsFixed(1)} h, ${bin.centerY.toStringAsFixed(0)} mil COP\nVisitas: ${bin.count}',
                textStyle: TextStyle(color: spot.dotPainter.mainColor),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _HexDotPainter extends fl.FlDotPainter {
  const _HexDotPainter(this.color, this.size);
  final Color color;
  final double size;
  @override
  Color get mainColor => color;
  @override
  Size getSize(fl.FlSpot spot) => Size.square(size);
  @override
  void draw(Canvas canvas, fl.FlSpot spot, Offset center) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * size / 2;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  fl.FlDotPainter lerp(fl.FlDotPainter a, fl.FlDotPainter b, double t) => b;
  @override
  List<Object?> get props => [color, size];
}

Widget _heatmap() {
  final matrix = heatmapMatrix;
  return Padding(
    padding: const EdgeInsets.fromLTRB(28, 8, 8, 8),
    child: fl.ScatterChart(
      fl.ScatterChartData(
        minX: -0.5,
        maxX: matrix.xCategories.length - 0.5,
        minY: -0.5,
        maxY: matrix.yCategories.length - 0.5,
        scatterSpots: [
          for (final cell in matrix.orderedCells)
            fl.ScatterSpot(
              matrix.xCategories.indexOf(cell.xCategory).toDouble(),
              matrix.yCategories.indexOf(cell.yCategory).toDouble(),
              dotPainter: fl.FlDotSquarePainter(
                size: 21,
                color: _heatColor(cell.value, matrix.minValue, matrix.maxValue),
                strokeWidth: 0,
              ),
            ),
        ],
        titlesData: _titles(
          bottomCount: matrix.xCategories.length,
          bottom: (v) {
            final i = v.toInt();
            return i >= 0 && i < matrix.xCategories.length
                ? matrix.xCategories[i]
                : '';
          },
          leftCount: matrix.yCategories.length,
          left: (v) {
            final i = v.toInt();
            return i >= 0 && i < matrix.yCategories.length
                ? matrix.yCategories[i]
                : '';
          },
        ),
        scatterTouchData: fl.ScatterTouchData(
          enabled: true,
          touchTooltipData: fl.ScatterTouchTooltipData(
            getTooltipItems: (spot) {
              final cell = matrix.orderedCells.firstWhere(
                (c) =>
                    matrix.xCategories.indexOf(c.xCategory) == spot.x.toInt() &&
                    matrix.yCategories.indexOf(c.yCategory) == spot.y.toInt(),
              );
              return fl.ScatterTooltipItem(
                '${cell.yCategory} · ${cell.xCategory}: ${cell.value.toInt()} visitas',
                textStyle: TextStyle(color: spot.dotPainter.mainColor),
              );
            },
          ),
        ),
      ),
    ),
  );
}

fl.FlTitlesData _titles({
  required int bottomCount,
  required String Function(double) bottom,
  int leftCount = 0,
  String Function(double)? left,
}) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      interval: 1,
      reservedSize: 38,
      getTitlesWidget: (v, _) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          bottom(v),
          style: const TextStyle(fontSize: 8),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ),
  leftTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: left != null,
      interval: 1,
      reservedSize: 54,
      getTitlesWidget: (v, _) =>
          Text(left?.call(v) ?? '', style: const TextStyle(fontSize: 8)),
    ),
  ),
);

Color _heatColor(double value, double min, double max) => Color.lerp(
  const Color(0xffe3f2fd),
  const Color(0xff0d47a1),
  max == min ? 0.5 : ((value - min) / (max - min)).clamp(0.0, 1.0),
)!;
