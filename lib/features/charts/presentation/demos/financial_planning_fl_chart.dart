import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

import '../../data/financial_planning_data.dart';

Widget buildFlFinancialPlanning(String id) => switch (id) {
  'range-area' => _rangeArea(),
  'candlestick' => _candlestick(),
  'ohlc' => _ohlc(),
  'waterfall' => _waterfall(),
  'gantt' => _gantt(),
  _ => throw ArgumentError.value(id, 'id'),
};

fl.FlTitlesData _titles(
  List<String> labels, {
  int every = 1,
  double bottom = 28,
}) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: bottom,
      getTitlesWidget: (value, meta) {
        final i = value.round();
        if (value != i || i < 0 || i >= labels.length || i % every != 0) {
          return const SizedBox.shrink();
        }
        return Text(labels[i], style: const TextStyle(fontSize: 10));
      },
    ),
  ),
  leftTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: true, reservedSize: 34),
  ),
);

Widget _padded(Widget chart) =>
    Padding(padding: const EdgeInsets.fromLTRB(8, 12, 12, 10), child: chart);

Widget _rangeArea() {
  final lower = fl.LineChartBarData(
    spots: [
      for (var i = 0; i < hotelOccupancyRange.length; i++)
        fl.FlSpot(i.toDouble(), hotelOccupancyRange[i].low),
    ],
    color: const Color(0xff1565c0),
    barWidth: 1.5,
    dotData: const fl.FlDotData(show: false),
  );
  final upper = fl.LineChartBarData(
    spots: [
      for (var i = 0; i < hotelOccupancyRange.length; i++)
        fl.FlSpot(i.toDouble(), hotelOccupancyRange[i].high),
    ],
    color: const Color(0xff1565c0),
    barWidth: 1.5,
    dotData: const fl.FlDotData(show: false),
  );
  return _padded(
    fl.LineChart(
      fl.LineChartData(
        minX: 0,
        maxX: (hotelOccupancyRange.length - 1).toDouble(),
        minY: 45,
        maxY: 95,
        lineBarsData: [lower, upper],
        betweenBarsData: [
          fl.BetweenBarsData(
            fromIndex: 0,
            toIndex: 1,
            color: const Color(0x8890caf9),
          ),
        ],
        titlesData: _titles([
          for (final p in hotelOccupancyRange) p.period.substring(3),
        ]),
        lineTouchData: fl.LineTouchData(
          touchTooltipData: fl.LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final spot in spots)
                fl.LineTooltipItem(
                  '${hotelOccupancyRange[spot.x.round()].period.substring(3)}: ${hotelOccupancyRange[spot.x.round()].low}–${hotelOccupancyRange[spot.x.round()].high}% (rango ${hotelOccupancyRange[spot.x.round()].span} pp)',
                  const TextStyle(color: Colors.white, fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _candlestick() => _padded(
  fl.CandlestickChart(
    fl.CandlestickChartData(
      candlestickSpots: [
        for (var i = 0; i < educationalOhlc.length; i++)
          fl.CandlestickSpot(
            x: i.toDouble(),
            open: educationalOhlc[i].open,
            high: educationalOhlc[i].high,
            low: educationalOhlc[i].low,
            close: educationalOhlc[i].close,
          ),
      ],
      minX: -.5,
      maxX: 11.5,
      minY: 96,
      maxY: 114,
      candlestickTouchData: fl.CandlestickTouchData(
        touchTooltipData: fl.CandlestickTouchTooltipData(
          getTooltipItems: (painter, spot, index) {
            final p = educationalOhlc[index];
            return fl.CandlestickTooltipItem(
              'Sesión ${p.period}\nO ${p.open} · H ${p.high}\nL ${p.low} · C ${p.close}',
              textStyle: const TextStyle(color: Colors.white, fontSize: 11),
            );
          },
        ),
      ),
      titlesData: _titles([
        for (final p in educationalOhlc) p.period,
      ], every: 2),
    ),
  ),
);

Widget _ohlc() {
  final lines = <fl.LineChartBarData>[];
  for (var i = 0; i < educationalOhlc.length; i++) {
    final p = educationalOhlc[i];
    final color = p.isBullish
        ? const Color(0xff2e7d32)
        : const Color(0xffc62828);
    for (final segment in [
      [fl.FlSpot(i.toDouble(), p.low), fl.FlSpot(i.toDouble(), p.high)],
      [fl.FlSpot(i - .25, p.open), fl.FlSpot(i.toDouble(), p.open)],
      [fl.FlSpot(i.toDouble(), p.close), fl.FlSpot(i + .25, p.close)],
    ]) {
      lines.add(
        fl.LineChartBarData(
          spots: segment,
          color: color,
          barWidth: 2,
          dotData: const fl.FlDotData(show: false),
        ),
      );
    }
  }
  return _padded(
    fl.LineChart(
      fl.LineChartData(
        minX: -.5,
        maxX: 11.5,
        minY: 96,
        maxY: 114,
        titlesData: _titles([
          for (final p in educationalOhlc) p.period,
        ], every: 2),
        lineBarsData: lines,
        lineTouchData: fl.LineTouchData(
          touchTooltipData: fl.LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final spot in spots)
                fl.LineTooltipItem(() {
                  final p = educationalOhlc[spot.x.round().clamp(0, 11)];
                  return '${p.period} · O ${p.open} H ${p.high} L ${p.low} C ${p.close}';
                }(), const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _waterfall() => _padded(
  fl.BarChart(
    fl.BarChartData(
      minY: 0,
      maxY: 145,
      titlesData: _titles([
        for (final b in hotelWaterfall) b.step.label,
      ], bottom: 42),
      barGroups: [
        for (var i = 0; i < hotelWaterfall.length; i++)
          fl.BarChartGroupData(
            x: i,
            barRods: [
              fl.BarChartRodData(
                fromY: hotelWaterfall[i].startY,
                toY: hotelWaterfall[i].endY,
                width: 19,
                color: switch (hotelWaterfall[i].step.type) {
                  WaterfallType.start ||
                  WaterfallType.total => const Color(0xff1565c0),
                  WaterfallType.increase => const Color(0xff2e7d32),
                  _ => const Color(0xffc62828),
                },
                borderRadius: BorderRadius.zero,
              ),
            ],
          ),
      ],
      barTouchData: fl.BarTouchData(
        touchTooltipData: fl.BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final b = hotelWaterfall[group.x];
            return fl.BarTooltipItem(
              '${b.step.label}\n${b.contribution >= 0 ? '+' : ''}${b.contribution} M\nAcumulado ${b.endY} M',
              const TextStyle(color: Colors.white, fontSize: 11),
            );
          },
        ),
      ),
    ),
  ),
);

Widget _gantt() => _padded(
  fl.BarChart(
    fl.BarChartData(
      rotationQuarterTurns: 1,
      minY: 1,
      maxY: 21,
      titlesData: fl.FlTitlesData(
        topTitles: const fl.AxisTitles(
          sideTitles: fl.SideTitles(showTitles: false),
        ),
        rightTitles: const fl.AxisTitles(
          sideTitles: fl.SideTitles(showTitles: false),
        ),
        leftTitles: fl.AxisTitles(
          sideTitles: fl.SideTitles(
            showTitles: true,
            reservedSize: 38,
            interval: 4,
            getTitlesWidget: (v, meta) =>
                Text(ganttDate(v), style: const TextStyle(fontSize: 10)),
          ),
        ),
        bottomTitles: fl.AxisTitles(
          sideTitles: fl.SideTitles(
            showTitles: true,
            reservedSize: 88,
            getTitlesWidget: (v, meta) {
              final i = v.round();
              return v == i && i >= 0 && i < flutterFeatureTasks.length
                  ? Text(
                      flutterFeatureTasks[i].label,
                      style: const TextStyle(fontSize: 10),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ),
      ),
      barGroups: [
        for (var i = 0; i < flutterFeatureTasks.length; i++)
          fl.BarChartGroupData(
            x: i,
            barRods: [
              fl.BarChartRodData(
                fromY: ganttDay(flutterFeatureTasks[i].start),
                toY: ganttDay(flutterFeatureTasks[i].end),
                width: 16,
                color: const Color(0xff1565c0),
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
      ],
      barTouchData: fl.BarTouchData(
        touchTooltipData: fl.BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final t = flutterFeatureTasks[group.x];
            return fl.BarTooltipItem(
              '${t.label}\n${ganttDate(ganttDay(t.start))}–${ganttDate(ganttDay(t.end))}\n${t.duration.inDays} días · ${(t.progress * 100).round()}%',
              const TextStyle(color: Colors.white, fontSize: 11),
            );
          },
        ),
      ),
    ),
  ),
);
