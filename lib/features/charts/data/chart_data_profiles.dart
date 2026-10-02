import '../domain/chart_concept.dart';

class ChartDataProfiles {
  ChartDataProfiles._();

  static const _timeValue = ChartDataProfile(
    fields: ['fecha', 'valor'],
    variableCount: 2,
    structure: 'serie temporal',
  );
  static const _timeSeries = ChartDataProfile(
    fields: ['fecha', 'serie', 'valor'],
    variableCount: 3,
    structure: 'series temporales comparables',
  );
  static const _categoryValue = ChartDataProfile(
    fields: ['categoría', 'valor'],
    variableCount: 2,
    structure: 'magnitud por categoría',
  );
  static const _categorySeries = ChartDataProfile(
    fields: ['categoría', 'grupo', 'valor'],
    variableCount: 3,
    structure: 'categorías y subgrupos',
  );
  static const _parts = ChartDataProfile(
    fields: ['parte', 'valor'],
    variableCount: 2,
    structure: 'partes de un total',
    invariant: 'valores no negativos y total positivo',
  );
  static const _distribution = ChartDataProfile(
    fields: ['observación'],
    variableCount: 1,
    structure: 'muestra numérica sin agregar',
  );
  static const _xy = ChartDataProfile(
    fields: ['x', 'y'],
    variableCount: 2,
    structure: 'observaciones numéricas emparejadas',
  );
  static const _range = ChartDataProfile(
    fields: ['categoría', 'mínimo', 'máximo'],
    variableCount: 3,
    structure: 'intervalos por categoría',
    invariant: 'mínimo <= máximo',
  );
  static const _timeRange = ChartDataProfile(
    fields: ['fecha', 'límite inferior', 'límite superior'],
    variableCount: 3,
    structure: 'intervalo temporal',
    invariant: 'inferior <= superior',
  );
  static const _ohlc = ChartDataProfile(
    fields: ['fecha', 'open', 'high', 'low', 'close'],
    variableCount: 5,
    structure: 'cotizaciones OHLC ordenadas',
    invariant: 'low <= open,close <= high',
  );
  static const _matrix = ChartDataProfile(
    fields: ['fila', 'columna', 'valor'],
    variableCount: 3,
    structure: 'matriz de intensidad',
  );
  static const _flow = ChartDataProfile(
    fields: ['origen', 'destino', 'peso'],
    variableCount: 3,
    structure: 'vínculos ponderados',
    invariant: 'peso >= 0',
  );

