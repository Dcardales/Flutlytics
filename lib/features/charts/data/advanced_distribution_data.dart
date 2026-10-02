import 'dart:math' as math;
import 'dart:ui';

import 'distribution_basics_data.dart';

class DistributionGroup {
  DistributionGroup({required this.label, required List<double> values})
    : values = List.unmodifiable(values) {
    if (values.isEmpty || values.any((value) => !value.isFinite)) {
      throw ArgumentError('Distribution groups must contain finite values.');
    }
  }
  final String label;
  final List<double> values;
}

class BoxPlotStats {
  const BoxPlotStats({
    required this.minWhisker,
    required this.q1,
    required this.median,
    required this.q3,
    required this.maxWhisker,
    required this.outliers,
    required this.iqr,
    required this.lowerFence,
    required this.upperFence,
  });
  final double minWhisker;
  final double q1;
  final double median;
  final double q3;
  final double maxWhisker;
  final List<double> outliers;
  final double iqr;
  final double lowerFence;
  final double upperFence;
}

BoxPlotStats calculateBoxPlotStats(List<double> values) {
  if (values.isEmpty || values.any((value) => !value.isFinite)) {
    throw ArgumentError('Box plot values must be non-empty and finite.');
  }
  final sorted = List<double>.of(values)..sort();
  double quantile(double p) {
    final position = (sorted.length - 1) * p;
    final lower = position.floor();
    final upper = position.ceil();
    if (lower == upper) return sorted[lower];
    final fraction = position - lower;
    return sorted[lower] + (sorted[upper] - sorted[lower]) * fraction;
  }

  final q1 = quantile(0.25);
  final median = quantile(0.5);
  final q3 = quantile(0.75);
  final iqr = q3 - q1;
  final lowerFence = q1 - 1.5 * iqr;
  final upperFence = q3 + 1.5 * iqr;
  final inliers = sorted.where((v) => v >= lowerFence && v <= upperFence);
  return BoxPlotStats(
    minWhisker: inliers.first,
    q1: q1,
    median: median,
    q3: q3,
    maxWhisker: inliers.last,
    outliers: List.unmodifiable(
      sorted.where((v) => v < lowerFence || v > upperFence),
    ),
    iqr: iqr,
    lowerFence: lowerFence,
    upperFence: upperFence,
  );
}

class ViolinPoint {
  const ViolinPoint({
    required this.value,
    required this.density,
    required this.halfWidth,
    required this.groupIndex,
    required this.group,
  });
  final double value;
  final double density;
  final double halfWidth;
  final int groupIndex;
  final String group;
}

List<ViolinPoint> buildViolinGeometry(
  List<DistributionGroup> groups, {
  required double bandwidth,
  double maxHalfWidth = 0.38,
  int gridCount = 80,
}) {
  if (groups.isEmpty || !maxHalfWidth.isFinite || maxHalfWidth <= 0) {
    throw ArgumentError('Violin groups and maxHalfWidth must be valid.');
  }
  final allValues = groups.expand((g) => g.values).toList();
  final min = allValues.reduce(math.min);
  final max = allValues.reduce(math.max);
  final h = bandwidth;
  if (!h.isFinite || h <= 0) throw ArgumentError.value(h, 'bandwidth');
  final kdeByGroup = [
    for (final group in groups)
      buildGaussianKde(
        group.values,
        bandwidth: h,
        gridCount: gridCount,
        gridMin: min - 3 * h,
        gridMax: max + 3 * h,
      ),
  ];
  final maxima = [
    for (final kde in kdeByGroup)
      kde.fold<double>(0, (m, p) => math.max(m, p.y)),
  ];
  return List.unmodifiable([
    for (var groupIndex = 0; groupIndex < groups.length; groupIndex++)
      for (final point in kdeByGroup[groupIndex])
        ViolinPoint(
          value: point.x,
          density: point.y,
          halfWidth: maxima[groupIndex] == 0
              ? 0
              : point.y / maxima[groupIndex] * maxHalfWidth,
          groupIndex: groupIndex,
          group: groups[groupIndex].label,
        ),
  ]);
}

