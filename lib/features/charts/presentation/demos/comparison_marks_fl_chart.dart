import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';

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
List<String> _labels(List<ChartPoint> data) => [
  for (final row in data) row.label,
];

Widget _legend(List<({String label, Color color, bool square})> entries) =>
    Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 3,
      children: [
        for (final entry in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              entry.square
                  ? Container(width: 9, height: 9, color: entry.color)
                  : Icon(Icons.circle, color: entry.color, size: 10),
              const SizedBox(width: 4),
              Text(entry.label, style: const TextStyle(fontSize: 10)),
            ],
          ),
      ],
    );

Widget buildFlComparisonChart(String id) => switch (id) {
  'dot-plot' => _flDot(_points(id)),
  'lollipop' => _flLollipop(_points(id)),
  'dumbbell' => _flDumbbell(_dumbbells()),
  'slope' => _flSlope(_slopes()),
  _ => _flPareto(_pareto()),
};
fl.FlTitlesData _flHorizontalTitles(List<String> categories) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  leftTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: 76,
      getTitlesWidget: (value, meta) {
        final index = value.round();
        return index >= 0 &&
                index < categories.length &&
                value == index.toDouble()
            ? Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  categories[index],
                  style: const TextStyle(fontSize: 9),
                ),
              )
            : const SizedBox.shrink();
      },
    ),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: 26,
      getTitlesWidget: (value, meta) =>
          Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 9)),
    ),
  ),
);

Widget _flDot(List<ChartPoint> data) => fl.ScatterChart(
  fl.ScatterChartData(
    minX: 0,
    maxX: 10,
    minY: -0.5,
    maxY: data.length - 0.5,
    scatterSpots: [
      for (var i = 0; i < data.length; i++)
        fl.ScatterSpot(
          data[i].value,
          i.toDouble(),
          dotPainter: fl.FlDotCirclePainter(
            radius: 6,
            color: _colors[i % _colors.length],
          ),
        ),
    ],
    titlesData: _flHorizontalTitles(_labels(data)),
    gridData: const fl.FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: false,
    ),
    scatterTouchData: fl.ScatterTouchData(enabled: true),
  ),
);

Widget _flLollipop(List<ChartPoint> data) => Column(
  children: [
    Expanded(
      child: fl.LineChart(
        fl.LineChartData(
          minX: 0,
          maxX: 100,
          minY: -0.5,
          maxY: data.length - 0.5,
          lineBarsData: [
            for (var i = 0; i < data.length; i++)
              fl.LineChartBarData(
                spots: [
                  fl.FlSpot(0, i.toDouble()),
                  fl.FlSpot(data[i].value, i.toDouble()),
                ],
                color: _colors[i % _colors.length],
                barWidth: 2.5,
                dotData: fl.FlDotData(
                  show: true,
                  checkToShowDot: (spot, bar) => spot.x > 0,
                  getDotPainter: (spot, percent, bar, index) =>
                      fl.FlDotCirclePainter(
                        radius: 6,
                        color: bar.color ?? _colors.first,
                      ),
                ),
              ),
          ],
          titlesData: _flHorizontalTitles(_labels(data)),
          gridData: const fl.FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: false,
          ),
          lineTouchData: fl.LineTouchData(enabled: true),
        ),
      ),
    ),
    _legend([
      for (var i = 0; i < data.length; i++)
        (
          label: data[i].label,
          color: _colors[i % _colors.length],
          square: false,
        ),
    ]),
  ],
);

Widget _flDumbbell(List<DumbbellDatum> data) => Column(
  children: [
    Expanded(
      child: fl.LineChart(
        fl.LineChartData(
          minX: 0,
          maxX: 10,
          minY: -0.5,
          maxY: data.length - 0.5,
          lineBarsData: [
            for (var i = 0; i < data.length; i++)
              fl.LineChartBarData(
                spots: [
                  fl.FlSpot(data[i].startValue, i.toDouble()),
                  fl.FlSpot(data[i].endValue, i.toDouble()),
                ],
                color: _neutral,
                barWidth: 3,
                dotData: const fl.FlDotData(show: false),
              ),
            fl.LineChartBarData(
              spots: [
                for (var i = 0; i < data.length; i++)
                  fl.FlSpot(data[i].startValue, i.toDouble()),
              ],
              color: _startColor,
              barWidth: 0,
              dotData: fl.FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    fl.FlDotCirclePainter(radius: 5, color: _startColor),
              ),
            ),
            fl.LineChartBarData(
              spots: [
                for (var i = 0; i < data.length; i++)
                  fl.FlSpot(data[i].endValue, i.toDouble()),
              ],
              color: _endColor,
              barWidth: 0,
              dotData: fl.FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    fl.FlDotSquarePainter(size: 10, color: _endColor),
              ),
            ),
          ],
          titlesData: _flHorizontalTitles([for (final row in data) row.label]),
          gridData: const fl.FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: false,
          ),
          lineTouchData: fl.LineTouchData(enabled: true),
        ),
      ),
    ),
    _legend([
      (label: 'Antes · círculo', color: _startColor, square: false),
      (label: 'Después · cuadrado', color: _endColor, square: true),
    ]),
  ],
);

