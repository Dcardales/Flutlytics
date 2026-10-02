import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/performance_process_data.dart';
import 'performance_process_batch_demos.dart';

Widget buildGraphicPerformanceProcess(String id) => switch (id) {
  'funnel' => _funnel(),
  'pyramid' => _pyramid(),
  'gauge' => _gauge(),
  'bullet' => _bullet(),
  'timeline' => timelineFrame(_timeline()),
  _ => throw ArgumentError.value(id, 'id'),
};

Map<String, gr.Selection> _selection() => {
  'point': gr.PointSelection(
    on: {gr.GestureType.hover, gr.GestureType.tap},
    dim: gr.Dim.x,
  ),
};

Widget _funnel() => Column(
  children: [
    const Text(
      'Conversión de reservas · ancho proporcional a personas',
      style: TextStyle(fontSize: 11),
    ),
    Expanded(
      child: gr.Chart<FunnelStep>(
        data: [
          ...bookingFunnel.steps,
          FunnelStep(
            bookingFunnel.steps.last.stage,
            5,
            bookingFunnel.steps.last.conversionFromPrevious,
            bookingFunnel.steps.last.conversionFromStart,
            bookingFunnel.steps.last.dropOff,
          ),
        ],
        variables: {
          'stage': gr.Variable(accessor: (FunnelStep s) => s.stage.label),
          'index': gr.Variable(
            accessor: (FunnelStep s) => s.index.toDouble(),
            scale: gr.LinearScale(min: 0, max: 5),
          ),
          'upper': gr.Variable(
            accessor: (FunnelStep s) => s.stage.value / 2,
            scale: gr.LinearScale(min: -5500, max: 5500),
          ),
          'lower': gr.Variable(
            accessor: (FunnelStep s) => -s.stage.value / 2,
            scale: gr.LinearScale(min: -5500, max: 5500),
          ),
          'count': gr.Variable(accessor: (FunnelStep s) => s.stage.value),
          'previous': gr.Variable(
            accessor: (FunnelStep s) =>
                formatConversion(s.conversionFromPrevious),
          ),
          'start': gr.Variable(
            accessor: (FunnelStep s) => formatConversion(s.conversionFromStart),
          ),
        },
        marks: [
          gr.AreaMark(
            position:
                gr.Varset('index') * (gr.Varset('lower') + gr.Varset('upper')),
            color: gr.ColorEncode(value: const Color(0x8842a5f5)),
          ),
          gr.LineMark(
            position: gr.Varset('index') * gr.Varset('upper'),
            color: gr.ColorEncode(value: const Color(0xff1565c0)),
          ),
          gr.LineMark(
            position: gr.Varset('index') * gr.Varset('lower'),
            color: gr.ColorEncode(value: const Color(0xff1565c0)),
          ),
          gr.PointMark(
            position: gr.Varset('index') * gr.Varset('upper'),
            size: gr.SizeEncode(value: 7),
          ),
        ],
        axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
        tooltip: gr.TooltipGuide(
          variables: ['stage', 'count', 'previous', 'start'],
        ),
        selections: _selection(),
      ),
    ),
    Wrap(
      spacing: 8,
      runSpacing: 2,
      children: [
        for (var i = 0; i < funnelShortLabels.length; i++)
          Text(
            '${i + 1}. ${funnelShortLabels[i]}',
            style: const TextStyle(fontSize: 9),
          ),
      ],
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
      child: gr.Chart<PopulationPyramidRow>(
        data: touristAgePyramid.rows,
        variables: {
          'age': gr.Variable(accessor: (PopulationPyramidRow r) => r.category),
          'zero': gr.Variable(
            accessor: (PopulationPyramidRow r) => 0.0,
            scale: gr.LinearScale(min: -260, max: 260),
          ),
          'left': gr.Variable(
            accessor: (PopulationPyramidRow r) => r.leftCoordinate,
            scale: gr.LinearScale(min: -260, max: 260),
          ),
          'right': gr.Variable(
            accessor: (PopulationPyramidRow r) => r.rightCoordinate,
            scale: gr.LinearScale(min: -260, max: 260),
          ),
          'nacionales': gr.Variable(
            accessor: (PopulationPyramidRow r) => r.leftValue,
          ),
          'internacionales': gr.Variable(
            accessor: (PopulationPyramidRow r) => r.rightValue,
          ),
        },
        marks: [
          gr.LineMark(
            position: gr.Varset('age') * gr.Varset('zero'),
            color: gr.ColorEncode(value: const Color(0xff263238)),
            size: gr.SizeEncode(value: 2),
          ),
          gr.IntervalMark(
            position:
                gr.Varset('age') * (gr.Varset('zero') + gr.Varset('left')),
            color: gr.ColorEncode(value: const Color(0xff1565c0)),
            size: gr.SizeEncode(value: 12),
          ),
          gr.IntervalMark(
            position:
                gr.Varset('age') * (gr.Varset('zero') + gr.Varset('right')),
            color: gr.ColorEncode(value: const Color(0xffef6c00)),
            size: gr.SizeEncode(value: 12),
          ),
        ],
        coord: gr.RectCoord(transposed: true),
        axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
        tooltip: gr.TooltipGuide(
          variables: ['age', 'nacionales', 'internacionales'],
        ),
        selections: _selection(),
      ),
    ),
  ],
);