class RidgelinePoint {
  const RidgelinePoint({
    required this.x,
    required this.density,
    required this.baseline,
    required this.height,
    required this.group,
  });
  final double x;
  final double density;
  final double baseline;
  final double height;
  final String group;
}

class RidgelineSeries {
  const RidgelineSeries({required this.label, required this.points});
  final String label;
  final List<RidgelinePoint> points;
}

List<RidgelineSeries> buildRidgeline(
  List<DistributionGroup> groups, {
  required double bandwidth,
  int gridCount = 90,
  double ridgeGap = 1,
  double maxHeight = 0.82,
}) {
  if (groups.isEmpty ||
      !bandwidth.isFinite ||
      bandwidth <= 0 ||
      !ridgeGap.isFinite ||
      ridgeGap <= 0 ||
      !maxHeight.isFinite ||
      maxHeight <= 0) {
    throw ArgumentError('Ridgeline inputs must be valid.');
  }
  final allValues = groups.expand((g) => g.values).toList();
  final min = allValues.reduce(math.min);
  final max = allValues.reduce(math.max);
  final gridMin = min - 3 * bandwidth;
  final gridMax = max + 3 * bandwidth;
  final kde = [
    for (final group in groups)
      buildGaussianKde(
        group.values,
        bandwidth: bandwidth,
        gridCount: gridCount,
        gridMin: gridMin,
        gridMax: gridMax,
      ),
  ];
  final sharedMax = kde
      .expand((series) => series)
      .fold<double>(0, (m, point) => math.max(m, point.y));
  return List.unmodifiable([
    for (var i = 0; i < groups.length; i++)
      RidgelineSeries(
        label: groups[i].label,
        points: List.unmodifiable([
          for (final point in kde[i])
            RidgelinePoint(
              x: point.x,
              density: point.y,
              baseline: i * ridgeGap,
              height: sharedMax == 0 ? 0 : point.y / sharedMax * maxHeight,
              group: groups[i].label,
            ),
        ]),
      ),
  ]);
}

class HexObservation {
  const HexObservation(this.x, this.y);
  final double x;
  final double y;
}

class HexBin {
  const HexBin({
    required this.q,
    required this.r,
    required this.centerX,
    required this.centerY,
    required this.count,
  });
  final int q;
  final int r;
  final double centerX;
  final double centerY;
  final int count;
  String get id => '$q:$r';
}

List<HexBin> buildHexBins(
  List<HexObservation> points, {
  required double hexSize,
  required double minX,
  required double maxX,
  required double minY,
  required double maxY,
  double plotAspect = 1.5,
}) {
  if (!hexSize.isFinite ||
      hexSize <= 0 ||
      !plotAspect.isFinite ||
      plotAspect <= 0 ||
      ![minX, maxX, minY, maxY].every((v) => v.isFinite) ||
      maxX <= minX ||
      maxY <= minY ||
      points.any((p) => !p.x.isFinite || !p.y.isFinite)) {
    throw ArgumentError(
      'Hexbin coordinates, domains, and size must be finite and valid.',
    );
  }
  final counts = <(int, int), int>{};
  for (final point in points) {
    final x = (point.x - minX) / (maxX - minX) * plotAspect;
    final y = (point.y - minY) / (maxY - minY);
    final q = (math.sqrt(3) / 3 * x - y / 3) / hexSize;
    final r = (2 * y / 3) / hexSize;
    var cubeX = q;
    var cubeZ = r;
    var cubeY = -cubeX - cubeZ;
    var rx = cubeX.round();
    var ry = cubeY.round();
    var rz = cubeZ.round();
    final dx = (rx - cubeX).abs();
    final dy = (ry - cubeY).abs();
    final dz = (rz - cubeZ).abs();
    if (dx > dy && dx > dz) {
      rx = -ry - rz;
    } else if (dy > dz) {
      ry = -rx - rz;
    } else {
      rz = -rx - ry;
    }
    counts.update((rx, rz), (count) => count + 1, ifAbsent: () => 1);
  }
  final cells =
      counts.entries.map((entry) {
          final (q, r) = entry.key;
          final x = hexSize * math.sqrt(3) * (q + r / 2);
          final y = hexSize * 1.5 * r;
          return HexBin(
            q: q,
            r: r,
            centerX: minX + x / plotAspect * (maxX - minX),
            centerY: minY + y * (maxY - minY),
            count: entry.value,
          );
        }).toList()
        ..sort((a, b) => a.q == b.q ? a.r.compareTo(b.r) : a.q.compareTo(b.q));
  return List.unmodifiable(cells);
}

