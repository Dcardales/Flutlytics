import 'dart:math' as math;

class BarLinePoint {
  const BarLinePoint({
    required this.period,
    required this.label,
    required this.barValue,
    required this.lineValue,
  });
  final int period;
  final String label;
  final double barValue;
  final double lineValue;
}

class AreaLinePoint {
  const AreaLinePoint({
    required this.period,
    required this.label,
    required this.areaValue,
    required this.lineValue,
  });
  final int period;
  final String label;
  final double areaValue;
  final double lineValue;
}

class SmallMultiplePanel<T> {
  const SmallMultiplePanel({
    required this.id,
    required this.label,
    required this.points,
  });
  final String id;
  final String label;
  final List<T> points;
}

class SmallLinePoint {
  const SmallLinePoint(this.period, this.label, this.value);
  final int period;
  final String label;
  final double value;
}

class SmallBarPoint {
  const SmallBarPoint(this.category, this.value);
  final String category;
  final double value;
}

class SparklinePoint {
  const SparklinePoint(this.period, this.value);
  final int period;
  final double value;
}

class SparklineKpi {
  const SparklineKpi({
    required this.label,
    required this.currentValue,
    required this.unit,
    required this.points,
  });
  final String label;
  final double currentValue;
  final String unit;
  final List<SparklinePoint> points;
}

const barLineBarUnit = 'millones COP';
const barLineUnit = '% de margen';
const barLinePeriods = <BarLinePoint>[
  BarLinePoint(period: 1, label: 'Ene', barValue: 32, lineValue: 18),
  BarLinePoint(period: 2, label: 'Feb', barValue: 37, lineValue: 21),
  BarLinePoint(period: 3, label: 'Mar', barValue: 35, lineValue: 19),
  BarLinePoint(period: 4, label: 'Abr', barValue: 44, lineValue: 23),
  BarLinePoint(period: 5, label: 'May', barValue: 49, lineValue: 25),
  BarLinePoint(period: 6, label: 'Jun', barValue: 46, lineValue: 24),
];

const areaLineUnit = 'kWh por día';
const areaLinePeriods = <AreaLinePoint>[
  AreaLinePoint(period: 1, label: 'Lun', areaValue: 410, lineValue: 450),
  AreaLinePoint(period: 2, label: 'Mar', areaValue: 462, lineValue: 450),
  AreaLinePoint(period: 3, label: 'Mié', areaValue: 448, lineValue: 450),
  AreaLinePoint(period: 4, label: 'Jue', areaValue: 520, lineValue: 470),
  AreaLinePoint(period: 5, label: 'Vie', areaValue: 495, lineValue: 470),
  AreaLinePoint(period: 6, label: 'Sáb', areaValue: 575, lineValue: 500),
];

const smallMultiplesLinePanels = <SmallMultiplePanel<SmallLinePoint>>[
  SmallMultiplePanel(
    id: 'bogota',
    label: 'Bogotá',
    points: [
      SmallLinePoint(1, 'Ene', 62),
      SmallLinePoint(2, 'Feb', 66),
      SmallLinePoint(3, 'Mar', 64),
      SmallLinePoint(4, 'Abr', 69),
      SmallLinePoint(5, 'May', 72),
      SmallLinePoint(6, 'Jun', 74),
    ],
  ),
  SmallMultiplePanel(
    id: 'medellin',
    label: 'Medellín',
    points: [
      SmallLinePoint(1, 'Ene', 58),
      SmallLinePoint(2, 'Feb', 61),
      SmallLinePoint(3, 'Mar', 65),
      SmallLinePoint(4, 'Abr', 67),
      SmallLinePoint(5, 'May', 70),
      SmallLinePoint(6, 'Jun', 71),
    ],
  ),
  SmallMultiplePanel(
    id: 'cartagena',
    label: 'Cartagena',
    points: [
      SmallLinePoint(1, 'Ene', 78),
      SmallLinePoint(2, 'Feb', 75),
      SmallLinePoint(3, 'Mar', 71),
      SmallLinePoint(4, 'Abr', 73),
      SmallLinePoint(5, 'May', 77),
      SmallLinePoint(6, 'Jun', 81),
    ],
  ),
  SmallMultiplePanel(
    id: 'cali',
    label: 'Cali',
    points: [
      SmallLinePoint(1, 'Ene', 53),
      SmallLinePoint(2, 'Feb', 57),
      SmallLinePoint(3, 'Mar', 59),
      SmallLinePoint(4, 'Abr', 63),
      SmallLinePoint(5, 'May', 66),
      SmallLinePoint(6, 'Jun', 68),
    ],
  ),
];

