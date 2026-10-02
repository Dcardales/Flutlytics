class ChartCombination {
  const ChartCombination(this.id, this.name, this.reason);
  final String id;
  final String name;
  final String reason;
}

class ChartCombinations {
  static const all = <String, ChartCombination>{
    'bar-line': ChartCombination(
      'bar-line',
      'Barras + línea',
      'Relaciona volumen por periodo con una tasa o meta temporal.',
    ),
    'area-line': ChartCombination(
      'area-line',
      'Área + línea',
      'Contrasta volumen acumulado con una referencia en la misma línea temporal.',
    ),
    'scatter-trend': ChartCombination(
      'scatter-trend',
      'Dispersión + tendencia',
      'Añade una tendencia estimada sin ocultar las observaciones individuales.',
    ),
    'histogram-density': ChartCombination(
      'histogram-density',
      'Histograma + densidad',
      'Compara frecuencias por intervalo con una forma suavizada de la distribución.',
    ),
    'candlestick-volume': ChartCombination(
      'candlestick-volume',
      'Velas + volumen',
      'Da contexto de actividad a los cambios de precio de cada sesión.',
    ),
    'stacked-column-line': ChartCombination(
      'stacked-column-line',
      'Columnas apiladas + línea',
      'Relaciona componentes del total con una medida de rendimiento temporal.',
    ),
  };
}
