import '../../charts/data/chart_catalog.dart';

class AdvisorOption {
  const AdvisorOption(this.label, this.nextId);
  final String label;
  final String nextId;
}

class AdvisorNode {
  const AdvisorNode(this.prompt, this.options);
  final String prompt;
  final List<AdvisorOption> options;
}

class AdvisorRecommendation {
  const AdvisorRecommendation(this.conceptId, this.reason, this.alternatives);
  final String conceptId;
  final String reason;
  final List<String> alternatives;
}

class AdvisorEngine {
  static const start = 'start';

  static const nodes = <String, AdvisorNode>{
    start: AdvisorNode('¿Qué quieres descubrir en tus datos?', [
      AdvisorOption('Comparar categorías', 'comparison'),
      AdvisorOption('Ver evolución temporal', 'temporal'),
      AdvisorOption('Entender partes de un total', 'composition'),
      AdvisorOption('Explorar distribución', 'distribution'),
      AdvisorOption('Relacionar variables', 'correlation'),
      AdvisorOption('Explorar relaciones entre métricas', 'scatterplot-matrix'),
      AdvisorOption('Analizar ubicaciones o superficies', 'spatial'),
      AdvisorOption('Medir rendimiento', 'performance'),
      AdvisorOption('Detectar valores atípicos', 'box-plot'),
      AdvisorOption('Relacionar entidades', 'network-graph'),
      AdvisorOption('Comparar múltiples dimensiones', 'radar'),
      AdvisorOption('Analizar finanzas', 'financial'),
      AdvisorOption('Planificar tareas', 'gantt'),
    ]),
    'comparison': AdvisorNode('¿Cómo quieres comparar las categorías?', [
      AdvisorOption('Un periodo', 'bar'),
      AdvisorOption('Por subgrupos', 'grouped-bar'),
      AdvisorOption('A través del tiempo', 'line'),
    ]),
    'temporal': AdvisorNode('¿Qué aspecto del tiempo importa?', [
      AdvisorOption('Tendencia continua', 'line'),
      AdvisorOption('Hitos y eventos', 'timeline'),
      AdvisorOption('Acumulado hacia una meta', 'cumulative-line'),
    ]),
    'composition': AdvisorNode('¿Qué necesitas comparar del total?', [
      AdvisorOption('Un total simple', 'pie'),
      AdvisorOption('Partes entre grupos', 'stacked-bar'),
      AdvisorOption('Proporciones entre grupos', 'normalized-stacked-bar'),
    ]),
    'distribution': AdvisorNode('¿Qué tamaño tiene la muestra?', [
      AdvisorOption('Pocas observaciones', 'strip-plot'),
      AdvisorOption('Muchas observaciones', 'histogram'),
      AdvisorOption('Comparar grupos y extremos', 'box-plot'),
    ]),
    'correlation': AdvisorNode('¿Cuántas variables numéricas tienes?', [
      AdvisorOption('Dos variables', 'scatter'),
      AdvisorOption('Tres variables', 'bubble'),
      AdvisorOption('Muchas variables', 'parallel-coordinates'),
    ]),
    'performance': AdvisorNode('¿Qué quieres evaluar?', [
      AdvisorOption('Valor frente a meta', 'bullet'),
      AdvisorOption('Pérdidas entre etapas', 'funnel'),
      AdvisorOption('Variación del proceso', 'control-chart'),
    ]),
    'financial': AdvisorNode('¿Qué información financiera tienes?', [
      AdvisorOption('Apertura, máximo, mínimo y cierre', 'candlestick'),
      AdvisorOption('Cambios que explican un total', 'waterfall'),
    ]),
    'spatial': AdvisorNode('¿Qué tipo de dato espacial tienes?', [
      AdvisorOption('Campo continuo medido en el espacio', 'contour'),
      AdvisorOption('Ubicaciones discretas', 'geographic-unavailable'),
    ]),
    'geographic-unavailable': AdvisorNode(
      'El catálogo aún no tiene un mapa geográfico. Si quieres comparar un valor por ubicación, usa barras.',
      [AdvisorOption('Comparar ubicaciones por valor', 'bar')],
    ),
  };

