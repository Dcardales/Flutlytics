/// Synthetic educational data. No price represents a real security.
class RangeTimePoint {
  RangeTimePoint({
    required this.period,
    required this.low,
    required this.high,
  }) {
    if (period.trim().isEmpty ||
        !low.isFinite ||
        !high.isFinite ||
        low > high) {
      throw ArgumentError('A range needs a period and finite low <= high.');
    }
  }
  final String period;
  final double low, high;
  double get span => high - low;
}

class OhlcPoint {
  OhlcPoint({
    required this.period,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  }) {
    if (period.trim().isEmpty ||
        ![open, high, low, close].every((v) => v.isFinite) ||
        low > high ||
        open < low ||
        open > high ||
        close < low ||
        close > high) {
      throw ArgumentError(
        'OHLC must be finite and open/close within low/high.',
      );
    }
  }
  final String period;
  final double open, high, low, close;
  bool get isBullish => close > open;
  bool get isBearish => close < open;
  double get bodyLow => open < close ? open : close;
  double get bodyHigh => open > close ? open : close;
}

enum WaterfallType { start, increase, decrease, subtotal, total }

/// Increase/decrease inputs are nonnegative magnitudes. The transform applies
/// the sign once; subtotals and totals ignore their input value.
class WaterfallStep {
  WaterfallStep(this.label, this.value, this.type) {
    if (label.trim().isEmpty ||
        !value.isFinite ||
        ((type == WaterfallType.increase || type == WaterfallType.decrease) &&
            value < 0)) {
      throw ArgumentError('Invalid waterfall step.');
    }
  }
  final String label;
  final double value;
  final WaterfallType type;
}

class WaterfallBar {
  const WaterfallBar(this.step, this.startY, this.endY);
  final WaterfallStep step;
  final double startY, endY;
  double get contribution => switch (step.type) {
    WaterfallType.increase => step.value,
    WaterfallType.decrease => -step.value,
    _ => 0,
  };
  double get runningTotal => endY;
}

List<WaterfallBar> transformWaterfall(List<WaterfallStep> steps) {
  if (steps.isEmpty ||
      steps.first.type != WaterfallType.start ||
      steps.last.type != WaterfallType.total ||
      steps.where((s) => s.type == WaterfallType.start).length != 1 ||
      steps.where((s) => s.type == WaterfallType.total).length != 1) {
    throw ArgumentError(
      'Waterfall needs one initial start and one final total.',
    );
  }
  final result = <WaterfallBar>[];
  var current = steps.first.value;
  for (final step in steps) {
    final start = switch (step.type) {
      WaterfallType.start ||
      WaterfallType.subtotal ||
      WaterfallType.total => 0.0,
      _ => current,
    };
    final end = switch (step.type) {
      WaterfallType.start => current,
      WaterfallType.increase => current + step.value,
      WaterfallType.decrease => current - step.value,
      WaterfallType.subtotal || WaterfallType.total => current,
    };
    if (!end.isFinite) throw ArgumentError('Nonfinite running total.');
    result.add(WaterfallBar(step, start, end));
    current = end;
  }
  return List.unmodifiable(result);
}

class GanttTask {
  GanttTask({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
    this.progress = 0,
  }) {
    if (id.trim().isEmpty ||
        label.trim().isEmpty ||
        !start.isBefore(end) ||
        !progress.isFinite ||
        progress < 0 ||
        progress > 1) {
      throw ArgumentError('Invalid Gantt task.');
    }
  }
  final String id, label;
  final DateTime start, end;
  final double progress;
  Duration get duration => end.difference(start);
}

List<T> _uniqueOrdered<T>(List<T> rows, String Function(T) key) {
  if (rows.isEmpty || rows.map(key).toSet().length != rows.length) {
    throw ArgumentError('Periods/IDs must be unique and nonempty.');
  }
  return List.unmodifiable(rows);
}

List<RangeTimePoint> orderRangeTimePoints(List<RangeTimePoint> rows) {
  final ordered = [...rows]..sort((a, b) => a.period.compareTo(b.period));
  return _uniqueOrdered(ordered, (p) => p.period);
}

List<OhlcPoint> orderOhlcPoints(List<OhlcPoint> rows) {
  final ordered = [...rows]..sort((a, b) => a.period.compareTo(b.period));
  return _uniqueOrdered(ordered, (p) => p.period);
}

