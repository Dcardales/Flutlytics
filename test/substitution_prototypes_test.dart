// Executable risk prototypes. These are not production demo registrations.
import 'dart:convert';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphic/graphic.dart' as gr;
import 'package:graphify/graphify.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

typedef _Pair = ({double x, double y});
typedef _Band = ({
  double x,
  double low90,
  double low50,
  double high50,
  double high90,
});

const _pairs = <_Pair>[
  (x: 0.15, y: 0.2),
  (x: 0.35, y: 0.42),
  (x: 0.65, y: 0.61),
  (x: 0.85, y: 0.9),
];

const _bands = <_Band>[
  (x: 0, low90: 7, low50: 9, high50: 11, high90: 13),
  (x: 1, low90: 6, low50: 8, high50: 12, high90: 15),
  (x: 2, low90: 5, low50: 7, high50: 13, high90: 17),
];

List<fl.FlSpot> _bandSpots(double Function(_Band) value) => [
  for (final row in _bands) fl.FlSpot(row.x, value(row)),
];

Widget _flMatrix() => GridView.count(
  crossAxisCount: 2,
  children: [
    for (var i = 0; i < 4; i++)
      fl.ScatterChart(
        fl.ScatterChartData(
          minX: 0,
          maxX: 1,
          minY: 0,
          maxY: 1,
          scatterSpots: [
            for (final point in _pairs)
              fl.ScatterSpot(
                i.isEven ? point.x : point.y,
                i < 2 ? point.y : 1 - point.x,
              ),
          ],
        ),
      ),
  ],
);

Widget _flTernary() {
  final components = <({double a, double b, double c})>[
    (a: 0.2, b: 0.3, c: 0.5),
    (a: 0.5, b: 0.4, c: 0.1),
  ];
  return fl.LineChart(
    fl.LineChartData(
      minX: 0,
      maxX: 1,
      minY: 0,
      maxY: 0.9,
      lineBarsData: [
        fl.LineChartBarData(
          spots: [
            const fl.FlSpot(0, 0),
            const fl.FlSpot(1, 0),
            fl.FlSpot(0.5, math.sqrt(3) / 2),
            const fl.FlSpot(0, 0),
          ],
          dotData: const fl.FlDotData(show: false),
        ),
        fl.LineChartBarData(
          spots: [
            for (final row in components)
              fl.FlSpot(row.b + row.c / 2, row.c * math.sqrt(3) / 2),
          ],
          barWidth: 0,
          dotData: const fl.FlDotData(show: true),
        ),
      ],
    ),
  );
}

Widget _flFan() => fl.LineChart(
  fl.LineChartData(
    minX: 0,
    maxX: 2,
    minY: 0,
    maxY: 20,
    lineBarsData: [
      for (final getter in <double Function(_Band)>[
        (r) => r.low90,
        (r) => r.low50,
        (r) => r.high50,
        (r) => r.high90,
      ])
        fl.LineChartBarData(spots: _bandSpots(getter)),
    ],
    betweenBarsData: [
      fl.BetweenBarsData(
        fromIndex: 0,
        toIndex: 3,
        color: Colors.blue.withValues(alpha: 0.15),
      ),
      fl.BetweenBarsData(
        fromIndex: 1,
        toIndex: 2,
        color: Colors.blue.withValues(alpha: 0.35),
      ),
    ],
  ),
);

Widget _flQq() => fl.LineChart(
  fl.LineChartData(
    minX: 0,
    maxX: 1,
    minY: 0,
    maxY: 1,
    lineBarsData: [
      fl.LineChartBarData(
        spots: [const fl.FlSpot(0, 0), const fl.FlSpot(1, 1)],
        dotData: const fl.FlDotData(show: false),
      ),
      fl.LineChartBarData(
        spots: [for (final row in _pairs) fl.FlSpot(row.x, row.y)],
        barWidth: 0,
        dotData: const fl.FlDotData(show: true),
      ),
    ],
  ),
);

Widget _flDivergingStack() => fl.BarChart(
  fl.BarChartData(
    minY: -40,
    maxY: 60,
    barGroups: [
      fl.BarChartGroupData(
        x: 0,
        groupVertically: true,
        barRods: [
          fl.BarChartRodData(
            toY: -40,
            rodStackItems: [
              fl.BarChartRodStackItem(-40, -20, Colors.red),
              fl.BarChartRodStackItem(-20, 0, Colors.orange),
            ],
          ),
          fl.BarChartRodData(
            toY: 60,
            rodStackItems: [
              fl.BarChartRodStackItem(0, 30, Colors.lightGreen),
              fl.BarChartRodStackItem(30, 60, Colors.green),
            ],
          ),
        ],
      ),
    ],
  ),
);

