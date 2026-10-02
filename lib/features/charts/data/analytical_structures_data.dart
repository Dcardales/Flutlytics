import 'dart:math' as math;

class LikertRow {
  LikertRow({
    required this.label,
    required this.stronglyNegative,
    required this.negative,
    required this.neutral,
    required this.positive,
    required this.stronglyPositive,
  }) {
    final values = [
      stronglyNegative,
      negative,
      neutral,
      positive,
      stronglyPositive,
    ];
    if (label.trim().isEmpty ||
        values.any((v) => !v.isFinite || v < 0) ||
        values.fold<double>(0, (sum, v) => sum + v) <= 0) {
      throw ArgumentError(
        'Likert counts must be finite, nonnegative and nonempty.',
      );
    }
  }
  final String label;
  final double stronglyNegative, negative, neutral, positive, stronglyPositive;
  double get total =>
      stronglyNegative + negative + neutral + positive + stronglyPositive;
}

class LikertSegment {
  const LikertSegment(
    this.dimension,
    this.response,
    this.percentage,
    this.start,
    this.end,
    this.side,
  );
  final String dimension, response, side;
  final double percentage, start, end;
  double get signedValue => end - start;
}

/// Neutral is split 50/50 across zero. All other percentages retain their
/// ordinal order, extending outward from the center on each side.
List<LikertSegment> divergingLikert(LikertRow row) {
  double pct(double count) => 100 * count / row.total;
  final sn = pct(row.stronglyNegative), n = pct(row.negative);
  final half = pct(row.neutral) / 2, p = pct(row.positive);
  final sp = pct(row.stronglyPositive);
  return List.unmodifiable([
    LikertSegment(row.label, 'Neutral', half, 0, -half, 'left'),
    LikertSegment(row.label, 'Insatisfecho', n, -half, -half - n, 'left'),
    LikertSegment(
      row.label,
      'Muy insatisfecho',
      sn,
      -half - n,
      -half - n - sn,
      'left',
    ),
    LikertSegment(row.label, 'Neutral', half, 0, half, 'right'),
    LikertSegment(row.label, 'Satisfecho', p, half, half + p, 'right'),
    LikertSegment(
      row.label,
      'Muy satisfecho',
      sp,
      half + p,
      half + p + sp,
      'right',
    ),
  ]);
}

final touristLikert = List<LikertRow>.unmodifiable([
  LikertRow(
    label: 'Seguridad',
    stronglyNegative: 8,
    negative: 13,
    neutral: 18,
    positive: 37,
    stronglyPositive: 24,
  ),
  LikertRow(
    label: 'Limpieza',
    stronglyNegative: 5,
    negative: 9,
    neutral: 16,
    positive: 42,
    stronglyPositive: 28,
  ),
  LikertRow(
    label: 'Atención',
    stronglyNegative: 3,
    negative: 8,
    neutral: 13,
    positive: 44,
    stronglyPositive: 32,
  ),
  LikertRow(
    label: 'Movilidad',
    stronglyNegative: 12,
    negative: 21,
    neutral: 22,
    positive: 30,
    stronglyPositive: 15,
  ),
  LikertRow(
    label: 'Precio',
    stronglyNegative: 16,
    negative: 24,
    neutral: 19,
    positive: 29,
    stronglyPositive: 12,
  ),
]);
final touristLikertSegments = List<LikertSegment>.unmodifiable([
  for (final row in touristLikert) ...divergingLikert(row),
]);

class MatrixVariable {
  MatrixVariable(this.id, this.label, this.unit) {
    if (id.trim().isEmpty || label.trim().isEmpty || unit.trim().isEmpty) {
      throw ArgumentError('Matrix variable metadata must be nonempty.');
    }
  }
  final String id, label, unit;
}

class MultivariateObservation {
  MultivariateObservation(this.label, Map<String, double> values)
    : values = Map.unmodifiable(values) {
    if (label.trim().isEmpty ||
        values.isEmpty ||
        values.values.any((v) => !v.isFinite)) {
      throw ArgumentError('Observation needs a label and finite values.');
    }
  }
  final String label;
  final Map<String, double> values;
  double value(MatrixVariable variable) => values[variable.id]!;
}

