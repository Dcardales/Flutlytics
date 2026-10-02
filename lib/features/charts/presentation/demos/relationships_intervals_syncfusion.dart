import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/relationships_intervals_data.dart';

const _colors = [
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
  Color(0xff00838f),
];

Widget buildSyncfusionRelationshipsIntervals(String id) => switch (id) {
  'scatter' => _scatter(),
  'bubble' => _bubble(),
  'connected-scatter' => _connected(),
  'error-bar' => _errorBar(),
  _ => _rangeColumn(),
};

Widget _scatter() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(title: sf.AxisTitle(text: 'Noches')),
  primaryYAxis: const sf.NumericAxis(
    title: sf.AxisTitle(text: 'Gasto total (mil COP)'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (dynamic data, dynamic point, dynamic series, int i, int j) {
      final p = data as ScatterObservation;
      return _tip(
        '${p.label}\n${p.nights.toStringAsFixed(1)} noches · ${p.spendThousands.toStringAsFixed(0)} mil COP',
      );
    },
  ),
  series: <sf.CartesianSeries<ScatterObservation, double>>[
    sf.ScatterSeries<ScatterObservation, double>(
      dataSource: scatterObservations,
      xValueMapper: (p, _) => p.nights,
      yValueMapper: (p, _) => p.spendThousands,
      markerSettings: const sf.MarkerSettings(width: 9, height: 9),
      animationDuration: 0,
    ),
  ],
);

Widget _bubble() {
  final radii = bubbleDestinationRadii;
  final minRadius = radii.reduce((a, b) => a < b ? a : b);
  final maxRadius = radii.reduce((a, b) => a > b ? a : b);
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(
      title: sf.AxisTitle(text: 'Visitantes (miles)'),
    ),
    primaryYAxis: const sf.NumericAxis(
      title: sf.AxisTitle(text: 'Gasto por turista (mil COP)'),
    ),
    legend: const sf.Legend(
      isVisible: true,
      position: sf.LegendPosition.bottom,
      title: sf.LegendTitle(text: 'Tamano = establecimientos registrados'),
    ),
    tooltipBehavior: sf.TooltipBehavior(
      enable: true,
      builder: (dynamic data, dynamic point, dynamic series, int i, int j) {
        final p = data as BubbleObservation;
        return _tip(
          '${p.label}\n${p.visitorsThousands} mil visitantes · ${p.spendPerVisitorThousands} mil COP\nEstablecimientos: ${p.establishments.toInt()}',
        );
      },
    ),
    series: <sf.CartesianSeries<BubbleObservation, double>>[
      sf.BubbleSeries<BubbleObservation, double>(
        name: 'Establecimientos registrados',
        dataSource: bubbleDestinations,
        xValueMapper: (p, _) => p.visitorsThousands,
        yValueMapper: (p, _) => p.spendPerVisitorThousands,
        sizeValueMapper: (p, _) => radii[bubbleDestinations.indexOf(p)],
        minimumRadius: minRadius,
        maximumRadius: maxRadius,
        animationDuration: 0,
        opacity: .68,
      ),
    ],
  );
}

Widget _connected() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(
    title: sf.AxisTitle(text: 'Ocupacion (%)'),
  ),
  primaryYAxis: const sf.NumericAxis(
    title: sf.AxisTitle(text: 'Tarifa media (mil COP)'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (dynamic data, dynamic point, dynamic series, int i, int j) {
      final p = data as ConnectedScatterPoint;
      return _tip('${p.label}\nOcupacion ${p.x}% · tarifa ${p.y} mil COP');
    },
  ),
  series: <sf.CartesianSeries<ConnectedScatterPoint, double>>[
    sf.LineSeries<ConnectedScatterPoint, double>(
      dataSource: connectedScatterPoints,
      xValueMapper: (p, _) => p.x,
      yValueMapper: (p, _) => p.y,
      markerSettings: const sf.MarkerSettings(
        isVisible: true,
        width: 7,
        height: 7,
      ),
      animationDuration: 0,
      pointColorMapper: (p, index) => index == 0
          ? Colors.green
          : index == connectedScatterPoints.length - 1
          ? Colors.red
          : _colors[0],
      dataLabelMapper: (p, index) => index == 0
          ? 'Inicio'
          : index == connectedScatterPoints.length - 1
          ? 'Fin'
          : null,
      dataLabelSettings: const sf.DataLabelSettings(isVisible: true),
    ),
  ],
);

Widget _errorBar() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(
    title: sf.AxisTitle(text: 'Servicio'),
    labelRotation: -30,
  ),
  primaryYAxis: const sf.NumericAxis(title: sf.AxisTitle(text: 'Minutos')),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (dynamic data, dynamic point, dynamic series, int i, int j) {
      final p = data as IntervalEstimate;
      return _tip(
        '${p.label}\nMedia ${p.estimate.toStringAsFixed(2)} min\n95% aprox. [${p.lower.toStringAsFixed(2)}, ${p.upper.toStringAsFixed(2)}]',
      );
    },
  ),
  series: <sf.CartesianSeries<IntervalEstimate, String>>[
    sf.ScatterSeries<IntervalEstimate, String>(
      name: 'Media',
      dataSource: errorBarEstimates,
      xValueMapper: (p, _) => p.label,
      yValueMapper: (p, _) => p.estimate,
      markerSettings: const sf.MarkerSettings(width: 9, height: 9),
      animationDuration: 0,
    ),
    for (final estimate in errorBarEstimates)
      sf.ErrorBarSeries<IntervalEstimate, String>(
        name: '${estimate.label} 95% CI',
        dataSource: [estimate],
        xValueMapper: (p, _) => p.label,
        yValueMapper: (p, _) => p.estimate,
        type: sf.ErrorBarType.custom,
        verticalPositiveErrorValue: estimate.upper - estimate.estimate,
        verticalNegativeErrorValue: estimate.estimate - estimate.lower,
        capLength: 10,
        animationDuration: 0,
      ),
  ],
);

Widget _rangeColumn() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(title: sf.AxisTitle(text: 'Dia')),
  primaryYAxis: const sf.NumericAxis(
    minimum: 14,
    title: sf.AxisTitle(text: 'Temperatura (°C)'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (dynamic data, dynamic point, dynamic series, int i, int j) {
      final p = data as RangeValue;
      return _tip(
        '${p.label}\nLow ${p.low}°C · High ${p.high}°C\nSpan ${p.span.toStringAsFixed(1)}°C',
      );
    },
  ),
  series: <sf.CartesianSeries<RangeValue, String>>[
    sf.RangeColumnSeries<RangeValue, String>(
      dataSource: dailyTemperatureRanges,
      xValueMapper: (p, _) => p.label,
      lowValueMapper: (p, _) => p.low,
      highValueMapper: (p, _) => p.high,
      animationDuration: 0,
      width: .58,
    ),
  ],
);

Widget _tip(String text) => Container(
  padding: const EdgeInsets.all(9),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(6),
    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
  ),
  child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 12)),
);
