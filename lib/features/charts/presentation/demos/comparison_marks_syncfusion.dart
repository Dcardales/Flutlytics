import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/sample_datasets.dart';

const _colors = <Color>[
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
  Color(0xff00838f),
];
const _startColor = Color(0xff1565c0);
const _endColor = Color(0xffef6c00);
const _neutral = Color(0xff78909c);
List<ChartPoint> _points(String id) => ChartDatasetRegistry.pointsFor(id);
List<DumbbellDatum> _dumbbells() => ChartDatasetRegistry.dumbbellData();
List<SlopeDatum> _slopes() => ChartDatasetRegistry.slopeData();
List<ParetoPoint> _pareto() =>
    calculatePareto(ChartDatasetRegistry.paretoSources());

Widget buildSyncfusionComparisonChart(String id) => switch (id) {
  'dot-plot' => _sfDot(_points(id)),
  'lollipop' => _sfLollipop(_points(id)),
  'dumbbell' => _sfDumbbell(_dumbbells()),
  'slope' => _sfSlope(_slopes()),
  _ => _sfPareto(_pareto()),
};
Widget _sfDot(List<ChartPoint> data) => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 10, interval: 2),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  series: <sf.CartesianSeries<ChartPoint, String>>[
    sf.LineSeries<ChartPoint, String>(
      dataSource: data,
      animationDuration: 0,
      width: 0,
      markerSettings: const sf.MarkerSettings(
        isVisible: true,
        width: 12,
        height: 12,
      ),
      xValueMapper: (r, _) => r.label,
      yValueMapper: (r, _) => r.value,
    ),
  ],
);

class _LollipopRow {
  const _LollipopRow(this.label, this.value);
  final String label;
  final double value;
}

Widget _sfLollipop(List<ChartPoint> data) => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 100),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  legend: const sf.Legend(isVisible: false),
  series: <sf.CartesianSeries<_LollipopRow, String>>[
    for (var i = 0; i < data.length; i++)
      sf.LineSeries<_LollipopRow, String>(
        name: data[i].label,
        dataSource: [
          _LollipopRow(data[i].label, 0),
          _LollipopRow(data[i].label, data[i].value),
        ],
        color: _colors[i % _colors.length],
        width: 2,
        animationDuration: 0,
        markerSettings: const sf.MarkerSettings(
          isVisible: true,
          width: 9,
          height: 9,
        ),
        xValueMapper: (r, _) => r.label,
        yValueMapper: (r, _) => r.value,
      ),
  ],
);

Widget _sfDumbbell(List<DumbbellDatum> data) => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 10, interval: 2),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  legend: const sf.Legend(isVisible: true, position: sf.LegendPosition.bottom),
  series: <sf.CartesianSeries<DumbbellDatum, String>>[
    for (final row in data)
      sf.LineSeries<DumbbellDatum, String>(
        name: row.label,
        dataSource: [row, row],
        color: _neutral,
        width: 2,
        animationDuration: 0,
        markerSettings: const sf.MarkerSettings(isVisible: false),
        xValueMapper: (r, _) => r.label,
        yValueMapper: (r, index) => index == 0 ? row.startValue : row.endValue,
      ),
    sf.LineSeries<DumbbellDatum, String>(
      name: 'Antes · círculo',
      dataSource: data,
      color: _startColor,
      width: 0,
      animationDuration: 0,
      markerSettings: const sf.MarkerSettings(
        isVisible: true,
        width: 9,
        height: 9,
      ),
      xValueMapper: (r, _) => r.label,
      yValueMapper: (r, _) => r.startValue,
    ),
    sf.LineSeries<DumbbellDatum, String>(
      name: 'Después · cuadrado',
      dataSource: data,
      color: _endColor,
      width: 0,
      animationDuration: 0,
      markerSettings: const sf.MarkerSettings(
        isVisible: true,
        width: 10,
        height: 10,
        shape: sf.DataMarkerType.rectangle,
      ),
      xValueMapper: (r, _) => r.label,
      yValueMapper: (r, _) => r.endValue,
    ),
  ],
);

Widget _sfSlope(List<SlopeDatum> data) => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 40, interval: 10),
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  legend: const sf.Legend(isVisible: true, position: sf.LegendPosition.bottom),
  series: <sf.CartesianSeries<SlopeDatum, String>>[
    for (var i = 0; i < data.length; i++)
      sf.LineSeries<SlopeDatum, String>(
        name: data[i].label,
        dataSource: [data[i], data[i]],
        color: _colors[i % _colors.length],
        width: 2,
        animationDuration: 0,
        markerSettings: const sf.MarkerSettings(
          isVisible: true,
          width: 8,
          height: 8,
        ),
        xValueMapper: (r, index) => index == 0 ? r.startPeriod : r.endPeriod,
        yValueMapper: (r, index) => index == 0 ? r.startValue : r.endValue,
      ),
  ],
);

Widget _sfPareto(List<ParetoPoint> data) => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(labelRotation: -35),
  primaryYAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 50,
    interval: 10,
    title: sf.AxisTitle(text: 'Incidencias'),
  ),
  axes: const <sf.ChartAxis>[
    sf.NumericAxis(
      name: 'percentAxis',
      opposedPosition: true,
      minimum: 0,
      maximum: 100,
      interval: 20,
      title: sf.AxisTitle(text: 'Acumulado (%)'),
    ),
  ],
  tooltipBehavior: sf.TooltipBehavior(enable: true),
  legend: const sf.Legend(isVisible: true, position: sf.LegendPosition.bottom),
  series: <sf.CartesianSeries<ParetoPoint, String>>[
    sf.ColumnSeries<ParetoPoint, String>(
      name: 'Frecuencia',
      dataSource: data,
      animationDuration: 0,
      xValueMapper: (r, _) => r.category,
      yValueMapper: (r, _) => r.frequency,
    ),
    sf.LineSeries<ParetoPoint, String>(
      name: 'Acumulado (%)',
      dataSource: data,
      yAxisName: 'percentAxis',
      color: _endColor,
      width: 2,
      animationDuration: 0,
      markerSettings: const sf.MarkerSettings(isVisible: true),
      xValueMapper: (r, _) => r.category,
      yValueMapper: (r, _) => r.cumulativePercent,
    ),
    sf.LineSeries<ParetoPoint, String>(
      name: 'Referencia 80 %',
      dataSource: data,
      yAxisName: 'percentAxis',
      color: _neutral,
      width: 1,
      dashArray: const [4, 3],
      animationDuration: 0,
      markerSettings: const sf.MarkerSettings(isVisible: false),
      xValueMapper: (r, _) => r.category,
      yValueMapper: (r, _) => 80,
    ),
  ],
);
