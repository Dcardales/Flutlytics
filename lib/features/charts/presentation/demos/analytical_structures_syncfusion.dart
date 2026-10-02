import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/analytical_structures_data.dart';
import 'analytical_structures_batch_demos.dart' show matrixGrid;

Widget buildSyncfusionAnalyticalStructures(String id) => switch (id) {
  'diverging-stacked-bar' => _diverging(),
  'scatterplot-matrix' => matrixGrid(_matrixCell),
  'ternary-plot' => _ternary(),
  'fan-chart' => _fan(),
  'calibration-plot' => _calibration(),
  _ => throw ArgumentError.value(id, 'id'),
};

Widget _tip(String text) => Container(
  color: Colors.white,
  padding: const EdgeInsets.all(8),
  child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 11)),
);

const _likertParts = <(String, String, Color)>[
  ('Neutral', 'left', Color(0xffb0bec5)),
  ('Insatisfecho', 'left', Color(0xffef9a9a)),
  ('Muy insatisfecho', 'left', Color(0xffc62828)),
  ('Neutral', 'right', Color(0xffb0bec5)),
  ('Satisfecho', 'right', Color(0xff81c784)),
  ('Muy satisfecho', 'right', Color(0xff2e7d32)),
];

Widget _diverging() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(isInversed: true),
  primaryYAxis: const sf.NumericAxis(
    minimum: -55,
    maximum: 85,
    title: sf.AxisTitle(text: '% de respuestas'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      final row = data as LikertRow;
      final part = _likertParts[j];
      final segment = divergingLikert(row)
          .firstWhere((s) => s.response == part.$1 && s.side == part.$2);
      return _tip(
        '${row.label}\n${part.$1}: ${segment.percentage.toStringAsFixed(1)}%',
      );
    },
  ),
  series: <sf.CartesianSeries<LikertRow, String>>[
    for (final (response, side, color) in _likertParts)
      sf.StackedBarSeries<LikertRow, String>(
        name: '$response $side',
        dataSource: touristLikert,
        animationDuration: 0,
        color: color,
        xValueMapper: (r, _) => r.label,
        yValueMapper: (r, _) =>
            divergingLikert(r)
                .firstWhere((s) => s.response == response && s.side == side)
                .signedValue,
      ),
  ],
);

Widget _matrixCell(MatrixCell cell) {
  final xs = touristMatrix.scales[cell.x.id]!;
  final ys = touristMatrix.scales[cell.y.id]!;
  return Column(
    children: [
      Text(
        '${cell.y.label} × ${cell.x.label}',
        style: const TextStyle(fontSize: 9),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      Expanded(
        child: sf.SfCartesianChart(
          margin: EdgeInsets.zero,
          plotAreaBorderWidth: 0,
          primaryXAxis: sf.NumericAxis(
            minimum: xs.min,
            maximum: xs.max,
            labelStyle: const TextStyle(fontSize: 8),
          ),
          primaryYAxis: sf.NumericAxis(
            minimum: ys.min,
            maximum: ys.max,
            labelStyle: const TextStyle(fontSize: 8),
          ),
          tooltipBehavior: sf.TooltipBehavior(
            enable: true,
            builder: (data, point, series, i, j) {
              final o = data as MultivariateObservation;
              return _tip(
                '${o.label}\n${cell.x.label}: ${o.value(cell.x).toStringAsFixed(1)} ${cell.x.unit}\n${cell.y.label}: ${o.value(cell.y).toStringAsFixed(1)} ${cell.y.unit}',
              );
            },
          ),
          series: <sf.CartesianSeries<MultivariateObservation, double>>[
            sf.ScatterSeries<MultivariateObservation, double>(
              dataSource: touristMatrix.observations,
              animationDuration: 0,
              xValueMapper: (o, _) => o.value(cell.x),
              yValueMapper: (o, _) => o.value(cell.y),
              markerSettings: const sf.MarkerSettings(width: 5, height: 5),
            ),
          ],
        ),
      ),
    ],
  );
}

class _XY {
  const _XY(this.x, this.y);
  final double x, y;
}

Widget _ternary() {
  const outline = [_XY(0, 0), _XY(1, 0), _XY(.5, ternaryHeight), _XY(0, 0)];
  return Column(
    children: [
      const Text('Alojamiento', style: TextStyle(fontSize: 11)),
      Expanded(
        child: sf.SfCartesianChart(
          primaryXAxis: const sf.NumericAxis(
            minimum: 0,
            maximum: 1,
            isVisible: false,
          ),
          primaryYAxis: const sf.NumericAxis(
            minimum: 0,
            maximum: ternaryHeight,
            isVisible: false,
          ),
          tooltipBehavior: sf.TooltipBehavior(
            enable: true,
            builder: (data, point, series, i, j) {
              if (data is! TernaryPoint) return const SizedBox.shrink();
              return _tip(
                '${data.label}\nAlojamiento ${data.a}% · Alimentación ${data.b}% · Transporte ${data.c}%',
              );
            },
          ),
          series: <sf.CartesianSeries<dynamic, double>>[
            sf.LineSeries<_XY, double>(
              dataSource: outline,
              animationDuration: 0,
              enableTooltip: false,
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
            ),
            sf.ScatterSeries<TernaryPoint, double>(
              dataSource: touristBudgetMix,
              animationDuration: 0,
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
              markerSettings: const sf.MarkerSettings(width: 9, height: 9),
            ),
          ],
        ),
      ),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Alimentación', style: TextStyle(fontSize: 11)),
          Text('Transporte', style: TextStyle(fontSize: 11)),
        ],
      ),
    ],
  );
}

