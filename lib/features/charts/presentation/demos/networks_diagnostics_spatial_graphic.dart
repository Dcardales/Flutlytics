import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/networks_diagnostics_spatial_data.dart';
import 'networks_diagnostics_spatial_batch_demos.dart';

Widget buildGraphicNetworksDiagnosticsSpatial(String id) => switch (id) {
  'network-graph' => _network(),
  'qq-plot' => _qq(),
  'parallel-coordinates' => parallelFrame(_parallel()),
  'contour' => _contour(),
  'calendar-heatmap' => calendarFrame(_calendar()),
  _ => throw ArgumentError.value(id, 'id'),
};

class _Row {
  const _Row(
    this.group,
    this.kind,
    this.x,
    this.y,
    this.label,
    this.detail, [
    this.shade = '0',
  ]);
  final String group, kind, label, detail, shade;
  final double x, y;
}

Map<String, gr.Variable<_Row, dynamic>> _vars(
  double minX,
  double maxX,
  double minY,
  double maxY,
) => {
  'group': gr.Variable(accessor: (r) => r.group),
  'kind': gr.Variable(accessor: (r) => r.kind),
  'label': gr.Variable(accessor: (r) => r.label),
  'detail': gr.Variable(accessor: (r) => r.detail),
  'shade': gr.Variable(accessor: (r) => r.shade),
  'x': gr.Variable(
    accessor: (r) => r.x,
    scale: gr.LinearScale(min: minX, max: maxX),
  ),
  'y': gr.Variable(
    accessor: (r) => r.y,
    scale: gr.LinearScale(min: minY, max: maxY),
  ),
};

Map<String, gr.Selection> _selection() => {
  'point': gr.PointSelection(
    on: {gr.GestureType.hover, gr.GestureType.tap},
    dim: gr.Dim.x,
  ),
};

Widget _chart(
  List<_Row> rows,
  double minX,
  double maxX,
  double minY,
  double maxY,
  List<gr.Mark> marks, {
  bool axes = true,
}) => gr.Chart<_Row>(
  data: rows,
  variables: _vars(minX, maxX, minY, maxY),
  marks: marks,
  axes: axes ? [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis] : [],
  tooltip: gr.TooltipGuide(variables: ['label', 'detail']),
  selections: _selection(),
);

