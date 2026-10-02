import 'distribution_basics_data.dart';
import 'advanced_distribution_data.dart';
import 'relationships_intervals_data.dart';
import 'financial_planning_data.dart';
import 'analytical_structures_data.dart';
import 'networks_diagnostics_spatial_data.dart';
import 'performance_process_data.dart';

class ChartPoint {
  const ChartPoint(this.label, this.value);
  final String label;
  final double value;
}

class ChartDataset {
  const ChartDataset({
    required this.conceptId,
    required this.scenario,
    required this.title,
    required this.unit,
    required this.description,
    required this.rows,
    required this.invariants,
    this.sourceNote = 'Datos sintéticos educativos',
  });

  final String conceptId;
  final String scenario;
  final String title;
  final String unit;
  final String description;
  final List<Map<String, Object>> rows;
  final List<String> invariants;
  final String sourceNote;
}

class ChartDatasetRegistry {
  ChartDatasetRegistry._();

  static final all = Map<String, ChartDataset>.unmodifiable({
    'funnel': ChartDataset(
      conceptId: 'funnel',
      scenario: 'Conversión secuencial de reservas turísticas',
      title: 'Funnel de reservas',
      unit: 'personas',
      description: 'Cinco etapas decrecientes, ancho proporcional y conversiones derivadas.',
      invariants: [
        'orden secuencial',
        'valores no crecientes en la demo',
        'denominador cero no calculable',
      ],
      rows: [
        for (final s in bookingFunnel.steps)
          {
            'stage': s.stage.label,
            'value': s.stage.value,
            'previousConversion': s.conversionFromPrevious ?? 'no calculable',
            'startConversion': s.conversionFromStart ?? 'no calculable',
            'dropOff': s.dropOff ?? 'no aplicable',
          },
      ],
    ),
    'pyramid': ChartDataset(
      conceptId: 'pyramid',
      scenario: 'Turistas nacionales e internacionales por edad',
      title: 'Population Pyramid',
      unit: 'personas',
      description: 'Dos poblaciones positivas enfrentadas por seis edades con escala simétrica.',
      invariants: [
        'valores originales no negativos',
        'izquierda visual negativa',
        'escala simétrica',
      ],
      rows: [
        for (final r in touristAgePyramid.rows)
          {
            'age': r.category,
            'national': r.leftValue,
            'international': r.rightValue,
          },
      ],
    ),
    'gauge': ChartDataset(
      conceptId: 'gauge',
      scenario: 'Estado actual de ocupación hotelera',
      title: 'Ocupación frente a objetivo',
      unit: '%',
      description: '78% actual en arco de 0–100% con target en 80%.',
      invariants: [
        'min < max',
        'valor y meta dentro de escala',
        'normalización 0–1',
      ],
      rows: [
        {
          'label': hotelOccupancyGauge.label,
          'value': hotelOccupancyGauge.value,
          'min': hotelOccupancyGauge.min,
          'max': hotelOccupancyGauge.max,
          'target': hotelOccupancyGauge.target!,
        },
      ],
    ),
    'bullet': ChartDataset(
      conceptId: 'bullet',
      scenario: 'Ingresos mensuales frente a meta',
      title: 'Ingresos y rangos cualitativos',
      unit: 'M COP',
      description: 'Actual 82, meta 90 y tres bandas ordenadas en una escala lineal 0–100.',
      invariants: [
        'escala compartida',
        'meta perpendicular',
        'rangos crecientes',
      ],
      rows: [
        for (final b in monthlyRevenueBullet.bands)
          {
            'range': b.label,
            'start': b.start,
            'end': b.end,
            'actual': monthlyRevenueBullet.value,
            'target': monthlyRevenueBullet.target,
          },
      ],
    ),
    'timeline': ChartDataset(
      conceptId: 'timeline',
      scenario: 'Hitos ficticios de proyecto Flutter educativo',
      title: 'Secuencia de hitos',
      unit: 'fecha',
      description: 'Seis eventos puntuales ordenados por DateTime, sin duración de tareas.',
      invariants: ['IDs únicos', 'orden por fecha', 'espaciado temporal real'],
      rows: [
        for (final p in flutterMilestones.points)
          {
            'id': p.event.id,
            'date': isoDate(p.event.date),
            'title': p.event.title,
            'description': p.event.description,
            'dayOffset': p.dayOffset,
          },
      ],
    ),
    'network-graph': ChartDataset(
      conceptId: 'network-graph',
      scenario: 'Conexiones entre destinos y servicios turísticos',
      title: 'Red turística',
      unit: 'peso de relación',
      description: 'Siete nodos en círculo estable y ocho conexiones reales.',
      invariants: [
        'IDs únicos',
        'endpoints existentes',
        'layout circular determinístico',
      ],
      rows: [
        for (final e in touristNetwork.edges)
          {'source': e.sourceId, 'target': e.targetId, 'weight': e.weight},
      ],
    ),
    'qq-plot': ChartDataset(
      conceptId: 'qq-plot',
      scenario: 'Tiempos de servicio turístico',
      title: 'Normalidad de tiempos de servicio',
      unit: 'z-score',
      description:
          '48 observaciones estandarizadas frente a cuantiles normales.',
      invariants: ['p=(i-0.5)/n', 'SD muestral', 'diagonal y=x'],
      rows: [
        for (final p in serviceQq)
          {
            'p': p.probability,
            'theoretical': p.theoretical,
            'observed': p.observed,
          },
      ],
    ),
    'parallel-coordinates': ChartDataset(
      conceptId: 'parallel-coordinates',
      scenario: 'Diez destinos turísticos por cinco dimensiones',
      title: 'Perfiles de destinos',
      unit: 'normalizado 0–1',
      description:
          'Cada destino cruza cinco ejes lineales con normalización min-max.',
      invariants: [
        'dimensiones compartidas',
        'dimensión constante = 0.5',
        'orden estable',
      ],
      rows: [
        for (final p in touristParallel.points)
          {
            'destination': p.observation.label,
            'dimension': p.variable.id,
            'raw': p.raw,
            'normalized': p.normalized,
            'axis': p.axis,
          },
      ],
    ),
    'contour': ChartDataset(
      conceptId: 'contour',
      scenario: 'Campo abstracto de demanda turística este-oeste / norte-sur',
      title: 'Curvas de igual intensidad',
      unit: 'intensidad estimada',
      description: 'Grid 25×20 de tres picos gaussianos; seis niveles extraídos por Marching Squares.',
      invariants: [
        'grid completo',
        'interpolación lineal',
        'niveles ordenados',
      ],
      rows: [
        for (final s in touristContour.segments)
          {
            'level': s.level,
            'x1': s.a.x,
            'y1': s.a.y,
            'x2': s.b.x,
            'y2': s.b.y,
          },
      ],
    ),
    'calendar-heatmap': ChartDataset(
      conceptId: 'calendar-heatmap',
      scenario: 'Reservas diarias de octubre de 2025 a marzo de 2026',
      title: 'Actividad diaria de reservas',
      unit: 'reservas',
      description: '181 días consecutivos en semanas alineadas a lunes; color por intensidad.',
      invariants: ['fecha única', 'lunes=0', 'una celda por día'],
      rows: [
        for (final c in bookingCalendar.cells)
          {
            'date': isoDay(c.day.date),
            'value': c.day.value,
            'week': c.week,
            'weekday': c.weekday,
          },
      ],
    ),
    'diverging-stacked-bar': ChartDataset(
      conceptId: 'diverging-stacked-bar',
      scenario: 'Encuesta Likert de satisfacción turística',
      title: 'Opiniones por dimensión',
      unit: '% de respuestas',
      description: 'Cinco respuestas ordinales forman pilas a ambos lados de cero; Neutral se divide 50/50.',
      invariants: [
        'cada dimensión suma 100 %',
        'Neutral dividido alrededor de cero',
      ],
      rows: [
        for (final s in touristLikertSegments)
          {
            'dimension': s.dimension,
            'response': s.response,
            'side': s.side,
            'percentage': s.percentage,
            'start': s.start,
            'end': s.end,
          },
      ],
    ),
    'scatterplot-matrix': ChartDataset(
      conceptId: 'scatterplot-matrix',
      scenario: '24 destinos con cuatro métricas turísticas',
      title: 'Matriz de relaciones entre métricas',
      unit: 'unidades por variable',
      description: '16 celdas: 12 pares de dispersión y cuatro diagonales con nombre/rango.',
      invariants: [
        '4 variables compartidas',
        '16 celdas',
        'una escala global por variable',
      ],
      rows: [
        for (final o in touristMatrix.observations)
          {'label': o.label, ...o.values},
      ],
    ),
    'ternary-plot': ChartDataset(
      conceptId: 'ternary-plot',
      scenario: 'Presupuesto de 12 perfiles turísticos',
      title: 'Alojamiento, alimentación y transporte',
      unit: '% del presupuesto',
      description: 'Tres componentes restringidos a 100 % dentro de un triángulo equilátero.',
      invariants: [
        'A+B+C = 100 %',
        'coordenadas baricéntricas dentro del triángulo',
      ],
      rows: [
        for (final p in touristBudgetMix)
          {
            'label': p.label,
            'lodging': p.a,
            'food': p.b,
            'transport': p.c,
            'x': p.x,
            'y': p.y,
          },
      ],
    ),
    'fan-chart': ChartDataset(
      conceptId: 'fan-chart',
      scenario: 'Pronóstico de ocupación hotelera a 12 meses',
      title: 'Mediana e incertidumbre',
      unit: '% de ocupación',
      description: 'Bandas probabilísticas 50/80/95 % anidadas que se ensanchan con el horizonte.',
      invariants: [
        '12 periodos ordenados',
        '95 contiene 80, 80 contiene 50, 50 contiene mediana',
      ],
      rows: [
        for (final p in hotelForecastFan)
          {
            'period': p.period,
            'median': p.median,
            'lower50': p.lower50,
            'upper50': p.upper50,
            'lower80': p.lower80,
            'upper80': p.upper80,
            'lower95': p.lower95,
            'upper95': p.upper95,
          },
      ],
    ),
    'calibration-plot': ChartDataset(
      conceptId: 'calibration-plot',
      scenario: 'Predicción ficticia de cancelación de reservas',
      title: 'Probabilidad predicha y frecuencia observada',
      unit: 'probabilidad 0–1',
      description: '100 predicciones binarias determinísticas agrupadas en cinco bins frente a la diagonal ideal.',
      invariants: [
        '100 observaciones conservadas',
        'último bin incluye 1.0',
        'ambos ejes de 0 a 1',
      ],
      rows: [
        for (final b in cancellationCalibration)
          {
            'bin': b.index,
            'lower': b.lower,
            'upper': b.upper,
            'avgPredicted': b.avgPredicted,
            'observedRate': b.observedRate,
            'count': b.count,
          },
      ],
    ),
    'range-area': ChartDataset(
      conceptId: 'range-area',
      scenario: 'Pronóstico mensual de ocupación hotelera',
      title: 'Banda de ocupación',
      unit: '%',
      description: 'Banda continua entre pronóstico inferior y superior; las columnas de rango comparan intervalos discretos.',
      invariants: [
        'periodos únicos ordenados',
        'low <= high',
        'span = high - low',
      ],
      rows: [
        for (final p in hotelOccupancyRange)
          {'period': p.period, 'low': p.low, 'high': p.high, 'span': p.span},
      ],
    ),
    for (final id in ['candlestick', 'ohlc'])
      id: ChartDataset(
        conceptId: id,
        scenario: 'Índice turístico ficticio durante 12 sesiones',
        title: id == 'candlestick' ? 'Velas OHLC' : 'Ticks OHLC',
        unit: 'puntos de índice',
        description: id == 'candlestick'
            ? 'Cuerpo open–close y mecha low–high. Datos educativos, no cotizaciones reales.'
            : 'Línea low–high con tick izquierdo open y derecho close; mismos datos que velas.',
        invariants: [
          '12 sesiones únicas',
          'open y close dentro de low/high',
          'datos educativos ficticios',
        ],
        rows: [
          for (final p in educationalOhlc)
            {
              'period': p.period,
              'open': p.open,
              'high': p.high,
              'low': p.low,
              'close': p.close,
            },
        ],
      ),
    'waterfall': ChartDataset(
      conceptId: 'waterfall',
      scenario: 'Resultado mensual de un hotel',
      title: 'Puente al resultado neto',
      unit: 'millones COP',
      description: 'Cada contribución parte del acumulado previo; el neto se calcula a partir de los cambios.',
      invariants: [
        'incrementos y decrementos como magnitudes positivas',
        'total final calculado',
      ],
      rows: [
        for (final b in hotelWaterfall)
          {
            'label': b.step.label,
            'type': b.step.type.name,
            'value': b.step.value,
            'startY': b.startY,
            'endY': b.endY,
            'contribution': b.contribution,
          },
      ],
    ),
    'gantt': ChartDataset(
      conceptId: 'gantt',
      scenario: 'Desarrollo de una funcionalidad Flutter',
      title: 'Plan de seis tareas',
      unit: 'fechas de octubre de 2026',
      description: 'Cada barra horizontal muestra inicio, fin, duración y solapamiento sobre un eje temporal.',
      invariants: [
        'IDs únicos',
        'start < end',
        'seis tareas con solapamientos',
      ],
      rows: [
        for (final t in flutterFeatureTasks)
          {
            'id': t.id,
            'label': t.label,
            'start': t.start.toIso8601String(),
            'end': t.end.toIso8601String(),
            'durationDays': t.duration.inDays,
            'progress': t.progress,
          },
      ],
    ),
    'bar-line': ChartDataset(
      conceptId: 'bar-line',
      scenario: 'Ventas y margen mensual de un operador turístico',
      title: 'Ventas y margen',
      unit: 'millones COP y %',
      description: 'Ventas absolutas en barras con el margen relacionado en un eje porcentual secundario.',
      invariants: [
        'seis periodos únicos y ordenados',
        'margen entre 0 y 100 %',
        'dominio temporal compartido',
        'escalas y unidades independientes',
      ],
      rows: [
        {'period': 1, 'label': 'Ene', 'barValue': 32.0, 'lineValue': 18.0},
        {'period': 2, 'label': 'Feb', 'barValue': 37.0, 'lineValue': 21.0},
        {'period': 3, 'label': 'Mar', 'barValue': 35.0, 'lineValue': 19.0},
        {'period': 4, 'label': 'Abr', 'barValue': 44.0, 'lineValue': 23.0},
        {'period': 5, 'label': 'May', 'barValue': 49.0, 'lineValue': 25.0},
        {'period': 6, 'label': 'Jun', 'barValue': 46.0, 'lineValue': 24.0},
      ],
    ),
    'area-line': ChartDataset(
      conceptId: 'area-line',
      scenario: 'Consumo diario real frente a meta de un hotel',
      title: 'Consumo real y meta',
      unit: 'kWh por día',
      description: 'El área muestra el consumo real; la línea marca la meta diaria en el mismo dominio y unidad.',
      invariants: [
        'seis periodos ordenados',
        'misma unidad para real y meta',
        'hay días por debajo, cerca y por encima de la meta',
      ],
      rows: [
        {'period': 1, 'label': 'Lun', 'areaValue': 410.0, 'lineValue': 450.0},
        {'period': 2, 'label': 'Mar', 'areaValue': 462.0, 'lineValue': 450.0},
        {'period': 3, 'label': 'Mié', 'areaValue': 448.0, 'lineValue': 450.0},
        {'period': 4, 'label': 'Jue', 'areaValue': 520.0, 'lineValue': 470.0},
        {'period': 5, 'label': 'Vie', 'areaValue': 495.0, 'lineValue': 470.0},
        {'period': 6, 'label': 'Sáb', 'areaValue': 575.0, 'lineValue': 500.0},
      ],
    ),
    'small-multiples-line': ChartDataset(
      conceptId: 'small-multiples-line',
      scenario: 'Ocupación hotelera mensual por ciudad',
      title: 'Ocupación por ciudad',
      unit: '% de habitaciones ocupadas',
      description: 'Cuatro paneles repiten el mismo dominio de seis meses y usan escala fija de 0 a 100 %.',
      invariants: [
        'cuatro paneles identificados',
        'dominio y unidad compartidos',
        'escala Y común de 0 a 100 %',
      ],
      rows: [
        {'panel': 'Bogotá', 'period': 1, 'label': 'Ene', 'value': 62.0},
        {'panel': 'Bogotá', 'period': 2, 'label': 'Feb', 'value': 66.0},
        {'panel': 'Bogotá', 'period': 3, 'label': 'Mar', 'value': 64.0},
        {'panel': 'Bogotá', 'period': 4, 'label': 'Abr', 'value': 69.0},
        {'panel': 'Bogotá', 'period': 5, 'label': 'May', 'value': 72.0},
        {'panel': 'Bogotá', 'period': 6, 'label': 'Jun', 'value': 74.0},
        {'panel': 'Medellín', 'period': 1, 'label': 'Ene', 'value': 58.0},
        {'panel': 'Medellín', 'period': 2, 'label': 'Feb', 'value': 61.0},
        {'panel': 'Medellín', 'period': 3, 'label': 'Mar', 'value': 65.0},
        {'panel': 'Medellín', 'period': 4, 'label': 'Abr', 'value': 67.0},
        {'panel': 'Medellín', 'period': 5, 'label': 'May', 'value': 70.0},
        {'panel': 'Medellín', 'period': 6, 'label': 'Jun', 'value': 71.0},
        {'panel': 'Cartagena', 'period': 1, 'label': 'Ene', 'value': 78.0},
        {'panel': 'Cartagena', 'period': 2, 'label': 'Feb', 'value': 75.0},
        {'panel': 'Cartagena', 'period': 3, 'label': 'Mar', 'value': 71.0},
        {'panel': 'Cartagena', 'period': 4, 'label': 'Abr', 'value': 73.0},
        {'panel': 'Cartagena', 'period': 5, 'label': 'May', 'value': 77.0},
        {'panel': 'Cartagena', 'period': 6, 'label': 'Jun', 'value': 81.0},
        {'panel': 'Cali', 'period': 1, 'label': 'Ene', 'value': 53.0},
        {'panel': 'Cali', 'period': 2, 'label': 'Feb', 'value': 57.0},
        {'panel': 'Cali', 'period': 3, 'label': 'Mar', 'value': 59.0},
        {'panel': 'Cali', 'period': 4, 'label': 'Abr', 'value': 63.0},
        {'panel': 'Cali', 'period': 5, 'label': 'May', 'value': 66.0},
        {'panel': 'Cali', 'period': 6, 'label': 'Jun', 'value': 68.0},
      ],
    ),
    'small-multiples-bar': ChartDataset(
      conceptId: 'small-multiples-bar',
      scenario: 'Ventas turísticas por categoría y sucursal',
      title: 'Ventas por sucursal y categoría',
      unit: 'millones COP',
      description: 'Cada sucursal es un panel separado con las mismas categorías y escala global.',
      invariants: [
        'cuatro paneles',
        'mismas tres categorías en el mismo orden',
        'escala Y común calculada globalmente',
      ],
      rows: [
        {'panel': 'Bogotá', 'category': 'Hospedaje', 'value': 82.0},
        {'panel': 'Bogotá', 'category': 'Gastronomía', 'value': 55.0},
        {'panel': 'Bogotá', 'category': 'Transporte', 'value': 31.0},
        {'panel': 'Medellín', 'category': 'Hospedaje', 'value': 64.0},
        {'panel': 'Medellín', 'category': 'Gastronomía', 'value': 47.0},
        {'panel': 'Medellín', 'category': 'Transporte', 'value': 28.0},
        {'panel': 'Cartagena', 'category': 'Hospedaje', 'value': 95.0},
        {'panel': 'Cartagena', 'category': 'Gastronomía', 'value': 68.0},
        {'panel': 'Cartagena', 'category': 'Transporte', 'value': 42.0},
        {'panel': 'Cali', 'category': 'Hospedaje', 'value': 51.0},
        {'panel': 'Cali', 'category': 'Gastronomía', 'value': 38.0},
        {'panel': 'Cali', 'category': 'Transporte', 'value': 24.0},
      ],
    ),
    'sparkline': ChartDataset(
      conceptId: 'sparkline',
      scenario: 'Tarjetas KPI de un dashboard turístico',
      title: 'Tendencia reciente de indicadores',
      unit: 'unidad propia por KPI',
      description: 'Cuatro mini-series de ocho días aparecen junto al valor actual; cada una conserva su propia escala.',
      invariants: [
        'cada KPI tiene al menos dos observaciones ordenadas',
        'el valor actual coincide con el punto final',
        'sin ejes completos ni leyenda',
      ],
      rows: [
        {'label': 'Reservas', 'currentValue': 48.0, 'unit': 'reservas'},
        {'label': 'Ingresos', 'currentValue': 12.4, 'unit': 'M COP'},
        {'label': 'Ocupación', 'currentValue': 81.0, 'unit': '%'},
        {
          'label': 'Cancelaciones',
          'currentValue': 6.0,
          'unit': 'cancelaciones',
        },
      ],
    ),
    'line': ChartDataset(
      conceptId: 'line',
      scenario: 'Tienda minorista durante un año',
      title: 'Ventas mensuales',
      unit: 'millones COP',
      description: 'Ingresos registrados al cierre de cada mes.',
      invariants: ['doce meses en orden cronológico', 'ventas no negativas'],
      rows: [
        {'period': 1, 'label': 'Ene', 'value': 18.0},
        {'period': 2, 'label': 'Feb', 'value': 24.0},
        {'period': 3, 'label': 'Mar', 'value': 21.0},
        {'period': 4, 'label': 'Abr', 'value': 31.0},
        {'period': 5, 'label': 'May', 'value': 28.0},
        {'period': 6, 'label': 'Jun', 'value': 36.0},
        {'period': 7, 'label': 'Jul', 'value': 33.0},
        {'period': 8, 'label': 'Ago', 'value': 39.0},
        {'period': 9, 'label': 'Sep', 'value': 35.0},
        {'period': 10, 'label': 'Oct', 'value': 42.0},
        {'period': 11, 'label': 'Nov', 'value': 47.0},
        {'period': 12, 'label': 'Dic', 'value': 54.0},
      ],
    ),
    'multi-line': ChartDataset(
      conceptId: 'multi-line',
      scenario: 'Ocupación mensual de hoteles en tres ciudades',
      title: 'Ocupación hotelera por ciudad',
      unit: '% de habitaciones ocupadas',
      description: 'Compara la ocupación mensual con las mismas unidades y los mismos periodos para Bogotá, Medellín y Cartagena.',
      invariants: [
        'tres ciudades',
        'periodos mensuales compartidos y ordenados',
        'misma unidad porcentual',
        'valores entre 0 y 100',
      ],
      rows: [
        {'series': 'Bogotá', 'period': 1, 'label': 'Ene', 'value': 62.0},
        {'series': 'Bogotá', 'period': 2, 'label': 'Feb', 'value': 66.0},
        {'series': 'Bogotá', 'period': 3, 'label': 'Mar', 'value': 64.0},
        {'series': 'Bogotá', 'period': 4, 'label': 'Abr', 'value': 69.0},
        {'series': 'Bogotá', 'period': 5, 'label': 'May', 'value': 72.0},
        {'series': 'Bogotá', 'period': 6, 'label': 'Jun', 'value': 74.0},
        {'series': 'Medellín', 'period': 1, 'label': 'Ene', 'value': 58.0},
        {'series': 'Medellín', 'period': 2, 'label': 'Feb', 'value': 61.0},
        {'series': 'Medellín', 'period': 3, 'label': 'Mar', 'value': 65.0},
        {'series': 'Medellín', 'period': 4, 'label': 'Abr', 'value': 67.0},
        {'series': 'Medellín', 'period': 5, 'label': 'May', 'value': 70.0},
        {'series': 'Medellín', 'period': 6, 'label': 'Jun', 'value': 71.0},
        {'series': 'Cartagena', 'period': 1, 'label': 'Ene', 'value': 78.0},
        {'series': 'Cartagena', 'period': 2, 'label': 'Feb', 'value': 75.0},
        {'series': 'Cartagena', 'period': 3, 'label': 'Mar', 'value': 71.0},
        {'series': 'Cartagena', 'period': 4, 'label': 'Abr', 'value': 73.0},
        {'series': 'Cartagena', 'period': 5, 'label': 'May', 'value': 77.0},
        {'series': 'Cartagena', 'period': 6, 'label': 'Jun', 'value': 81.0},
      ],
    ),
    'area': ChartDataset(
      conceptId: 'area',
      scenario: 'Consumo energético diario de un hotel',
      title: 'Consumo diario de energía',
      unit: 'kWh por día',
      description: 'El área entre cero y la curva enfatiza la magnitud consumida cada día.',
      invariants: [
        'una sola serie temporal',
        'consumo no negativo',
        'baseline cero explícita',
      ],
      rows: [
        {'period': 1, 'label': 'Lun', 'value': 420.0},
        {'period': 2, 'label': 'Mar', 'value': 390.0},
        {'period': 3, 'label': 'Mié', 'value': 450.0},
        {'period': 4, 'label': 'Jue', 'value': 470.0},
        {'period': 5, 'label': 'Vie', 'value': 520.0},
        {'period': 6, 'label': 'Sáb', 'value': 610.0},
        {'period': 7, 'label': 'Dom', 'value': 560.0},
      ],
    ),
    'stacked-area': ChartDataset(
      conceptId: 'stacked-area',
      scenario: 'Reservas mensuales por canal de venta',
      title: 'Reservas por canal',
      unit: 'reservas por mes',
      description: 'Las áreas muestran la contribución absoluta de web, agencia y teléfono al total mensual variable.',
      invariants: [
        'tres canales completos en cada periodo',
        'valores no negativos',
        'total mensual es la suma absoluta de canales',
        'sin normalización porcentual',
      ],
      rows: [
        {'series': 'Web', 'period': 1, 'label': 'Ene', 'value': 40.0},
        {'series': 'Agencia', 'period': 1, 'label': 'Ene', 'value': 25.0},
        {'series': 'Teléfono', 'period': 1, 'label': 'Ene', 'value': 10.0},
        {'series': 'Web', 'period': 2, 'label': 'Feb', 'value': 44.0},
        {'series': 'Agencia', 'period': 2, 'label': 'Feb', 'value': 22.0},
        {'series': 'Teléfono', 'period': 2, 'label': 'Feb', 'value': 12.0},
        {'series': 'Web', 'period': 3, 'label': 'Mar', 'value': 48.0},
        {'series': 'Agencia', 'period': 3, 'label': 'Mar', 'value': 24.0},
        {'series': 'Teléfono', 'period': 3, 'label': 'Mar', 'value': 14.0},
        {'series': 'Web', 'period': 4, 'label': 'Abr', 'value': 46.0},
        {'series': 'Agencia', 'period': 4, 'label': 'Abr', 'value': 30.0},
        {'series': 'Teléfono', 'period': 4, 'label': 'Abr', 'value': 13.0},
        {'series': 'Web', 'period': 5, 'label': 'May', 'value': 55.0},
        {'series': 'Agencia', 'period': 5, 'label': 'May', 'value': 28.0},
        {'series': 'Teléfono', 'period': 5, 'label': 'May', 'value': 17.0},
        {'series': 'Web', 'period': 6, 'label': 'Jun', 'value': 61.0},
        {'series': 'Agencia', 'period': 6, 'label': 'Jun', 'value': 31.0},
        {'series': 'Teléfono', 'period': 6, 'label': 'Jun', 'value': 19.0},
      ],
    ),
    'step-line': ChartDataset(
      conceptId: 'step-line',
      scenario: 'Tarifa diaria de estacionamiento con cambios por fecha',
      title: 'Tarifa vigente de estacionamiento',
      unit: 'miles COP por día',
      description: 'Cada tarifa permanece vigente desde su fecha de cambio hasta el siguiente evento.',
      invariants: [
        'eventos en orden cronológico',
        'tarifas no negativas',
        'step-after: el valor de un evento rige hasta el siguiente',
      ],
      rows: [
        {'period': 1, 'label': 'Ene', 'value': 8.0},
        {'period': 3, 'label': 'Mar', 'value': 10.0},
        {'period': 5, 'label': 'May', 'value': 9.0},
        {'period': 8, 'label': 'Ago', 'value': 12.0},
        {'period': 11, 'label': 'Nov', 'value': 11.0},
      ],
    ),
    'cumulative-line': ChartDataset(
      conceptId: 'cumulative-line',
      scenario: 'Ingresos acumulados de un negocio turístico durante el año',
      title: 'Ingresos acumulados',
      unit: 'millones COP acumulados',
      description:
          'Cada punto suma los ingresos del mes a todos los meses anteriores.',
      invariants: [
        'doce meses ordenados',
        'ventas mensuales no negativas',
        'acumulado monótono',
      ],
      rows: [
        {'period': 1, 'label': 'Ene', 'value': 20.0},
        {'period': 2, 'label': 'Feb', 'value': 15.0},
        {'period': 3, 'label': 'Mar', 'value': 30.0},
        {'period': 4, 'label': 'Abr', 'value': 22.0},
        {'period': 5, 'label': 'May', 'value': 28.0},
        {'period': 6, 'label': 'Jun', 'value': 34.0},
        {'period': 7, 'label': 'Jul', 'value': 31.0},
        {'period': 8, 'label': 'Ago', 'value': 37.0},
        {'period': 9, 'label': 'Sep', 'value': 33.0},
        {'period': 10, 'label': 'Oct', 'value': 42.0},
        {'period': 11, 'label': 'Nov', 'value': 46.0},
        {'period': 12, 'label': 'Dic', 'value': 52.0},
      ],
    ),
    'indexed-line': ChartDataset(
      conceptId: 'indexed-line',
      scenario:
          'Índice mensual de precios de alojamiento, transporte y alimentación',
      title: 'Evolución relativa de precios',
      unit: 'índice (periodo inicial = 100)',
      description: 'Rebasa cada precio a 100 para comparar crecimiento relativo desde escalas monetarias distintas.',
      invariants: [
        'tres categorías de precios',
        'dominio común de doce meses',
        'base positiva por serie',
        'índice inicial 100',
      ],
      rows: [
        {'series': 'Alojamiento', 'period': 1, 'label': 'Ene', 'value': 180.0},
        {'series': 'Alojamiento', 'period': 2, 'label': 'Feb', 'value': 184.0},
        {'series': 'Alojamiento', 'period': 3, 'label': 'Mar', 'value': 178.0},
        {'series': 'Alojamiento', 'period': 4, 'label': 'Abr', 'value': 190.0},
        {'series': 'Alojamiento', 'period': 5, 'label': 'May', 'value': 198.0},
        {'series': 'Alojamiento', 'period': 6, 'label': 'Jun', 'value': 205.0},
        {'series': 'Alojamiento', 'period': 7, 'label': 'Jul', 'value': 212.0},
        {'series': 'Alojamiento', 'period': 8, 'label': 'Ago', 'value': 208.0},
        {'series': 'Alojamiento', 'period': 9, 'label': 'Sep', 'value': 220.0},
        {'series': 'Alojamiento', 'period': 10, 'label': 'Oct', 'value': 224.0},
        {'series': 'Alojamiento', 'period': 11, 'label': 'Nov', 'value': 230.0},
        {'series': 'Alojamiento', 'period': 12, 'label': 'Dic', 'value': 238.0},
        {'series': 'Transporte', 'period': 1, 'label': 'Ene', 'value': 45.0},
        {'series': 'Transporte', 'period': 2, 'label': 'Feb', 'value': 46.0},
        {'series': 'Transporte', 'period': 3, 'label': 'Mar', 'value': 47.0},
        {'series': 'Transporte', 'period': 4, 'label': 'Abr', 'value': 48.0},
        {'series': 'Transporte', 'period': 5, 'label': 'May', 'value': 47.0},
        {'series': 'Transporte', 'period': 6, 'label': 'Jun', 'value': 49.0},
        {'series': 'Transporte', 'period': 7, 'label': 'Jul', 'value': 50.0},
        {'series': 'Transporte', 'period': 8, 'label': 'Ago', 'value': 51.0},
        {'series': 'Transporte', 'period': 9, 'label': 'Sep', 'value': 53.0},
        {'series': 'Transporte', 'period': 10, 'label': 'Oct', 'value': 54.0},
        {'series': 'Transporte', 'period': 11, 'label': 'Nov', 'value': 55.0},
        {'series': 'Transporte', 'period': 12, 'label': 'Dic', 'value': 56.0},
        {'series': 'Alimentación', 'period': 1, 'label': 'Ene', 'value': 30.0},
        {'series': 'Alimentación', 'period': 2, 'label': 'Feb', 'value': 31.0},
        {'series': 'Alimentación', 'period': 3, 'label': 'Mar', 'value': 31.0},
        {'series': 'Alimentación', 'period': 4, 'label': 'Abr', 'value': 32.0},
        {'series': 'Alimentación', 'period': 5, 'label': 'May', 'value': 33.0},
        {'series': 'Alimentación', 'period': 6, 'label': 'Jun', 'value': 33.0},
        {'series': 'Alimentación', 'period': 7, 'label': 'Jul', 'value': 34.0},
        {'series': 'Alimentación', 'period': 8, 'label': 'Ago', 'value': 35.0},
        {'series': 'Alimentación', 'period': 9, 'label': 'Sep', 'value': 35.0},
        {'series': 'Alimentación', 'period': 10, 'label': 'Oct', 'value': 36.0},
        {'series': 'Alimentación', 'period': 11, 'label': 'Nov', 'value': 37.0},
        {'series': 'Alimentación', 'period': 12, 'label': 'Dic', 'value': 38.0},
      ],
    ),
    'normalized-stacked-area': ChartDataset(
      conceptId: 'normalized-stacked-area',
      scenario: 'Participación mensual de reservas por canal',
      title: 'Composición porcentual de reservas',
      unit: '% del total mensual',
      description: 'Normaliza cada mes a 100 % para comparar la mezcla de canales sin el efecto del volumen total.',
      invariants: [
        'tres canales por mes',
        'valores no negativos',
        'cada periodo positivo suma 100 %',
        'periodo total cero produce porcentajes cero',
      ],
      rows: [
        {'series': 'Web', 'period': 1, 'label': 'Ene', 'value': 40.0},
        {'series': 'Agencia', 'period': 1, 'label': 'Ene', 'value': 25.0},
        {'series': 'Teléfono', 'period': 1, 'label': 'Ene', 'value': 10.0},
        {'series': 'Web', 'period': 2, 'label': 'Feb', 'value': 46.0},
        {'series': 'Agencia', 'period': 2, 'label': 'Feb', 'value': 19.0},
        {'series': 'Teléfono', 'period': 2, 'label': 'Feb', 'value': 15.0},
        {'series': 'Web', 'period': 3, 'label': 'Mar', 'value': 38.0},
        {'series': 'Agencia', 'period': 3, 'label': 'Mar', 'value': 32.0},
        {'series': 'Teléfono', 'period': 3, 'label': 'Mar', 'value': 18.0},
        {'series': 'Web', 'period': 4, 'label': 'Abr', 'value': 52.0},
        {'series': 'Agencia', 'period': 4, 'label': 'Abr', 'value': 28.0},
        {'series': 'Teléfono', 'period': 4, 'label': 'Abr', 'value': 20.0},
        {'series': 'Web', 'period': 5, 'label': 'May', 'value': 61.0},
        {'series': 'Agencia', 'period': 5, 'label': 'May', 'value': 30.0},
        {'series': 'Teléfono', 'period': 5, 'label': 'May', 'value': 24.0},
        {'series': 'Web', 'period': 6, 'label': 'Jun', 'value': 57.0},
        {'series': 'Agencia', 'period': 6, 'label': 'Jun', 'value': 38.0},
        {'series': 'Teléfono', 'period': 6, 'label': 'Jun', 'value': 25.0},
        {'series': 'Web', 'period': 7, 'label': 'Jul', 'value': 69.0},
        {'series': 'Agencia', 'period': 7, 'label': 'Jul', 'value': 35.0},
        {'series': 'Teléfono', 'period': 7, 'label': 'Jul', 'value': 29.0},
        {'series': 'Web', 'period': 8, 'label': 'Ago', 'value': 64.0},
        {'series': 'Agencia', 'period': 8, 'label': 'Ago', 'value': 41.0},
        {'series': 'Teléfono', 'period': 8, 'label': 'Ago', 'value': 32.0},
        {'series': 'Web', 'period': 9, 'label': 'Sep', 'value': 73.0},
        {'series': 'Agencia', 'period': 9, 'label': 'Sep', 'value': 40.0},
        {'series': 'Teléfono', 'period': 9, 'label': 'Sep', 'value': 35.0},
        {'series': 'Web', 'period': 10, 'label': 'Oct', 'value': 80.0},
        {'series': 'Agencia', 'period': 10, 'label': 'Oct', 'value': 46.0},
        {'series': 'Teléfono', 'period': 10, 'label': 'Oct', 'value': 39.0},
        {'series': 'Web', 'period': 11, 'label': 'Nov', 'value': 82.0},
        {'series': 'Agencia', 'period': 11, 'label': 'Nov', 'value': 51.0},
        {'series': 'Teléfono', 'period': 11, 'label': 'Nov', 'value': 43.0},
        {'series': 'Web', 'period': 12, 'label': 'Dic', 'value': 94.0},
        {'series': 'Agencia', 'period': 12, 'label': 'Dic', 'value': 56.0},
        {'series': 'Teléfono', 'period': 12, 'label': 'Dic', 'value': 48.0},
      ],
    ),
    'streamgraph': ChartDataset(
      conceptId: 'streamgraph',
      scenario: 'Conversaciones sobre temas turísticos durante doce meses',
      title: 'Interés turístico por tema',
      unit: 'conversaciones por mes',
      description: 'Las bandas conservan su volumen y se apilan alrededor de una baseline centrada para comparar su espesor.',
      invariants: [
        'cuatro temas completos por mes',
        'conteos no negativos',
        'baseline por periodo igual a menos la mitad del total',
        'offset centrado simple; no ThemeRiver/Wiggle',
      ],
      rows: [
        {'series': 'Alojamiento', 'period': 1, 'label': 'Ene', 'value': 28.0},
        {'series': 'Gastronomía', 'period': 1, 'label': 'Ene', 'value': 18.0},
        {'series': 'Transporte', 'period': 1, 'label': 'Ene', 'value': 14.0},
        {'series': 'Cultura', 'period': 1, 'label': 'Ene', 'value': 12.0},
        {'series': 'Alojamiento', 'period': 2, 'label': 'Feb', 'value': 30.0},
        {'series': 'Gastronomía', 'period': 2, 'label': 'Feb', 'value': 20.0},
        {'series': 'Transporte', 'period': 2, 'label': 'Feb', 'value': 13.0},
        {'series': 'Cultura', 'period': 2, 'label': 'Feb', 'value': 15.0},
        {'series': 'Alojamiento', 'period': 3, 'label': 'Mar', 'value': 26.0},
        {'series': 'Gastronomía', 'period': 3, 'label': 'Mar', 'value': 22.0},
        {'series': 'Transporte', 'period': 3, 'label': 'Mar', 'value': 16.0},
        {'series': 'Cultura', 'period': 3, 'label': 'Mar', 'value': 19.0},
        {'series': 'Alojamiento', 'period': 4, 'label': 'Abr', 'value': 34.0},
        {'series': 'Gastronomía', 'period': 4, 'label': 'Abr', 'value': 25.0},
        {'series': 'Transporte', 'period': 4, 'label': 'Abr', 'value': 18.0},
        {'series': 'Cultura', 'period': 4, 'label': 'Abr', 'value': 17.0},
        {'series': 'Alojamiento', 'period': 5, 'label': 'May', 'value': 38.0},
        {'series': 'Gastronomía', 'period': 5, 'label': 'May', 'value': 31.0},
        {'series': 'Transporte', 'period': 5, 'label': 'May', 'value': 17.0},
        {'series': 'Cultura', 'period': 5, 'label': 'May', 'value': 22.0},
        {'series': 'Alojamiento', 'period': 6, 'label': 'Jun', 'value': 42.0},
        {'series': 'Gastronomía', 'period': 6, 'label': 'Jun', 'value': 34.0},
        {'series': 'Transporte', 'period': 6, 'label': 'Jun', 'value': 21.0},
        {'series': 'Cultura', 'period': 6, 'label': 'Jun', 'value': 24.0},
        {'series': 'Alojamiento', 'period': 7, 'label': 'Jul', 'value': 48.0},
        {'series': 'Gastronomía', 'period': 7, 'label': 'Jul', 'value': 39.0},
        {'series': 'Transporte', 'period': 7, 'label': 'Jul', 'value': 24.0},
        {'series': 'Cultura', 'period': 7, 'label': 'Jul', 'value': 28.0},
        {'series': 'Alojamiento', 'period': 8, 'label': 'Ago', 'value': 45.0},
        {'series': 'Gastronomía', 'period': 8, 'label': 'Ago', 'value': 43.0},
        {'series': 'Transporte', 'period': 8, 'label': 'Ago', 'value': 26.0},
        {'series': 'Cultura', 'period': 8, 'label': 'Ago', 'value': 31.0},
        {'series': 'Alojamiento', 'period': 9, 'label': 'Sep', 'value': 40.0},
        {'series': 'Gastronomía', 'period': 9, 'label': 'Sep', 'value': 46.0},
        {'series': 'Transporte', 'period': 9, 'label': 'Sep', 'value': 29.0},
        {'series': 'Cultura', 'period': 9, 'label': 'Sep', 'value': 34.0},
        {'series': 'Alojamiento', 'period': 10, 'label': 'Oct', 'value': 44.0},
        {'series': 'Gastronomía', 'period': 10, 'label': 'Oct', 'value': 51.0},
        {'series': 'Transporte', 'period': 10, 'label': 'Oct', 'value': 31.0},
        {'series': 'Cultura', 'period': 10, 'label': 'Oct', 'value': 38.0},
        {'series': 'Alojamiento', 'period': 11, 'label': 'Nov', 'value': 50.0},
        {'series': 'Gastronomía', 'period': 11, 'label': 'Nov', 'value': 54.0},
        {'series': 'Transporte', 'period': 11, 'label': 'Nov', 'value': 35.0},
        {'series': 'Cultura', 'period': 11, 'label': 'Nov', 'value': 42.0},
        {'series': 'Alojamiento', 'period': 12, 'label': 'Dic', 'value': 62.0},
        {'series': 'Gastronomía', 'period': 12, 'label': 'Dic', 'value': 68.0},
        {'series': 'Transporte', 'period': 12, 'label': 'Dic', 'value': 46.0},
        {'series': 'Cultura', 'period': 12, 'label': 'Dic', 'value': 58.0},
      ],
    ),
    'control-chart': ChartDataset(
      conceptId: 'control-chart',
      scenario: 'Tiempo de respuesta diario de una API',
      title: 'Control de tiempo de respuesta',
      unit: 'milisegundos',
      description: 'Ejemplo educativo Individuals-style: media y límites a tres desviaciones estándar poblacionales.',
      invariants: [
        'doce observaciones ordenadas',
        'media y σ poblacional constantes',
        'señalar observaciones fuera de UCL/LCL',
        'ejemplo educativo, no SPC industrial completo',
      ],
      rows: [
        {'period': 1, 'label': 'D1', 'value': 100.0},
        {'period': 2, 'label': 'D2', 'value': 102.0},
        {'period': 3, 'label': 'D3', 'value': 98.0},
        {'period': 4, 'label': 'D4', 'value': 101.0},
        {'period': 5, 'label': 'D5', 'value': 99.0},
        {'period': 6, 'label': 'D6', 'value': 103.0},
        {'period': 7, 'label': 'D7', 'value': 97.0},
        {'period': 8, 'label': 'D8', 'value': 100.0},
        {'period': 9, 'label': 'D9', 'value': 104.0},
        {'period': 10, 'label': 'D10', 'value': 96.0},
        {'period': 11, 'label': 'D11', 'value': 101.0},
        {'period': 12, 'label': 'D12', 'value': 145.0},
      ],
    ),
    'bar': ChartDataset(
      conceptId: 'bar',
      scenario: 'Ventas por línea de productos',
      title: 'Ventas por categoría',
      unit: 'millones COP',
      description: 'Ingresos del mismo período para categorías comparables.',
      invariants: ['categorías únicas', 'ventas no negativas'],
      rows: [
        {'label': 'Libros', 'value': 36.0},
        {'label': 'Tecnología', 'value': 52.0},
        {'label': 'Hogar', 'value': 29.0},
        {'label': 'Deporte', 'value': 41.0},
      ],
    ),
    'grouped-bar': ChartDataset(
      conceptId: 'grouped-bar',
      scenario: 'Ventas trimestrales por canal en tres regiones',
      title: 'Ventas por región y canal',
      unit: 'millones COP',
      description: 'Cada región contiene una barra por canal de venta.',
      invariants: ['mismas categorías para cada canal', 'valores no negativos'],
      rows: [
        {'category': 'Norte', 'series': 'Tienda física', 'value': 42.0},
        {'category': 'Norte', 'series': 'Web', 'value': 35.0},
        {'category': 'Norte', 'series': 'Marketplace', 'value': 21.0},
        {'category': 'Centro', 'series': 'Tienda física', 'value': 38.0},
        {'category': 'Centro', 'series': 'Web', 'value': 46.0},
        {'category': 'Centro', 'series': 'Marketplace', 'value': 27.0},
        {'category': 'Sur', 'series': 'Tienda física', 'value': 31.0},
        {'category': 'Sur', 'series': 'Web', 'value': 29.0},
        {'category': 'Sur', 'series': 'Marketplace', 'value': 34.0},
      ],
    ),
    'stacked-bar': ChartDataset(
      conceptId: 'stacked-bar',
      scenario: 'Tickets de soporte por departamento y estado',
      title: 'Composición de tickets',
      unit: 'tickets',
      description:
          'Los segmentos apilados forman el total absoluto por departamento.',
      invariants: ['segmentos no negativos', 'el total es la suma de estados'],
      rows: [
        {'category': 'Ventas', 'series': 'Resueltos', 'value': 46.0},
        {'category': 'Ventas', 'series': 'Escalados', 'value': 12.0},
        {'category': 'Ventas', 'series': 'Pendientes', 'value': 18.0},
        {'category': 'Producto', 'series': 'Resueltos', 'value': 34.0},
        {'category': 'Producto', 'series': 'Escalados', 'value': 21.0},
        {'category': 'Producto', 'series': 'Pendientes', 'value': 25.0},
        {'category': 'Logística', 'series': 'Resueltos', 'value': 52.0},
        {'category': 'Logística', 'series': 'Escalados', 'value': 9.0},
        {'category': 'Logística', 'series': 'Pendientes', 'value': 14.0},
      ],
    ),
    'normalized-stacked-bar': ChartDataset(
      conceptId: 'normalized-stacked-bar',
      scenario: 'Asignación anual del presupuesto por área en tres sedes',
      title: 'Composición proporcional del presupuesto',
      unit: '% del presupuesto de cada sede',
      description: 'Cada barra suma exactamente 100 %; se comparan proporciones, no montos.',
      invariants: [
        'valores base no negativos',
        'por sede la suma normalizada es 100 %',
      ],
      rows: [
        {'category': 'Bogotá', 'series': 'Personal', 'value': 480.0},
        {'category': 'Bogotá', 'series': 'Operación', 'value': 320.0},
        {'category': 'Bogotá', 'series': 'Tecnología', 'value': 200.0},
        {'category': 'Medellín', 'series': 'Personal', 'value': 390.0},
        {'category': 'Medellín', 'series': 'Operación', 'value': 260.0},
        {'category': 'Medellín', 'series': 'Tecnología', 'value': 350.0},
        {'category': 'Cali', 'series': 'Personal', 'value': 300.0},
        {'category': 'Cali', 'series': 'Operación', 'value': 450.0},
        {'category': 'Cali', 'series': 'Tecnología', 'value': 250.0},
      ],
    ),
    'diverging-bar': ChartDataset(
      conceptId: 'diverging-bar',
      scenario: 'Desviación mensual de ventas frente a la meta',
      title: 'Variación respecto al objetivo',
      unit: 'millones COP respecto a la meta',
      description: 'Cero representa cumplir la meta; positivo la supera y negativo queda por debajo.',
      invariants: [
        'cero es la referencia',
        'existen variaciones positivas y negativas',
      ],
      rows: [
        {'label': 'Ene', 'value': 8.0},
        {'label': 'Feb', 'value': -5.0},
        {'label': 'Mar', 'value': 3.0},
        {'label': 'Abr', 'value': -11.0},
        {'label': 'May', 'value': 6.0},
        {'label': 'Jun', 'value': -2.0},
      ],
    ),
    'dot-plot': ChartDataset(
      conceptId: 'dot-plot',
      scenario: 'Encuesta de satisfacción media por servicio turístico',
      title: 'Satisfacción por servicio',
      unit: 'puntos sobre 10',
      description:
          'Un punto por servicio; su posición en la escala expresa la media.',
      invariants: ['una observación por servicio', 'escala fija de 0 a 10'],
      rows: [
        {'label': 'Transporte', 'value': 7.2},
        {'label': 'Hospedaje', 'value': 8.6},
        {'label': 'Alimentación', 'value': 7.8},
        {'label': 'Atención', 'value': 9.1},
        {'label': 'Actividades', 'value': 8.2},
      ],
    ),
    'lollipop': ChartDataset(
      conceptId: 'lollipop',
      scenario: 'Descargas del último mes por aplicación',
      title: 'Descargas por aplicación',
      unit: 'miles de descargas',
      description: 'El tallo conecta la base cero con el punto que marca el valor final.',
      invariants: ['una observación por aplicación', 'descargas no negativas'],
      rows: [
        {'label': 'Clima', 'value': 84.0},
        {'label': 'Finanzas', 'value': 61.0},
        {'label': 'Lectura', 'value': 47.0},
        {'label': 'Salud', 'value': 72.0},
        {'label': 'Viajes', 'value': 38.0},
      ],
    ),
    'dumbbell': ChartDataset(
      conceptId: 'dumbbell',
      scenario: 'Satisfacción hotelera antes y después de una mejora',
      title: 'Satisfacción antes y después',
      unit: 'puntos sobre 10',
      description:
          'Dos puntos por área conectados; su distancia muestra el cambio.',
      invariants: [
        'exactamente dos mediciones por área',
        'escala común de 0 a 10',
      ],
      rows: [
        {'label': 'Recepción', 'start': 6.2, 'end': 8.1},
        {'label': 'Restaurante', 'start': 7.1, 'end': 7.8},
        {'label': 'Habitaciones', 'start': 6.8, 'end': 8.7},
        {'label': 'Reservas', 'start': 5.9, 'end': 7.2},
      ],
    ),
    'slope': ChartDataset(
      conceptId: 'slope',
      scenario: 'Participación de mercado entre 2025 y 2026',
      title: 'Cambio de participación de mercado',
      unit: '% del mercado',
      description: 'Compara solo dos periodos fijos; cada línea une el valor inicial y final de una empresa.',
      invariants: [
        'exactamente dos periodos: 2025 y 2026',
        'participación entre 0 y 100 %',
      ],
      rows: [
        {
          'label': 'Andes',
          'startPeriod': '2025',
          'start': 28.0,
          'endPeriod': '2026',
          'end': 34.0,
        },
        {
          'label': 'Brisa',
          'startPeriod': '2025',
          'start': 24.0,
          'endPeriod': '2026',
          'end': 21.0,
        },
        {
          'label': 'Cumbre',
          'startPeriod': '2025',
          'start': 19.0,
          'endPeriod': '2026',
          'end': 23.0,
        },
        {
          'label': 'Delta',
          'startPeriod': '2025',
          'start': 17.0,
          'endPeriod': '2026',
          'end': 13.0,
        },
        {
          'label': 'Estrella',
          'startPeriod': '2025',
          'start': 12.0,
          'endPeriod': '2026',
          'end': 9.0,
        },
      ],
    ),
    'pareto': ChartDataset(
      conceptId: 'pareto',
      scenario: 'Incidencias reportadas en una plataforma durante el trimestre',
      title: 'Causas de incidencias',
      unit: 'incidencias y porcentaje acumulado',
      description: 'Frecuencias ordenadas por importancia y línea del porcentaje que acumulan.',
      invariants: [
        'frecuencias no negativas',
        'categorías únicas',
        'orden descendente',
      ],
      rows: [
        {'label': 'Pagos rechazados', 'value': 27.0},
        {'label': 'Timeout', 'value': 18.0},
        {'label': 'Otros', 'value': 1.0},
        {'label': 'Autenticación', 'value': 42.0},
        {'label': 'Navegación', 'value': 4.0},
        {'label': 'Datos incompletos', 'value': 8.0},
      ],
    ),
    'pie': ChartDataset(
      conceptId: 'pie',
      scenario: 'Reservas por canal de venta',
      title: 'Reservas por canal',
      unit: 'reservas',
      description: 'Cuatro canales forman el total de 100 reservas; los sectores expresan la proporción de cada canal.',
      invariants: [
        'un único total',
        'cuatro categorías',
        'valores no negativos',
        'total de 100 reservas',
      ],
      rows: [
        {'label': 'Web', 'value': 48.0},
        {'label': 'Agencia', 'value': 27.0},
        {'label': 'Teléfono', 'value': 15.0},
        {'label': 'Walk-in', 'value': 10.0},
      ],
    ),
    'donut': ChartDataset(
      conceptId: 'donut',
      scenario: 'Ingresos por línea de negocio hotelera',
      title: 'Ingresos por línea',
      unit: 'millones COP',
      description: 'La composición de ingresos reserva el centro para el total económico de \$100 M.',
      invariants: [
        'slices suman el KPI central',
        'cuatro categorías',
        'valores no negativos',
      ],
      rows: [
        {'label': 'Hospedaje', 'value': 42.0},
        {'label': 'Gastronomía', 'value': 26.0},
        {'label': 'Tours', 'value': 19.0},
        {'label': 'Transporte', 'value': 13.0},
      ],
    ),
    'waffle': ChartDataset(
      conceptId: 'waffle',
      scenario: 'Ocupación hotelera expresada en unidades discretas',
      title: 'Ocupación',
      unit: '%',
      description: 'Una cuadrícula de 10×10 conserva 100 unidades; 73 están ocupadas y 27 disponibles.',
      invariants: [
        '100 celdas fijas',
        'una celda representa un punto porcentual',
        'redondeo al entero más cercano',
      ],
      rows: [
        {'label': 'Ocupadas', 'value': 73.0},
        {'label': 'Disponibles', 'value': 27.0},
      ],
    ),
    'polar-area': ChartDataset(
      conceptId: 'polar-area',
      scenario: 'Solicitudes turísticas por categoría',
      title: 'Demanda por categoría',
      unit: 'solicitudes',
      description: 'Sectores de igual ángulo comparan magnitudes absolutas mediante su radio; no representan partes de un total.',
      invariants: [
        'cinco categorías únicas',
        'magnitudes finitas no negativas',
        'no requiere suma de 100',
      ],
      rows: [
        {'label': 'Alojamiento', 'value': 2100.0},
        {'label': 'Gastronomía', 'value': 1750.0},
        {'label': 'Transporte', 'value': 1300.0},
        {'label': 'Ocio', 'value': 980.0},
        {'label': 'Cultura', 'value': 760.0},
      ],
    ),
    'radar': ChartDataset(
      conceptId: 'radar',
      scenario: 'Perfil comparable de destinos turísticos',
      title: 'Perfil por destino',
      unit: 'puntuación de 0 a 10',
      description: 'Cartagena y Medellín se comparan en seis dimensiones homogéneas con una escala común.',
      invariants: [
        'mismas seis dimensiones para todos los perfiles',
        'escala común de 0 a 10',
        'valores finitos',
      ],
      rows: [
        {'profile': 'Cartagena', 'dimension': 'Seguridad', 'value': 8.1},
        {'profile': 'Cartagena', 'dimension': 'Precio', 'value': 7.0},
        {'profile': 'Cartagena', 'dimension': 'Gastronomía', 'value': 9.2},
        {'profile': 'Cartagena', 'dimension': 'Movilidad', 'value': 6.8},
        {'profile': 'Cartagena', 'dimension': 'Cultura', 'value': 9.4},
        {'profile': 'Cartagena', 'dimension': 'Alojamiento', 'value': 8.7},
        {'profile': 'Medellín', 'dimension': 'Seguridad', 'value': 8.5},
        {'profile': 'Medellín', 'dimension': 'Precio', 'value': 8.2},
        {'profile': 'Medellín', 'dimension': 'Gastronomía', 'value': 8.4},
        {'profile': 'Medellín', 'dimension': 'Movilidad', 'value': 8.8},
        {'profile': 'Medellín', 'dimension': 'Cultura', 'value': 8.1},
        {'profile': 'Medellín', 'dimension': 'Alojamiento', 'value': 8.6},
      ],
    ),
    for (final id in const [
      'histogram',
      'frequency-polygon',
      'ogive',
      'strip-plot',
      'density',
    ])
      id: ChartDataset(
        conceptId: id,
        scenario: 'Tourist customer service times',
        title: touristServiceSample.label,
        unit: touristServiceSample.unit,
        description: switch (id) {
          'histogram' => '46 individual observations grouped into six equal-width numeric bins.',
          'frequency-polygon' =>
            'The same six bins as the histogram, plotted at their midpoints.',
          'ogive' => 'The same six bins as the histogram, with cumulative percentages at upper bounds.',
          'strip-plot' =>
            'All individual observations retained; Y jitter is visual only.',
          _ => 'The same observations smoothed with Gaussian KDE.',
        },
        invariants: [
          '46 finite observations in minutes',
          'shared source sample across all five distribution demos',
          if (id == 'strip-plot') 'original observation order retained',
        ],
        rows: [
          for (final value in touristServiceSample.values)
            {'observation': value},
        ],
      ),
    'box-plot': ChartDataset(
      conceptId: 'box-plot',
      scenario: 'Customer service time by branch',
      title: 'Service time by branch',
      unit: 'minutes',
      description: 'Four branch samples summarized with median, quartiles, whiskers, and IQR outliers.',
      invariants: [
        'four comparable groups',
        'statistics calculated from observations',
        'outlier flags derived by 1.5 IQR rule',
      ],
      rows: [
        for (final group in boxPlotGroups)
          for (final value in group.values)
            {'group': group.label, 'value': value},
      ],
    ),
    'violin': ChartDataset(
      conceptId: 'violin',
      scenario: 'Waiting time by service type',
      title: 'Wait distribution by service',
      unit: 'minutes',
      description:
          'Three service samples compared through their Gaussian KDE shapes.',
      invariants: [
        'shared X range and bandwidth',
        'symmetric KDE-derived width',
        'same samples also support box plot reading',
      ],
      rows: [
        for (final group in violinGroups)
          for (final value in group.values)
            {'group': group.label, 'value': value},
      ],
    ),
    'ridgeline': ChartDataset(
      conceptId: 'ridgeline',
      scenario: 'Search time by month',
      title: 'Search duration by month',
      unit: 'minutes',
      description: 'Four monthly distributions shown as offset ridges with a shared X scale and density height scale.',
      invariants: [
        'four groups',
        'common bandwidth and X domain',
        'shared density normalization',
      ],
      rows: [
        for (final group in ridgelineGroups)
          for (final value in group.values)
            {'group': group.label, 'value': value},
      ],
    ),
    'hexbin': ChartDataset(
      conceptId: 'hexbin',
      scenario: 'Tourist visit duration and spending',
      title: 'Visit duration vs spending',
      unit: 'hours and thousand COP',
      description: '300 deterministic bivariate observations aggregated into pointy-top axial hexagonal cells.',
      invariants: [
        'every observation assigned once',
        'hexSize 0.11 in normalized plot coordinates',
        'cell count preserves all 300 observations',
      ],
      rows: [
        for (final point in hexbinObservations)
          {'duration': point.x, 'spend': point.y},
      ],
    ),
    'heatmap': ChartDataset(
      conceptId: 'heatmap',
      scenario: 'Tourist demand by weekday and time period',
      title: 'Demand intensity matrix',
      unit: 'visits',
      description: 'A complete 7-day by 6-period matrix with stronger weekend and daytime demand.',
      invariants: [
        '42 unique cells',
        'all weekday-period pairs present',
        'shared min/max color scale',
      ],
      rows: [
        for (final cell in heatmapMatrix.orderedCells)
          {
            'day': cell.yCategory,
            'period': cell.xCategory,
            'value': cell.value,
          },
      ],
    ),
    'scatter': ChartDataset(
      conceptId: 'scatter',
      scenario: 'Tourist stay duration and total spending',
      title: 'Stay and spend',
      unit: 'nights and thousand COP',
      description: '32 deterministic paired stays and spends with a positive noisy association.',
      invariants: [
        'two numeric measures',
        'individual observations',
        'no connecting path',
      ],
      rows: [
        for (final point in scatterObservations)
          {
            'label': point.label,
            'nights': point.nights,
            'spendThousands': point.spendThousands,
          },
      ],
    ),
    'bubble': ChartDataset(
      conceptId: 'bubble',
      scenario: 'Visitors, visitor spending, and registered establishments by destination',
      title: 'Destination scale and spending',
      unit: 'thousand visitors, thousand COP, establishments',
      description:
          'Eight destinations use marker area to encode establishment counts.',
      invariants: [
        'two numeric axes',
        'area-scaled third magnitude',
        'zero magnitude maps to a visible minimum radius',
      ],
      rows: [
        for (final destination in bubbleDestinations)
          {
            'label': destination.label,
            'visitorsThousands': destination.visitorsThousands,
            'spendPerVisitorThousands': destination.spendPerVisitorThousands,
            'establishments': destination.establishments,
          },
      ],
    ),
    'connected-scatter': ChartDataset(
      conceptId: 'connected-scatter',
      scenario: 'Hotel occupancy and average rate by month',
      title: 'Occupancy-rate trajectory',
      unit: 'occupancy percent and thousand COP',
      description: 'Monthly order connects numeric occupancy and rate coordinates; time is not an axis.',
      invariants: [
        '12 unique month orders',
        'two numeric axes',
        'connection follows order only',
      ],
      rows: [
        for (final point in connectedScatterPoints)
          {
            'order': point.order,
            'label': point.label,
            'occupancy': point.x,
            'averageRate': point.y,
          },
      ],
    ),
    'error-bar': ChartDataset(
      conceptId: 'error-bar',
      scenario: 'Mean customer wait by service with approximate 95% confidence intervals',
      title: 'Wait estimate and uncertainty',
      unit: 'minutes',
      description: 'Means and normal-approximation confidence intervals are calculated from ten observations per service.',
      invariants: [
        'five services',
        'sample SD uses n - 1',
        'mean plus/minus 1.96 standard errors',
      ],
      rows: [
        for (final estimate in errorBarEstimates)
          {
            'label': estimate.label,
            'estimate': estimate.estimate,
            'lower': estimate.lower,
            'upper': estimate.upper,
            'sampleSize': estimate.sampleSize,
          },
      ],
    ),
    'range-column': ChartDataset(
      conceptId: 'range-column',
      scenario: 'Daily minimum and maximum temperature',
      title: 'Temperature ranges',
      unit: '°C',
      description: 'Seven daily columns span the observed low and high temperature; there is no central estimate.',
      invariants: [
        'seven days',
        'low <= high',
        'column span is high minus low',
      ],
      rows: [
        for (final range in dailyTemperatureRanges)
          {
            'label': range.label,
            'low': range.low,
            'high': range.high,
            'span': range.span,
          },
      ],
    ),
  });

