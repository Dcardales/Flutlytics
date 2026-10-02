import '../domain/chart_concept.dart';

/// Explicit feasibility classification in ChartLibrary.values order:
/// FL Chart, Syncfusion, Graphic, Graphify.
/// N = native, C = custom, S = simulated. Unsupported is intentionally absent.
class ChartSupportMatrix {
  ChartSupportMatrix._();

  static const codes = <String, String>{
    'line': 'NNNN',
    'multi-line': 'NNNN',
    'area': 'NNNN',
    'stacked-area': 'CNNN',
    'step-line': 'NNNN',
    'slope': 'CCCC',
    'bar': 'NNNN',
    'grouped-bar': 'NNNN',
    'stacked-bar': 'NNNN',
    'normalized-stacked-bar': 'CNCC',
    'diverging-bar': 'CCCC',
    'dot-plot': 'CCCC',
    'lollipop': 'CCCC',
    'dumbbell': 'CCCC',
    'pie': 'NNNN',
    'donut': 'CCCC',
    'waffle': 'CCCC',
    'scatter': 'NNNN',
    'bubble': 'CNNC',
    'histogram': 'CCCC',
    'frequency-polygon': 'CCCC',
    'ogive': 'CCCC',
    'strip-plot': 'CCCC',
    'radar': 'NCCN',
    'polar-area': 'CCCN',
    'range-column': 'CNCC',
    'error-bar': 'CNCC',
    'sparkline': 'SNSS',
    'timeline': 'CCCC',
    'connected-scatter': 'CCCC',
    'bar-line': 'CCCC',
    'area-line': 'CCCC',
    'small-multiples-line': 'SSSS',
    'small-multiples-bar': 'SSSS',
    'diverging-stacked-bar': 'CCCC',
    'normalized-stacked-area': 'CNCC',
    'cumulative-line': 'CCCC',
    'indexed-line': 'CCCC',
    'control-chart': 'CCCC',
    'pareto': 'CCCC',
    'box-plot': 'CNCN',
    'violin': 'CCCC',
    'heatmap': 'CCNN',
    'calendar-heatmap': 'CCCN',
    'scatterplot-matrix': 'SSSS',
    'ternary-plot': 'CCCC',
    'fan-chart': 'CCCC',
    'network-graph': 'CCCN',
    'qq-plot': 'CCCC',
    'funnel': 'CNNN',
    'pyramid': 'CCCC',
    'waterfall': 'CNCC',
    'candlestick': 'NNNN',
    'ohlc': 'CNCC',
    'gauge': 'CCCN',
    'gantt': 'CCCC',
    'streamgraph': 'CCCC',
    'parallel-coordinates': 'CCCN',
    'hexbin': 'CCCC',
    'density': 'CCCC',
    'bullet': 'CCCC',
    'range-area': 'CNCC',
    'ridgeline': 'CCCC',
    'contour': 'CCCC',
    'calibration-plot': 'CCCC',
  };

  static ChartSupportType _decode(String code) => switch (code) {
    'N' => ChartSupportType.native,
    'C' => ChartSupportType.custom,
    'S' => ChartSupportType.simulated,
    _ => throw StateError('Unknown support code: $code'),
  };

  static Map<ChartLibrary, ChartSupportType> forConcept(String id) {
    final row = codes[id];
    if (row == null || row.length != ChartLibrary.values.length) {
      throw StateError('Missing support strategy for $id');
    }
    return Map.unmodifiable({
      for (var i = 0; i < ChartLibrary.values.length; i++)
        ChartLibrary.values[i]: _decode(row[i]),
    });
  }
}
