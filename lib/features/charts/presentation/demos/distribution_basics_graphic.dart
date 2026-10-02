import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart' as gr;

import '../../data/distribution_basics_data.dart';

const _bins = 6;
const _bandwidth = 2.4;
const _blue = Color(0xff1565c0);

Widget buildGraphicDistributionChart(String id) {
  final sample = touristServiceSample;
  final bins = buildHistogramBins(sample.values, binCount: _bins);
  if (id == 'histogram') {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: gr.Chart<HistogramBin>(
        data: bins,
        variables: {
          'mid': gr.Variable(
            accessor: (HistogramBin b) => b.midpoint,
            scale: gr.LinearScale(
              min: bins.first.lowerBound,
              max: bins.last.upperBound,
            ),
          ),
          'frequency': gr.Variable(accessor: (HistogramBin b) => b.frequency),
          'interval': gr.Variable(accessor: (HistogramBin b) => b.label),
        },
        marks: [
          gr.IntervalMark(
            position: gr.Varset('mid') * gr.Varset('frequency'),
            color: gr.ColorEncode(value: _blue),
          ),
        ],
        axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
        tooltip: gr.TooltipGuide(variables: ['interval', 'frequency']),
        selections: {
          'point': gr.PointSelection(
            on: {gr.GestureType.hover, gr.GestureType.tap},
            dim: gr.Dim.x,
          ),
        },
      ),
    );
  }
  if (id == 'strip-plot') {
    final points = buildStripPoints(sample.values);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: gr.Chart<StripPoint>(
        data: points,
        variables: {
          'value': gr.Variable(
            accessor: (StripPoint p) => p.value,
            scale: gr.LinearScale(min: 5, max: 28),
          ),
          'jitter': gr.Variable(
            accessor: (StripPoint p) => p.jitter,
            scale: gr.LinearScale(min: -0.16, max: 0.16),
          ),
        },
        marks: [
          gr.PointMark(
            position: gr.Varset('value') * gr.Varset('jitter'),
            color: gr.ColorEncode(value: _blue),
            size: gr.SizeEncode(value: 6),
          ),
        ],
        axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
        tooltip: gr.TooltipGuide(variables: ['value']),
        selections: {
          'point': gr.PointSelection(
            on: {gr.GestureType.hover, gr.GestureType.tap},
            dim: gr.Dim.x,
          ),
        },
      ),
    );
  }
  final List<DistributionPoint> points = switch (id) {
    'frequency-polygon' => buildFrequencyPolygon(bins),
    'ogive' => [
      for (final p in buildOgive(bins))
        DistributionPoint(
          p.upperBound,
          p.cumulativePercentage,
          detail:
              'Acumulado: ${p.cumulativeFrequency} (${p.cumulativePercentage.toStringAsFixed(1)}%)',
        ),
    ],
    _ => buildGaussianKde(sample.values, bandwidth: _bandwidth),
  };
  final isOgive = id == 'ogive';
  return Padding(
    padding: const EdgeInsets.all(10),
    child: gr.Chart<DistributionPoint>(
      data: points,
      variables: {
        'x': gr.Variable(accessor: (DistributionPoint p) => p.x),
        'y': gr.Variable(
          accessor: (DistributionPoint p) => p.y,
          scale: gr.LinearScale(min: 0, max: isOgive ? 100 : null),
        ),
        'detail': gr.Variable(
          accessor: (DistributionPoint p) => p.detail ?? '',
        ),
      },
      marks: [
        gr.LineMark(
          position: gr.Varset('x') * gr.Varset('y'),
          color: gr.ColorEncode(value: _blue),
          size: gr.SizeEncode(value: 2.5),
        ),
        if (id != 'density')
          gr.PointMark(
            position: gr.Varset('x') * gr.Varset('y'),
            color: gr.ColorEncode(value: _blue),
            size: gr.SizeEncode(value: 6),
          ),
      ],
      axes: [gr.Defaults.horizontalAxis, gr.Defaults.verticalAxis],
      tooltip: gr.TooltipGuide(
        variables: id == 'frequency-polygon'
            ? ['detail', 'y']
            : id == 'ogive'
            ? ['detail']
            : ['x', 'y'],
      ),
      selections: {
        'point': gr.PointSelection(
          on: {gr.GestureType.hover, gr.GestureType.tap},
          dim: gr.Dim.x,
        ),
      },
    ),
  );
}