const smallMultiplesBarUnit = 'millones COP';
const smallMultiplesCategories = <String>[
  'Hospedaje',
  'Gastronomía',
  'Transporte',
];
const smallMultiplesBarPanels = <SmallMultiplePanel<SmallBarPoint>>[
  SmallMultiplePanel(
    id: 'bogota',
    label: 'Bogotá',
    points: [
      SmallBarPoint('Hospedaje', 82),
      SmallBarPoint('Gastronomía', 55),
      SmallBarPoint('Transporte', 31),
    ],
  ),
  SmallMultiplePanel(
    id: 'medellin',
    label: 'Medellín',
    points: [
      SmallBarPoint('Hospedaje', 64),
      SmallBarPoint('Gastronomía', 47),
      SmallBarPoint('Transporte', 28),
    ],
  ),
  SmallMultiplePanel(
    id: 'cartagena',
    label: 'Cartagena',
    points: [
      SmallBarPoint('Hospedaje', 95),
      SmallBarPoint('Gastronomía', 68),
      SmallBarPoint('Transporte', 42),
    ],
  ),
  SmallMultiplePanel(
    id: 'cali',
    label: 'Cali',
    points: [
      SmallBarPoint('Hospedaje', 51),
      SmallBarPoint('Gastronomía', 38),
      SmallBarPoint('Transporte', 24),
    ],
  ),
];

double maxAcrossPanels<T>(
  Iterable<SmallMultiplePanel<T>> panels,
  double Function(T) valueOf,
) {
  var maximum = double.negativeInfinity;
  var found = false;
  for (final panel in panels) {
    for (final point in panel.points) {
      final value = valueOf(point);
      if (!value.isFinite) throw ArgumentError('Panel values must be finite.');
      maximum = math.max(maximum, value);
      found = true;
    }
  }
  if (!found) throw ArgumentError('At least one panel value is required.');
  return maximum;
}

const sparklineKpis = <SparklineKpi>[
  SparklineKpi(
    label: 'Reservas',
    currentValue: 48,
    unit: 'reservas',
    points: [
      SparklinePoint(1, 31),
      SparklinePoint(2, 34),
      SparklinePoint(3, 33),
      SparklinePoint(4, 39),
      SparklinePoint(5, 42),
      SparklinePoint(6, 40),
      SparklinePoint(7, 45),
      SparklinePoint(8, 48),
    ],
  ),
  SparklineKpi(
    label: 'Ingresos',
    currentValue: 12.4,
    unit: 'M COP',
    points: [
      SparklinePoint(1, 9.2),
      SparklinePoint(2, 9.8),
      SparklinePoint(3, 9.5),
      SparklinePoint(4, 10.7),
      SparklinePoint(5, 10.3),
      SparklinePoint(6, 11.5),
      SparklinePoint(7, 11.9),
      SparklinePoint(8, 12.4),
    ],
  ),
  SparklineKpi(
    label: 'Ocupación',
    currentValue: 81,
    unit: '%',
    points: [
      SparklinePoint(1, 72),
      SparklinePoint(2, 74),
      SparklinePoint(3, 73),
      SparklinePoint(4, 77),
      SparklinePoint(5, 76),
      SparklinePoint(6, 79),
      SparklinePoint(7, 80),
      SparklinePoint(8, 81),
    ],
  ),
  SparklineKpi(
    label: 'Cancelaciones',
    currentValue: 6,
    unit: 'cancelaciones',
    points: [
      SparklinePoint(1, 9),
      SparklinePoint(2, 8),
      SparklinePoint(3, 10),
      SparklinePoint(4, 7),
      SparklinePoint(5, 8),
      SparklinePoint(6, 6),
      SparklinePoint(7, 7),
      SparklinePoint(8, 6),
    ],
  ),
];

