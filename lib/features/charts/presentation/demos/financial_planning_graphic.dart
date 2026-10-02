import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/financial_planning_data.dart';

Widget buildGraphicFinancialPlanning(String id) => switch (id) {
  'range-area' => _rangeArea(),
  'candlestick' => _candlestick(),
  'ohlc' => _ohlc(),
  'waterfall' => _waterfall(),
  'gantt' => _gantt(),
  _ => throw ArgumentError.value(id, 'id'),
};

Map<String, gr.Selection> _selection() => {
  'point': gr.PointSelection(
    on: {gr.GestureType.hover, gr.GestureType.tap},
    dim: gr.Dim.x,
  ),
};

Widget _rangeArea() => gr.Chart<RangeTimePoint>(
  data: hotelOccupancyRange,
  variables: {
    'period': gr.Variable(accessor: (p) => p.period.substring(3)),
    'low': gr.Variable(
      accessor: (p) => p.low,
      scale: gr.LinearScale(min: 45, max: 95),
    ),
    'high': gr.Variable(
      accessor: (p) => p.high,
      scale: gr.LinearScale(min: 45, max: 95),
    ),
    'span': gr.Variable(accessor: (p) => p.span),
  },
  marks: [
    gr.AreaMark(
      position: gr.Varset('period') * (gr.Varset('low') + gr.Varset('high')),
      color: gr.ColorEncode(value: const Color(0x8890caf9)),
    ),
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('low'),
      color: gr.ColorEncode(value: const Color(0xff1565c0)),
    ),
    gr.LineMark(
      position: gr.Varset('period') * gr.Varset('high'),
      color: gr.ColorEncode(value: const Color(0xff1565c0)),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  tooltip: gr.TooltipGuide(variables: ['period', 'low', 'high', 'span']),
  selections: _selection(),
);

Widget _candlestick() => gr.Chart<OhlcPoint>(
  data: educationalOhlc,
  variables: {
    'period': gr.Variable(accessor: (p) => p.period),
    'open': gr.Variable(
      accessor: (p) => p.open,
      scale: gr.LinearScale(min: 96, max: 114),
    ),
    'close': gr.Variable(
      accessor: (p) => p.close,
      scale: gr.LinearScale(min: 96, max: 114),
    ),
    'high': gr.Variable(
      accessor: (p) => p.high,
      scale: gr.LinearScale(min: 96, max: 114),
    ),
    'low': gr.Variable(
      accessor: (p) => p.low,
      scale: gr.LinearScale(min: 96, max: 114),
    ),
    'direction': gr.Variable(
      accessor: (p) => p.isBullish
          ? 'Alcista'
          : p.isBearish
          ? 'Bajista'
          : 'Neutral',
    ),
  },
  marks: [
    gr.CustomMark(
      position:
          gr.Varset('period') *
          (gr.Varset('open') +
              gr.Varset('close') +
              gr.Varset('high') +
              gr.Varset('low')),
      shape: gr.ShapeEncode<gr.Shape>(
        value: gr.CandlestickShape(hollow: false),
      ),
      size: gr.SizeEncode(value: 10),
      color: gr.ColorEncode(
        variable: 'direction',
        values: const [Color(0xff2e7d32), Color(0xffc62828), Color(0xff455a64)],
      ),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  tooltip: gr.TooltipGuide(
    variables: ['period', 'open', 'high', 'low', 'close', 'direction'],
  ),
  selections: _selection(),
);

class _OhlcSegment {
  const _OhlcSegment(this.period, this.segment, this.x, this.y, this.point);
  final String period, segment;
  final double x, y;
  final OhlcPoint point;
}

Widget _ohlc() {
  final rows = <_OhlcSegment>[];
  for (var i = 0; i < educationalOhlc.length; i++) {
    final p = educationalOhlc[i];
    rows.addAll([
      _OhlcSegment(p.period, '$i-wick', i.toDouble(), p.low, p),
      _OhlcSegment(p.period, '$i-wick', i.toDouble(), p.high, p),
      _OhlcSegment(p.period, '$i-open', i - .25, p.open, p),
      _OhlcSegment(p.period, '$i-open', i.toDouble(), p.open, p),
      _OhlcSegment(p.period, '$i-close', i.toDouble(), p.close, p),
      _OhlcSegment(p.period, '$i-close', i + .25, p.close, p),
    ]);
  }
  return gr.Chart<_OhlcSegment>(
    data: rows,
    variables: {
      'period': gr.Variable(accessor: (p) => p.period),
      'segment': gr.Variable(accessor: (p) => p.segment),
      'x': gr.Variable(
        accessor: (p) => p.x,
        scale: gr.LinearScale(min: -.5, max: 11.5),
      ),
      'y': gr.Variable(
        accessor: (p) => p.y,
        scale: gr.LinearScale(min: 96, max: 114),
      ),
      'open': gr.Variable(accessor: (p) => p.point.open),
      'high': gr.Variable(accessor: (p) => p.point.high),
      'low': gr.Variable(accessor: (p) => p.point.low),
      'close': gr.Variable(accessor: (p) => p.point.close),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('x') * gr.Varset('y') / gr.Varset('segment'),
        color: gr.ColorEncode(value: const Color(0xff1565c0)),
        size: gr.SizeEncode(value: 2),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(
      variables: ['period', 'open', 'high', 'low', 'close'],
    ),
    selections: _selection(),
  );
}

Widget _waterfall() => gr.Chart<WaterfallBar>(
  data: hotelWaterfall,
  variables: {
    'step': gr.Variable(accessor: (b) => b.step.label),
    'start': gr.Variable(
      accessor: (b) => b.startY,
      scale: gr.LinearScale(min: 0, max: 145),
    ),
    'end': gr.Variable(
      accessor: (b) => b.endY,
      scale: gr.LinearScale(min: 0, max: 145),
    ),
    'contribution': gr.Variable(accessor: (b) => b.contribution),
    'running': gr.Variable(accessor: (b) => b.runningTotal),
    'kind': gr.Variable(accessor: (b) => b.step.type.name),
  },
  marks: [
    gr.IntervalMark(
      position: gr.Varset('step') * (gr.Varset('start') + gr.Varset('end')),
      color: gr.ColorEncode(
        variable: 'kind',
        values: const [
          Color(0xff1565c0),
          Color(0xff2e7d32),
          Color(0xffc62828),
          Color(0xff455a64),
          Color(0xff1565c0),
        ],
      ),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  tooltip: gr.TooltipGuide(variables: ['step', 'contribution', 'running']),
  selections: _selection(),
);

Widget _gantt() => gr.Chart<GanttTask>(
  data: flutterFeatureTasks,
  variables: {
    'task': gr.Variable(accessor: (t) => t.label),
    'start': gr.Variable(
      accessor: (t) => ganttDay(t.start),
      scale: gr.LinearScale(
        min: 1,
        max: 21,
        formatter: (v) => ganttDate(v.toDouble()),
      ),
    ),
    'end': gr.Variable(
      accessor: (t) => ganttDay(t.end),
      scale: gr.LinearScale(
        min: 1,
        max: 21,
        formatter: (v) => ganttDate(v.toDouble()),
      ),
    ),
    'inicio': gr.Variable(accessor: (t) => ganttDate(ganttDay(t.start))),
    'fin': gr.Variable(accessor: (t) => ganttDate(ganttDay(t.end))),
    'dias': gr.Variable(accessor: (t) => t.duration.inDays),
    'avance': gr.Variable(accessor: (t) => '${(t.progress * 100).round()}%'),
  },
  marks: [
    gr.IntervalMark(
      position: gr.Varset('task') * (gr.Varset('start') + gr.Varset('end')),
      color: gr.ColorEncode(value: const Color(0xff1565c0)),
    ),
  ],
  coord: gr.RectCoord(transposed: true),
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
  tooltip: gr.TooltipGuide(
    variables: ['task', 'inicio', 'fin', 'dias', 'avance'],
  ),
  selections: _selection(),
);