class HeatmapCell {
  const HeatmapCell({
    required this.xCategory,
    required this.yCategory,
    required this.value,
  });
  final String xCategory;
  final String yCategory;
  final double value;
}

class HeatmapMatrix {
  HeatmapMatrix({
    required List<String> xCategories,
    required List<String> yCategories,
    required List<HeatmapCell> cells,
  }) : xCategories = List.unmodifiable(xCategories),
       yCategories = List.unmodifiable(yCategories),
       cells = List.unmodifiable(cells) {
    if (xCategories.isEmpty ||
        yCategories.isEmpty ||
        xCategories.toSet().length != xCategories.length ||
        yCategories.toSet().length != yCategories.length) {
      throw ArgumentError('Heatmap categories must be non-empty and unique.');
    }
    final keys = cells.map((c) => '${c.xCategory}\u0000${c.yCategory}').toSet();
    if (keys.length != cells.length ||
        cells.any(
          (cell) =>
              !xCategories.contains(cell.xCategory) ||
              !yCategories.contains(cell.yCategory) ||
              !cell.value.isFinite,
        )) {
      throw ArgumentError('Heatmap cells must be unique, known, and finite.');
    }
    if (cells.length != xCategories.length * yCategories.length) {
      throw ArgumentError('Heatmap matrix must contain every category pair.');
    }
  }
  final List<String> xCategories;
  final List<String> yCategories;
  final List<HeatmapCell> cells;
  double get minValue => cells.map((c) => c.value).reduce(math.min);
  double get maxValue => cells.map((c) => c.value).reduce(math.max);
  List<HeatmapCell> get orderedCells => List.unmodifiable([
    for (final y in yCategories)
      for (final x in xCategories)
        cells.firstWhere((cell) => cell.xCategory == x && cell.yCategory == y),
  ]);
}

Color distributionIntensityColor(
  double value,
  double minValue,
  double maxValue,
) => Color.lerp(
  const Color(0xffe3f2fd),
  const Color(0xff0d47a1),
  maxValue == minValue
      ? 0.5
      : ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0),
)!;

final boxPlotGroups = List<DistributionGroup>.unmodifiable([
  DistributionGroup(
    label: 'Bogota',
    values: [
      8.4,
      9.1,
      9.4,
      9.8,
      10.0,
      10.2,
      10.4,
      10.7,
      10.8,
      11.0,
      11.1,
      11.3,
      11.5,
      11.6,
      11.8,
      12.0,
      12.1,
      12.3,
      12.5,
      12.7,
      12.9,
      13.0,
      13.2,
      13.5,
      14.0,
      15.0,
      38.0,
    ],
  ),
  DistributionGroup(
    label: 'Medellin',
    values: [
      7.8,
      8.2,
      8.5,
      8.9,
      9.0,
      9.3,
      9.5,
      9.7,
      9.9,
      10.0,
      10.2,
      10.4,
      10.5,
      10.7,
      10.9,
      11.0,
      11.1,
      11.3,
      11.5,
      11.7,
      11.9,
      12.0,
      12.2,
      12.5,
      13.0,
    ],
  ),
  DistributionGroup(
    label: 'Cartagena',
    values: [
      9.0,
      9.2,
      9.4,
      9.8,
      10.0,
      10.2,
      10.4,
      10.6,
      10.8,
      11.0,
      11.2,
      11.4,
      11.5,
      11.8,
      12.0,
      12.2,
      12.5,
      12.8,
      13.0,
      13.2,
      13.5,
      13.8,
      14.0,
      14.5,
      16.0,
    ],
  ),
  DistributionGroup(
    label: 'Cali',
    values: [
      6.8,
      7.2,
      7.5,
      7.8,
      8.0,
      8.2,
      8.4,
      8.6,
      8.8,
      9.0,
      9.2,
      9.4,
      9.5,
      9.8,
      10.0,
      10.2,
      10.4,
      10.6,
      10.8,
      11.0,
      11.2,
      11.5,
      12.0,
      12.5,
      34.0,
    ],
  ),
]);

