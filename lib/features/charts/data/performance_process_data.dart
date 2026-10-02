import 'dart:math' as math;

class FunnelStage {
  FunnelStage(this.id, this.label, this.value) {
    if (id.trim().isEmpty ||
        label.trim().isEmpty ||
        !value.isFinite ||
        value < 0) {
      throw ArgumentError(
        'Funnel stage needs an ID, label and finite nonnegative value.',
      );
    }
  }
  final String id, label;
  final double value;
}

class FunnelStep {
  const FunnelStep(
    this.stage,
    this.index,
    this.conversionFromPrevious,
    this.conversionFromStart,
    this.dropOff,
  );
  final FunnelStage stage;
  final int index;
  final double? conversionFromPrevious, conversionFromStart, dropOff;
}

class FunnelData {
  FunnelData(List<FunnelStage> stages) : stages = List.unmodifiable(stages) {
    if (stages.length < 2 ||
        stages.map((s) => s.id).toSet().length != stages.length) {
      throw ArgumentError(
        'Funnel needs at least two uniquely identified stages.',
      );
    }
    steps = List.unmodifiable([
      for (var i = 0; i < stages.length; i++)
        FunnelStep(
          stages[i],
          i,
          i == 0 ? null : _ratio(stages[i].value, stages[i - 1].value),
          _ratio(stages[i].value, stages.first.value),
          i == 0 ? null : stages[i - 1].value - stages[i].value,
        ),
    ]);
  }
  final List<FunnelStage> stages;
  late final List<FunnelStep> steps;
  static double? _ratio(double numerator, double denominator) =>
      denominator == 0 ? null : numerator / denominator;
  double get maxValue => stages.map((s) => s.value).reduce(math.max);
}

final bookingFunnel = FunnelData([
  FunnelStage('visits', 'Visitas al sitio', 10000),
  FunnelStage('searches', 'Búsquedas', 6200),
  FunnelStage('selections', 'Selecciones', 3900),
  FunnelStage('checkout', 'Inicio de reserva', 2100),
  FunnelStage('confirmed', 'Confirmadas', 1450),
]);

class PopulationPyramidRow {
  PopulationPyramidRow(this.category, this.leftValue, this.rightValue) {
    if (category.trim().isEmpty ||
        !leftValue.isFinite ||
        !rightValue.isFinite ||
        leftValue < 0 ||
        rightValue < 0) {
      throw ArgumentError('Population values must be finite and nonnegative.');
    }
  }
  final String category;
  final double leftValue, rightValue;
  double get leftCoordinate => -leftValue;
  double get rightCoordinate => rightValue;
}

class PopulationPyramidData {
  PopulationPyramidData(List<PopulationPyramidRow> rows)
    : rows = List.unmodifiable(rows) {
    if (rows.isEmpty ||
        rows.map((r) => r.category).toSet().length != rows.length) {
      throw ArgumentError('Population pyramid needs unique age categories.');
    }
    maxMagnitude = rows
        .expand((r) => [r.leftValue, r.rightValue])
        .reduce(math.max);
  }
  final List<PopulationPyramidRow> rows;
  late final double maxMagnitude;
  double get minAxis => -maxMagnitude;
  double get maxAxis => maxMagnitude;
}

final touristAgePyramid = PopulationPyramidData([
  PopulationPyramidRow('18–24', 135, 95),
  PopulationPyramidRow('25–34', 245, 210),
  PopulationPyramidRow('35–44', 220, 185),
  PopulationPyramidRow('45–54', 175, 150),
  PopulationPyramidRow('55–64', 120, 105),
  PopulationPyramidRow('65+', 75, 85),
]);

class GaugeMetric {
  GaugeMetric(this.label, this.value, this.min, this.max, {this.target}) {
    if (label.trim().isEmpty ||
        ![value, min, max, ?target].every((v) => v.isFinite) ||
        min >= max ||
        value < min ||
        value > max ||
        (target != null && (target! < min || target! > max))) {
      throw ArgumentError(
        'Gauge needs finite value and target within a valid range.',
      );
    }
  }
  final String label;
  final double value, min, max;
  final double? target;
  double normalize(double v) {
    if (!v.isFinite || v < min || v > max) {
      throw ArgumentError.value(v, 'v', 'Value outside gauge range.');
    }
    return (v - min) / (max - min);
  }

  double get normalizedValue => normalize(value);
  double? get normalizedTarget => target == null ? null : normalize(target!);
}

final hotelOccupancyGauge = GaugeMetric(
  'Ocupación hotelera',
  78,
  0,
  100,
  target: 80,
);