class MatrixScale {
  const MatrixScale(this.min, this.max);
  final double min, max;
}

class MatrixCell {
  const MatrixCell(this.row, this.column, this.x, this.y);
  final int row, column;
  final MatrixVariable x, y;
  bool get isDiagonal => row == column;
}

class ScatterplotMatrixData {
  ScatterplotMatrixData(
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
              o.values.keys.toSet().difference(ids).isNotEmpty ||
              ids.difference(o.values.keys.toSet()).isNotEmpty,
        )) {
      throw ArgumentError(
        'Matrix needs unique variables and identical finite columns.',
      );
    }
    scales = Map.unmodifiable({
      for (final variable in variables)
        variable.id: _scale(
          observations.map((o) => o.value(variable)).toList(),
        ),
    });
    cells = List.unmodifiable([
      for (var row = 0; row < variables.length; row++)
        for (var col = 0; col < variables.length; col++)
          MatrixCell(row, col, variables[col], variables[row]),
    ]);
  }
  final List<MatrixVariable> variables;
  final List<MultivariateObservation> observations;
  late final Map<String, MatrixScale> scales;
  late final List<MatrixCell> cells;
  static MatrixScale _scale(List<double> values) {
    final min = values.reduce(math.min), max = values.reduce(math.max);
    final pad = min == max ? 1.0 : (max - min) * .06;
    return MatrixScale(min - pad, max + pad);
  }
}

final touristMatrix = ScatterplotMatrixData(
  [
    MatrixVariable('visitors', 'Visitantes', 'miles'),
    MatrixVariable('spend', 'Gasto', 'mil COP'),
    MatrixVariable('nights', 'Duración', 'noches'),
    MatrixVariable('rating', 'Satisfacción', 'puntos / 10'),
  ],
  [
    for (var i = 0; i < 24; i++)
      MultivariateObservation('Destino ${i + 1}', {
        'visitors': 120 + (i * 37) % 340 + (i % 3) * 8.0,
        'spend': 260 + (i * 59) % 390 + (i % 4) * 13.0,
        'nights': 2.1 + ((i * 7) % 17) / 5,
        'rating': 6.2 + ((i * 11) % 23) / 10,
      }),
  ],
);

const ternaryHeight = 0.8660254037844386; // sqrt(3)/2.

class TernaryPoint {
  TernaryPoint(this.label, this.a, this.b, this.c) {
    final values = [a, b, c];
    if (label.trim().isEmpty ||
        values.any((v) => !v.isFinite || v < 0) ||
        (a + b + c - 100).abs() > .05) {
      throw ArgumentError('Ternary percentages must sum to 100 ± 0.05.');
    }
  }
  final String label;
  final double a, b, c;
  double get x => .5 * a / 100 + c / 100;
  double get y => ternaryHeight * a / 100;
}

final touristBudgetMix = List<TernaryPoint>.unmodifiable([
  TernaryPoint('Familiar', 50, 30, 20),
  TernaryPoint('Mochilero', 30, 40, 30),
  TernaryPoint('Negocios', 65, 20, 15),
  TernaryPoint('Gastronómico', 35, 50, 15),
  TernaryPoint('Ruta larga', 40, 25, 35),
  TernaryPoint('Escapada', 55, 25, 20),
  TernaryPoint('Costero', 45, 35, 20),
  TernaryPoint('Aventura', 25, 30, 45),
  TernaryPoint('Premium', 70, 20, 10),
  TernaryPoint('Urbano', 40, 40, 20),
  TernaryPoint('Cultural', 45, 40, 15),
  TernaryPoint('Regional', 30, 35, 35),
]);

