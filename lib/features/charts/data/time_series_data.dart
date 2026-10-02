import 'sample_datasets.dart';

/// A single observation on an ordered numeric time domain.
class SingleTimeSeriesPoint {
  const SingleTimeSeriesPoint({
    required this.period,
    required this.label,
    required this.value,
  });

  final int period;
  final String label;
  final double value;
}

/// A normalized long-form temporal observation, suitable for grouped renderers.
class MultiTimeSeriesPoint extends SingleTimeSeriesPoint {
  const MultiTimeSeriesPoint({
    required this.series,
    required super.period,
    required super.label,
    required super.value,
  });

  final String series;
}

class StackedAreaPoint extends MultiTimeSeriesPoint {
  const StackedAreaPoint({
    required super.series,
    required super.period,
    required super.label,
    required super.value,
    required this.lower,
    required this.upper,
    required this.total,
  });

  final double lower;
  final double upper;
  final double total;
}

List<SingleTimeSeriesPoint> singleTimeSeriesFor(String id) {
  final rows = ChartDatasetRegistry.forConcept(id)!.rows;
  final points = [
    for (final row in rows)
      SingleTimeSeriesPoint(
        period: row['period']! as int,
        label: row['label']! as String,
        value: (row['value']! as num).toDouble(),
      ),
  ];
  _validateSingle(points);
  return List.unmodifiable(
    points..sort((a, b) => a.period.compareTo(b.period)),
  );
}

List<MultiTimeSeriesPoint> multiTimeSeriesFor(String id) {
  final rows = ChartDatasetRegistry.forConcept(id)!.rows;
  final points = [
    for (final row in rows)
      MultiTimeSeriesPoint(
        series: row['series']! as String,
        period: row['period']! as int,
        label: row['label']! as String,
        value: (row['value']! as num).toDouble(),
      ),
  ];
  _validateMulti(points);
  points.sort((a, b) {
    final bySeries = a.series.compareTo(b.series);
    return bySeries != 0 ? bySeries : a.period.compareTo(b.period);
  });
  return List.unmodifiable(points);
}

/// Builds absolute cumulative bounds. Negative values are rejected because
/// this educational stacked-area transformation models non-negative totals.
List<StackedAreaPoint> stackedAreaFor(String id) {
  final source = multiTimeSeriesFor(id);
  final periods = source.map((point) => point.period).toSet().toList()..sort();
  final seriesNames = source.map((point) => point.series).toSet().toList()
    ..sort();
  final points = <StackedAreaPoint>[];
  for (final period in periods) {
    final members = source.where((point) => point.period == period).toList();
    var cumulative = 0.0;
    for (final series in seriesNames) {
      final point = members.singleWhere((item) => item.series == series);
      final lower = cumulative;
      cumulative += point.value;
      points.add(
        StackedAreaPoint(
          series: series,
          period: period,
          label: point.label,
          value: point.value,
          lower: lower,
          upper: cumulative,
          total: members.fold<double>(0, (sum, item) => sum + item.value),
        ),
      );
    }
  }
  return List.unmodifiable(points);
}

/// Inserts duplicate-X vertices for a step-after path. Each value stays
/// current through the interval and changes at the next event period.
List<SingleTimeSeriesPoint> stepAfter(List<SingleTimeSeriesPoint> input) {
  final ordered = input.toList()..sort((a, b) => a.period.compareTo(b.period));
  _validateSingle(ordered);
  final result = <SingleTimeSeriesPoint>[];
  for (var i = 0; i < ordered.length; i++) {
    final current = ordered[i];
    result.add(current);
    if (i + 1 < ordered.length) {
      final next = ordered[i + 1];
      result.add(
        SingleTimeSeriesPoint(
          period: next.period,
          label: current.label,
          value: current.value,
        ),
      );
    }
  }
  return List.unmodifiable(result);
}

void _validateSingle(List<SingleTimeSeriesPoint> points) {
  final seen = <int>{};
  for (final point in points) {
    if (point.label.trim().isEmpty ||
        !point.value.isFinite ||
        point.value < 0 ||
        !seen.add(point.period)) {
      throw ArgumentError(
        'Time-series points need unique periods and finite non-negative values.',
      );
    }
  }
}

void _validateMulti(List<MultiTimeSeriesPoint> points) {
  if (points.isEmpty) {
    throw ArgumentError('A multi-series dataset cannot be empty.');
  }
  final series = <String>{};
  final periodsBySeries = <String, Set<int>>{};
  final labelsByPeriod = <int, String>{};
  for (final point in points) {
    if (point.series.trim().isEmpty ||
        point.label.trim().isEmpty ||
        !point.value.isFinite ||
        point.value < 0 ||
        !periodsBySeries
            .putIfAbsent(point.series, () => <int>{})
            .add(point.period)) {
      throw ArgumentError(
        'Multi-series points need unique series-period pairs and non-negative values.',
      );
    }
    series.add(point.series);
    final previousLabel = labelsByPeriod.putIfAbsent(
      point.period,
      () => point.label,
    );
    if (previousLabel != point.label) {
      throw ArgumentError('A shared period must have one consistent label.');
    }
  }
  if (series.length < 2) {
    throw ArgumentError('At least two series are required.');
  }
  final domain = periodsBySeries.values.first;
  if (periodsBySeries.values.any(
    (periods) => !periods.containsAll(domain) || !domain.containsAll(periods),
  )) {
    throw ArgumentError('All series must share the same complete time domain.');
  }
}