class _Sector {
  const _Sector(this.part, this.value, this.color);
  final String part;
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
        child: gr.Chart<_Sector>(
          data: sectors,
          variables: {
            'part': gr.Variable(accessor: (_Sector s) => s.part),
            'value': gr.Variable(accessor: (_Sector s) => s.value),
          },
          transforms: [gr.Proportion(variable: 'value', as: 'share')],
          marks: [
            gr.IntervalMark(
              position: gr.Varset('share') / gr.Varset('part'),
              modifiers: [gr.StackModifier()],
              color: gr.ColorEncode(
                encoder: (tuple) =>
                    sectors.firstWhere((s) => s.part == tuple['part']).color,
              ),
            ),
          ],
          coord: gr.PolarCoord(
            transposed: true,
            dimCount: 1,
            startAngle: math.pi,
            endAngle: 3 * math.pi,
            startRadius: .62,
          ),
          tooltip: gr.TooltipGuide(variables: ['part', 'value']),
          selections: _selection(),
        ),
      ),
      gaugeCaption(),
      const SizedBox(height: 6),
    ],
  );
}

class _BulletRow {
  const _BulletRow(this.kind, this.range, this.start, this.end);
  final String kind, range;
  final double start, end;
}

Widget _bullet() {
  final rows = <_BulletRow>[
    for (final band in monthlyRevenueBullet.bands)
      _BulletRow('band', band.label, band.start, band.end),
    _BulletRow(
      'actual',
      'Actual',
      monthlyRevenueBullet.min,
      monthlyRevenueBullet.value,
    ),
    _BulletRow(
      'target',
      'Meta',
      monthlyRevenueBullet.target - .5,
      monthlyRevenueBullet.target + .5,
    ),
  ];
  return Column(
    children: [
      const Text(
        'Ingresos mensuales · barra=actual · línea=meta',
        style: TextStyle(fontSize: 11),
      ),
      Expanded(
        child: gr.Chart<_BulletRow>(
          data: rows,
          variables: {
            'metric': gr.Variable(
              accessor: (_BulletRow r) => monthlyRevenueBullet.label,
            ),
            'kind': gr.Variable(accessor: (_BulletRow r) => r.kind),
            'range': gr.Variable(accessor: (_BulletRow r) => r.range),
            'start': gr.Variable(
              accessor: (_BulletRow r) => r.start,
              scale: gr.LinearScale(min: 0, max: 100),
            ),
            'end': gr.Variable(
              accessor: (_BulletRow r) => r.end,
              scale: gr.LinearScale(min: 0, max: 100),
            ),
          },
          marks: [
            gr.IntervalMark(
              position:
                  gr.Varset('metric') * (gr.Varset('start') + gr.Varset('end')),
              size: gr.SizeEncode(
                encoder: (tuple) => switch (tuple['kind']) {
                  'actual' => 14,
                  'target' => 38,
                  _ => 34,
                },
              ),
              color: gr.ColorEncode(
                encoder: (tuple) => switch (tuple['kind']) {
                  'actual' => const Color(0xff1565c0),
                  'target' => const Color(0xffc62828),
                  _ => switch (tuple['range']) {
                    'Insuficiente' => const Color(0xffeceff1),
                    'Aceptable' => const Color(0xffb0bec5),
                    _ => const Color(0xff78909c),
                  },
                },
              ),
            ),
          ],
          coord: gr.RectCoord(transposed: true),
          axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
          tooltip: gr.TooltipGuide(
            variables: ['metric', 'range', 'start', 'end'],
          ),
          selections: _selection(),
        ),
      ),
      const Text(
        'Bajo <60 · aceptable 60–80 · bueno 80–100 · meta 90',
        style: TextStyle(fontSize: 10),
      ),
    ],
  );
}

