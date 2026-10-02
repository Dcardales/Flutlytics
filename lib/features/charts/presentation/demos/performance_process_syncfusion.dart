import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/performance_process_data.dart';
import 'performance_process_batch_demos.dart';

Widget buildSyncfusionPerformanceProcess(String id) => switch (id) {
  'funnel' => _funnel(),
  'pyramid' => _pyramid(),
  'gauge' => _gauge(),
  'bullet' => _bullet(),
  'timeline' => timelineFrame(_timeline()),
  _ => throw ArgumentError.value(id, 'id'),
};

Widget _tip(String text) => Container(
  color: Colors.white,
  padding: const EdgeInsets.all(7),
  child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 10)),
);

Widget _funnel() => sf.SfFunnelChart(
  title: const sf.ChartTitle(text: 'Conversión de reservas'),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) =>
        _tip(funnelTip(bookingFunnel.steps[i])),
  ),
  series: sf.FunnelSeries<FunnelStep, String>(
    dataSource: bookingFunnel.steps,
    xValueMapper: (s, _) => funnelShortLabels[s.index],
    yValueMapper: (s, _) => s.stage.value,
    neckWidth: '15%',
    neckHeight: '0%',
    gapRatio: .03,
    dataLabelSettings: const sf.DataLabelSettings(
      isVisible: true,
      textStyle: TextStyle(fontSize: 10),
    ),
    animationDuration: 0,
  ),
);

Widget _pyramid() => sf.SfCartesianChart(
  legend: const sf.Legend(isVisible: true, position: sf.LegendPosition.top),
  primaryXAxis: const sf.CategoryAxis(),
  primaryYAxis: sf.NumericAxis(
    minimum: -touristAgePyramid.maxMagnitude,
    maximum: touristAgePyramid.maxMagnitude,
    plotBands: [
      sf.PlotBand(
        start: 0,
        end: 0,
        borderWidth: 2,
        borderColor: const Color(0xff263238),
      ),
    ],
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) =>
        _tip(pyramidTip(data as PopulationPyramidRow)),
  ),
  series: <sf.CartesianSeries<PopulationPyramidRow, String>>[
    sf.BarSeries<PopulationPyramidRow, String>(
      name: 'Nacionales · izquierda',
      dataSource: touristAgePyramid.rows,
      xValueMapper: (r, _) => r.category,
      yValueMapper: (r, _) => r.leftCoordinate,
      color: const Color(0xff1565c0),
      animationDuration: 0,
    ),
    sf.BarSeries<PopulationPyramidRow, String>(
      name: 'Internacionales · derecha',
      dataSource: touristAgePyramid.rows,
      xValueMapper: (r, _) => r.category,
      yValueMapper: (r, _) => r.rightCoordinate,
      color: const Color(0xffef6c00),
      animationDuration: 0,
    ),
  ],
);

class _Sector {
  const _Sector(this.name, this.value, this.color);
  final String name;
  final double value;
  final Color color;
}

