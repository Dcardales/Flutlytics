import 'dart:math' as math;

class ScatterObservation {
  const ScatterObservation({
    required this.label,
    required this.nights,
    required this.spendThousands,
  });
  final String label;
  final double nights;
  final double spendThousands;
}

class BubbleObservation {
  const BubbleObservation({
    required this.label,
    required this.visitorsThousands,
    required this.spendPerVisitorThousands,
    required this.establishments,
  });
  final String label;
  final double visitorsThousands;
  final double spendPerVisitorThousands;
  final double establishments;
}

List<double> scaleBubbleRadii(
  List<double> magnitudes, {
  double minRadius = 7,
  double maxRadius = 30,
}) {
  if (!minRadius.isFinite ||
      minRadius <= 0 ||
      !maxRadius.isFinite ||
      maxRadius < minRadius ||
      magnitudes.any((value) => !value.isFinite || value < 0)) {
    throw ArgumentError('Bubble magnitudes and radius bounds must be valid.');
  }
  if (magnitudes.isEmpty) return const [];
  final minMagnitude = magnitudes.reduce(math.min);
  final maxMagnitude = magnitudes.reduce(math.max);
  if (maxMagnitude == minMagnitude) {
    return List<double>.unmodifiable(List.filled(magnitudes.length, minRadius));
  }
  final minArea = minRadius * minRadius;
  final maxArea = maxRadius * maxRadius;
  return List<double>.unmodifiable([
    for (final magnitude in magnitudes)
      math.sqrt(
        minArea +
            (maxArea - minArea) *
                ((magnitude - minMagnitude) / (maxMagnitude - minMagnitude)),
      ),
  ]);
}

class ConnectedScatterPoint {
  ConnectedScatterPoint({
    required this.order,
    required this.label,
    required this.x,
    required this.y,
  }) {
    if (label.trim().isEmpty || !x.isFinite || !y.isFinite) {
      throw ArgumentError(
        'Connected scatter points need labels and finite values.',
      );
    }
  }
  final int order;
  final String label;
  final double x;
  final double y;
}

List<ConnectedScatterPoint> orderConnectedScatterPoints(
  List<ConnectedScatterPoint> points,
) {
  if (points.map((point) => point.order).toSet().length != points.length) {
    throw ArgumentError('Connected scatter order values must be unique.');
  }
  final ordered = List<ConnectedScatterPoint>.of(points)
    ..sort((a, b) => a.order.compareTo(b.order));
  return List.unmodifiable(ordered);
}

class IntervalEstimate {
  IntervalEstimate({
    required this.label,
    required this.estimate,
    required this.lower,
    required this.upper,
    required this.sampleSize,
    required this.sampleStandardDeviation,
    required this.standardError,
  }) {
    if (label.trim().isEmpty ||
        ![estimate, lower, upper].every((value) => value.isFinite) ||
        !sampleStandardDeviation.isFinite ||
        sampleStandardDeviation < 0 ||
        !standardError.isFinite ||
        standardError < 0 ||
        lower > estimate ||
        estimate > upper ||
        sampleSize < 2) {
      throw ArgumentError('Interval estimates must be finite and ordered.');
    }
  }
  final String label;
  final double estimate;
  final double lower;
  final double upper;
  final int sampleSize;
  final double sampleStandardDeviation;
  final double standardError;
}

IntervalEstimate calculateMeanConfidenceInterval(
  String label,
  List<double> sample,
) {
  if (label.trim().isEmpty ||
      sample.length < 2 ||
      sample.any((value) => !value.isFinite)) {
    throw ArgumentError('A finite sample of at least two values is required.');
  }
  final mean = sample.reduce((a, b) => a + b) / sample.length;
  final squaredDeviations = sample.fold<double>(
    0,
    (sum, value) => sum + math.pow(value - mean, 2),
  );
  final sampleStandardDeviation = math.sqrt(
    squaredDeviations / (sample.length - 1),
  );
  final standardError = sampleStandardDeviation / math.sqrt(sample.length);
  final margin = 1.96 * standardError;
  return IntervalEstimate(
    label: label,
    estimate: mean,
    lower: mean - margin,
    upper: mean + margin,
    sampleSize: sample.length,
    sampleStandardDeviation: sampleStandardDeviation,
    standardError: standardError,
  );
}

List<IntervalEstimate> buildMeanConfidenceIntervals(
  Map<String, List<double>> samplesByLabel,
) {
  if (samplesByLabel.isEmpty ||
      samplesByLabel.keys.any((label) => label.trim().isEmpty)) {
    throw ArgumentError('Interval groups need unique, non-empty labels.');
  }
  return List.unmodifiable([
    for (final entry in samplesByLabel.entries)
      calculateMeanConfidenceInterval(entry.key, entry.value),
  ]);
}