class BulletRange {
  BulletRange(this.end, this.label) {
    if (!end.isFinite || label.trim().isEmpty) {
      throw ArgumentError('Bullet range needs a finite end and label.');
    }
  }
  final double end;
  final String label;
}

class BulletBand {
  const BulletBand(this.start, this.end, this.label);
  final double start, end;
  final String label;
}

class BulletMetric {
  BulletMetric(
    this.label,
    this.value,
    this.target,
    this.min,
    this.max,
    List<BulletRange> ranges,
  ) : ranges = List.unmodifiable(ranges) {
    if (label.trim().isEmpty ||
        ![value, target, min, max].every((v) => v.isFinite) ||
        min >= max ||
        value < min ||
        value > max ||
        target < min ||
        target > max ||
        ranges.isEmpty ||
        ranges.last.end > max) {
      throw ArgumentError(
        'Bullet metric needs finite values inside a valid range.',
      );
    }
    var previous = min;
    for (final range in ranges) {
      if (range.end <= previous) {
        throw ArgumentError('Bullet ranges must increase.');
      }
      previous = range.end;
    }
    bands = List.unmodifiable([
      for (var i = 0; i < ranges.length; i++)
        BulletBand(
          i == 0 ? min : ranges[i - 1].end,
          ranges[i].end,
          ranges[i].label,
        ),
    ]);
  }
  final String label;
  final double value, target, min, max;
  final List<BulletRange> ranges;
  late final List<BulletBand> bands;
  BulletBand? get currentBand {
    for (final band in bands) {
      if (value <= band.end) return band;
    }
    return null;
  }
}

final monthlyRevenueBullet = BulletMetric(
  'Ingresos mensuales (M COP)',
  82,
  90,
  0,
  100,
  [
    BulletRange(60, 'Insuficiente'),
    BulletRange(80, 'Aceptable'),
    BulletRange(100, 'Bueno'),
  ],
);

class TimelineEvent {
  TimelineEvent(
    this.id,
    this.date,
    this.title,
    this.description,
    this.category,
  ) {
    if (id.trim().isEmpty ||
        title.trim().isEmpty ||
        description.trim().isEmpty ||
        category.trim().isEmpty) {
      throw ArgumentError('Timeline event needs metadata and a date.');
    }
  }
  final String id, title, description, category;
  final DateTime date;
}

class TimelinePoint {
  const TimelinePoint(this.event, this.index, this.dayOffset, this.lane);
  final TimelineEvent event;
  final int index;
  final double dayOffset, lane;
}

class TimelineData {
  TimelineData(List<TimelineEvent> events) {
    if (events.isEmpty ||
        events.map((e) => e.id).toSet().length != events.length) {
      throw ArgumentError('Timeline needs uniquely identified events.');
    }
    final ordered = [...events]
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.id.compareTo(b.id);
      });
    this.events = List.unmodifiable(ordered);
    final first = ordered.first.date;
    points = List.unmodifiable([
      for (var i = 0; i < ordered.length; i++)
        TimelinePoint(
          ordered[i],
          i,
          ordered[i].date.difference(first).inMinutes / 1440,
          i.isEven ? 1 : -1,
        ),
    ]);
  }
  late final List<TimelineEvent> events;
  late final List<TimelinePoint> points;
  double get maxDay => points.last.dayOffset;
}

final flutterMilestones = TimelineData([
  TimelineEvent(
    'delivery',
    DateTime.utc(2026, 10, 22),
    'Entrega',
    'Entrega funcional del proyecto educativo.',
    'Entrega',
  ),
  TimelineEvent(
    'start',
    DateTime.utc(2026, 1, 12),
    'Inicio',
    'Definición del problema y alcance.',
    'Planificación',
  ),
  TimelineEvent(
    'catalog',
    DateTime.utc(2026, 5, 18),
    'Catálogo',
    'Consolidación de conceptos de gráficos.',
    'Contenido',
  ),
  TimelineEvent(
    'design',
    DateTime.utc(2026, 2, 16),
    'Diseño',
    'Aprobación de la propuesta visual.',
    'Diseño',
  ),
  TimelineEvent(
    'tests',
    DateTime.utc(2026, 9, 25),
    'Pruebas',
    'Validación de demos y navegación.',
    'Validación',
  ),
  TimelineEvent(
    'prototype',
    DateTime.utc(2026, 7, 8),
    'Prototipo',
    'Primera versión navegable.',
    'Desarrollo',
  ),
]);

String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