Widget _sfMatrix() => GridView.count(
  crossAxisCount: 2,
  children: [
    for (var i = 0; i < 4; i++)
      sf.SfCartesianChart(
        primaryXAxis: const sf.NumericAxis(minimum: 0, maximum: 1),
        primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 1),
        series: <sf.CartesianSeries<_Pair, double>>[
          sf.ScatterSeries<_Pair, double>(
            dataSource: _pairs,
            animationDuration: 0,
            xValueMapper: (p, _) => i.isEven ? p.x : p.y,
            yValueMapper: (p, _) => i < 2 ? p.y : 1 - p.x,
          ),
        ],
      ),
  ],
);

Widget _sfTernary() {
  const triangle = <_Pair>[
    (x: 0, y: 0),
    (x: 1, y: 0),
    (x: 0.5, y: 0.8660254),
    (x: 0, y: 0),
  ];
  const compositions = <_Pair>[
    (x: 0.55, y: 0.4330127),
    (x: 0.45, y: 0.0866025),
  ];
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(minimum: 0, maximum: 1),
    primaryYAxis: const sf.NumericAxis(minimum: 0, maximum: 0.9),
    series: <sf.CartesianSeries<_Pair, double>>[
      sf.LineSeries<_Pair, double>(
        dataSource: triangle,
        animationDuration: 0,
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,
      ),
      sf.ScatterSeries<_Pair, double>(
        dataSource: compositions,
        animationDuration: 0,
        xValueMapper: (p, _) => p.x,
        yValueMapper: (p, _) => p.y,
      ),
    ],
  );
}

Widget _sfFan() => sf.SfCartesianChart(
  primaryXAxis: const sf.NumericAxis(minimum: 0, maximum: 2),
  series: <sf.CartesianSeries<_Band, double>>[
    sf.RangeAreaSeries<_Band, double>(
      dataSource: _bands,
      animationDuration: 0,
      xValueMapper: (r, _) => r.x,
      lowValueMapper: (r, _) => r.low90,
      highValueMapper: (r, _) => r.high90,
    ),
    sf.RangeAreaSeries<_Band, double>(
      dataSource: _bands,
      animationDuration: 0,
      xValueMapper: (r, _) => r.x,
      lowValueMapper: (r, _) => r.low50,
      highValueMapper: (r, _) => r.high50,
    ),
  ],
);

typedef _Likert = ({String category, double negative, double positive});
const _likert = <_Likert>[
  (category: 'Servicio A', negative: -35, positive: 65),
];

Widget _sfDivergingStack() => sf.SfCartesianChart(
  primaryXAxis: const sf.CategoryAxis(),
  series: <sf.CartesianSeries<_Likert, String>>[
    sf.StackedColumnSeries<_Likert, String>(
      dataSource: _likert,
      animationDuration: 0,
      xValueMapper: (r, _) => r.category,
      yValueMapper: (r, _) => r.negative,
    ),
    sf.StackedColumnSeries<_Likert, String>(
      dataSource: _likert,
      animationDuration: 0,
      xValueMapper: (r, _) => r.category,
      yValueMapper: (r, _) => r.positive,
    ),
  ],
);