final violinGroups = List<DistributionGroup>.unmodifiable([
  DistributionGroup(
    label: 'Restaurante',
    values: [
      11.2,
      12.0,
      12.2,
      12.5,
      12.7,
      12.8,
      13.0,
      13.1,
      13.2,
      13.4,
      13.6,
      13.7,
      13.9,
      14.0,
      14.2,
      14.4,
      14.7,
      15.0,
      15.2,
      15.5,
      15.8,
      16.0,
      16.4,
      17.0,
    ],
  ),
  DistributionGroup(
    label: 'Recepcion',
    values: [
      5.8,
      6.2,
      6.4,
      6.8,
      7.0,
      7.2,
      7.4,
      7.5,
      7.8,
      8.0,
      8.2,
      8.3,
      8.5,
      8.6,
      8.8,
      9.0,
      9.2,
      9.5,
      9.8,
      10.0,
      10.3,
      10.8,
      11.2,
      12.0,
    ],
  ),
  DistributionGroup(
    label: 'Transporte',
    values: [
      14.0,
      14.8,
      15.2,
      15.8,
      16.0,
      16.4,
      16.8,
      17.0,
      17.5,
      18.0,
      18.2,
      18.5,
      19.0,
      19.5,
      20.0,
      20.4,
      21.0,
      21.5,
      22.0,
      23.0,
      24.0,
      25.0,
      27.0,
      30.0,
    ],
  ),
]);

final ridgelineGroups = List<DistributionGroup>.unmodifiable([
  for (final (label, base, spread) in const [
    ('Enero', 8.0, 4.0),
    ('Febrero', 9.2, 3.6),
    ('Marzo', 10.8, 4.8),
    ('Abril', 12.0, 5.2),
  ])
    DistributionGroup(
      label: label,
      values: List.generate(
        24,
        (i) => base + ((i * 17) % 23 - 11) * spread / 8 + (i % 5) * 0.12,
      ),
    ),
]);

final hexbinObservations = List<HexObservation>.unmodifiable([
  for (var i = 0; i < 300; i++)
    () {
      final cluster = i % 3;
      const centerX = [2.2, 5.7, 8.0];
      const centerY = [520.0, 1120.0, 1620.0];
      final jitterX = ((i * 37) % 31 - 15) * 0.075;
      final jitterY = ((i * 19) % 29 - 14) * 14.0;
      return HexObservation(
        centerX[cluster] + jitterX,
        centerY[cluster] + jitterY,
      );
    }(),
]);

final heatmapMatrix = HeatmapMatrix(
  xCategories: const [
    'Manana',
    'Tarde',
    'Noche',
    'Madrugada',
    'Alba',
    'Mediodia',
  ],
  yCategories: const ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'],
  cells: [
    for (var day = 0; day < 7; day++)
      for (var period = 0; period < 6; period++)
        HeatmapCell(
          xCategory: const [
            'Manana',
            'Tarde',
            'Noche',
            'Madrugada',
            'Alba',
            'Mediodia',
          ][period],
          yCategory: const [
            'Lun',
            'Mar',
            'Mie',
            'Jue',
            'Vie',
            'Sab',
            'Dom',
          ][day],
          value:
              18 +
              day * 3 +
              period * 5 +
              (day >= 5 ? 16 : 0) +
              ((day + period) % 4) * 2,
        ),
  ],
);
