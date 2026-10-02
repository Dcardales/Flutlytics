import 'dart:math' as math;

import 'sample_datasets.dart';
import 'time_series_data.dart';

class IndexedSeriesPoint extends MultiTimeSeriesPoint {
  const IndexedSeriesPoint({
    required super.series,
    required super.period,
    required super.label,
    required super.value,
    required this.originalValue,
  });

  final double originalValue;
}

class StreamgraphPoint extends MultiTimeSeriesPoint {
  const StreamgraphPoint({
    required super.series,
    required super.period,
    required super.label,
    required super.value,
    required this.lower,
    required this.upper,
    required this.baseline,
    required this.total,
  });

  final double lower;
  final double upper;
  final double baseline;
  final double total;
  double get thickness => upper - lower;
}

class ControlChartStats {
  const ControlChartStats({
    required this.mean,
    required this.standardDeviation,
  });

  final double mean;
  final double standardDeviation;
  double get upperControlLimit => mean + 3 * standardDeviation;
  double get lowerControlLimit => mean - 3 * standardDeviation;
}

class ControlChartPoint extends SingleTimeSeriesPoint {
  const ControlChartPoint({
    required super.period,
    required super.label,
    required super.value,
    required this.outOfControl,
  });

  final bool outOfControl;
}

/// Running sum by chronological period. Finite negative values are supported
/// for valid net-flow series; the educational sales dataset itself is >= 0.
List<SingleTimeSeriesPoint> cumulativeTimeSeries(
  List<SingleTimeSeriesPoint> input,
) {
  final ordered = input.toList()..sort((a, b) => a.period.compareTo(b.period));
  _validateSingle(input, allowNegative: true);
  var total = 0.0;
  final result = <SingleTimeSeriesPoint>[];
  for (final point in ordered) {
    total += point.value;
    if (!total.isFinite) {
      throw ArgumentError('Cumulative total must remain finite.');
    }
    result.add(
      SingleTimeSeriesPoint(
        period: point.period,
        label: point.label,
        value: total,
      ),
    );
  }
  return List.unmodifiable(result);
}

List<SingleTimeSeriesPoint> cumulativeTimeSeriesFor(String id) =>
    cumulativeTimeSeries(singleTimeSeriesFor(id));

/// Rebases at the earliest period of each series. Zero baselines are rejected.
List<IndexedSeriesPoint> indexTimeSeries(List<MultiTimeSeriesPoint> input) {
  final ordered = _validatedMulti(input, minimumSeries: 3, nonNegative: true);
  final baseBySeries = <String, double>{};
  for (final point in ordered) {
    baseBySeries.putIfAbsent(point.series, () => point.value);
  }
  for (final entry in baseBySeries.entries) {
    if (entry.value == 0) {
      throw ArgumentError(
        'Indexed series "${entry.key}" cannot have a zero baseline.',
      );
    }
  }
  final indexed = <IndexedSeriesPoint>[];
  for (final point in ordered) {
    final value = point.value / baseBySeries[point.series]! * 100;
    if (!value.isFinite) {
      throw ArgumentError('Indexed values must remain finite.');
    }
    indexed.add(
      IndexedSeriesPoint(
        series: point.series,
        period: point.period,
        label: point.label,
        value: value,
        originalValue: point.value,
      ),
    );
  }
  return List.unmodifiable(indexed);
}

List<IndexedSeriesPoint> indexedTimeSeriesFor(String id) =>
    indexTimeSeries(multiTimeSeriesFor(id));

/// Normalizes each period through the shared `normalizeBars` primitive.
/// Periods with a zero total retain zero for every series.
List<MultiTimeSeriesPoint> normalizeTimeSeriesByPeriod(
  List<MultiTimeSeriesPoint> input,
) {
  final ordered = _validatedMulti(input, minimumSeries: 2, nonNegative: true);
  final periods = ordered.map((point) => point.period).toSet().toList()..sort();
  final seriesNames = ordered.map((point) => point.series).toSet().toList()
    ..sort();
  final output = <MultiTimeSeriesPoint>[];
  for (final period in periods) {
    final rows = ordered.where((point) => point.period == period).toList();
    final total = rows.fold<double>(0, (sum, point) => sum + point.value);
    if (!total.isFinite) {
      throw ArgumentError('Normalized totals must remain finite.');
    }
    final normalized = normalizeBars([
      for (final point in rows)
        BarDatum(category: '$period', series: point.series, value: point.value),
    ]);
    final percentBySeries = {
      for (final row in normalized) row.series: row.value,
    };
    for (final series in seriesNames) {
      final source = rows.singleWhere((point) => point.series == series);
      output.add(
        MultiTimeSeriesPoint(
          series: series,
          period: period,
          label: source.label,
          value: percentBySeries[series]!,
        ),
      );
    }
  }
  return List.unmodifiable(output);
}

List<MultiTimeSeriesPoint> normalizedStackedAreaFor(String id) =>
    normalizeTimeSeriesByPeriod(multiTimeSeriesFor(id));

