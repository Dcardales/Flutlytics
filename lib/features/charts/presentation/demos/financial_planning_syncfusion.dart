import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/financial_planning_data.dart';

Widget buildSyncfusionFinancialPlanning(String id) => switch (id) {
  'range-area' => _rangeArea(),
  'candlestick' => _financial(true),
  'ohlc' => _financial(false),
  'waterfall' => _waterfall(),
  'gantt' => _gantt(),
  _ => throw ArgumentError.value(id, 'id'),
};

Widget _tip(String message) => Container(
  padding: const EdgeInsets.all(8),
  color: Colors.white,
  child: Text(
    message,
    style: const TextStyle(color: Colors.black, fontSize: 11),
  ),
);

Widget _rangeArea() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(title: sf.AxisTitle(text: 'Mes')),
  primaryYAxis: const sf.NumericAxis(
    minimum: 45,
    maximum: 95,
    title: sf.AxisTitle(text: 'Ocupación (%)'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      final p = data as RangeTimePoint;
      return _tip(
        '${p.period.substring(3)} · Low ${p.low}% · High ${p.high}% · Banda ${p.span} pp',
      );
    },
  ),
  series: <sf.CartesianSeries<RangeTimePoint, String>>[
    sf.RangeAreaSeries<RangeTimePoint, String>(
      dataSource: hotelOccupancyRange,
      xValueMapper: (p, _) => p.period.substring(3),
      lowValueMapper: (p, _) => p.low,
      highValueMapper: (p, _) => p.high,
      animationDuration: 0,
      color: const Color(0xff90caf9),
    ),
  ],
);

Widget _financial(bool candle) => sf.SfCartesianChart(
  primaryXAxis: sf.CategoryAxis(
    title: const sf.AxisTitle(text: 'Sesión'),
    axisLabelFormatter: (args) => sf.ChartAxisLabel(
      int.tryParse(args.text)?.isEven == true ? args.text : '',
      args.textStyle,
    ),
  ),
  primaryYAxis: const sf.NumericAxis(
    minimum: 96,
    maximum: 114,
    title: sf.AxisTitle(text: 'Índice educativo'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      final p = data as OhlcPoint;
      return _tip(
        'Sesión ${p.period}\nO ${p.open} · H ${p.high} · L ${p.low} · C ${p.close}',
      );
    },
  ),
  series: candle
      ? <sf.CartesianSeries<OhlcPoint, String>>[
          sf.CandleSeries<OhlcPoint, String>(
            dataSource: educationalOhlc,
            xValueMapper: (p, _) => p.period,
            openValueMapper: (p, _) => p.open,
            highValueMapper: (p, _) => p.high,
            lowValueMapper: (p, _) => p.low,
            closeValueMapper: (p, _) => p.close,
            animationDuration: 0,
            bullColor: const Color(0xff2e7d32),
            bearColor: const Color(0xffc62828),
          ),
        ]
      : <sf.CartesianSeries<OhlcPoint, String>>[
          sf.HiloOpenCloseSeries<OhlcPoint, String>(
            dataSource: educationalOhlc,
            xValueMapper: (p, _) => p.period,
            openValueMapper: (p, _) => p.open,
            highValueMapper: (p, _) => p.high,
            lowValueMapper: (p, _) => p.low,
            closeValueMapper: (p, _) => p.close,
            animationDuration: 0,
            bullColor: const Color(0xff2e7d32),
            bearColor: const Color(0xffc62828),
          ),
        ],
);

Widget _waterfall() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(labelRotation: -35),
  primaryYAxis: const sf.NumericAxis(
    minimum: 0,
    maximum: 145,
    title: sf.AxisTitle(text: 'Millones COP'),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      final b = data as WaterfallBar;
      return _tip(
        '${b.step.label}\nContribución ${b.contribution} M\nAcumulado ${b.endY} M',
      );
    },
  ),
  series: <sf.CartesianSeries<WaterfallBar, String>>[
    sf.WaterfallSeries<WaterfallBar, String>(
      dataSource: hotelWaterfall,
      xValueMapper: (b, _) => b.step.label,
      yValueMapper: (b, _) => switch (b.step.type) {
        WaterfallType.start => b.endY,
        WaterfallType.increase || WaterfallType.decrease => b.contribution,
        _ => 0,
      },
      totalSumPredicate: (b, index) => b.step.type == WaterfallType.total,
      color: const Color(0xff2e7d32),
      negativePointsColor: const Color(0xffc62828),
      totalSumColor: const Color(0xff1565c0),
      animationDuration: 0,
    ),
  ],
);

Widget _gantt() => sf.SfCartesianChart(
  isTransposed: true,
  primaryXAxis: const sf.CategoryAxis(
    isInversed: true,
    title: sf.AxisTitle(text: 'Tarea'),
  ),
  primaryYAxis: sf.NumericAxis(
    minimum: 1,
    maximum: 21,
    interval: 4,
    title: const sf.AxisTitle(text: 'Fecha (oct 2026)'),
    axisLabelFormatter: (args) =>
        sf.ChartAxisLabel(ganttDate(args.value.toDouble()), args.textStyle),
  ),
  tooltipBehavior: sf.TooltipBehavior(
    enable: true,
    builder: (data, point, series, i, j) {
      final t = data as GanttTask;
      return _tip(
        '${t.label}\n${ganttDate(ganttDay(t.start))}–${ganttDate(ganttDay(t.end))}\n${t.duration.inDays} días · ${(t.progress * 100).round()}%',
      );
    },
  ),
  series: <sf.CartesianSeries<GanttTask, String>>[
    sf.RangeColumnSeries<GanttTask, String>(
      dataSource: flutterFeatureTasks,
      xValueMapper: (t, _) => t.label,
      lowValueMapper: (t, _) => ganttDay(t.start),
      highValueMapper: (t, _) => ganttDay(t.end),
      animationDuration: 0,
      width: .52,
      color: const Color(0xff1565c0),
    ),
  ],
);