Widget _network() {
  final rows = <_Row>[
    for (var i = 0; i < touristNetwork.edges.length; i++) ...[
      _Row(
        'edge$i',
        'edge',
        touristNetwork.byId[touristNetwork.edges[i].sourceId]!.x,
        touristNetwork.byId[touristNetwork.edges[i].sourceId]!.y,
        'Conexión',
        'peso ${touristNetwork.edges[i].weight}',
      ),
      _Row(
        'edge$i',
        'edge',
        touristNetwork.byId[touristNetwork.edges[i].targetId]!.x,
        touristNetwork.byId[touristNetwork.edges[i].targetId]!.y,
        'Conexión',
        'peso ${touristNetwork.edges[i].weight}',
      ),
    ],
    for (final p in touristNetwork.positions)
      _Row(p.node.id, 'node', p.x, p.y, p.node.label, networkTooltip(p)),
  ];
  return Column(
    children: [
      const Text(
        'Red de destinos y servicios · disposición circular',
        style: TextStyle(fontSize: 11),
      ),
      Expanded(
        child: _chart(rows, -1.25, 1.25, -1.25, 1.25, [
          gr.LineMark(
            position: gr.Varset('x') * gr.Varset('y') / gr.Varset('group'),
            color: gr.ColorEncode(value: const Color(0xff90a4ae)),
          ),
          gr.PointMark(
            position: gr.Varset('x') * gr.Varset('y'),
            size: gr.SizeEncode(variable: 'kind', values: [0, 14]),
            color: gr.ColorEncode(
              variable: 'kind',
              values: const [Colors.transparent, Color(0xff1565c0)],
            ),
          ),
        ], axes: false),
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
}

Widget _qq() => _chart(
  [
    const _Row('ideal', 'ideal', -3, -3, 'Ideal', 'y=x'),
    const _Row('ideal', 'ideal', 3, 3, 'Ideal', 'y=x'),
    for (final p in serviceQq)
      _Row(
        'quantile${p.probability}',
        'point',
        p.theoretical,
        p.observed,
        'Tiempo de servicio',
        'Normal ${p.theoretical.toStringAsFixed(2)}; observado z=${p.observed.toStringAsFixed(2)}',
      ),
  ],
  -3,
  3,
  -3,
  3,
  [
    gr.LineMark(
      position: gr.Varset('x') * gr.Varset('y') / gr.Varset('group'),
      color: gr.ColorEncode(value: const Color(0xff78909c)),
    ),
    gr.PointMark(
      position: gr.Varset('x') * gr.Varset('y'),
      size: gr.SizeEncode(variable: 'kind', values: [0, 7]),
      color: gr.ColorEncode(value: const Color(0xff1565c0)),
    ),
  ],
);

Widget _parallel() => _chart(
  [
    for (final p in touristParallel.points)
      _Row(
        p.observation.label,
        'observation',
        p.axis.toDouble(),
        p.normalized,
        p.observation.label,
        '${p.variable.label}: ${p.raw.toStringAsFixed(1)} ${p.variable.unit}',
      ),
  ],
  0,
  (touristParallel.variables.length - 1).toDouble(),
  0,
  1,
  [
    gr.LineMark(
      position: gr.Varset('x') * gr.Varset('y') / gr.Varset('group'),
      color: gr.ColorEncode(
        variable: 'group',
        values: Colors.primaries.take(10).toList(),
      ),
      size: gr.SizeEncode(value: 2),
    ),
    gr.PointMark(
      position: gr.Varset('x') * gr.Varset('y'),
      size: gr.SizeEncode(value: 4),
      color: gr.ColorEncode(
        variable: 'group',
        values: Colors.primaries.take(10).toList(),
      ),
    ),
  ],
);

Widget _contour() => _chart(
  [
    for (var i = 0; i < touristContour.segments.length; i++) ...[
      _Row(
        'segment$i',
        'line',
        touristContour.segments[i].a.x,
        touristContour.segments[i].a.y,
        'Curva de nivel',
        'Intensidad ${touristContour.segments[i].level.toStringAsFixed(1)}',
        touristContour.levels
            .indexOf(touristContour.segments[i].level)
            .toString(),
      ),
      _Row(
        'segment$i',
        'line',
        touristContour.segments[i].b.x,
        touristContour.segments[i].b.y,
        'Curva de nivel',
        'Intensidad ${touristContour.segments[i].level.toStringAsFixed(1)}',
        touristContour.levels
            .indexOf(touristContour.segments[i].level)
            .toString(),
      ),
    ],
  ],
  0,
  24,
  0,
  19,
  [
    gr.LineMark(
      position: gr.Varset('x') * gr.Varset('y') / gr.Varset('group'),
      color: gr.ColorEncode(
        variable: 'shade',
        values: Colors.primaries.take(6).toList(),
      ),
      size: gr.SizeEncode(value: 1.7),
    ),
  ],
);

Widget _calendar() => Column(
  children: [
    Wrap(
      spacing: 12,
      children: [
        for (var i = 0; i < 7; i++)
          Text(
            '${weekdayLabels[i]} = ${const ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'][i]}',
            style: const TextStyle(fontSize: 9),
          ),
      ],
    ),
    Expanded(
      child: _chart(
        [
          for (final c in bookingCalendar.cells)
            _Row(
              'day${isoDay(c.day.date)}',
              'day',
              c.week.toDouble(),
              c.weekday.toDouble(),
              isoDay(c.day.date),
              '${c.day.value.toStringAsFixed(0)} reservas',
              (bookingCalendar.intensity(c.day) * 4)
                  .floor()
                  .clamp(0, 4)
                  .toString(),
            ),
        ],
        -1,
        bookingCalendar.cells.last.week + 1.0,
        -.6,
        6.6,
        [
          gr.PointMark(
            position: gr.Varset('x') * gr.Varset('y'),
            shape: gr.ShapeEncode(value: gr.SquareShape()),
            size: gr.SizeEncode(value: 13),
            color: gr.ColorEncode(
              variable: 'shade',
              values: const [
                Color(0xffe3f2fd),
                Color(0xffbbdefb),
                Color(0xff64b5f6),
                Color(0xff1976d2),
                Color(0xff0d47a1),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
);
