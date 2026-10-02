import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as sf;

import '../../data/distribution_basics_data.dart';

const _bins = 6;
const _bandwidth = 2.4;

Widget buildSyncfusionDistributionChart(String id) {
  final sample = touristServiceSample;
  final bins = buildHistogramBins(sample.values, binCount: _bins);
  final ogive = buildOgive(bins);
  final points = switch (id) {
    'frequency-polygon' => buildFrequencyPolygon(bins),
    'ogive' => [
      for (final p in ogive)
        DistributionPoint(p.upperBound, p.cumulativePercentage),
    ],
    'density' => buildGaussianKde(sample.values, bandwidth: _bandwidth),
    _ => const <DistributionPoint>[],
  };
  if (id == 'histogram') {
    return sf.SfCartesianChart(
      primaryXAxis: const sf.NumericAxis(
        title: sf.AxisTitle(text: 'Tiempo (minutos)'),
        edgeLabelPlacement: sf.EdgeLabelPlacement.shift,
      ),
      primaryYAxis: const sf.NumericAxis(
        minimum: 0,
        title: sf.AxisTitle(text: 'Frecuencia'),
      ),
      tooltipBehavior: sf.TooltipBehavior(
        enable: true,
        builder:
            (
              dynamic data,
              dynamic point,
              dynamic series,
              int pointIndex,
              int seriesIndex,
            ) {
              final bin = data as HistogramBin;
              final closing = pointIndex == bins.length - 1 ? ']' : ')';
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Intervalo [${bin.lowerBound.toStringAsFixed(1)}, '
                  '${bin.upperBound.toStringAsFixed(1)}$closing\n'
                  'Frecuencia: ${bin.frequency}',
                ),
              );
            },
      ),
      series: <sf.CartesianSeries<HistogramBin, double>>[
        sf.ColumnSeries<HistogramBin, double>(
          dataSource: bins,
          animationDuration: 0,
          spacing: 0,
          xValueMapper: (b, _) => b.midpoint,
          yValueMapper: (b, _) => b.frequency,
          dataLabelMapper: (b, _) => b.label,
          dataLabelSettings: const sf.DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }
  if (id == 'strip-plot') {
    final strip = buildStripPoints(sample.values);
    return sf.SfCartesianChart(
      primaryXAxis: const sf.NumericAxis(
        title: sf.AxisTitle(text: 'Tiempo (minutos)'),
      ),
      primaryYAxis: const sf.NumericAxis(
        minimum: -0.16,
        maximum: 0.16,
        isVisible: false,
      ),
      tooltipBehavior: sf.TooltipBehavior(
        enable: true,
        builder:
            (
              dynamic data,
              dynamic point,
              dynamic series,
              int pointIndex,
              int seriesIndex,
            ) {
              final observation = data as StripPoint;
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Tiempo: ${observation.value.toStringAsFixed(1)} min',
                ),
              );
            },
      ),
      series: <sf.CartesianSeries<StripPoint, double>>[
        sf.ScatterSeries<StripPoint, double>(
          dataSource: strip,
          animationDuration: 0,
          markerSettings: const sf.MarkerSettings(width: 7, height: 7),
          xValueMapper: (p, _) => p.value,
          yValueMapper: (p, _) => p.jitter,
        ),
      ],
    );
  }
  final isOgive = id == 'ogive';
  return sf.SfCartesianChart(
    primaryXAxis: const sf.NumericAxis(
      title: sf.AxisTitle(text: 'Tiempo (minutos)'),
      edgeLabelPlacement: sf.EdgeLabelPlacement.shift,
    ),
    primaryYAxis: sf.NumericAxis(
      minimum: 0,
      maximum: isOgive ? 100 : null,
      title: sf.AxisTitle(
        text: isOgive
            ? 'Acumulado (%)'
            : id == 'density'
            ? 'Densidad estimada'
            : 'Frecuencia',
      ),
    ),
    tooltipBehavior: sf.TooltipBehavior(
      enable: true,
      builder:
          (
            dynamic data,
            dynamic point,
            dynamic series,
            int pointIndex,
            int seriesIndex,
          ) {
            final observation = data as DistributionPoint;
            if (id == 'frequency-polygon') {
              final bin = bins[pointIndex];
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Intervalo ${bin.label}\nFrecuencia: ${bin.frequency}',
                ),
              );
            }
            if (id == 'ogive') {
              final cumulative = ogive[pointIndex];
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Hasta ${cumulative.upperBound.toStringAsFixed(1)} min\n'
                  'Acumulado: ${cumulative.cumulativeFrequency} '
                  '(${cumulative.cumulativePercentage.toStringAsFixed(1)}%)',
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Tiempo: ${observation.x.toStringAsFixed(1)} min\n'
                'Densidad: ${observation.y.toStringAsFixed(4)}',
              ),
            );
          },
    ),
    series: <sf.CartesianSeries<DistributionPoint, double>>[
      id == 'density'
          ? sf.SplineSeries<DistributionPoint, double>(
              dataSource: points,
              animationDuration: 0,
              markerSettings: const sf.MarkerSettings(isVisible: false),
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
            )
          : sf.LineSeries<DistributionPoint, double>(
              dataSource: points,
              animationDuration: 0,
              markerSettings: const sf.MarkerSettings(
                isVisible: true,
                width: 6,
                height: 6,
              ),
              xValueMapper: (p, _) => p.x,
              yValueMapper: (p, _) => p.y,
            ),
    ],
  );
}