  static ChartDataset? forConcept(String id) => all[id];

  /// Adapter for the two existing demos. Other chart shapes can read rows
  /// with their own typed adapters without changing the registry contract.
  static List<ChartPoint> pointsFor(String id) => [
    for (final row in all[id]!.rows)
      ChartPoint(row['label']! as String, (row['value']! as num).toDouble()),
  ];

  static List<BarDatum> barDataFor(String id) => [
    for (final row in all[id]!.rows)
      BarDatum(
        category: row['category']! as String,
        series: row['series']! as String,
        value: (row['value']! as num).toDouble(),
      ),
  ];

  static List<DumbbellDatum> dumbbellData() => [
    for (final row in all['dumbbell']!.rows)
      DumbbellDatum(
        label: row['label']! as String,
        startValue: (row['start']! as num).toDouble(),
        endValue: (row['end']! as num).toDouble(),
      ),
  ];

  static List<SlopeDatum> slopeData() => [
    for (final row in all['slope']!.rows)
      SlopeDatum(
        label: row['label']! as String,
        startPeriod: row['startPeriod']! as String,
        startValue: (row['start']! as num).toDouble(),
        endPeriod: row['endPeriod']! as String,
        endValue: (row['end']! as num).toDouble(),
      ),
  ];

  static List<ParetoSource> paretoSources() => [
    for (final row in all['pareto']!.rows)
      ParetoSource(
        category: row['label']! as String,
        frequency: (row['value']! as num).toDouble(),
      ),
  ];
}

