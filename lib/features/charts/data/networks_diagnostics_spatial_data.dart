import 'dart:math' as math;

import 'analytical_structures_data.dart';

class NetworkNode {
  NetworkNode(this.id, this.label, this.group, this.weight) {
    if (id.trim().isEmpty ||
        label.trim().isEmpty ||
        group.trim().isEmpty ||
        !weight.isFinite ||
        weight < 0) {
      throw ArgumentError(
        'Network node needs metadata and finite nonnegative weight.',
      );
    }
  }
  final String id, label, group;
  final double weight;
}

class NetworkEdge {
  NetworkEdge(this.sourceId, this.targetId, this.weight) {
    if (sourceId.trim().isEmpty ||
        targetId.trim().isEmpty ||
        sourceId == targetId ||
        !weight.isFinite ||
        weight < 0) {
      throw ArgumentError(
        'Network edge needs two distinct endpoints and finite nonnegative weight.',
      );
    }
  }
  final String sourceId, targetId;
  final double weight;
}

class NetworkPosition {
  const NetworkPosition(this.node, this.x, this.y);
  final NetworkNode node;
  final double x, y;
}

class NetworkGraphData {
  NetworkGraphData(List<NetworkNode> nodes, List<NetworkEdge> edges)
    : nodes = List.unmodifiable(nodes),
      edges = List.unmodifiable(edges) {
    final ids = nodes.map((n) => n.id).toSet();
    if (nodes.length < 2 ||
        ids.length != nodes.length ||
        edges.isEmpty ||
        edges.any(
          (e) => !ids.contains(e.sourceId) || !ids.contains(e.targetId),
        )) {
      throw ArgumentError(
        'Network needs unique nodes and existing edge endpoints.',
      );
    }
    // Stable input order around a unit circle; this is not force-directed.
    positions = List.unmodifiable([
      for (var i = 0; i < nodes.length; i++)
        NetworkPosition(
          nodes[i],
          math.cos(-math.pi / 2 + 2 * math.pi * i / nodes.length),
          math.sin(-math.pi / 2 + 2 * math.pi * i / nodes.length),
        ),
    ]);
    byId = Map.unmodifiable({for (final p in positions) p.node.id: p});
  }
  final List<NetworkNode> nodes;
  final List<NetworkEdge> edges;
  late final List<NetworkPosition> positions;
  late final Map<String, NetworkPosition> byId;
  List<NetworkEdge> connections(String id) => edges
      .where((e) => e.sourceId == id || e.targetId == id)
      .toList(growable: false);
}

final touristNetwork = NetworkGraphData(
  [
    NetworkNode('centro', 'Centro Histórico', 'Destino', 9),
    NetworkNode('aeropuerto', 'Aeropuerto', 'Transporte', 8),
    NetworkNode('terminal', 'Terminal', 'Transporte', 6),
    NetworkNode('hotel', 'Hotel A', 'Servicio', 7),
    NetworkNode('restaurante', 'Restaurante B', 'Servicio', 5),
    NetworkNode('museo', 'Museo C', 'Destino', 4),
    NetworkNode('playa', 'Playa D', 'Destino', 7),
  ],
  [
    NetworkEdge('aeropuerto', 'centro', 8),
    NetworkEdge('terminal', 'centro', 6),
    NetworkEdge('centro', 'hotel', 7),
    NetworkEdge('centro', 'museo', 5),
    NetworkEdge('hotel', 'restaurante', 4),
    NetworkEdge('hotel', 'playa', 5),
    NetworkEdge('playa', 'restaurante', 3),
    NetworkEdge('terminal', 'hotel', 3),
  ],
);