class ForecastPoint {
  ForecastPoint({
    required this.period,
    required this.median,
    required this.lower50,
    required this.upper50,
    required this.lower80,
    required this.upper80,
    required this.lower95,
    required this.upper95,
  }) {
    final values = [
      lower95,
      lower80,
      lower50,
      median,
      upper50,
      upper80,
      upper95,
    ];
    if (period.trim().isEmpty ||
        values.any((v) => !v.isFinite) ||
        values.any((v) => v < 0 || v > 100) ||
        ![
          for (var i = 0; i < values.length - 1; i++)
            values[i] <= values[i + 1],
        ].every((b) => b)) {
      throw ArgumentError('Forecast intervals must be finite and nested.');
    }
  }
  final String period;
  final double median, lower50, upper50, lower80, upper80, lower95, upper95;
  double get span50 => upper50 - lower50;
  double get span80 => upper80 - lower80;
  double get span95 => upper95 - lower95;
}

List<ForecastPoint> orderForecastPoints(List<ForecastPoint> points) {
  if (points.isEmpty ||
      points.map((p) => p.period).toSet().length != points.length) {
    throw ArgumentError('Forecast periods must be unique and nonempty.');
  }
  return List.unmodifiable(
    [...points]..sort((a, b) => a.period.compareTo(b.period)),
  );
}

final hotelForecastFan = orderForecastPoints([
  for (var i = 0; i < 12; i++)
    ForecastPoint(
      period: (i + 1).toString().padLeft(2, '0'),
      median: 68 + i * .65 + (i % 3 - 1) * 1.2,
      lower50: 68 + i * .65 + (i % 3 - 1) * 1.2 - (2 + i * .35),
      upper50: 68 + i * .65 + (i % 3 - 1) * 1.2 + (2 + i * .35),
      lower80: 68 + i * .65 + (i % 3 - 1) * 1.2 - (4 + i * .65),
      upper80: 68 + i * .65 + (i % 3 - 1) * 1.2 + (4 + i * .65),
      lower95: 68 + i * .65 + (i % 3 - 1) * 1.2 - (6 + i * .85),
      upper95: 68 + i * .65 + (i % 3 - 1) * 1.2 + (6 + i * .85),
    ),
]);

class PredictionObservation {
  PredictionObservation(this.probability, this.outcome) {
    if (!probability.isFinite ||
        probability < 0 ||
        probability > 1 ||
        (outcome != 0 && outcome != 1)) {
      throw ArgumentError(
        'Prediction must have probability 0–1 and binary outcome.',
      );
    }
  }
  final double probability;
  final int outcome;
}

class CalibrationBin {
  const CalibrationBin(
    this.index,
    this.lower,
    this.upper,
    this.avgPredicted,
    this.observedRate,
    this.count,
  );
  final int index, count;
  final double lower, upper, avgPredicted, observedRate;
}

/// Half-open bins; the final bin also includes probability 1.0.
List<CalibrationBin> buildCalibrationBins(
  List<PredictionObservation> observations, {
  int binCount = 5,
}) {
  if (binCount <= 0 || observations.isEmpty) {
    throw ArgumentError(
      'Nonempty predictions and positive bin count required.',
    );
  }
  final counts = List<int>.filled(binCount, 0);
  final probabilities = List<double>.filled(binCount, 0);
  final outcomes = List<int>.filled(binCount, 0);
  for (final observation in observations) {
    final i = math.min(
      (observation.probability * binCount).floor(),
      binCount - 1,
    );
    counts[i]++;
    probabilities[i] += observation.probability;
    outcomes[i] += observation.outcome;
  }
  return List.unmodifiable([
    for (var i = 0; i < binCount; i++)
      if (counts[i] > 0)
        CalibrationBin(
          i,
          i / binCount,
          (i + 1) / binCount,
          probabilities[i] / counts[i],
          outcomes[i] / counts[i],
          counts[i],
        ),
  ]);
}

final cancellationPredictions = List<PredictionObservation>.unmodifiable([
  for (var i = 0; i < 100; i++)
    PredictionObservation(
      i / 99,
      ((i * 7) % 20) < [2, 5, 9, 13, 17][i ~/ 20] ? 1 : 0,
    ),
]);
final cancellationCalibration = buildCalibrationBins(cancellationPredictions);
