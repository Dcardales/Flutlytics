import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/networks_diagnostics_spatial_data.dart';
import 'networks_diagnostics_spatial_batch_demos.dart';

Widget buildSyncfusionNetworksDiagnosticsSpatial(String id) => switch (id) {
  'network-graph' => _network(),
  'qq-plot' => _qq(),
  'parallel-coordinates' => parallelFrame(_parallel()),
  'contour' => _contour(),
  'calendar-heatmap' => calendarFrame(_calendar()),
  _ => throw ArgumentError.value(id, 'id'),
};

class _XY {
  const _XY(this.x, this.y);
  final double x, y;
}

Widget _tip(String text) => Container(
  color: Colors.white,
  padding: const EdgeInsets.all(7),
  child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 10)),
);

Widget _network() => Column(
  children: [
    const Text(
      'Red de destinos y servicios · disposición circular',
      style: TextStyle(fontSize: 11),
    ),
    Expanded(
      child: sf.SfCartesianChart(
        primaryXAxis: const sf.NumericAxis(
          minimum: -1.25,
          maximum: 1.25,
          isVisible: false,
        ),
        primaryYAxis: const sf.NumericAxis(
          minimum: -1.25,
          maximum: 1.25,
          isVisible: false,
        ),
        tooltipBehavior: sf.TooltipBehavior(
          enable: true,
          builder: (data, point, series, i, j) => data is NetworkPosition
              ? _tip(networkTooltip(data))
              : const SizedBox.shrink(),
        ),
        series: <sf.CartesianSeries<dynamic, double>>[
          for (final e in touristNetwork.edges)
            sf.LineSeries<_XY, double>(
              dataSource: [
                _XY(
                  touristNetwork.byId[e.sourceId]!.x,
                  touristNetwork.byId[e.sourceId]!.y,
                ),
                _XY(
                  touristNetwork.byId[e.targetId]!.x,
                  touristNetwork.byId[e.targetId]!.y,
                ),
              ],
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
              color: const Color(0xff90a4ae),
              width: 1 + e.weight / 6,
              enableTooltip: false,
              animationDuration: 0,
            ),
          sf.ScatterSeries<NetworkPosition, double>(
            dataSource: touristNetwork.positions,
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            pointColorMapper: (p, _) => p.node.group == 'Destino'
                ? const Color(0xff1565c0)
                : p.node.group == 'Transporte'
                ? const Color(0xffef6c00)
                : const Color(0xff2e7d32),
            markerSettings: const sf.MarkerSettings(width: 14, height: 14),
            animationDuration: 0,
          ),
        ],
      ),
    ),
    Wrap(
      spacing: 10,
      children: [
        for (final p in touristNetwork.positions)
          Text('● ${p.node.label}', style: const TextStyle(fontSize: 9)),
      ],
    ),
  ],
);

Widget _qq() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(
    minimum: -3,
    maximum: 3,
    title: sf.AxisTitle(text: 'Normal teórica'),
  ),
  primaryYAxis: const sf.NumericAxis(
    minimum: -3,
    maximum: 3,
    title: sf.AxisTitle(text: 'Observado z'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) => data is QqPoint
        ? _tip(
            'Normal ${data.theoretical.toStringAsFixed(2)}\nObservado z=${data.observed.toStringAsFixed(2)}',
          )
        : const SizedBox.shrink(),
  ),
  series: <sf.CartesianSeries<dynamic, double>>[
    sf.LineSeries<_XY, double>(
      dataSource: const [_XY(-3, -3), _XY(3, 3)],
      xValueMapper: (p, _) => p.x,
      yValueMapper: (p, _) => p.y,
      dashArray: const [5, 4],
      color: const Color(0xff78909c),
      enableTooltip: false,
      animationDuration: 0,
    ),
    sf.ScatterSeries<QqPoint, double>(
      dataSource: serviceQq,
      xValueMapper: (p, _) => p.theoretical,
      yValueMapper: (p, _) => p.observed,
      markerSettings: const sf.MarkerSettings(width: 8, height: 8),
      animationDuration: 0,
    ),
  ],
);

Widget _parallel() => sf.SfCartesianChart(
  primaryXAxis: sf.CategoryAxis(labelStyle: const TextStyle(fontSize: 10)),
  primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 1),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      final p = data as ParallelPoint;
      return _tip(
        '${p.observation.label}\n${p.variable.label}: ${p.raw.toStringAsFixed(1)} ${p.variable.unit}',
      );
    },
  ),
  series: <sf.CartesianSeries<ParallelPoint, String>>[
    for (var i = 0; i < touristParallel.observations.length; i++)
      sf.LineSeries<ParallelPoint, String>(
        name: touristParallel.observations[i].label,
        dataSource: touristParallel.forObservation(
          touristParallel.observations[i],
        ),
        xValueMapper: (p, _) => p.variable.label,
        yValueMapper: (p, _) => p.normalized,
        color: Colors.primaries[i % Colors.primaries.length].withValues(
          alpha: .75,
        ),
        markerSettings: const sf.MarkerSettings(
          isVisible: true,
          width: 5,
          height: 5,
        ),
        animationDuration: 0,
      ),
  ],
);

Widget _contour() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 24,
    title: sf.AxisTitle(text: 'Este-oeste'),
  ),
  primaryYAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 19,
    title: sf.AxisTitle(text: 'Norte-sur'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) =>
        _tip('Intensidad ${(series as sf.LineSeries).name}'),
  ),
  series: <sf.CartesianSeries<FieldPoint, double>>[
    for (final s in touristContour.segments)
      sf.LineSeries<FieldPoint, double>(
        name: s.level.toStringAsFixed(1),
        dataSource: [s.a, s.b],
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,
        color:
            Colors.primaries[touristContour.levels.indexOf(s.level) %
                Colors.primaries.length],
        width: 1.7,
        animationDuration: 0,
      ),
  ],
);

Widget _calendar() => sf.SfCartesianChart(
  primaryXAxis: sf.NumericAxis(
    minimum: -1,
    maximum: bookingCalendar.cells.last.week + 1.0,
    interval: 1,
    axisLabelFormatter: (details) => sf.ChartAxisLabel(
      monthLabel(details.value.toInt()),
      const TextStyle(fontSize: 9),
    ),
  ),
  primaryYAxis: sf.NumericAxis(
    minimum: -.6,
    maximum: 6.6,
    interval: 1,
    isInversed: true,
    axisLabelFormatter: (details) => sf.ChartAxisLabel(
      details.value >= 0 && details.value < 7
          ? weekdayLabels[details.value.toInt()]
          : '',
      const TextStyle(fontSize: 10),
    ),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      final c = data as CalendarCell;
      return _tip(
        '${isoDay(c.day.date)}\n${c.day.value.toStringAsFixed(0)} reservas',
      );
    },
  ),
  series: <sf.CartesianSeries<CalendarCell, double>>[
    sf.ScatterSeries<CalendarCell, double>(
      dataSource: bookingCalendar.cells,
      xValueMapper: (c, _) => c.week.toDouble(),
      yValueMapper: (c, _) => c.weekday.toDouble(),
      pointColorMapper: (c, _) => Color.lerp(
        const Color(0xffe3f2fd),
        const Color(0xff0d47a1),
        bookingCalendar.intensity(c.day),
      )!,
      markerSettings: const sf.MarkerSettings(
        shape: sf.DataMarkerType.rectangle,
        width: 13,
        height: 13,
      ),
      animationDuration: 0,
    ),
  ],
);