  // Explicit per-concept declarations. Shared profiles describe equal data contracts,
  // not an inferred category-wide default.
  static const byId = <String, ChartDataProfile>{
    'line': _timeValue,
    'multi-line': _timeSeries,
    'area': _timeValue,
    'stacked-area': _timeSeries,
    'step-line': _timeValue,
    'slope': ChartDataProfile(
      fields: ['grupo', 'antes', 'después'],
      variableCount: 3,
      structure: 'dos momentos por grupo',
    ),
    'bar': _categoryValue,
    'grouped-bar': _categorySeries,
    'stacked-bar': _categorySeries,
    'normalized-stacked-bar': _categorySeries,
    'diverging-bar': _categoryValue,
    'dot-plot': _categoryValue,
    'lollipop': _categoryValue,
    'dumbbell': ChartDataProfile(
      fields: ['categoría', 'inicio', 'fin'],
      variableCount: 3,
      structure: 'pares por categoría',
    ),
    'pie': _parts,
    'donut': _parts,
    'waffle': _parts,
    'scatter': _xy,
    'bubble': ChartDataProfile(
      fields: ['x', 'y', 'magnitud'],
      variableCount: 3,
      structure: 'observaciones bivariadas con tamaño',
      invariant: 'magnitud >= 0',
    ),
    'histogram': _distribution,
    'frequency-polygon': ChartDataProfile(
      fields: ['grupo', 'observación'],
      variableCount: 2,
      structure: 'muestras por grupo',
    ),
    'ogive': _distribution,
    'strip-plot': _distribution,
    'radar': ChartDataProfile(
      fields: ['perfil', 'dimensión comparable', 'puntuación'],
      variableCount: 3,
      structure: 'perfiles con tres o más dimensiones compartidas',
      invariant: 'dimensiones y escala numérica compartidas entre perfiles',
    ),
    'polar-area': ChartDataProfile(
      fields: ['categoría', 'magnitud absoluta'],
      variableCount: 2,
      structure: 'magnitudes categóricas comparadas por radio; no composición',
    ),
    'range-column': _range,
    'error-bar': ChartDataProfile(
      fields: ['categoría', 'estimación', 'error inferior', 'error superior'],
      variableCount: 4,
      structure: 'estimaciones con incertidumbre',
      invariant: 'error inferior <= estimación <= error superior',
    ),
    'sparkline': _timeValue,
    'timeline': ChartDataProfile(
      fields: ['fecha', 'evento'],
      variableCount: 2,
      structure: 'hitos cualitativos ordenados',
    ),
    'connected-scatter': ChartDataProfile(
      fields: ['fecha', 'x', 'y'],
      variableCount: 3,
      structure: 'trayectoria bivariada temporal',
    ),
    'bar-line': ChartDataProfile(
      fields: ['fecha', 'volumen', 'tasa'],
      variableCount: 3,
      structure: 'dos medidas con unidades distintas',
    ),
    'area-line': ChartDataProfile(
      fields: ['fecha', 'volumen', 'referencia'],
      variableCount: 3,
      structure: 'serie frente a meta',
    ),
    'small-multiples-line': _timeSeries,
    'small-multiples-bar': _categorySeries,
    'diverging-stacked-bar': ChartDataProfile(
      fields: ['categoría', 'respuesta', 'frecuencia'],
      variableCount: 3,
      structure: 'composición ordinal bilateral',
      invariant: 'segmentos positivos y negativos comparten cero',
    ),
    'normalized-stacked-area': _timeSeries,
    'cumulative-line': _timeValue,
    'indexed-line': _timeSeries,
    'control-chart': ChartDataProfile(
      fields: [
        'fecha',
        'medición',
        'centro',
        'límite inferior',
        'límite superior',
      ],
      variableCount: 5,
      structure: 'proceso con límites estadísticos',
    ),
    'pareto': ChartDataProfile(
      fields: ['causa', 'frecuencia'],
      variableCount: 2,
      structure: 'causas ordenables por frecuencia',
    ),
    'box-plot': ChartDataProfile(
      fields: ['grupo', 'observación'],
      variableCount: 2,
      structure: 'muestras por grupo',
    ),
    'violin': ChartDataProfile(
      fields: ['grupo', 'observación'],
      variableCount: 2,
      structure: 'muestras por grupo',
    ),
    'heatmap': _matrix,
    'calendar-heatmap': ChartDataProfile(
      fields: ['fecha diaria', 'valor'],
      variableCount: 2,
      structure: 'serie diaria con calendario real',
    ),
    'scatterplot-matrix': ChartDataProfile(
      fields: ['destino', 'visitantes', 'gasto', 'duración', 'satisfacción'],
      variableCount: 5,
      structure: 'cuatro métricas numéricas por registro y 16 paneles',
    ),
    'ternary-plot': ChartDataProfile(
      fields: ['componente A', 'componente B', 'componente C'],
      variableCount: 3,
      structure: 'composición ternaria',
      invariant: 'A+B+C = 100 % y componentes >= 0',
    ),
    'fan-chart': ChartDataProfile(
      fields: [
        'horizonte',
        'mediana',
        'low50',
        'high50',
        'low80',
        'high80',
        'low95',
        'high95',
      ],
      variableCount: 8,
      structure: 'mediana e intervalos probabilísticos anidados',
      invariant: '95 % contiene 80 %, 80 % contiene 50 % y mediana',
    ),
    'network-graph': _flow,
    'qq-plot': ChartDataProfile(
      fields: ['cuantil teórico', 'cuantil observado'],
      variableCount: 2,
      structure: 'pares de cuantiles ordenados',
    ),
    'funnel': ChartDataProfile(
      fields: ['etapa', 'volumen'],
      variableCount: 2,
      structure: 'etapas secuenciales',
      invariant: 'volumen no aumenta entre etapas',
    ),
    'pyramid': ChartDataProfile(
      fields: ['grupo etario', 'sexo', 'población'],
      variableCount: 3,
      structure: 'pirámide de población bilateral',
    ),
    'waterfall': ChartDataProfile(
      fields: ['causa', 'variación'],
      variableCount: 2,
      structure: 'cambios desde un total inicial',
    ),
    'candlestick': _ohlc,
    'ohlc': _ohlc,
    'gauge': ChartDataProfile(
      fields: ['indicador', 'valor', 'meta', 'umbral'],
      variableCount: 4,
      structure: 'KPI en escala fija',
    ),
    'gantt': ChartDataProfile(
      fields: ['tarea', 'inicio', 'fin'],
      variableCount: 3,
      structure: 'intervalos de tareas',
      invariant: 'inicio <= fin',
    ),
    'streamgraph': _timeSeries,
    'parallel-coordinates': ChartDataProfile(
      fields: ['registro', 'múltiples métricas'],
      variableCount: 4,
      structure: 'perfil multivariante',
    ),
    'hexbin': _xy,
    'density': _distribution,
    'bullet': ChartDataProfile(
      fields: ['indicador', 'valor', 'meta', 'bandas'],
      variableCount: 4,
      structure: 'KPI lineal',
    ),
    'range-area': _timeRange,
    'ridgeline': ChartDataProfile(
      fields: ['grupo', 'observación'],
      variableCount: 2,
      structure: 'muestras por grupo',
    ),
    'contour': ChartDataProfile(
      fields: ['x espacial', 'y espacial', 'intensidad'],
      variableCount: 3,
      structure: 'campo continuo espacial',
    ),
    'calibration-plot': ChartDataProfile(
      fields: ['probabilidad predicha', 'resultado observado', 'conteo'],
      variableCount: 3,
      structure: 'probabilidades agrupadas en bins',
      invariant: 'probabilidades entre 0 y 1',
    ),
  };
}