  static const recommendations = <String, AdvisorRecommendation>{
    'bar': AdvisorRecommendation(
      'bar',
      'Las barras comparten una base y permiten comparar magnitudes por categoría.',
      ['dot-plot', 'grouped-bar'],
    ),
    'grouped-bar': AdvisorRecommendation(
      'grouped-bar',
      'Las barras lado a lado comparan categorías y subgrupos.',
      ['stacked-bar', 'small-multiples-bar'],
    ),
    'line': AdvisorRecommendation(
      'line',
      'Una línea preserva el orden temporal y revela la tendencia.',
      ['area', 'multi-line'],
    ),
    'timeline': AdvisorRecommendation(
      'timeline',
      'Los hitos se leen mejor como eventos ordenados, sin inventar magnitudes.',
      ['gantt'],
    ),
    'cumulative-line': AdvisorRecommendation(
      'cumulative-line',
      'La suma acumulada deja ver el avance hacia una meta.',
      ['line'],
    ),
    'pie': AdvisorRecommendation(
      'pie',
      'Pocas partes de un único total se leen como proporciones.',
      ['donut', 'waffle'],
    ),
    'stacked-bar': AdvisorRecommendation(
      'stacked-bar',
      'Cada barra conserva el total y muestra sus componentes.',
      ['normalized-stacked-bar'],
    ),
    'normalized-stacked-bar': AdvisorRecommendation(
      'normalized-stacked-bar',
      'Normalizar separa la mezcla porcentual del tamaño del total.',
      ['stacked-bar'],
    ),
    'strip-plot': AdvisorRecommendation(
      'strip-plot',
      'Mostrar cada punto evita ocultar observaciones en muestras pequeñas.',
      ['dot-plot'],
    ),
    'histogram': AdvisorRecommendation(
      'histogram',
      'Los intervalos revelan frecuencia, concentración y colas.',
      ['density', 'box-plot'],
    ),
    'box-plot': AdvisorRecommendation(
      'box-plot',
      'Cuartiles y bigotes resumen dispersión y posibles valores atípicos.',
      ['violin', 'strip-plot'],
    ),
    'scatter': AdvisorRecommendation(
      'scatter',
      'Cada observación empareja dos variables numéricas.',
      ['bubble', 'connected-scatter'],
    ),
    'bubble': AdvisorRecommendation(
      'bubble',
      'El tamaño de cada punto agrega una tercera variable.',
      ['scatter'],
    ),
    'parallel-coordinates': AdvisorRecommendation(
      'parallel-coordinates',
      'Los ejes paralelos muestran perfiles de muchas variables por registro.',
      ['radar'],
    ),
    'scatterplot-matrix': AdvisorRecommendation(
      'scatterplot-matrix',
      'Cada panel muestra la relación entre un par distinto de métricas.',
      ['parallel-coordinates'],
    ),
    'contour': AdvisorRecommendation(
      'contour',
      'Las curvas de igual intensidad ayudan a localizar zonas de un campo espacial.',
      ['heatmap'],
    ),
    'bullet': AdvisorRecommendation(
      'bullet',
      'Valor, meta y bandas caben en una misma escala.',
      ['gauge'],
    ),
    'funnel': AdvisorRecommendation(
      'funnel',
      'Las etapas consecutivas muestran dónde se pierde volumen.',
      ['waterfall'],
    ),
    'control-chart': AdvisorRecommendation(
      'control-chart',
      'Los límites de proceso ayudan a distinguir variación común de señales especiales.',
      ['line'],
    ),
    'network-graph': AdvisorRecommendation(
      'network-graph',
      'Nodos y enlaces muestran relaciones explícitas entre entidades.',
      [],
    ),
    'radar': AdvisorRecommendation(
      'radar',
      'Los ejes radiales permiten explorar un perfil multidimensional comparable.',
      ['parallel-coordinates'],
    ),
    'candlestick': AdvisorRecommendation(
      'candlestick',
      'Cada vela contiene los cuatro precios de una sesión.',
      ['ohlc'],
    ),
    'waterfall': AdvisorRecommendation(
      'waterfall',
      'Los cambios positivos y negativos explican cómo se alcanza el total.',
      ['diverging-bar'],
    ),
    'gantt': AdvisorRecommendation(
      'gantt',
      'Los intervalos sobre fechas muestran duración y solapamiento de tareas.',
      ['timeline'],
    ),
  };

  String? interpret(String message) {
    final text = message.toLowerCase();
    if (text.contains('tres variable')) {
      return 'bubble';
    }
    if (text.contains('campo continuo') ||
        text.contains('superficie espacial')) {
      return 'contour';
    }
    if (text.contains('ubicaci') ||
        text.contains('geográf') ||
        text.contains('mapa')) {
      return 'spatial';
    }
    if (text.contains('relaci') || text.contains('correla')) {
      return 'correlation';
    }
    if (text.contains('venta') &&
        (text.contains('tiempo') || text.contains('mes'))) {
      return 'line';
    }
    if (text.contains('compar') ||
        text.contains('venta') ||
        text.contains('categor')) {
      return 'comparison';
    }
    if (text.contains('tiempo') || text.contains('evoluci')) {
      return 'temporal';
    }
    if (text.contains('proporci') || text.contains('total')) {
      return 'composition';
    }
    if (text.contains('distribu')) {
      return 'distribution';
    }
    if (text.contains('atíp') || text.contains('extremo')) {
      return 'box-plot';
    }
    if (text.contains('tarea') || text.contains('planif')) {
      return 'gantt';
    }
    if (text.contains('finanz') || text.contains('precio')) {
      return 'financial';
    }
    return null;
  }

  bool get referencesAreValid => recommendations.values.every(
    (r) =>
        ChartCatalog.concepts.any((c) => c.id == r.conceptId) &&
        r.alternatives.every(
          (id) => ChartCatalog.concepts.any((c) => c.id == id),
        ),
  );
}
