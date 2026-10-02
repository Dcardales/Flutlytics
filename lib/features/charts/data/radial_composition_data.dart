import 'dart:math' as math;

class CompositionSlice {
  const CompositionSlice(this.label, this.value);
  final String label;
  final double value;
}

class CompositionShare {
  const CompositionShare(this.slice, this.percent);
  final CompositionSlice slice;
  final double percent;
}

class CompositionSummary {
  const CompositionSummary(this.total, this.shares);
  final double total;
  final List<CompositionShare> shares;
}

CompositionSummary compositionPercentages(List<CompositionSlice> slices) {
  if (slices.isEmpty) throw ArgumentError('Composition needs slices.');
  final labels = <String>{};
  for (final slice in slices) {
    if (slice.label.trim().isEmpty || !labels.add(slice.label)) {
      throw ArgumentError('Slice labels must be non-empty and unique.');
    }
    if (!slice.value.isFinite || slice.value < 0) {
      throw ArgumentError('Slice values must be finite and non-negative.');
    }
  }
  final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
  if (!total.isFinite || total <= 0) {
    throw ArgumentError('Composition total must be finite and greater than 0.');
  }
  return CompositionSummary(
    total,
    List.unmodifiable(
      slices.map((s) => CompositionShare(s, s.value / total * 100)),
    ),
  );
}

class WaffleCell {
  const WaffleCell({
    required this.row,
    required this.column,
    required this.active,
  });
  final int row;
  final int column;
  final bool active;
}

List<WaffleCell> waffleCells(
  double percent, {
  int rows = 10,
  int columns = 10,
}) {
  if (!percent.isFinite ||
      percent < 0 ||
      percent > 100 ||
      rows <= 0 ||
      columns <= 0) {
    throw ArgumentError('Waffle percent and dimensions are invalid.');
  }
  final activeCount = (percent / 100 * rows * columns).round();
  return List.unmodifiable([
    for (var i = 0; i < rows * columns; i++)
      WaffleCell(
        row: i ~/ columns,
        column: i % columns,
        active: i < activeCount,
      ),
  ]);
}

class PolarDatum {
  const PolarDatum(this.label, this.value);
  final String label;
  final double value;
}

List<PolarDatum> validatePolarArea(List<PolarDatum> data) {
  if (data.length < 3) {
    throw ArgumentError('Polar area needs at least 3 categories.');
  }
  final labels = <String>{};
  for (final item in data) {
    if (item.label.trim().isEmpty || !labels.add(item.label)) {
      throw ArgumentError('Polar categories must be non-empty and unique.');
    }
    if (!item.value.isFinite || item.value < 0) {
      throw ArgumentError('Polar values must be finite and non-negative.');
    }
  }
  return List.unmodifiable(data);
}

class RadarProfile {
  const RadarProfile(this.label, this.values);
  final String label;
  final List<double> values;
}

List<RadarProfile> validateRadarProfiles(
  List<String> dimensions,
  List<RadarProfile> profiles, {
  double min = 0,
  double max = 10,
}) {
  if (dimensions.length < 3 ||
      dimensions.any((d) => d.trim().isEmpty) ||
      dimensions.toSet().length != dimensions.length) {
    throw ArgumentError('Radar dimensions must have 3+ unique labels.');
  }
  if (!min.isFinite || !max.isFinite || min >= max || profiles.isEmpty) {
    throw ArgumentError('Radar scale and profiles are invalid.');
  }
  final names = <String>{};
  for (final profile in profiles) {
    if (profile.label.trim().isEmpty ||
        !names.add(profile.label) ||
        profile.values.length != dimensions.length) {
      throw ArgumentError(
        'Radar profiles need unique labels and shared dimensions.',
      );
    }
    if (profile.values.any((v) => !v.isFinite || v < min || v > max)) {
      throw ArgumentError(
        'Radar values must be finite and within the common range.',
      );
    }
  }
  return List.unmodifiable(profiles);
}

double maxAcrossPolarPanels(Iterable<Iterable<PolarDatum>> panels) {
  final values = panels.expand((panel) => panel).map((d) => d.value).toList();
  if (values.any((v) => !v.isFinite)) {
    throw ArgumentError('Panel values must be finite.');
  }
  if (values.isEmpty) {
    throw ArgumentError('Cannot calculate a scale for empty panels.');
  }
  return math.max(0, values.reduce(math.max));
}

const reservationSlices = <CompositionSlice>[
  CompositionSlice('Web', 48),
  CompositionSlice('Agencia', 27),
  CompositionSlice('Teléfono', 15),
  CompositionSlice('Walk-in', 10),
];
const revenueSlices = <CompositionSlice>[
  CompositionSlice('Hospedaje', 42),
  CompositionSlice('Gastronomía', 26),
  CompositionSlice('Tours', 19),
  CompositionSlice('Transporte', 13),
];
const hotelOccupancyPercent = 73.0;
const tourismDemand = <PolarDatum>[
  PolarDatum('Alojamiento', 2100),
  PolarDatum('Gastronomía', 1750),
  PolarDatum('Transporte', 1300),
  PolarDatum('Ocio', 980),
  PolarDatum('Cultura', 760),
];
const tourismDimensions = <String>[
  'Seguridad',
  'Precio',
  'Gastronomía',
  'Movilidad',
  'Cultura',
  'Alojamiento',
];
const tourismProfiles = <RadarProfile>[
  RadarProfile('Cartagena', [8.1, 7.0, 9.2, 6.8, 9.4, 8.7]),
  RadarProfile('Medellín', [8.5, 8.2, 8.4, 8.8, 8.1, 8.6]),
];
