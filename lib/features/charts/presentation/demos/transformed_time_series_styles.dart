import 'package:flutter/material.dart';

const analyticalSeriesColors = <Color>[
  Color(0xff1976d2),
  Color(0xffef6c00),
  Color(0xff2e7d32),
  Color(0xff8e24aa),
];

Widget analyticalLegend(List<String> names) => Wrap(
  alignment: WrapAlignment.center,
  spacing: 10,
  runSpacing: 2,
  children: [
    for (var i = 0; i < names.length; i++)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 9,
            color: analyticalSeriesColors[i % analyticalSeriesColors.length],
          ),
          const SizedBox(width: 4),
          Text(names[i], style: const TextStyle(fontSize: 11)),
        ],
      ),
  ],
);

List<String> stableSeriesNames(Iterable<String> values) =>
    values.toSet().toList()..sort();
