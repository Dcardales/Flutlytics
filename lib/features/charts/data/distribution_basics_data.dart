import 'dart:math' as math;

/// One immutable sample. [values] keeps its supplied order for strip plots.
class DistributionSample {
  DistributionSample({
    required this.label,
    required this.unit,
    required List<double> values,
  }) : values = List.unmodifiable(values) {
    if (values.isEmpty || values.any((v) => !v.isFinite)) {
      throw ArgumentError('A sample must contain finite observations.');
    }
  }

  final String label;
  final String unit;
  final List<double> values;
}

class HistogramBin {
  const HistogramBin({
    required this.lowerBound,
    required this.upperBound,
    required this.frequency,
  });
  final double lowerBound;
  final double upperBound;
  final int frequency;
  double get midpoint => (lowerBound + upperBound) / 2;
  String get label => '${_format(lowerBound)}-${_format(upperBound)}';
}

class DistributionPoint {
  const DistributionPoint(this.x, this.y, {this.detail});
  final double x;
  final double y;
  final String? detail;
}

class OgivePoint {
  const OgivePoint({
    required this.upperBound,
    required this.cumulativeFrequency,
    required this.cumulativePercentage,
  });
  final double upperBound;
  final int cumulativeFrequency;
  final double cumulativePercentage;
}

class StripPoint {
  const StripPoint({required this.value, required this.jitter});
  final double value;
  final double jitter;
}

final touristServiceSample = DistributionSample(
  label: 'Tiempo de atencion de clientes',
  unit: 'minutos',
  values: [
    6.2,
    7.1,
    7.4,
    8.0,
    8.1,
    8.4,
    8.8,
    9.0,
    9.2,
    9.4,
    9.6,
    9.8,
    10.0,
    10.1,
    10.3,
    10.5,
    10.7,
    10.8,
    11.0,
    11.1,
    11.3,
    11.5,
    11.7,
    11.8,
    12.0,
    12.2,
    12.4,
    12.6,
    12.8,
    13.0,
    13.2,
    13.5,
    13.8,
    14.0,
    14.4,
    14.8,
    15.2,
    15.7,
    16.1,
    16.8,
    17.5,
    18.3,
    19.4,
    21.0,
    23.5,
    27.0,
  ],
);

List<HistogramBin> buildHistogramBins(
  List<double> values, {
  required int binCount,
}) {
  if (values.isEmpty || values.any((v) => !v.isFinite)) {
    throw ArgumentError('Values must be non-empty and finite.');
  }
  if (binCount <= 0) throw ArgumentError.value(binCount, 'binCount');
  final minimum = values.reduce((a, b) => a < b ? a : b);
  final maximum = values.reduce((a, b) => a > b ? a : b);
  if (maximum == minimum) {
    return List.unmodifiable([
      HistogramBin(
        lowerBound: minimum - 0.5,
        upperBound: maximum + 0.5,
        frequency: values.length,
      ),
    ]);
  }
  final width = (maximum - minimum) / binCount;
  final lower = minimum;
  final bins = List.generate(
    binCount,
    (i) => HistogramBin(
      lowerBound: lower + width * i,
      upperBound: lower + width * (i + 1),
      frequency: 0,
    ),
  );
  final counts = List<int>.filled(binCount, 0);
  for (final value in values) {
    final index = value == maximum
        ? binCount - 1
        : ((value - minimum) / width).floor().clamp(0, binCount - 1);
    counts[index]++;
  }
  return List.unmodifiable([
    for (var i = 0; i < binCount; i++)
      HistogramBin(
        lowerBound: bins[i].lowerBound,
        upperBound: bins[i].upperBound,
        frequency: counts[i],
      ),
  ]);
}

List<DistributionPoint> buildFrequencyPolygon(List<HistogramBin> bins) =>
    List.unmodifiable([
      for (final b in bins)
        DistributionPoint(b.midpoint, b.frequency.toDouble(), detail: b.label),
    ]);

List<OgivePoint> buildOgive(List<HistogramBin> bins) {
  if (bins.isEmpty) return const [];
  final total = bins.fold<int>(0, (sum, b) => sum + b.frequency);
  var cumulative = 0;
  return List.unmodifiable([
    for (final bin in bins)
      () {
        cumulative += bin.frequency;
        return OgivePoint(
          upperBound: bin.upperBound,
          cumulativeFrequency: cumulative,
          cumulativePercentage: total == 0 ? 0 : cumulative * 100 / total,
        );
      }(),
  ]);
}

List<StripPoint> buildStripPoints(
  List<double> values, {
  double jitterRange = 0.12,
}) {
  if (values.any((v) => !v.isFinite) ||
      !jitterRange.isFinite ||
      jitterRange < 0) {
    throw ArgumentError('Values must be finite and jitterRange non-negative.');
  }
  const pattern = [-1.0, 0.0, 1.0, -0.5, 0.5];
  final multiplicity = <double, int>{};
  for (final value in values) {
    multiplicity.update(value, (count) => count + 1, ifAbsent: () => 1);
  }
  final occurrences = <double, int>{};
  return List.unmodifiable([
    for (var i = 0; i < values.length; i++)
      () {
        final value = values[i];
        final count = multiplicity[value]!;
        final rank = occurrences.update(
          value,
          (seen) => seen + 1,
          ifAbsent: () => 0,
        );
        final jitter = count == 1
            ? pattern[i % pattern.length] * jitterRange
            : -jitterRange + 2 * jitterRange * rank / (count - 1);
        return StripPoint(value: value, jitter: jitter);
      }(),
  ]);
}

List<DistributionPoint> buildGaussianKde(
  List<double> values, {
  required double bandwidth,
  int gridCount = 100,
  double? gridMin,
  double? gridMax,
}) {
  if (values.isEmpty || values.any((v) => !v.isFinite)) {
    throw ArgumentError('Values must be non-empty and finite.');
  }
  if (!bandwidth.isFinite || bandwidth <= 0) {
    throw ArgumentError.value(bandwidth, 'bandwidth');
  }
  if (gridCount < 2) throw ArgumentError.value(gridCount, 'gridCount');
  if ((gridMin == null) != (gridMax == null) ||
      (gridMin != null &&
          (!gridMin.isFinite || !gridMax!.isFinite || gridMax <= gridMin))) {
    throw ArgumentError('KDE grid bounds must be finite and increasing.');
  }
  final min = gridMin ?? values.reduce((a, b) => a < b ? a : b) - 3 * bandwidth;
  final max = gridMax ?? values.reduce((a, b) => a > b ? a : b) + 3 * bandwidth;
  final normalizer = values.length * bandwidth * math.sqrt(2 * math.pi);
  return List.unmodifiable([
    for (var i = 0; i < gridCount; i++)
      () {
        final x = min + (max - min) * i / (gridCount - 1);
        var sum = 0.0;
        for (final value in values) {
          final u = (x - value) / bandwidth;
          sum += math.exp(-0.5 * u * u);
        }
        return DistributionPoint(x, sum / normalizer);
      }(),
  ]);
}

String _format(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);