class RangeValue {
  RangeValue({required this.label, required this.low, required this.high}) {
    if (label.trim().isEmpty || !low.isFinite || !high.isFinite || low > high) {
      throw ArgumentError('Range values need a label and finite low <= high.');
    }
  }
  final String label;
  final double low;
  final double high;
  double get span => high - low;
}

final scatterObservations = List<ScatterObservation>.unmodifiable([
  for (var i = 0; i < 32; i++)
    ScatterObservation(
      label: 'Estadia ${i + 1}',
      nights: 1 + (i * 7 % 13) / 2,
      spendThousands:
          380 +
          (1 + (i * 7 % 13) / 2) * 465 +
          ((i * 37) % 181 - 90) +
          (i == 27 ? 460 : 0),
    ),
]);

final bubbleDestinations = List<BubbleObservation>.unmodifiable([
  const BubbleObservation(
    label: 'Bogota',
    visitorsThousands: 940,
    spendPerVisitorThousands: 510,
    establishments: 1520,
  ),
  const BubbleObservation(
    label: 'Cartagena',
    visitorsThousands: 730,
    spendPerVisitorThousands: 890,
    establishments: 840,
  ),
  const BubbleObservation(
    label: 'Medellin',
    visitorsThousands: 810,
    spendPerVisitorThousands: 620,
    establishments: 1260,
  ),
  const BubbleObservation(
    label: 'Santa Marta',
    visitorsThousands: 490,
    spendPerVisitorThousands: 710,
    establishments: 510,
  ),
  const BubbleObservation(
    label: 'Cali',
    visitorsThousands: 560,
    spendPerVisitorThousands: 470,
    establishments: 690,
  ),
  const BubbleObservation(
    label: 'San Andres',
    visitorsThousands: 310,
    spendPerVisitorThousands: 1280,
    establishments: 190,
  ),
  const BubbleObservation(
    label: 'Pereira',
    visitorsThousands: 280,
    spendPerVisitorThousands: 540,
    establishments: 360,
  ),
  const BubbleObservation(
    label: 'Bucaramanga',
    visitorsThousands: 250,
    spendPerVisitorThousands: 490,
    establishments: 330,
  ),
]);

final connectedScatterPoints = orderConnectedScatterPoints([
  ConnectedScatterPoint(order: 8, label: 'Sep', x: 73, y: 385),
  ConnectedScatterPoint(order: 1, label: 'Feb', x: 58, y: 315),
  ConnectedScatterPoint(order: 11, label: 'Dec', x: 81, y: 430),
  ConnectedScatterPoint(order: 4, label: 'May', x: 67, y: 350),
  ConnectedScatterPoint(order: 0, label: 'Ene', x: 55, y: 300),
  ConnectedScatterPoint(order: 7, label: 'Ago', x: 78, y: 410),
  ConnectedScatterPoint(order: 2, label: 'Mar', x: 63, y: 338),
  ConnectedScatterPoint(order: 10, label: 'Nov', x: 76, y: 395),
  ConnectedScatterPoint(order: 5, label: 'Jun', x: 72, y: 372),
  ConnectedScatterPoint(order: 3, label: 'Abr', x: 70, y: 360),
  ConnectedScatterPoint(order: 9, label: 'Oct', x: 69, y: 365),
  ConnectedScatterPoint(order: 6, label: 'Jul', x: 82, y: 445),
]);

final waitingSamples = <String, List<double>>{
  'Recepcion': [8.1, 7.6, 9.2, 8.7, 7.9, 8.4, 9.0, 8.2, 7.8, 8.6],
  'Restaurante': [14.2, 12.8, 16.1, 13.7, 15.4, 14.8, 17.0, 13.2, 15.1, 14.5],
  'Transporte': [6.8, 8.2, 7.5, 9.1, 6.4, 7.8, 8.6, 7.1, 9.4, 7.6],
  'Reservas': [4.2, 5.1, 4.8, 6.0, 4.5, 5.6, 4.9, 5.3, 6.2, 4.7],
  'Actividades': [11.0, 9.8, 12.4, 10.6, 13.1, 11.8, 10.2, 12.0, 9.5, 11.4],
};
final errorBarEstimates = buildMeanConfidenceIntervals(waitingSamples);

final dailyTemperatureRanges = List<RangeValue>.unmodifiable([
  RangeValue(label: 'Lun', low: 17.2, high: 26.8),
  RangeValue(label: 'Mar', low: 16.8, high: 27.5),
  RangeValue(label: 'Mie', low: 17.6, high: 28.1),
  RangeValue(label: 'Jue', low: 18.0, high: 27.2),
  RangeValue(label: 'Vie', low: 17.1, high: 28.6),
  RangeValue(label: 'Sab', low: 16.5, high: 25.9),
  RangeValue(label: 'Dom', low: 16.9, high: 26.4),
]);

List<double> get bubbleDestinationRadii => scaleBubbleRadii([
  for (final destination in bubbleDestinations) destination.establishments,
]);