List<GanttTask> orderGanttTasks(List<GanttTask> rows) {
  final ordered = [...rows]
    ..sort((a, b) {
      final time = a.start.compareTo(b.start);
      return time != 0 ? time : a.id.compareTo(b.id);
    });
  return _uniqueOrdered(ordered, (t) => t.id);
}

final hotelOccupancyRange = orderRangeTimePoints([
  RangeTimePoint(period: '01 Ene', low: 53, high: 68),
  RangeTimePoint(period: '02 Feb', low: 55, high: 70),
  RangeTimePoint(period: '03 Mar', low: 59, high: 74),
  RangeTimePoint(period: '04 Abr', low: 57, high: 76),
  RangeTimePoint(period: '05 May', low: 62, high: 79),
  RangeTimePoint(period: '06 Jun', low: 68, high: 84),
  RangeTimePoint(period: '07 Jul', low: 70, high: 89),
  RangeTimePoint(period: '08 Ago', low: 67, high: 86),
]);

final educationalOhlc = orderOhlcPoints([
  OhlcPoint(period: '01', open: 100, high: 104, low: 98, close: 103),
  OhlcPoint(period: '02', open: 103, high: 105, low: 99, close: 101),
  OhlcPoint(period: '03', open: 101, high: 106, low: 100, close: 105),
  OhlcPoint(period: '04', open: 105, high: 107, low: 102, close: 103),
  OhlcPoint(period: '05', open: 103, high: 106, low: 101, close: 103.1),
  OhlcPoint(period: '06', open: 103, high: 108, low: 102, close: 107),
  OhlcPoint(period: '07', open: 107, high: 109, low: 104, close: 105),
  OhlcPoint(period: '08', open: 105, high: 108, low: 103, close: 107),
  OhlcPoint(period: '09', open: 107, high: 110, low: 105, close: 109),
  OhlcPoint(period: '10', open: 109, high: 111, low: 106, close: 107),
  OhlcPoint(period: '11', open: 107, high: 110, low: 105, close: 109),
  OhlcPoint(period: '12', open: 109, high: 112, low: 107, close: 108),
]);

final hotelWaterfall = transformWaterfall([
  WaterfallStep('Base', 100, WaterfallType.start),
  WaterfallStep('Reservas', 20, WaterfallType.increase),
  WaterfallStep('Eventos', 15, WaterfallType.increase),
  WaterfallStep('Operación', 35, WaterfallType.decrease),
  WaterfallStep('Comisiones', 12, WaterfallType.decrease),
  WaterfallStep('Mant.', 8, WaterfallType.decrease),
  WaterfallStep('Otros', 5, WaterfallType.increase),
  WaterfallStep('Neto', 0, WaterfallType.total),
]);

final flutterFeatureTasks = orderGanttTasks([
  GanttTask(
    id: 'ux',
    label: 'Diseño UX',
    start: DateTime(2026, 10, 1),
    end: DateTime(2026, 10, 5),
    progress: 1,
  ),
  GanttTask(
    id: 'model',
    label: 'Modelado',
    start: DateTime(2026, 10, 3),
    end: DateTime(2026, 10, 7),
    progress: 1,
  ),
  GanttTask(
    id: 'impl',
    label: 'Implementación',
    start: DateTime(2026, 10, 6),
    end: DateTime(2026, 10, 13),
    progress: .6,
  ),
  GanttTask(
    id: 'test',
    label: 'Pruebas',
    start: DateTime(2026, 10, 10),
    end: DateTime(2026, 10, 16),
    progress: .2,
  ),
  GanttTask(
    id: 'fix',
    label: 'Correcciones',
    start: DateTime(2026, 10, 15),
    end: DateTime(2026, 10, 19),
  ),
  GanttTask(
    id: 'ship',
    label: 'Entrega',
    start: DateTime(2026, 10, 19),
    end: DateTime(2026, 10, 21),
  ),
]);

final ganttOrigin = flutterFeatureTasks.first.start;
double ganttDay(DateTime date) => 1 + date.difference(ganttOrigin).inHours / 24;
String ganttDate(double day) {
  final date = ganttOrigin.add(Duration(hours: ((day - 1) * 24).round()));
  return '${date.day}/${date.month}';
}