class DumbbellDatum {
  const DumbbellDatum({
    required this.label,
    required this.startValue,
    required this.endValue,
  });
  final String label;
  final double startValue;
  final double endValue;
  double get delta => endValue - startValue;
}

class SlopeDatum {
  const SlopeDatum({
    required this.label,
    required this.startPeriod,
    required this.startValue,
    required this.endPeriod,
    required this.endValue,
  });
  final String label;
  final String startPeriod;
  final double startValue;
  final String endPeriod;
  final double endValue;
  double get delta => endValue - startValue;
}

class ParetoSource {
  const ParetoSource({required this.category, required this.frequency});
  final String category;
  final double frequency;
}

class ParetoPoint {
  const ParetoPoint({
    required this.category,
    required this.frequency,
    required this.cumulative,
    required this.cumulativePercent,
  });
  final String category;
  final double frequency;
  final double cumulative;
  final double cumulativePercent;
}

/// Sorts frequencies descending and computes their running count and percentage.
/// Empty input returns empty output; a zero total has a defined 0% at every row.
List<ParetoPoint> calculatePareto(List<ParetoSource> source) {
  final names = <String>{};
  for (final row in source) {
    if (row.category.trim().isEmpty || !names.add(row.category)) {
      throw ArgumentError('Pareto categories must be non-empty and unique.');
    }
    if (!row.frequency.isFinite || row.frequency < 0) {
      throw ArgumentError(
        'Pareto frequencies must be finite and non-negative.',
      );
    }
  }
  final ordered = source.toList()
    ..sort((a, b) {
      final byFrequency = b.frequency.compareTo(a.frequency);
      return byFrequency != 0 ? byFrequency : a.category.compareTo(b.category);
    });
  final total = ordered.fold<double>(0, (sum, row) => sum + row.frequency);
  if (!total.isFinite) {
    throw ArgumentError('Pareto frequency total must be finite.');
  }
  var cumulative = 0.0;
  final result = <ParetoPoint>[];
  for (final row in ordered) {
    cumulative += row.frequency;
    result.add(
      ParetoPoint(
        category: row.category,
        frequency: row.frequency,
        cumulative: cumulative,
        cumulativePercent: total == 0 ? 0 : cumulative / total * 100,
      ),
    );
  }
  return List.unmodifiable(result);
}

class BarDatum {
  const BarDatum({
    required this.category,
    required this.series,
    required this.value,
  });
  final String category;
  final String series;
  final double value;
}

/// Returns percentages per category; categories with a zero total map to zeroes.
/// Values are rounded to 2 decimals and the final segment absorbs rounding drift.
List<BarDatum> normalizeBars(List<BarDatum> rows) {
  final categories = rows.map((r) => r.category).toSet();
  final normalized = <BarDatum>[];
  for (final category in categories) {
    final members = rows.where((r) => r.category == category).toList();
    if (members.any((r) => r.value < 0)) {
      throw ArgumentError('Normalized bars require non-negative values.');
    }
    final total = members.fold<double>(0, (sum, r) => sum + r.value);
    if (total == 0) {
      normalized.addAll(
        members.map(
          (r) => BarDatum(category: r.category, series: r.series, value: 0),
        ),
      );
      continue;
    }
    var used = 0.0;
    for (var i = 0; i < members.length; i++) {
      final value = i == members.length - 1
          ? 100 - used
          : double.parse((members[i].value / total * 100).toStringAsFixed(2));
      used += value;
      normalized.add(
        BarDatum(category: category, series: members[i].series, value: value),
      );
    }
  }
  return List.unmodifiable(normalized);
}