Widget _flSlope(List<SlopeDatum> data) => Column(
  children: [
    Expanded(
      child: fl.LineChart(
        fl.LineChartData(
          minX: -0.2,
          maxX: 1.2,
          minY: 0,
          maxY: 40,
          lineBarsData: [
            for (var i = 0; i < data.length; i++)
              fl.LineChartBarData(
                spots: [
                  fl.FlSpot(0, data[i].startValue),
                  fl.FlSpot(1, data[i].endValue),
                ],
                color: _colors[i % _colors.length],
                barWidth: 2.5,
                dotData: fl.FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) => spot.x == 0
                      ? fl.FlDotCirclePainter(
                          radius: 4,
                          color: bar.color ?? _colors.first,
                        )
                      : fl.FlDotSquarePainter(
                          size: 8,
                          color: bar.color ?? _colors.first,
                        ),
                ),
              ),
          ],
          titlesData: _flSlopeTitles(
            data.first.startPeriod,
            data.first.endPeriod,
            data,
          ),
          gridData: const fl.FlGridData(show: true, drawVerticalLine: false),
          lineTouchData: fl.LineTouchData(enabled: true),
        ),
      ),
    ),
    _legend([
      for (var i = 0; i < data.length; i++)
        (
          label: data[i].label,
          color: _colors[i % _colors.length],
          square: false,
        ),
    ]),
  ],
);

fl.FlTitlesData _flSlopeTitles(
  String start,
  String end,
  List<SlopeDatum> data,
) => fl.FlTitlesData(
  topTitles: const fl.AxisTitles(sideTitles: fl.SideTitles(showTitles: false)),
  rightTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: false),
  ),
  leftTitles: const fl.AxisTitles(
    sideTitles: fl.SideTitles(showTitles: true, reservedSize: 32),
  ),
  bottomTitles: fl.AxisTitles(
    sideTitles: fl.SideTitles(
      showTitles: true,
      reservedSize: 26,
      getTitlesWidget: (value, meta) => value == 0
          ? Text(start, style: const TextStyle(fontSize: 10))
          : value == 1
          ? Text(end, style: const TextStyle(fontSize: 10))
          : const SizedBox.shrink(),
    ),
  ),
);

Widget _flPareto(List<ParetoPoint> data) {
  const left = 40.0;
  const right = 42.0;
  const bottom = 36.0;
  const namesStyle = TextStyle(fontSize: 8);
  final maxFrequency = data.fold<double>(
    0,
    (max, row) => row.frequency > max ? row.frequency : max,
  );
  final names = [for (final row in data) row.category];
  final categoryTitles = fl.FlTitlesData(
    topTitles: const fl.AxisTitles(
      sideTitles: fl.SideTitles(showTitles: false),
    ),
    leftTitles: const fl.AxisTitles(
      sideTitles: fl.SideTitles(showTitles: true, reservedSize: left),
    ),
    rightTitles: const fl.AxisTitles(
      sideTitles: fl.SideTitles(showTitles: false, reservedSize: right),
    ),
    bottomTitles: fl.AxisTitles(
      sideTitles: fl.SideTitles(
        showTitles: true,
        reservedSize: bottom,
        getTitlesWidget: (v, m) {
          final i = v.toInt();
          return i >= 0 && i < names.length && v == i
              ? Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    names[i],
                    style: namesStyle,
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink();
        },
      ),
    ),
  );
  return Stack(
    children: [
      fl.BarChart(
        fl.BarChartData(
          minY: 0,
          maxY: maxFrequency * 1.12,
          barGroups: [
            for (var i = 0; i < data.length; i++)
              fl.BarChartGroupData(
                x: i,
                barRods: [
                  fl.BarChartRodData(
                    toY: data[i].frequency,
                    color: _colors[0],
                    width: 18,
                  ),
                ],
              ),
          ],
          titlesData: categoryTitles,
          gridData: const fl.FlGridData(show: true, drawVerticalLine: false),
          barTouchData: fl.BarTouchData(enabled: true),
        ),
      ),
      fl.LineChart(
        fl.LineChartData(
          minX: -0.5,
          maxX: data.length - 0.5,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            fl.LineChartBarData(
              spots: [
                for (var i = 0; i < data.length; i++)
                  fl.FlSpot(i.toDouble(), data[i].cumulativePercent),
              ],
              color: _endColor,
              barWidth: 2.5,
              dotData: const fl.FlDotData(show: true),
            ),
            fl.LineChartBarData(
              spots: [
                for (var i = 0; i < data.length; i++)
                  fl.FlSpot(i.toDouble(), 80),
              ],
              color: _neutral,
              barWidth: 1,
              dotData: const fl.FlDotData(show: false),
              dashArray: [4, 3],
            ),
          ],
          titlesData: fl.FlTitlesData(
            topTitles: const fl.AxisTitles(
              sideTitles: fl.SideTitles(showTitles: false),
            ),
            leftTitles: const fl.AxisTitles(
              sideTitles: fl.SideTitles(showTitles: false, reservedSize: left),
            ),
            rightTitles: fl.AxisTitles(
              sideTitles: fl.SideTitles(
                showTitles: true,
                reservedSize: right,
                getTitlesWidget: (v, m) =>
                    Text('${v.toInt()}%', style: const TextStyle(fontSize: 8)),
              ),
            ),
            bottomTitles: const fl.AxisTitles(
              sideTitles: fl.SideTitles(
                showTitles: false,
                reservedSize: bottom,
              ),
            ),
          ),
          gridData: const fl.FlGridData(show: false),
          borderData: fl.FlBorderData(show: false),
          lineTouchData: fl.LineTouchData(enabled: true),
        ),
      ),
    ],
  );
}