Widget _fan() => sf.SfCartesianChart(
  legend: const sf.Legend(
    isVisible: true,
    position: sf.LegendPosition.top,
    textStyle: TextStyle(fontSize: 10),
  ),
  primaryXAxis: const sf.CategoryAxis(title: sf.AxisTitle(text: 'Mes futuro')),
  primaryYAxis: const sf.NumericAxis(
    minimum: 40,
    maximum: 100,
    title: sf.AxisTitle(text: 'Ocupación (%)'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      final p = data as ForecastPoint;
      return _tip(
        'Mes ${p.period}\nMediana ${p.median.toStringAsFixed(1)}%\n50% [${p.lower50.toStringAsFixed(1)}, ${p.upper50.toStringAsFixed(1)}]\n80% [${p.lower80.toStringAsFixed(1)}, ${p.upper80.toStringAsFixed(1)}]\n95% [${p.lower95.toStringAsFixed(1)}, ${p.upper95.toStringAsFixed(1)}]',
      );
    },
  ),
  series: <sf.CartesianSeries<ForecastPoint, String>>[
    sf.RangeAreaSeries<ForecastPoint, String>(
      name: '95%',
      dataSource: hotelForecastFan,
      xValueMapper: (p, _) => p.period,
      lowValueMapper: (p, _) => p.lower95,
      highValueMapper: (p, _) => p.upper95,
      color: const Color(0xffbbdefb),
      animationDuration: 0,
    ),
    sf.RangeAreaSeries<ForecastPoint, String>(
      name: '80%',
      dataSource: hotelForecastFan,
      xValueMapper: (p, _) => p.period,
      lowValueMapper: (p, _) => p.lower80,
      highValueMapper: (p, _) => p.upper80,
      color: const Color(0xff64b5f6),
      animationDuration: 0,
    ),
    sf.RangeAreaSeries<ForecastPoint, String>(
      name: '50%',
      dataSource: hotelForecastFan,
      xValueMapper: (p, _) => p.period,
      lowValueMapper: (p, _) => p.lower50,
      highValueMapper: (p, _) => p.upper50,
      color: const Color(0xff1976d2),
      animationDuration: 0,
    ),
    sf.LineSeries<ForecastPoint, String>(
      name: 'Mediana',
      dataSource: hotelForecastFan,
      xValueMapper: (p, _) => p.period,
      yValueMapper: (p, _) => p.median,
      color: const Color(0xff0d47a1),
      animationDuration: 0,
    ),
  ],
);

Widget _calibration() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 1,
    title: sf.AxisTitle(text: 'Probabilidad predicha'),
  ),
  primaryYAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 1,
    title: sf.AxisTitle(text: 'Frecuencia observada'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      if (data is! CalibrationBin) return const SizedBox.shrink();
      return _tip(
        'Bin ${data.index + 1}\nPredicha ${data.avgPredicted.toStringAsFixed(2)}\nObservada ${data.observedRate.toStringAsFixed(2)}\nn=${data.count}',
      );
    },
  ),
  series: <sf.CartesianSeries<dynamic, double>>[
    sf.LineSeries<_XY, double>(
      name: 'Ideal y=x',
      dataSource: const [_XY(0, 0), _XY(1, 1)],
      enableTooltip: false,
      xValueMapper: (p, _) => p.x,
      yValueMapper: (p, _) => p.y,
      dashArray: const [5, 4],
      animationDuration: 0,
    ),
    sf.ScatterSeries<CalibrationBin, double>(
      name: 'Bins',
      dataSource: cancellationCalibration,
      xValueMapper: (b, _) => b.avgPredicted,
      yValueMapper: (b, _) => b.observedRate,
      markerSettings: const sf.MarkerSettings(width: 10, height: 10),
      animationDuration: 0,
    ),
  ],
);
