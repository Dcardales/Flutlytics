import 'dart:convert';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:graphify/graphify.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/radial_composition_data.dart';
import '../../domain/chart_concept.dart';
import 'demo_registration.dart';

const _colors = [
  Color(0xff1565c0),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff7b1fa2),
  Color(0xff00838f),
  Color(0xffc62828),
];
const _concepts = ['pie', 'donut', 'waffle', 'polar-area', 'radar'];

class RadialCompositionBatchDemos {
  RadialCompositionBatchDemos._();
  static const newConcepts = _concepts;
  static final registrations = List<ChartDemoRegistration>.unmodifiable([
    for (final id in newConcepts)
      for (final library in ChartLibrary.values)
        ChartDemoRegistration(
          id,
          library,
          () => RadialCompositionChart(id: id, library: library),
        ),
  ]);
}

class RadialCompositionChart extends StatelessWidget {
  const RadialCompositionChart({
    super.key,
    required this.id,
    required this.library,
  });
  final String id;
  final ChartLibrary library;

  @override
  Widget build(BuildContext context) {
    final shares = compositionPercentages(
      id == 'pie' ? reservationSlices : revenueSlices,
    );
    validatePolarArea(tourismDemand);
    validateRadarProfiles(tourismDimensions, tourismProfiles);
    if (library == ChartLibrary.graphify) return _GraphifyRadial(id: id);
    if (id == 'waffle') return _waffle(library);
    if (id == 'polar-area') return _polar(library);
    if (id == 'radar') return _radar(library);
    return _composition(id, library, shares);
  }
}