Widget _graphicFan() => gr.Chart<_Band>(
  data: _bands,
  variables: {
    'x': gr.Variable(accessor: (_Band r) => r.x),
    'low90': gr.Variable(
      accessor: (_Band r) => r.low90,
      scale: gr.LinearScale(min: 0, max: 20),
    ),
    'high90': gr.Variable(
      accessor: (_Band r) => r.high90,
      scale: gr.LinearScale(min: 0, max: 20),
    ),
    'low50': gr.Variable(
      accessor: (_Band r) => r.low50,
      scale: gr.LinearScale(min: 0, max: 20),
    ),
    'high50': gr.Variable(
      accessor: (_Band r) => r.high50,
      scale: gr.LinearScale(min: 0, max: 20),
    ),
  },
  marks: [
    gr.AreaMark(
      position: gr.Varset('x') * (gr.Varset('low90') + gr.Varset('high90')),
    ),
    gr.AreaMark(
      position: gr.Varset('x') * (gr.Varset('low50') + gr.Varset('high50')),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
);

Widget _graphicQq() => gr.Chart<_Pair>(
  data: _pairs,
  variables: {
    'theoretical': gr.Variable(
      accessor: (_Pair r) => r.x,
      scale: gr.LinearScale(min: 0, max: 1),
    ),
    'observed': gr.Variable(
      accessor: (_Pair r) => r.y,
      scale: gr.LinearScale(min: 0, max: 1),
    ),
    'reference': gr.Variable(
      accessor: (_Pair r) => r.x,
      scale: gr.LinearScale(min: 0, max: 1),
    ),
  },
  marks: [
    gr.LineMark(position: gr.Varset('theoretical') * gr.Varset('reference')),
    gr.PointMark(position: gr.Varset('theoretical') * gr.Varset('observed')),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
);

typedef _Segment = ({String category, String response, double from, double to});
const _segments = <_Segment>[
  (category: 'Servicio A', response: 'Muy negativa', from: -40, to: -20),
  (category: 'Servicio A', response: 'Negativa', from: -20, to: 0),
  (category: 'Servicio A', response: 'Positiva', from: 0, to: 30),
  (category: 'Servicio A', response: 'Muy positiva', from: 30, to: 60),
];

Widget _graphicDivergingStack() => gr.Chart<_Segment>(
  data: _segments,
  variables: {
    'category': gr.Variable(accessor: (_Segment r) => r.category),
    'response': gr.Variable(accessor: (_Segment r) => r.response),
    'from': gr.Variable(
      accessor: (_Segment r) => r.from,
      scale: gr.LinearScale(min: -40, max: 60),
    ),
    'to': gr.Variable(
      accessor: (_Segment r) => r.to,
      scale: gr.LinearScale(min: -40, max: 60),
    ),
  },
  marks: [
    gr.IntervalMark(
      position: gr.Varset('category') * (gr.Varset('from') + gr.Varset('to')),
      color: gr.ColorEncode(
        variable: 'response',
        values: [Colors.red, Colors.orange, Colors.green, Colors.lightGreen],
      ),
    ),
  ],
  axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
);

// ECharts options stay JSON-only: no renderItem function or injected JavaScript.
const graphifyQqOptions = <String, dynamic>{
  'xAxis': {'type': 'value', 'min': 0, 'max': 1},
  'yAxis': {'type': 'value', 'min': 0, 'max': 1},
  'series': [
    {
      'type': 'line',
      'data': [
        [0, 0],
        [1, 1],
      ],
      'symbol': 'none',
    },
    {
      'type': 'scatter',
      'data': [
        [0.15, 0.2],
        [0.35, 0.42],
        [0.65, 0.61],
        [0.85, 0.9],
      ],
    },
  ],
};

const graphifyPrototypeOptions = <String, Map<String, dynamic>>{
  'diverging-stacked-bar': {
    'xAxis': {
      'type': 'category',
      'data': ['Servicio A'],
    },
    'yAxis': {'type': 'value', 'min': -100, 'max': 100},
    'series': [
      {
        'type': 'bar',
        'stack': 'negative',
        'data': [-20],
      },
      {
        'type': 'bar',
        'stack': 'negative',
        'data': [-15],
      },
      {
        'type': 'bar',
        'stack': 'positive',
        'data': [30],
      },
      {
        'type': 'bar',
        'stack': 'positive',
        'data': [35],
      },
    ],
  },
  'scatterplot-matrix': {
    'grid': [
      {'left': '10%', 'top': '10%', 'width': '35%', 'height': '35%'},
      {'left': '55%', 'top': '10%', 'width': '35%', 'height': '35%'},
      {'left': '10%', 'top': '55%', 'width': '35%', 'height': '35%'},
      {'left': '55%', 'top': '55%', 'width': '35%', 'height': '35%'},
    ],
    'xAxis': [
      {'type': 'value', 'gridIndex': 0},
      {'type': 'value', 'gridIndex': 1},
      {'type': 'value', 'gridIndex': 2},
      {'type': 'value', 'gridIndex': 3},
    ],
    'yAxis': [
      {'type': 'value', 'gridIndex': 0},
      {'type': 'value', 'gridIndex': 1},
      {'type': 'value', 'gridIndex': 2},
      {'type': 'value', 'gridIndex': 3},
    ],
    'series': [
      {
        'type': 'scatter',
        'xAxisIndex': 0,
        'yAxisIndex': 0,
        'data': [
          [0.2, 0.3],
        ],
      },
      {
        'type': 'scatter',
        'xAxisIndex': 1,
        'yAxisIndex': 1,
        'data': [
          [0.3, 0.7],
        ],
      },
      {
        'type': 'scatter',
        'xAxisIndex': 2,
        'yAxisIndex': 2,
        'data': [
          [0.4, 0.2],
        ],
      },
      {
        'type': 'scatter',
        'xAxisIndex': 3,
        'yAxisIndex': 3,
        'data': [
          [0.6, 0.8],
        ],
      },
    ],
  },
  'ternary-plot': {
    'xAxis': {'type': 'value', 'min': 0, 'max': 1},
    'yAxis': {'type': 'value', 'min': 0, 'max': 0.9},
    'series': [
      {
        'type': 'line',
        'data': [
          [0, 0],
          [1, 0],
          [0.5, 0.866],
          [0, 0],
        ],
      },
      {
        'type': 'scatter',
        'data': [
          [0.55, 0.433],
        ],
      },
    ],
  },
  'fan-chart': {
    'xAxis': {'type': 'value'},
    'yAxis': {'type': 'value'},
    'series': [
      {
        'type': 'line',
        'stack': 'outer',
        'lineStyle': {'opacity': 0},
        'areaStyle': {'opacity': 0},
        'data': [
          [0, 7],
          [1, 6],
        ],
      },
      {
        'type': 'line',
        'stack': 'outer',
        'lineStyle': {'opacity': 0},
        'areaStyle': {'opacity': 0.2},
        'data': [
          [0, 6],
          [1, 9],
        ],
      },
      {
        'type': 'line',
        'stack': 'inner',
        'lineStyle': {'opacity': 0},
        'areaStyle': {'opacity': 0},
        'data': [
          [0, 9],
          [1, 8],
        ],
      },
      {
        'type': 'line',
        'stack': 'inner',
        'lineStyle': {'opacity': 0},
        'areaStyle': {'opacity': 0.4},
        'data': [
          [0, 2],
          [1, 4],
        ],
      },
    ],
  },
  'calibration-plot': {
    'xAxis': {'type': 'value', 'min': 0, 'max': 1},
    'yAxis': {'type': 'value', 'min': 0, 'max': 1},
    'series': [
      {
        'type': 'line',
        'data': [
          [0, 0],
          [1, 1],
        ],
        'symbol': 'none',
      },
      {
        'type': 'scatter',
        'data': [
          [0.2, 0.16],
          [0.5, 0.55],
          [0.8, 0.72],
        ],
      },
    ],
  },
  'qq-plot': graphifyQqOptions,
};

void main() {
  final widgetPrototypes = <(String, Widget Function(), Type)>[
    ('FL matrix', _flMatrix, fl.ScatterChart),
    ('FL ternary', _flTernary, fl.LineChart),
    ('FL fan', _flFan, fl.LineChart),
    ('FL QQ', _flQq, fl.LineChart),
    ('FL diverging stack', _flDivergingStack, fl.BarChart),
    ('Syncfusion matrix', _sfMatrix, sf.SfCartesianChart),
    ('Syncfusion ternary', _sfTernary, sf.SfCartesianChart),
    ('Syncfusion fan', _sfFan, sf.SfCartesianChart),
    ('Syncfusion diverging stack', _sfDivergingStack, sf.SfCartesianChart),
    ('Graphic fan', _graphicFan, gr.Chart<_Band>),
    ('Graphic QQ', _graphicQq, gr.Chart<_Pair>),
    ('Graphic diverging stack', _graphicDivergingStack, gr.Chart<_Segment>),
  ];

  for (final (name, build, primitive) in widgetPrototypes) {
    testWidgets('$name builds at 280x240', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 280, height: 240, child: build()),
          ),
        ),
      );
      expect(find.byType(primitive), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  test('Graphify QQ uses JSON ECharts line and scatter primitives', () {
    final encoded = jsonEncode(graphifyQqOptions);
    final decoded = jsonDecode(encoded) as Map<String, dynamic>;
    final series = decoded['series'] as List<dynamic>;
    expect(series.map((s) => s['type']), ['line', 'scatter']);
    final view = GraphifyView(initialOptions: graphifyQqOptions);
    expect(view.initialOptions, graphifyQqOptions);
    expect(encoded, isNot(contains('renderItem')));
  });

  test(
    'all six Graphify candidate options need only serializable ECharts data',
    () {
      expect(graphifyPrototypeOptions, hasLength(6));
      for (final options in graphifyPrototypeOptions.values) {
        final encoded = jsonEncode(options);
        final decoded = jsonDecode(encoded) as Map<String, dynamic>;
        expect(decoded['series'], isNotEmpty);
        expect(encoded, isNot(contains('renderItem')));
        expect(GraphifyView(initialOptions: options).initialOptions, options);
      }
    },
  );

  testWidgets('Graphify QQ mounts at 280x240 on web', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 280,
            height: 240,
            child: GraphifyView(initialOptions: graphifyQqOptions),
          ),
        ),
      ),
    );
    expect(find.byType(GraphifyView), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, skip: !kIsWeb);
}
