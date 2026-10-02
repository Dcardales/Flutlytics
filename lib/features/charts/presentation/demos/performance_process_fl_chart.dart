import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/performance_process_data.dart';
import 'performance_process_batch_demos.dart';

Widget buildFlPerformanceProcess(String id) => switch (id) {
  'funnel' => _funnel(),
  'pyramid' => _pyramid(),
  'gauge' => _gauge(),
  'bullet' => _bullet(),
  'timeline' => timelineFrame(_timeline()),
  _ => throw ArgumentError.value(id, 'id'),
};

Widget _funnel() => Column(
  children: [
    const Text(
      'Conversión de reservas · ancho proporcional a personas',
      style: TextStyle(fontSize: 11),
    ),
    Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 5),
        child: fl.LineChart(
          fl.LineChartData(
            minX: 0,
            maxX: 5,
            minY: -5500,
            maxY: 5500,
            gridData: const fl.FlGridData(show: false),
            titlesData: fl.FlTitlesData(
              topTitles: const fl.AxisTitles(
                sideTitles: fl.SideTitles(showTitles: false),
              ),
              rightTitles: const fl.AxisTitles(
                sideTitles: fl.SideTitles(showTitles: false),
              ),
              leftTitles: const fl.AxisTitles(
                sideTitles: fl.SideTitles(showTitles: false),
              ),
              bottomTitles: fl.AxisTitles(
                sideTitles: fl.SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: 1,
                  getTitlesWidget: (v, meta) =>
                      v == v.round() && v >= 0 && v < bookingFunnel.steps.length
                      ? Text(
                          funnelShortLabels[v.toInt()],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 9),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            lineBarsData: [
              fl.LineChartBarData(
                spots: [
                  for (final s in bookingFunnel.steps)
                    fl.FlSpot(s.index.toDouble(), s.stage.value / 2),
                  fl.FlSpot(5, bookingFunnel.steps.last.stage.value / 2),
                ],
                color: const Color(0xff1565c0),
                barWidth: 1.5,
                dotData: const fl.FlDotData(show: true),
              ),
              fl.LineChartBarData(
                spots: [
                  for (final s in bookingFunnel.steps)
                    fl.FlSpot(s.index.toDouble(), -s.stage.value / 2),
                  fl.FlSpot(5, -bookingFunnel.steps.last.stage.value / 2),
                ],
                color: const Color(0xff1565c0),
                barWidth: 1.5,
                dotData: const fl.FlDotData(show: false),
              ),
            ],
            betweenBarsData: [
              fl.BetweenBarsData(
                fromIndex: 0,
                toIndex: 1,
                color: const Color(0x8842a5f5),
              ),
            ],
            lineTouchData: fl.LineTouchData(
              touchTooltipData: fl.LineTouchTooltipData(
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    s.barIndex == 0 && s.spotIndex < bookingFunnel.steps.length
                        ? fl.LineTooltipItem(
                            funnelTip(bookingFunnel.steps[s.spotIndex]),
                            const TextStyle(color: Colors.white, fontSize: 10),
                          )
                        : null,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ],
);

Widget _pyramid() => Column(
  children: [
    const Wrap(
      spacing: 12,
      children: [
        Text(
          '◀ Nacionales',
          style: TextStyle(color: Color(0xff1565c0), fontSize: 11),
        ),
        Text(
          'Internacionales ▶',
          style: TextStyle(color: Color(0xffef6c00), fontSize: 11),
        ),
      ],
    ),
    Expanded(
      child: fl.BarChart(
        fl.BarChartData(
          rotationQuarterTurns: 1,
          minY: -260,
          maxY: 260,
          extraLinesData: fl.ExtraLinesData(
            horizontalLines: [
              fl.HorizontalLine(
                y: 0,
                color: const Color(0xff263238),
                strokeWidth: 2,
              ),
            ],
          ),
          titlesData: fl.FlTitlesData(
            topTitles: const fl.AxisTitles(
              sideTitles: fl.SideTitles(showTitles: false),
            ),
            rightTitles: const fl.AxisTitles(
              sideTitles: fl.SideTitles(showTitles: false),
            ),
            bottomTitles: fl.AxisTitles(
              sideTitles: fl.SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: 1,
                getTitlesWidget: (v, meta) =>
                    v == v.round() &&
                        v >= 0 &&
                        v < touristAgePyramid.rows.length
                    ? Text(
                        touristAgePyramid.rows[v.toInt()].category,
                        style: const TextStyle(fontSize: 10),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < touristAgePyramid.rows.length; i++)
              fl.BarChartGroupData(
                x: i,
                barRods: [
                  fl.BarChartRodData(
                    fromY: 0,
                    toY: touristAgePyramid.rows[i].leftCoordinate,
                    width: 11,
                    color: const Color(0xff1565c0),
                    borderRadius: BorderRadius.zero,
                  ),
                  fl.BarChartRodData(
                    fromY: 0,
                    toY: touristAgePyramid.rows[i].rightCoordinate,
                    width: 11,
                    color: const Color(0xffef6c00),
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              ),
          ],
          barTouchData: fl.BarTouchData(
            touchTooltipData: fl.BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  fl.BarTooltipItem(
                    pyramidTip(touristAgePyramid.rows[group.x]),
                    const TextStyle(color: Colors.white, fontSize: 10),
                  ),
            ),
          ),
        ),
      ),
    ),
  ],
);

Widget _gauge() {
  final actual = hotelOccupancyGauge.normalizedValue * 100;
  final target = hotelOccupancyGauge.normalizedTarget! * 100;
  final sectors = <({double value, Color color})>[
    (value: actual, color: const Color(0xff1565c0)),
    (value: target - actual - .8, color: const Color(0xffdce8f2)),
    (value: 1.6, color: const Color(0xff263238)),
    (value: 100 - target - .8, color: const Color(0xffdce8f2)),
    (value: 100, color: Colors.transparent),
  ];
  return Column(
    children: [
      Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            fl.PieChart(
              fl.PieChartData(
                startDegreeOffset: 180,
                centerSpaceRadius: 54,
                sectionsSpace: 0,
                sections: [
                  for (final s in sectors)
                    fl.PieChartSectionData(
                      value: s.value,
                      color: s.color,
                      radius: 24,
                      showTitle: false,
                    ),
                ],
                pieTouchData: fl.PieTouchData(
                  touchCallback: (event, response) {},
                ),
              ),
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

Widget _bullet() {
  final bands = monthlyRevenueBullet.bands;
  return Column(
    children: [
      const Text(
        'Ingresos mensuales · barra=actual · línea=meta',
        style: TextStyle(fontSize: 11),
      ),
      Expanded(
        child: fl.LineChart(
          fl.LineChartData(
            minX: 0,
            maxX: 100,
            minY: 0,
            maxY: 1,
            titlesData: fl.FlTitlesData(
              topTitles: const fl.AxisTitles(
                sideTitles: fl.SideTitles(showTitles: false),
              ),
              rightTitles: const fl.AxisTitles(
                sideTitles: fl.SideTitles(showTitles: false),
              ),
              leftTitles: const fl.AxisTitles(
                sideTitles: fl.SideTitles(showTitles: false),
              ),
              bottomTitles: fl.AxisTitles(
                sideTitles: fl.SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: 20,
                  getTitlesWidget: (v, meta) => Text(
                    '${v.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            lineBarsData: [
              for (final b in bands) ...[
                fl.LineChartBarData(
                  spots: [fl.FlSpot(b.start, 0), fl.FlSpot(b.end, 0)],
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: const fl.FlDotData(show: false),
                ),
                fl.LineChartBarData(
                  spots: [fl.FlSpot(b.start, 1), fl.FlSpot(b.end, 1)],
                  color: Colors.transparent,
                  barWidth: 0,
                  dotData: const fl.FlDotData(show: false),
                ),
              ],
              fl.LineChartBarData(
                spots: [
                  const fl.FlSpot(0, .5),
                  fl.FlSpot(monthlyRevenueBullet.value, .5),
                ],
                barWidth: 14,
                color: const Color(0xff1565c0),
                dotData: const fl.FlDotData(show: false),
              ),
            ],
            betweenBarsData: [
              for (var i = 0; i < bands.length; i++)
                fl.BetweenBarsData(
                  fromIndex: i * 2,
                  toIndex: i * 2 + 1,
                  color: const [
                    Color(0xffeceff1),
                    Color(0xffb0bec5),
                    Color(0xff78909c),
                  ][i],
                ),
            ],
            extraLinesData: fl.ExtraLinesData(
              verticalLines: [
                fl.VerticalLine(
                  x: monthlyRevenueBullet.target,
                  color: const Color(0xffc62828),
                  strokeWidth: 3,
                ),
              ],
            ),
            lineTouchData: fl.LineTouchData(
              touchTooltipData: fl.LineTouchTooltipData(
                getTooltipItems: (spots) => [
                  for (final s in spots)
                    s.barIndex == bands.length * 2
                        ? fl.LineTooltipItem(
                            bulletTip(),
                            const TextStyle(color: Colors.white, fontSize: 10),
                          )
                        : null,
                ],
              ),
            ),
          ),
        ),
      ),
      const Text(
        'Bajo <60 · aceptable 60–80 · bueno 80–100 · meta 90',
        style: TextStyle(fontSize: 10),
      ),
    ],
  );
}

Widget _timeline() => fl.LineChart(
  fl.LineChartData(
    minX: 0,
    maxX: flutterMilestones.maxDay,
    minY: -1.5,
    maxY: 1.5,
    gridData: const fl.FlGridData(show: false),
    titlesData: fl.FlTitlesData(
      leftTitles: const fl.AxisTitles(
        sideTitles: fl.SideTitles(showTitles: false),
      ),
      rightTitles: const fl.AxisTitles(
        sideTitles: fl.SideTitles(showTitles: false),
      ),
      topTitles: fl.AxisTitles(
        sideTitles: fl.SideTitles(
          showTitles: true,
          reservedSize: 38,
          interval: 1,
          getTitlesWidget: (v, meta) => _timelineLabel(v, true),
        ),
      ),
      bottomTitles: fl.AxisTitles(
        sideTitles: fl.SideTitles(
          showTitles: true,
          reservedSize: 42,
          interval: 1,
          getTitlesWidget: (v, meta) => _timelineLabel(v, false),
        ),
      ),
    ),
    lineBarsData: [
      fl.LineChartBarData(
        spots: [fl.FlSpot(0, 0), fl.FlSpot(flutterMilestones.maxDay, 0)],
        color: const Color(0xff607d8b),
        barWidth: 2,
        dotData: const fl.FlDotData(show: false),
      ),
      for (final p in flutterMilestones.points)
        fl.LineChartBarData(
          spots: [fl.FlSpot(p.dayOffset, 0), fl.FlSpot(p.dayOffset, p.lane)],
          color: const Color(0xff1565c0),
          barWidth: 1.5,
          dotData: const fl.FlDotData(show: true),
        ),
    ],
    lineTouchData: fl.LineTouchData(
      touchTooltipData: fl.LineTouchTooltipData(
        getTooltipItems: (spots) => [
          for (final s in spots)
            s.barIndex > 0
                ? fl.LineTooltipItem(
                    timelineTip(flutterMilestones.points[s.barIndex - 1]),
                    const TextStyle(color: Colors.white, fontSize: 10),
                  )
                : null,
        ],
      ),
    ),
  ),
);

Widget _timelineLabel(double value, bool top) {
  for (final p in flutterMilestones.points) {
    if ((value - p.dayOffset).abs() < .01 && (p.lane > 0) == top) {
      return SizedBox(
        width: 95,
        child: Text(
          '${p.event.title}\n${isoDate(p.event.date)}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9),
        ),
      );
    }
  }
  return const SizedBox.shrink();
}