Widget _composition(
  String id,
  ChartLibrary library,
  CompositionSummary summary,
) {
  final donut = id == 'donut';
  final slices = summary.shares.map((s) => s.slice).toList();
  return Column(
    children: [
      _legend(slices),
      Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (library == ChartLibrary.flChart)
              fl.PieChart(
                fl.PieChartData(
                  centerSpaceRadius: donut ? 56 : 0,
                  sectionsSpace: 2,
                  sections: [
                    for (var i = 0; i < slices.length; i++)
                      fl.PieChartSectionData(
                        value: slices[i].value,
                        title: '${summary.shares[i].percent.round()}%',
                        color: _colors[i],
                        radius: 105,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              )
            else if (library == ChartLibrary.syncfusion)
              sf.SfCircularChart(
                tooltipBehavior: sf.TooltipBehavior(
                  enable: true,
                  format: 'point.x: point.y',
                ),
                series: <sf.CircularSeries<CompositionSlice, String>>[
                  if (donut)
                    sf.DoughnutSeries<CompositionSlice, String>(
                      dataSource: slices,
                      xValueMapper: (p, _) => p.label,
                      yValueMapper: (p, _) => p.value,
                      pointColorMapper: (p, i) => _colors[i % _colors.length],
                      dataLabelSettings: const sf.DataLabelSettings(
                        isVisible: true,
                      ),
                      innerRadius: '55%',
                    )
                  else
                    sf.PieSeries<CompositionSlice, String>(
                      dataSource: slices,
                      xValueMapper: (p, _) => p.label,
                      yValueMapper: (p, _) => p.value,
                      pointColorMapper: (p, i) => _colors[i % _colors.length],
                      dataLabelSettings: const sf.DataLabelSettings(
                        isVisible: true,
                      ),
                    ),
                ],
              )
            else
              _graphicComposition(slices, donut),
            if (donut)
              IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ingresos totales',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                    Text(
                      '\$${summary.total.round()} M',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

Widget _graphicComposition(List<CompositionSlice> slices, bool donut) =>
    gr.Chart<CompositionSlice>(
      data: slices,
      variables: {
        'label': gr.Variable(accessor: (CompositionSlice p) => p.label),
        'value': gr.Variable(accessor: (CompositionSlice p) => p.value),
      },
      transforms: [gr.Proportion(variable: 'value', as: 'percent')],
      marks: [
        gr.IntervalMark(
          position: gr.Varset('percent') / gr.Varset('label'),
          color: gr.ColorEncode(variable: 'label', values: _colors),
          modifiers: [gr.StackModifier()],
        ),
      ],
      coord: gr.PolarCoord(
        transposed: true,
        dimCount: 1,
        startRadius: donut ? .42 : 0,
      ),
      selections: {
        'slice': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
      tooltip: gr.TooltipGuide(variables: ['label', 'value', 'percent']),
    );

Widget _legend(List<CompositionSlice> slices) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
  child: Wrap(
    alignment: WrapAlignment.center,
    spacing: 9,
    runSpacing: 2,
    children: [
      for (var i = 0; i < slices.length; i++)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: _colors[i], size: 9),
            const SizedBox(width: 3),
            Text(slices[i].label, style: const TextStyle(fontSize: 10)),
          ],
        ),
    ],
  ),
);

Widget _waffle(ChartLibrary library) {
  final cells = waffleCells(hotelOccupancyPercent);
  return Column(
    children: [
      const Text(
        '73% ocupadas · 73 de 100 unidades equivalentes',
        style: TextStyle(fontSize: 12),
      ),
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: switch (library) {
                ChartLibrary.flChart => fl.ScatterChart(
                  fl.ScatterChartData(
                    minX: -.5,
                    maxX: 9.5,
                    minY: -.5,
                    maxY: 9.5,
                    titlesData: const fl.FlTitlesData(show: false),
                    gridData: const fl.FlGridData(show: false),
                    borderData: fl.FlBorderData(show: false),
                    scatterSpots: [
                      for (final c in cells)
                        fl.ScatterSpot(
                          c.column.toDouble(),
                          (9 - c.row).toDouble(),
                          dotPainter: fl.FlDotSquarePainter(
                            color: c.active ? _colors[0] : Colors.black12,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
                ChartLibrary.syncfusion => _sfWaffle(cells),
                ChartLibrary.graphic => _graphicWaffle(cells),
                ChartLibrary.graphify => const SizedBox.shrink(),
              },
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _sfWaffle(List<WaffleCell> cells) => sf.SfCartesianChart(
  margin: EdgeInsets.zero,
  plotAreaBorderWidth: 0,
  primaryXAxis: const sf.NumericAxis(
    minimum: -.5,
    maximum: 9.5,
    isVisible: false,
    majorGridLines: sf.MajorGridLines(width: 0),
  ),
  primaryYAxis: const sf.NumericAxis(
    minimum: -.5,
    maximum: 9.5,
    isVisible: false,
    majorGridLines: sf.MajorGridLines(width: 0),
  ),
  series: <sf.CartesianSeries<WaffleCell, int>>[
    sf.ScatterSeries<WaffleCell, int>(
      dataSource: cells,
      xValueMapper: (c, _) => c.column,
      yValueMapper: (c, _) => 9 - c.row,
      pointColorMapper: (c, _) => c.active ? _colors[0] : Colors.black12,
      markerSettings: const sf.MarkerSettings(
        shape: sf.DataMarkerType.rectangle,
        width: 15,
        height: 15,
      ),
      animationDuration: 0,
    ),
  ],
);

Widget _graphicWaffle(List<WaffleCell> cells) => gr.Chart<WaffleCell>(
  data: cells,
  variables: {
    'x': gr.Variable(
      accessor: (WaffleCell c) => c.column,
      scale: gr.LinearScale(min: -.5, max: 9.5),
    ),
    'y': gr.Variable(
      accessor: (WaffleCell c) => 9 - c.row,
      scale: gr.LinearScale(min: -.5, max: 9.5),
    ),
    'state': gr.Variable(
      accessor: (WaffleCell c) => c.active ? 'Ocupada' : 'Disponible',
    ),
  },
  marks: [
    gr.PolygonMark(
      position: gr.Varset('x') * gr.Varset('y'),
      shape: gr.ShapeEncode(value: gr.HeatmapShape(tileCounts: [10, 10])),
      color: gr.ColorEncode(
        variable: 'state',
        values: [_colors[0], Colors.black12],
      ),
    ),
  ],
  axes: [],
);

Widget _polar(ChartLibrary library) {
  final max = maxAcrossPolarPanels([tourismDemand]);
  return Column(
    children: [
      const Text('Solicitudes por categoría · radio = volumen'),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 7,
        runSpacing: 1,
        children: [
          for (var i = 0; i < tourismDemand.length; i++)
            Text(
              '${tourismDemand[i].label} ${tourismDemand[i].value.toInt()}',
              style: TextStyle(fontSize: 8, color: _colors[i]),
            ),
        ],
      ),
      Expanded(
        child: switch (library) {
          ChartLibrary.flChart => fl.PieChart(
            fl.PieChartData(
              centerSpaceRadius: 0,
              sectionsSpace: 2,
              sections: [
                for (var i = 0; i < tourismDemand.length; i++)
                  fl.PieChartSectionData(
                    value: 1,
                    radius: 36 + tourismDemand[i].value / max * 75,
                    color: _colors[i],
                    title: tourismDemand[i].label,
                    titleStyle: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          ChartLibrary.syncfusion => sf.SfCircularChart(
            series: <sf.CircularSeries<PolarDatum, String>>[
              sf.PieSeries<PolarDatum, String>(
                dataSource: tourismDemand,
                xValueMapper: (p, _) => p.label,
                yValueMapper: (p, _) => 1,
                pointRadiusMapper: (p, _) =>
                    '${(28 + p.value / max * 55).round()}%',
                pointColorMapper: (p, i) => _colors[i % _colors.length],
                dataLabelSettings: const sf.DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 8),
                ),
              ),
            ],
            tooltipBehavior: sf.TooltipBehavior(enable: true),
          ),
          ChartLibrary.graphic => _graphicPolarArea(),
          ChartLibrary.graphify => const SizedBox.shrink(),
        },
      ),
    ],
  );
}

Widget _graphicPolarArea() => gr.Chart<PolarDatum>(
  data: tourismDemand,
  variables: {
    'category': gr.Variable(accessor: (PolarDatum p) => p.label),
    'value': gr.Variable(
      accessor: (PolarDatum p) => p.value,
      scale: gr.LinearScale(min: 0, max: 2300),
    ),
  },
  marks: [
    gr.IntervalMark(
      position: gr.Varset('category') * gr.Varset('value'),
      color: gr.ColorEncode(variable: 'category', values: _colors),
    ),
  ],
  coord: gr.PolarCoord(startRadius: .1),
  selections: {
    'cat': gr.PointSelection(
      on: {gr.GestureType.hover, gr.GestureType.tap},
      dim: gr.Dim.x,
    ),
  },
  tooltip: gr.TooltipGuide(variables: ['category', 'value']),
);

Widget _radar(ChartLibrary library) {
  if (library == ChartLibrary.flChart) {
    return const _FlRadarPanel();
  }
  if (library == ChartLibrary.syncfusion) return _sfRadar();
  return _graphicRadar();
}

class _FlRadarPanel extends StatefulWidget {
  const _FlRadarPanel();

  @override
  State<_FlRadarPanel> createState() => _FlRadarPanelState();
}

class _FlRadarPanelState extends State<_FlRadarPanel> {
  String? _selected;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: fl.RadarChart(
          fl.RadarChartData(
            dataSets: [
              for (var i = 0; i < tourismProfiles.length; i++)
                fl.RadarDataSet(
                  dataEntries: [
                    for (final value in tourismProfiles[i].values)
                      fl.RadarEntry(value: value),
                  ],
                  fillColor: _colors[i].withValues(alpha: .16),
                  borderColor: _colors[i],
                  entryRadius: 3,
                ),
            ],
            radarShape: fl.RadarShape.polygon,
            tickCount: 5,
            getTitle: (index, _) => fl.RadarChartTitle(
              text: tourismDimensions[index],
              angle: 0,
              positionPercentageOffset: .18,
            ),
            titleTextStyle: const TextStyle(fontSize: 8),
            tickBorderData: const BorderSide(color: Colors.black26, width: .6),
            gridBorderData: const BorderSide(color: Colors.black26, width: .6),
            radarTouchData: fl.RadarTouchData(
              touchCallback: (event, response) {
                final touched = response?.touchedSpot;
                if (touched == null) return;
                final profile = tourismProfiles[touched.touchedDataSetIndex];
                final dimension =
                    tourismDimensions[touched.touchedRadarEntryIndex];
                setState(() {
                  _selected =
                      '${profile.label} · $dimension: ${touched.touchedRadarEntry.value}/10';
                });
              },
            ),
          ),
        ),
      ),
      if (_selected != null)
        Text(_selected!, style: const TextStyle(fontSize: 9)),
      _profileLegend(),
    ],
  );
}

Widget _sfRadar() {
  final series = <sf.CartesianSeries<_RadarXY, double>>[];
  final n = tourismDimensions.length;
  for (var ring = 2; ring <= 10; ring += 2) {
    series.add(
      sf.LineSeries<_RadarXY, double>(
        dataSource: [
          for (var i = 0; i <= n; i++)
            _RadarXY(
              ring * math.cos(2 * math.pi * i / n),
              ring * math.sin(2 * math.pi * i / n),
            ),
        ],
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,
        color: Colors.black26,
        width: .7,
        enableTooltip: false,
        animationDuration: 0,
      ),
    );
  }
  for (var i = 0; i < n; i++) {
    series.add(
      sf.LineSeries<_RadarXY, double>(
        dataSource: [
          const _RadarXY(0, 0),
          _RadarXY(
            10 * math.cos(2 * math.pi * i / n),
            10 * math.sin(2 * math.pi * i / n),
          ),
        ],
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,
        color: Colors.black26,
        width: .6,
        enableTooltip: false,
        animationDuration: 0,
      ),
    );
  }
  for (var p = 0; p < tourismProfiles.length; p++) {
    final profile = tourismProfiles[p];
    series.add(
      sf.LineSeries<_RadarXY, double>(
        name: profile.label,
        dataSource: [
          for (var i = 0; i <= n; i++)
            _RadarXY(
              profile.values[i % n] * math.cos(2 * math.pi * i / n),
              profile.values[i % n] * math.sin(2 * math.pi * i / n),
            ),
        ],
        xValueMapper: (v, _) => v.x,
        yValueMapper: (v, _) => v.y,
        color: _colors[p],
        width: 2,
        enableTooltip: true,
        markerSettings: const sf.MarkerSettings(isVisible: true),
        animationDuration: 0,
      ),
    );
  }
  return Column(
    children: [
      Expanded(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: sf.SfCartesianChart(
              primaryXAxis: const sf.NumericAxis(
                minimum: -11,
                maximum: 11,
                isVisible: false,
              ),
              primaryYAxis: const sf.NumericAxis(
                minimum: -11,
                maximum: 11,
                isVisible: false,
              ),
              tooltipBehavior: sf.TooltipBehavior(enable: true),
              onTooltipRender: (args) {
                final profileIndex = (args.seriesIndex as int) - 11;
                final dimensionIndex =
                    (args.pointIndex?.toInt() ?? 0) % tourismDimensions.length;
                if (profileIndex >= 0 &&
                    profileIndex < tourismProfiles.length) {
                  args.header = tourismProfiles[profileIndex].label;
                  args.text =
                      '${tourismDimensions[dimensionIndex]}: ${tourismProfiles[profileIndex].values[dimensionIndex]}/10';
                }
              },
              series: series,
            ),
          ),
        ),
      ),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 0,
        children: [
          for (final dimension in tourismDimensions)
            Text(dimension, style: const TextStyle(fontSize: 8)),
        ],
      ),
      _profileLegend(),
    ],
  );
}

class _RadarXY {
  const _RadarXY(this.x, this.y);
  final double x, y;
}

Widget _graphicRadar() {
  final rows = <_RadarGraphic>[];
  for (final p in tourismProfiles) {
    for (var i = 0; i < tourismDimensions.length; i++) {
      rows.add(_RadarGraphic(tourismDimensions[i], p.values[i], p.label));
    }
  }
  return Column(
    children: [
      Expanded(
        child: gr.Chart<_RadarGraphic>(
          data: rows,
          variables: {
            'dimension': gr.Variable(
              accessor: (_RadarGraphic p) => p.dimension,
            ),
            'score': gr.Variable(
              accessor: (_RadarGraphic p) => p.score,
              scale: gr.LinearScale(min: 0, max: 10),
            ),
            'profile': gr.Variable(accessor: (_RadarGraphic p) => p.profile),
          },
          marks: [
            gr.AreaMark(
              position:
                  gr.Varset('dimension') *
                  gr.Varset('score') /
                  gr.Varset('profile'),
              color: gr.ColorEncode(variable: 'profile', values: _colors),
            ),
            gr.LineMark(
              position:
                  gr.Varset('dimension') *
                  gr.Varset('score') /
                  gr.Varset('profile'),
              color: gr.ColorEncode(variable: 'profile', values: _colors),
            ),
          ],
          coord: gr.PolarCoord(startRadius: .05),
          axes: [gr.Defaults.radialAxis, gr.Defaults.circularAxis],
          selections: {
            'radar': gr.PointSelection(
              on: {gr.GestureType.hover, gr.GestureType.tap},
              dim: gr.Dim.x,
            ),
          },
          tooltip: gr.TooltipGuide(
            variables: ['profile', 'dimension', 'score'],
          ),
        ),
      ),
      _profileLegend(),
    ],
  );
}

Widget _profileLegend() => Wrap(
  alignment: WrapAlignment.center,
  spacing: 12,
  children: [
    for (var i = 0; i < tourismProfiles.length; i++)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 9, color: _colors[i]),
          const SizedBox(width: 3),
          Text(tourismProfiles[i].label, style: const TextStyle(fontSize: 9)),
        ],
      ),
  ],
);

class _RadarGraphic {
  const _RadarGraphic(this.dimension, this.score, this.profile);
  final String dimension, profile;
  final double score;
}

Map<String, dynamic> graphifyRadialOptions(String id) {
  if (id == 'pie' || id == 'donut') {
    final summary = compositionPercentages(
      id == 'pie' ? reservationSlices : revenueSlices,
    );
    return {
      'animation': false,
      'tooltip': {'trigger': 'item', 'formatter': '{b}: {c} ({d}%)'},
      'legend': {'type': 'scroll', 'bottom': 0},
      'series': [
        {
          'type': 'pie',
          'radius': id == 'donut' ? ['42%', '68%'] : '68%',
          'center': ['50%', '48%'],
          'data': [
            for (var i = 0; i < summary.shares.length; i++)
              {
                'name': summary.shares[i].slice.label,
                'value': summary.shares[i].slice.value,
                'itemStyle': {
                  'color':
                      '#${_colors[i].toARGB32().toRadixString(16).substring(2)}',
                },
              },
          ],
        },
      ],
    };
  }
  if (id == 'waffle') {
    final cells = waffleCells(hotelOccupancyPercent);
    return {
      'animation': false,
      'tooltip': {'show': false},
      'grid': {'left': 2, 'right': 2, 'top': 2, 'bottom': 2},
      'xAxis': {
        'type': 'value',
        'min': -.5,
        'max': 9.5,
        'show': false,
        'splitLine': {'show': false},
      },
      'yAxis': {
        'type': 'value',
        'min': -.5,
        'max': 9.5,
        'show': false,
        'splitLine': {'show': false},
      },
      'series': [
        {
          'type': 'scatter',
          'symbol': 'rect',
          'symbolSize': 17,
          'data': [
            for (final c in cells)
              {
                'value': [c.column, 9 - c.row],
                'itemStyle': {'color': c.active ? '#1565c0' : '#d6d6d6'},
              },
          ],
        },
      ],
    };
  }
  if (id == 'polar-area') {
    return {
      'animation': false,
      'tooltip': {'trigger': 'item', 'formatter': '{b}: {c} solicitudes'},
      'angleAxis': {
        'type': 'category',
        'data': [for (final p in tourismDemand) p.label],
        'startAngle': 90,
      },
      'radiusAxis': {'min': 0, 'max': 2300},
      'polar': {},
      'series': [
        {
          'type': 'bar',
          'coordinateSystem': 'polar',
          'data': [for (final p in tourismDemand) p.value],
          'itemStyle': {'color': '#1565c0'},
        },
      ],
    };
  }
  return {
    'animation': false,
    'tooltip': {'trigger': 'item'},
    'legend': {
      'data': [for (final p in tourismProfiles) p.label],
    },
    'radar': {
      'indicator': [
        for (final d in tourismDimensions) {'name': d, 'max': 10, 'min': 0},
      ],
      'radius': '65%',
    },
    'series': [
      {
        'type': 'radar',
        'data': [
          for (var p = 0; p < tourismProfiles.length; p++)
            {
              'name': tourismProfiles[p].label,
              'value': tourismProfiles[p].values,
              'areaStyle': {'opacity': .12},
              'lineStyle': {
                'width': 2,
                'color':
                    '#${_colors[p].toARGB32().toRadixString(16).substring(2)}',
              },
              'itemStyle': {
                'color':
                    '#${_colors[p].toARGB32().toRadixString(16).substring(2)}',
              },
            },
        ],
      },
    ],
  };
}

String encodeGraphifyRadialOptions(String id) =>
    jsonEncode(graphifyRadialOptions(id));

class _GraphifyRadial extends StatefulWidget {
  const _GraphifyRadial({required this.id});
  final String id;
  @override
  State<_GraphifyRadial> createState() => _GraphifyRadialState();
}

class _GraphifyRadialState extends State<_GraphifyRadial> {
  final _controller = GraphifyController();
  @override
  Widget build(BuildContext context) {
    final chart = GraphifyView(
      controller: _controller,
      initialOptions: graphifyRadialOptions(widget.id),
    );
    if (widget.id == 'waffle') {
      return Column(
        children: [
          const Text('73% ocupadas · 73 de 100 unidades equivalentes'),
          Expanded(
            child: Center(child: AspectRatio(aspectRatio: 1, child: chart)),
          ),
        ],
      );
    }
    if (widget.id == 'donut') {
      return Stack(
        alignment: Alignment.center,
        children: [
          chart,
          const IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ingresos totales', style: TextStyle(fontSize: 11)),
                Text('\$100 M', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      );
    }
    return chart;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