class _TimeRow {
  const _TimeRow(
    this.group,
    this.date,
    this.y,
    this.label,
    this.detail,
    this.kind,
  );
  final String group, label, detail, kind;
  final DateTime date;
  final double y;
}

Widget _timeline() {
  final rows = <_TimeRow>[
    _TimeRow(
      'baseline',
      flutterMilestones.events.first.date,
      0,
      '',
      '',
      'line',
    ),
    _TimeRow('baseline', flutterMilestones.events.last.date, 0, '', '', 'line'),
    for (final p in flutterMilestones.points) ...[
      _TimeRow(p.event.id, p.event.date, 0, '', '', 'line'),
      _TimeRow(
        p.event.id,
        p.event.date,
        p.lane,
        p.event.title,
        timelineTip(p),
        'event',
      ),
    ],
  ];
  return gr.Chart<_TimeRow>(
    data: rows,
    variables: {
      'group': gr.Variable(accessor: (_TimeRow r) => r.group),
      'date': gr.Variable(
        accessor: (_TimeRow r) => r.date,
        scale: gr.TimeScale(
          min: flutterMilestones.events.first.date,
          max: flutterMilestones.events.last.date,
          formatter: (date) => '${date.month}/${date.year}',
        ),
      ),
      'lane': gr.Variable(
        accessor: (_TimeRow r) => r.y,
        scale: gr.LinearScale(min: -1.5, max: 1.5),
      ),
      'label': gr.Variable(accessor: (_TimeRow r) => r.label),
      'detail': gr.Variable(accessor: (_TimeRow r) => r.detail),
      'kind': gr.Variable(accessor: (_TimeRow r) => r.kind),
    },
    marks: [
      gr.LineMark(
        position: gr.Varset('date') * gr.Varset('lane') / gr.Varset('group'),
        color: gr.ColorEncode(value: const Color(0xff607d8b)),
      ),
      gr.PointMark(
        position: gr.Varset('date') * gr.Varset('lane'),
        size: gr.SizeEncode(
          encoder: (tuple) => tuple['kind'] == 'event' ? 9 : 0,
        ),
        color: gr.ColorEncode(value: const Color(0xff1565c0)),
        label: gr.LabelEncode(
          encoder: (tuple) => gr.Label(
            tuple['label'],
            gr.LabelStyle(textStyle: const TextStyle(fontSize: 9)),
          ),
        ),
      ),
    ],
    axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
    tooltip: gr.TooltipGuide(variables: ['label', 'detail']),
    selections: _selection(),
  );
}