/// Computes centered absolute bands with baseline = -total / 2 per period.
/// This is a simple centered offset, not a ThemeRiver or Wiggle algorithm.
List<StreamgraphPoint> centerStreamgraph(List<MultiTimeSeriesPoint> input) {
  final ordered = _validatedMulti(input, minimumSeries: 2, nonNegative: true);
  final periods = ordered.map((point) => point.period).toSet().toList()..sort();
  final seriesNames = ordered.map((point) => point.series).toSet().toList()
    ..sort();
  final output = <StreamgraphPoint>[];
  for (final period in periods) {
    final rows = ordered.where((point) => point.period == period).toList();
    final total = rows.fold<double>(0, (sum, point) => sum + point.value);
    if (!total.isFinite) {
      throw ArgumentError('Streamgraph totals must remain finite.');
    }
    final baseline = -total / 2;
    var cumulative = baseline;
    for (final series in seriesNames) {
      final source = rows.singleWhere((point) => point.series == series);
      final lower = cumulative;
      cumulative += source.value;
      if (!cumulative.isFinite) {
        throw ArgumentError('Streamgraph bands must remain finite.');
      }
      output.add(
        StreamgraphPoint(
          series: series,
          period: period,
          label: source.label,
          value: source.value,
          lower: lower,
          upper: cumulative,
          baseline: baseline,
          total: total,
        ),
      );
    }
  }
  return List.unmodifiable(output);
}

List<StreamgraphPoint> streamgraphFor(String id) =>
    centerStreamgraph(multiTimeSeriesFor(id));

/// Individuals-style educational limits use the population standard
/// deviation: sqrt(sum((x - mean)^2) / n). This is not a complete industrial
/// SPC procedure.
ControlChartStats controlChartStatistics(List<double> values) {
  if (values.isEmpty) {
    throw ArgumentError('Control chart statistics require observations.');
  }
  if (values.any((value) => !value.isFinite)) {
    throw ArgumentError('Control chart observations must be finite.');
  }
  final mean =
      values.fold<double>(0, (sum, value) => sum + value) / values.length;
  final variance =
      values.fold<double>(0, (sum, value) => sum + math.pow(value - mean, 2)) /
      values.length;
  final standardDeviation = math.sqrt(variance);
  if (!mean.isFinite || !standardDeviation.isFinite) {
    throw ArgumentError('Control chart statistics must remain finite.');
  }
  return ControlChartStats(mean: mean, standardDeviation: standardDeviation);
}

({ControlChartStats stats, List<ControlChartPoint> points}) controlChartFor(
  String id,
) {
  final observations = singleTimeSeriesFor(id);
  final stats = controlChartStatistics(
    observations.map((point) => point.value).toList(),
  );
  return (
    stats: stats,
    points: List.unmodifiable([
      for (final point in observations)
        ControlChartPoint(
          period: point.period,
          label: point.label,
          value: point.value,
          outOfControl:
              point.value > stats.upperControlLimit ||
              point.value < stats.lowerControlLimit,
        ),
    ]),
  );
}

List<SingleTimeSeriesPoint> _validateSingle(
  List<SingleTimeSeriesPoint> input, {
  required bool allowNegative,
}) {
  final periods = <int>{};
  for (final point in input) {
    if (point.label.trim().isEmpty ||
        !point.value.isFinite ||
        (!allowNegative && point.value < 0) ||
        !periods.add(point.period)) {
      throw ArgumentError(
        'Temporal points must be unique and finite with valid signs.',
      );
    }
  }
  return input;
}

List<MultiTimeSeriesPoint> _validatedMulti(
  List<MultiTimeSeriesPoint> input, {
  required int minimumSeries,
  required bool nonNegative,
}) {
  if (input.isEmpty) throw ArgumentError('Multi-series data cannot be empty.');
  final series = <String>{};
  final periodsBySeries = <String, Set<int>>{};
  final labelsByPeriod = <int, String>{};
  for (final point in input) {
    if (point.series.trim().isEmpty ||
        point.label.trim().isEmpty ||
        !point.value.isFinite ||
        (nonNegative && point.value < 0) ||
        !periodsBySeries
            .putIfAbsent(point.series, () => <int>{})
            .add(point.period)) {
      throw ArgumentError(
        'Multi-series values must be finite, unique and valid.',
      );
    }
    series.add(point.series);
    final oldLabel = labelsByPeriod.putIfAbsent(
      point.period,
      () => point.label,
    );
    if (oldLabel != point.label) {
      throw ArgumentError('A shared period must have one consistent label.');
    }
  }
  if (series.length < minimumSeries) {
    throw ArgumentError('At least $minimumSeries series are required.');
  }
  final commonDomain = periodsBySeries.values.first;
  if (periodsBySeries.values.any(
    (domain) =>
        !domain.containsAll(commonDomain) || !commonDomain.containsAll(domain),
  )) {
    throw ArgumentError('All series must share the same complete time domain.');
  }
  return input.toList()..sort((a, b) {
    final bySeries = a.series.compareTo(b.series);
    return bySeries != 0 ? bySeries : a.period.compareTo(b.period);
  });
}