Widget _gauge() {
  final actual = hotelOccupancyGauge.normalizedValue * 100;
  final target = hotelOccupancyGauge.normalizedTarget! * 100;
  final sectors = [
    _Sector('Actual', actual, const Color(0xff1565c0)),
    _Sector('Hasta meta', target - actual - .8, const Color(0xffdce8f2)),
    const _Sector('Meta', 1.6, Color(0xff263238)),
    _Sector('Restante', 100 - target - .8, const Color(0xffdce8f2)),
    const _Sector('Fuera de escala', 100, Colors.transparent),
  ];
  return Column(
    children: [
      Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            sf.SfCircularChart(
              tooltipBehavior: sf.TooltipBehavior(
                enable: true,
                builder: (data, point, series, i, j) => _tip(gaugeTip()),
              ),
              series: <sf.CircularSeries<_Sector, String>>[
                sf.DoughnutSeries<_Sector, String>(
                  dataSource: sectors,
                  startAngle: 270,
                  endAngle: 630,
                  xValueMapper: (s, _) => s.name,
                  yValueMapper: (s, _) => s.value,
                  pointColorMapper: (s, _) => s.color,
                  innerRadius: '65%',
                  animationDuration: 0,
                ),
              ],
            ),
            const Positioned(
              bottom: 25,
              child: Text(
                '0%                    100%',
                style: TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
      gaugeCaption(),
      const SizedBox(height: 6),
    ],
  );
}

class _XY {
  const _XY(this.x, this.y);
  final double x, y;
}

Widget _bullet() => Column(
  children: [
    const Text(
      'Ingresos mensuales · barra=actual · línea=meta',
      style: TextStyle(fontSize: 11),
    ),
    Expanded(
      child: sf.SfCartesianChart(
        primaryXAxis: const sf.NumericAxis(
          minimum: 0,
          maximum: 100,
          interval: 20,
        ),
        primaryYAxis: const sf.NumericAxis(
          minimum: 0,
          maximum: 1,
          isVisible: false,
        ),
        tooltipBehavior: sf.TooltipBehavior(
          enable: true,
          builder: (data, point, series, i, j) => _tip(bulletTip()),
        ),
        series: <sf.CartesianSeries<_XY, double>>[
          for (var i = 0; i < monthlyRevenueBullet.bands.length; i++)
            sf.LineSeries<_XY, double>(
              dataSource: [
                _XY(monthlyRevenueBullet.bands[i].start, .5),
                _XY(monthlyRevenueBullet.bands[i].end, .5),
              ],
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
              width: 35,
              color: const [
                Color(0xffeceff1),
                Color(0xffb0bec5),
                Color(0xff78909c),
              ][i],
              enableTooltip: false,
              animationDuration: 0,
            ),
          sf.LineSeries<_XY, double>(
            dataSource: [const _XY(0, .5), _XY(monthlyRevenueBullet.value, .5)],
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            width: 14,
            color: const Color(0xff1565c0),
            animationDuration: 0,
          ),
          sf.LineSeries<_XY, double>(
            dataSource: [
              _XY(monthlyRevenueBullet.target, .15),
              _XY(monthlyRevenueBullet.target, .85),
            ],
            xValueMapper: (p, _) => p.x,
            yValueMapper: (p, _) => p.y,
            width: 3,
            color: const Color(0xffc62828),
            enableTooltip: false,
            animationDuration: 0,
          ),
        ],
      ),
    ),
    const Text(
      'Bajo <60 · aceptable 60–80 · bueno 80–100 · meta 90',
      style: TextStyle(fontSize: 10),
    ),
  ],
);

class _TimePoint {
  const _TimePoint(this.date, this.lane);
  final DateTime date;
  final double lane;
}

Widget _timeline() => sf.SfCartesianChart(
  primaryXAxis: const sf.DateTimeAxis(
    dateFormat: null,
    labelStyle: TextStyle(fontSize: 9),
  ),
  primaryYAxis: const sf.NumericAxis(
    minimum: -1.5,
    maximum: 1.5,
    isVisible: false,
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) => data is TimelinePoint
        ? _tip(timelineTip(data))
        : const SizedBox.shrink(),
  ),
  series: <sf.CartesianSeries<dynamic, DateTime>>[
    sf.LineSeries<_TimePoint, DateTime>(
      dataSource: [
        _TimePoint(flutterMilestones.events.first.date, 0),
        _TimePoint(flutterMilestones.events.last.date, 0),
      ],
      xValueMapper: (p, _) => p.date,
      yValueMapper: (p, _) => p.lane,
      enableTooltip: false,
      color: const Color(0xff607d8b),
      animationDuration: 0,
    ),
    for (final p in flutterMilestones.points)
      sf.LineSeries<_TimePoint, DateTime>(
        dataSource: [
          _TimePoint(p.event.date, 0),
          _TimePoint(p.event.date, p.lane),
        ],
        xValueMapper: (v, _) => v.date,
        yValueMapper: (v, _) => v.lane,
        enableTooltip: false,
        color: const Color(0xff1565c0),
        animationDuration: 0,
      ),
    sf.ScatterSeries<TimelinePoint, DateTime>(
      dataSource: flutterMilestones.points,
      xValueMapper: (p, _) => p.event.date,
      yValueMapper: (p, _) => p.lane,
      dataLabelMapper: (p, _) => p.event.title,
      dataLabelSettings: const sf.DataLabelSettings(
        isVisible: true,
        textStyle: TextStyle(fontSize: 9),
      ),
      markerSettings: const sf.MarkerSettings(width: 10, height: 10),
      animationDuration: 0,
    ),
  ],
);