void validateBatchFiveData() {
  _validateOrdered(
    barLinePeriods.map((p) => (p.period, p.label, [p.barValue, p.lineValue])),
  );
  if (barLineBarUnit.isEmpty ||
      barLineUnit.isEmpty ||
      barLinePeriods.any(
        (p) => p.barValue < 0 || p.lineValue < 0 || p.lineValue > 100,
      )) {
    throw ArgumentError(
      'bar-line requires units and a percentage in [0, 100].',
    );
  }
  _validateOrdered(
    areaLinePeriods.map((p) => (p.period, p.label, [p.areaValue, p.lineValue])),
  );
  final lineIds = <String>{};
  final lineDomain = smallMultiplesLinePanels.first.points
      .map((p) => p.period)
      .toList();
  for (final panel in smallMultiplesLinePanels) {
    if (panel.id.trim().isEmpty ||
        panel.label.trim().isEmpty ||
        !lineIds.add(panel.id) ||
        panel.points.isEmpty ||
        panel.points.any(
          (p) =>
              !p.value.isFinite ||
              p.value < 0 ||
              p.value > 100 ||
              p.label.trim().isEmpty,
        )) {
      throw ArgumentError(
        'Small multiple line panels require unique IDs, labels and finite points.',
      );
    }
    if (panel.points.map((p) => p.period).toList().toString() !=
        lineDomain.toString()) {
      throw ArgumentError(
        'Small multiple line panels must share an ordered domain.',
      );
    }
    if (panel.points.map((p) => p.label).toList().toString() !=
        smallMultiplesLinePanels.first.points
            .map((p) => p.label)
            .toList()
            .toString()) {
      throw ArgumentError('Small multiple line panels must share labels.');
    }
    _validateOrdered(panel.points.map((p) => (p.period, p.label, [p.value])));
  }
  _validatePanels(
    smallMultiplesBarPanels,
    (p) => p.category,
    (p) => p.value,
    smallMultiplesCategories,
  );
  for (final kpi in sparklineKpis) {
    if (kpi.label.trim().isEmpty ||
        kpi.unit.trim().isEmpty ||
        kpi.points.length < 2 ||
        kpi.currentValue != kpi.points.last.value) {
      throw ArgumentError('Invalid sparkline KPI.');
    }
    _validateOrdered(
      kpi.points.map((p) => (p.period, '${p.period}', [p.value])),
    );
  }
}

void _validatePanels<T>(
  Iterable<SmallMultiplePanel<T>> panels,
  String Function(T) categoryOf,
  double Function(T) valueOf,
  List<String> expectedCategories,
) {
  final ids = <String>{};
  for (final panel in panels) {
    if (panel.id.trim().isEmpty ||
        panel.label.trim().isEmpty ||
        !ids.add(panel.id) ||
        panel.points.isEmpty ||
        panel.points.map(categoryOf).toList().toString() !=
            expectedCategories.toString()) {
      throw ArgumentError(
        'Small multiple bar panels need unique labels and shared categories.',
      );
    }
    if (panel.points.any((p) => !valueOf(p).isFinite || valueOf(p) < 0)) {
      throw ArgumentError('Panel values must be finite and non-negative.');
    }
  }
}

void _validateOrdered(Iterable<(int, String, List<double>)> rows) {
  var previous = 0;
  for (final (period, label, values) in rows) {
    if (period <= previous ||
        label.trim().isEmpty ||
        values.any((v) => !v.isFinite)) {
      throw ArgumentError(
        'Periods must be unique, ordered; labels and values must be valid.',
      );
    }
    previous = period;
  }
}