/// Acklam rational approximation; valid only for 0 < p < 1.
double inverseNormalCdf(double p) {
  if (!p.isFinite || p <= 0 || p >= 1) throw ArgumentError.value(p, 'p');
  const a = [
    -39.69683028665376,
    220.9460984245205,
    -275.9285104469687,
    138.3577518672690,
    -30.66479806614716,
    2.506628277459239,
  ];
  const b = [
    -54.47609879822406,
    161.5858368580409,
    -155.6989798598866,
    66.80131188771972,
    -13.28068155288572,
  ];
  const c = [
    -0.007784894002430293,
    -0.3223964580411365,
    -2.400758277161838,
    -2.549732539343734,
    4.374664141464968,
    2.938163982698783,
  ];
  const d = [
    0.007784695709041462,
    0.3224671290700398,
    2.445134137142996,
    3.754408661907416,
  ];
  if (p < .02425 || p > .97575) {
    final q = math.sqrt(-2 * math.log(p < .5 ? p : 1 - p));
    final v =
        (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
        ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1);
    return p < .5 ? v : -v;
  }
  final q = p - .5, r = q * q;
  return (((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r + a[5]) *
      q /
      (((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1);
}

class QqPoint {
  const QqPoint(this.probability, this.theoretical, this.observed);
  final double probability, theoretical, observed;
}

/// Plotting positions p_i = (i - 0.5) / n; observed values use sample SD.
List<QqPoint> normalQq(List<double> observations) {
  if (observations.length < 3 || observations.any((v) => !v.isFinite)) {
    throw ArgumentError('Q-Q needs at least three finite observations.');
  }
  final sorted = [...observations]..sort();
  final mean = sorted.reduce((a, b) => a + b) / sorted.length;
  final sd = math.sqrt(
    sorted
            .map((v) => math.pow(v - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        (sorted.length - 1),
  );
  if (sd == 0) throw ArgumentError('Q-Q sample must vary.');
  return List.unmodifiable([
    for (var i = 0; i < sorted.length; i++)
      QqPoint(
        (i + .5) / sorted.length,
        inverseNormalCdf((i + .5) / sorted.length),
        (sorted[i] - mean) / sd,
      ),
  ]);
}

final serviceMinutes = List<double>.unmodifiable(
  [
    18,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    30,
    31,
    31,
    32,
    32,
    33,
    33,
    34,
    34,
    35,
    35,
    36,
    36,
    37,
    37,
    38,
    38,
    39,
    39,
    40,
    40,
    41,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    54,
    56,
    59,
    64,
  ].map((v) => v.toDouble()),
);
final serviceQq = normalQq(serviceMinutes);

class ParallelPoint {
  const ParallelPoint(
    this.observation,
    this.variable,
    this.axis,
    this.raw,
    this.normalized,
  );
  final MultivariateObservation observation;
  final MatrixVariable variable;
  final int axis;
  final double raw, normalized;
}

class ParallelCoordinatesData {
  ParallelCoordinatesData(
    List<MatrixVariable> variables,
    List<MultivariateObservation> observations,
  ) : variables = List.unmodifiable(variables),
      observations = List.unmodifiable(observations) {
    final ids = variables.map((v) => v.id).toSet();
    if (variables.length < 3 ||
        ids.length != variables.length ||
        observations.isEmpty ||
        observations.map((o) => o.label).toSet().length !=
            observations.length ||
        observations.any(
          (o) =>
              o.values.keys.toSet().length != ids.length ||
              !o.values.keys.toSet().containsAll(ids),
        )) {
      throw ArgumentError(
        'Parallel coordinates need shared finite dimensions.',
      );
    }
    ranges = Map.unmodifiable({
      for (final v in variables)
        v.id: (
          observations.map((o) => o.value(v)).reduce(math.min),
          observations.map((o) => o.value(v)).reduce(math.max),
        ),
    });
    points = List.unmodifiable([
      for (final o in observations)
        for (var i = 0; i < variables.length; i++)
          ParallelPoint(
            o,
            variables[i],
            i,
            o.value(variables[i]),
            normalize(
              o.value(variables[i]),
              ranges[variables[i].id]!.$1,
              ranges[variables[i].id]!.$2,
            ),
          ),
    ]);
  }
  final List<MatrixVariable> variables;
  final List<MultivariateObservation> observations;
  late final Map<String, (double, double)> ranges;
  late final List<ParallelPoint> points;
  static double normalize(double value, double min, double max) {
    if (![value, min, max].every((v) => v.isFinite) ||
        max < min ||
        value < min ||
        value > max) {
      throw ArgumentError('Invalid normalization bounds.');
    }
    return min == max ? .5 : (value - min) / (max - min);
  }

  List<ParallelPoint> forObservation(MultivariateObservation o) =>
      points.where((p) => identical(p.observation, o)).toList(growable: false);
}

final touristParallel = ParallelCoordinatesData(
  [
    MatrixVariable('safety', 'Seguridad', 'puntos / 10'),
    MatrixVariable('price', 'Precio', 'mil COP / día'),
    MatrixVariable('mobility', 'Movilidad', 'puntos / 10'),
    MatrixVariable('food', 'Gastronomía', 'puntos / 10'),
    MatrixVariable('lodging', 'Alojamiento', 'puntos / 10'),
  ],
  [
    for (var i = 0; i < 10; i++)
      MultivariateObservation('Destino ${i + 1}', {
        'safety': 5.7 + (i * 7 % 35) / 10,
        'price': 120 + (i * 43 % 180).toDouble(),
        'mobility': 4.8 + (i * 11 % 42) / 10,
        'food': 6.0 + (i * 13 % 32) / 10,
        'lodging': 5.5 + (i * 17 % 35) / 10,
      }),
  ],
);

class FieldPoint {
  const FieldPoint(this.x, this.y, this.z);
  final double x, y, z;
}

class IsolineSegment {
  const IsolineSegment(this.level, this.a, this.b);
  final double level;
  final FieldPoint a, b;
}

double touristIntensity(double x, double y) {
  double peak(double cx, double cy, double sx, double sy, double amplitude) =>
      amplitude *
      math.exp(-.5 * (math.pow((x - cx) / sx, 2) + math.pow((y - cy) / sy, 2)));
  return peak(7, 7, 3.2, 3, 90) +
      peak(17, 12, 4, 2.5, 65) +
      peak(13, 4, 2, 2, 28);
}

class ContourData {
  ContourData(List<List<FieldPoint>> grid, List<double> levels)
    : grid = List.unmodifiable(
        grid.map((r) => List<FieldPoint>.unmodifiable(r)),
      ),
      levels = List.unmodifiable(levels) {
    if (grid.length < 2 ||
        grid.first.length < 2 ||
        grid.any(
          (r) =>
              r.length != grid.first.length ||
              r.any((p) => !p.x.isFinite || !p.y.isFinite || !p.z.isFinite),
        ) ||
        levels.isEmpty ||
        levels.any((v) => !v.isFinite)) {
      throw ArgumentError('Contour needs a complete finite rectangular grid.');
    }
    final all = grid.expand((r) => r).map((p) => p.z);
    minZ = all.reduce(math.min);
    maxZ = all.reduce(math.max);
    if (levels.any((v) => v <= minZ || v >= maxZ) ||
        levels.toSet().length != levels.length ||
        List.generate(
          levels.length - 1,
          (i) => levels[i] >= levels[i + 1],
        ).contains(true)) {
      throw ArgumentError(
        'Contour levels must be distinct, ordered and inside range.',
      );
    }
    segments = List.unmodifiable([
      for (final level in levels)
        for (var row = 0; row < grid.length - 1; row++)
          for (var col = 0; col < grid.first.length - 1; col++)
            ..._cell(
              grid[row][col],
              grid[row][col + 1],
              grid[row + 1][col + 1],
              grid[row + 1][col],
              level,
            ),
    ]);
  }
  final List<List<FieldPoint>> grid;
  final List<double> levels;
  late final double minZ, maxZ;
  late final List<IsolineSegment> segments;

  // Marching Squares: interpolate crossings on each of four cell edges.
  static List<IsolineSegment> _cell(
    FieldPoint a,
    FieldPoint b,
    FieldPoint c,
    FieldPoint d,
    double level,
  ) {
    FieldPoint? crossing(FieldPoint p, FieldPoint q) {
      if ((p.z < level) == (q.z < level) || p.z == q.z) return null;
      final t = (level - p.z) / (q.z - p.z);
      return FieldPoint(p.x + t * (q.x - p.x), p.y + t * (q.y - p.y), level);
    }

    final hits = [
      crossing(a, b),
      crossing(b, c),
      crossing(c, d),
      crossing(d, a),
    ].whereType<FieldPoint>().toList();
    if (hits.length == 2) return [IsolineSegment(level, hits[0], hits[1])];
    if (hits.length == 4) {
      // Deterministic ambiguous-cell pairing by bilinear center value.
      final centerHigh = (a.z + b.z + c.z + d.z) / 4 >= level;
      return centerHigh == (a.z >= level)
          ? [
              IsolineSegment(level, hits[0], hits[1]),
              IsolineSegment(level, hits[2], hits[3]),
            ]
          : [
              IsolineSegment(level, hits[0], hits[3]),
              IsolineSegment(level, hits[1], hits[2]),
            ];
    }
    return const [];
  }
}

final touristContour = (() {
  final grid = [
    for (var y = 0; y < 20; y++)
      [
        for (var x = 0; x < 25; x++)
          FieldPoint(
            x.toDouble(),
            y.toDouble(),
            touristIntensity(x.toDouble(), y.toDouble()),
          ),
      ],
  ];
  final values = grid.expand((r) => r).map((p) => p.z);
  final min = values.reduce(math.min), max = values.reduce(math.max);
  return ContourData(grid, [
    for (var i = 1; i <= 6; i++) min + (max - min) * i / 7,
  ]);
})();

class CalendarDay {
  CalendarDay(this.date, this.value) {
    if (!value.isFinite || value < 0) {
      throw ArgumentError('Daily value must be finite and nonnegative.');
    }
  }
  final DateTime date;
  final double value;
}

class CalendarCell {
  const CalendarCell(this.day, this.week, this.weekday);
  final CalendarDay day;
  final int week, weekday; // Monday=0, Sunday=6.
}

class CalendarHeatmapData {
  CalendarHeatmapData(List<CalendarDay> days) : days = List.unmodifiable(days) {
    if (days.isEmpty ||
        days
                .map((d) => DateTime.utc(d.date.year, d.date.month, d.date.day))
                .toSet()
                .length !=
            days.length) {
      throw ArgumentError('Calendar dates must be unique.');
    }
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    final first = DateTime.utc(
      sorted.first.date.year,
      sorted.first.date.month,
      sorted.first.date.day,
    );
    monday = first.subtract(Duration(days: first.weekday - 1));
    cells = List.unmodifiable([
      for (final day in sorted)
        CalendarCell(
          day,
          DateTime.utc(
                day.date.year,
                day.date.month,
                day.date.day,
              ).difference(monday).inDays ~/
              7,
          day.date.weekday - 1,
        ),
    ]);
    minValue = sorted.map((d) => d.value).reduce(math.min);
    maxValue = sorted.map((d) => d.value).reduce(math.max);
  }
  final List<CalendarDay> days;
  late final DateTime monday;
  late final List<CalendarCell> cells;
  late final double minValue, maxValue;
  double intensity(CalendarDay day) => minValue == maxValue
      ? .5
      : (day.value - minValue) / (maxValue - minValue);
}

final bookingCalendar = CalendarHeatmapData([
  for (var i = 0; i < 181; i++)
    CalendarDay(
      DateTime.utc(2025, 10, 1).add(Duration(days: i)),
      (30 +
              8 * math.sin(i * 2 * math.pi / 75) +
              ([DateTime.saturday, DateTime.sunday].contains(
                    DateTime.utc(2025, 10, 1).add(Duration(days: i)).weekday,
                  )
                  ? 18
                  : 0) +
              (i % 37 == 0 ? 22 : 0) +
              (i * 13 % 9))
          .roundToDouble(),
    ),
]);

String isoDay(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
