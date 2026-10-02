import '../domain/chart_concept.dart';
import 'chart_data_profiles.dart';
import 'chart_support_matrix.dart';

class ChartCatalog {
  ChartCatalog._();

  static final List<ChartConcept> concepts = List.unmodifiable(
    parseRows(_rows),
  );

  /// Parses explicit level and metadata; row order has no semantic meaning.
  static List<ChartConcept> parseRows(String rows) =>
      rows.trim().split('\n').map((row) {
        final parts = row.trim().split('|');
        if (parts.length != 8) {
          throw FormatException('Expected 8 catalog fields: $row');
        }
        final id = parts[1];
        final category = ChartCategory.values.byName(parts[3]);
        final profile = ChartDataProfiles.byId[id];
        if (profile == null) throw StateError('Missing data profile for $id');
        return ChartConcept(
          id: id,
          name: parts[2],
          level: ChartLevel.values.byName(parts[0]),
          category: category,
          description: parts[4],
          useCase: parts[5],
          problemSolved: parts[6],
          dataProfile: profile,
          tags: [category.label.toLowerCase(), parts[7]],
          recommendedFor: parts[5],
          avoidWhen: _avoidWhen(category, id),
          support: ChartSupportMatrix.forConcept(id),
          compatibleCombinations: _combinations[id] ?? const [],
        );
      }).toList();

  static ChartConcept byId(String id) => concepts.firstWhere((c) => c.id == id);

  static String _avoidWhen(ChartCategory category, String id) => switch (id) {
    'grouped-bar' => 'Cuando hay demasiadas series o las categorías no son comparables en la misma escala.',
    'stacked-bar' => 'Cuando importa comparar con precisión los segmentos que no parten de cero.',
    'normalized-stacked-bar' => 'Cuando los totales absolutos importan o hay categorías cuyo total es cero.',
    'diverging-bar' => 'Cuando las observaciones no tienen una referencia significativa en cero.',
    'dot-plot' => 'Cuando las diferencias pequeñas entre puntos son menos importantes que la lectura de sus posiciones exactas.',
    'lollipop' => 'Cuando hay tantas categorías que las barras llenas siguen dominando visualmente pese a que interesa resaltar el extremo.',
    'dumbbell' => 'Cuando se comparan más de dos estados por categoría o no hay una pareja de medidas relacionada.',
    'slope' => 'Cuando se necesitan mostrar trayectorias intermedias o más de dos periodos.',
    'pareto' => 'Cuando el orden temporal importa más que priorizar las causas por frecuencia acumulada.',
    _ => switch (category) {
      ChartCategory.temporal => 'Cuando no existe un orden temporal fiable.',
      ChartCategory.composition =>
        'Cuando las partes no pertenecen al mismo total.',
      ChartCategory.correlation =>
        'Cuando las variables no están emparejadas por observación.',
      ChartCategory.distribution || ChartCategory.statistical =>
        'Cuando hay muy pocas observaciones para describir la distribución.',
      ChartCategory.hierarchy =>
        'Cuando los elementos no tienen una relación padre-hijo.',
      ChartCategory.network =>
        'Cuando no hay relaciones explícitas entre entidades.',
      ChartCategory.financial =>
        'Cuando no existen cotizaciones ordenadas en el tiempo.',
      ChartCategory.projectManagement =>
        'Cuando no hay fechas o duraciones de tareas.',
      _ => 'Cuando la escala o las unidades no son comparables.',
    },
  };

  static const _combinations = <String, List<String>>{
    'bar': ['bar-line'],
    'line': ['bar-line', 'area-line'],
    'scatter': ['scatter-trend'],
    'histogram': ['histogram-density'],
    'candlestick': ['candlestick-volume'],
    'stacked-bar': ['stacked-column-line'],
  };
}

const _rows = '''
basic|line|Línea|temporal|Une mediciones cronológicas para revelar una tendencia continua.|Seguir las ventas mensuales de una tienda durante un año.|Detectar crecimiento, caídas y cambios de ritmo.|tendencia
basic|multi-line|Líneas múltiples|temporal|Superpone series para comparar sus trayectorias en la misma escala.|Comparar visitas mensuales de tres canales de adquisición.|Identificar qué serie crece más rápido.|series
basic|area|Área|temporal|Rellena el espacio bajo una serie para enfatizar magnitud acumulada.|Mostrar el consumo eléctrico diario de una sede.|Percibir evolución y volumen simultáneamente.|magnitud
basic|stacked-area|Áreas apiladas|composition|Apila series temporales que forman un total cambiante.|Ver cómo cada canal contribuye al tráfico mensual.|Relacionar evolución del total y de sus componentes.|series
basic|step-line|Línea escalonada|temporal|Mantiene cada valor hasta que ocurre un cambio discreto.|Registrar el precio vigente entre cambios de tarifa.|Mostrar estados que no varían continuamente.|cambios
basic|slope|Gráfica de pendiente|comparison|Une los valores de cada categoría entre exactamente dos periodos para destacar cambios y cruces.|Comparar la participación de mercado de varias empresas entre 2025 y 2026.|Identificar quién gana o pierde participación entre un inicio y un final definidos.|antes-después
basic|bar|Barras|comparison|Compara magnitudes de categorías con una base común.|Comparar ventas de cinco categorías de productos.|Ordenar y contrastar categorías.|categorías
basic|grouped-bar|Barras agrupadas|comparison|Coloca una barra independiente por serie, lado a lado dentro de cada categoría.|Comparar ventas trimestrales por canal entre regiones.|Contrastar varias series comparables sin sumarlas.|subgrupos
basic|stacked-bar|Barras apiladas|composition|Apila segmentos para mostrar la composición y el total absoluto de cada categoría.|Mostrar tickets resueltos, escalados y pendientes por departamento.|Ver contribuciones y comparar los totales absolutos.|partes
basic|normalized-stacked-bar|Barras apiladas al 100 %|composition|Normaliza cada categoría para que sus segmentos sumen 100 % y compara proporciones, no magnitudes totales.|Comparar la distribución porcentual del presupuesto por área entre sedes.|Detectar diferencias de composición relativa cuando los totales difieren.|porcentajes
basic|diverging-bar|Barras divergentes|comparison|Extiende una medida positiva o negativa desde una referencia común en cero.|Mostrar la variación mensual de ventas frente a la meta.|Contrastar dirección y magnitud respecto a una referencia.|balance
basic|dot-plot|Gráfica de puntos|comparison|Sitúa un punto por categoría en una escala común: la posición codifica el valor y no hay barra que lo conecte a la base.|Comparar la puntuación media de satisfacción entre cinco servicios turísticos.|Leer y contrastar valores por su posición cuando importan las diferencias precisas.|ranking
basic|lollipop|Gráfica lollipop|comparison|Conecta el valor final con la base mediante un tallo fino y un marcador destacado en el extremo.|Comparar descargas del último mes entre aplicaciones.|Resaltar el valor terminal con menos peso visual que una barra completa.|ranking
basic|dumbbell|Gráfica dumbbell|comparison|Conecta dos mediciones relacionadas por categoría para mostrar dirección y tamaño del cambio.|Comparar satisfacción hotelera antes y después de una mejora en cuatro áreas.|Ver la brecha y el sentido del cambio entre dos estados emparejados.|brecha
basic|pie|Circular|composition|Divide las reservas de varios canales como partes de un único total.|Mostrar cómo se distribuyen cien reservas por canal.|Comparar pocas participaciones que componen un total.|proporción
basic|donut|Anillo con indicador central|composition|Compara líneas de ingreso y usa el centro para mostrar el ingreso total.|Mostrar la composición de ingresos hoteleros y el total en el centro.|Leer participaciones y KPI de total en una vista compacta.|total
basic|waffle|Waffle|composition|Representa la ocupación como unidades discretas contables en una cuadrícula 10×10.|Comunicar 73% de ocupación mediante 73 de 100 unidades activas.|Entender porcentajes como cantidades de unidades equivalentes.|porcentajes
basic|scatter|Dispersión|correlation|Cada observacion individual se ubica por dos medidas numericas y no se conecta a otra.|Relacionar noches de estadia y gasto total de visitantes.|Detectar asociacion, grupos y observaciones alejadas sin agregar valores.|relación
basic|bubble|Burbujas|correlation|Una dispersion incorpora el area de cada burbuja para codificar una tercera magnitud.|Comparar visitantes, gasto por turista y establecimientos registrados por destino.|Leer tres medidas emparejadas mediante posicion y tamano de burbuja.|tres-variables
basic|histogram|Histograma|distribution|Agrupa observaciones en bins numericos contiguos y cuenta frecuencias; no conserva cada valor individual.|Analizar tiempos de atencion de clientes en minutos.|Comparar la frecuencia observada por intervalo y reconocer concentracion y cola.|frecuencia
basic|frequency-polygon|Poligono de frecuencias|distribution|Conecta en orden los puntos medios y frecuencias de los mismos bins del histograma.|Explorar la forma de los tiempos de atencion agrupados en intervalos.|Describir la forma agregada; depende de los limites elegidos para los bins.|frecuencia
basic|ogive|Ojiva acumulada|distribution|Muestra en cada limite superior el porcentaje acumulado de observaciones hasta ese valor.|Saber que porcentaje de clientes fue atendido antes de un umbral de minutos.|Responder preguntas de umbral y percentil mediante acumulados no decrecientes.|acumulado
basic|strip-plot|Diagrama de tiras|distribution|Muestra cada observacion individual sobre el eje numerico con jitter vertical solo visual.|Inspeccionar tiempos individuales de atencion en una muestra pequena.|Conservar los valores individuales que el histograma agrega en bins.|observaciones
basic|radar|Radar|multidimensional|Compara perfiles de destinos mediante dimensiones homogéneas en una escala común.|Comparar Cartagena y Medellín de 0 a 10 en seis dimensiones turísticas.|Inspeccionar fortalezas relativas entre perfiles multidimensionales.|perfil
basic|polar-area|Área polar|comparison|Compara magnitudes absolutas por categoría mediante sectores de ángulo igual y radio variable.|Comparar solicitudes turísticas por alojamiento, gastronomía, transporte, ocio y cultura.|Relacionar magnitudes independientes en una disposición radial; no representa partes de un total.|radial
basic|range-column|Columnas de rango|statistical|La columna representa el intervalo low-high completo; no presupone una estimacion central.|Comparar temperatura minima y maxima diaria.|Leer amplitud y limites observados por categoria, a diferencia de un intervalo alrededor de una media.|intervalos
basic|error-bar|Barras de error|statistical|Muestra una estimacion central y su intervalo de incertidumbre; el estimado sigue siendo el valor principal.|Comparar tiempo medio de espera y un intervalo aproximado del 95% por servicio.|Separar el valor estimado de la precision asociada.|incertidumbre
basic|sparkline|Minigráfica de tendencia|performance|Condensa la tendencia reciente junto al valor actual de una métrica en una tarjeta o tabla.|Mostrar reservas, ingresos, ocupación y cancelaciones recientes en tarjetas KPI.|Dar contexto temporal sin ejes completos ni quitar espacio a la métrica.|indicador
basic|timeline|Línea de eventos|temporal|Ordena hitos cualitativos a lo largo del tiempo.|Narrar lanzamientos de versiones de una aplicación.|Mostrar secuencia y separación de acontecimientos.|hitos
basic|connected-scatter|Dispersión conectada|correlation|Conecta coordenadas numericas X/Y por un orden externo; el tiempo determina la secuencia, no un eje.|Seguir ocupacion y tarifa media de hotel por mes.|Reconocer giros en una trayectoria bivariada sin usar X temporal.|trayectoria
basic|bar-line|Barras y línea|performance|Combina una magnitud absoluta en barras y una métrica porcentual relacionada en una línea con eje secundario.|Comparar ventas mensuales en millones COP con el margen de utilidad porcentual.|Relacionar ventas y rentabilidad sin confundir sus unidades.|combinada
basic|area-line|Área y línea|temporal|Enfatiza la magnitud observada con un área y la compara con una referencia temporal mediante una línea.|Mostrar consumo energético diario real frente a una meta en kWh.|Identificar cuándo el consumo queda por debajo, cerca o por encima de la referencia.|combinada
basic|small-multiples-line|Líneas en paneles|temporal|Separa series temporales comparables en paneles titulados con una escala Y compartida.|Comparar la ocupación hotelera mensual de varias ciudades sin cruces de líneas.|Comparar patrones cuando superponer muchas trayectorias causa solapamiento.|paneles
basic|small-multiples-bar|Barras en paneles|comparison|Repite una comparación categórica en paneles separados con categorías y escala comunes.|Comparar ventas de hospedaje, gastronomía y transporte por sucursal.|Evitar saturar un único sistema de ejes con muchos subgrupos.|paneles
basic|diverging-stacked-bar|Barras apiladas divergentes|composition|Apila respuestas negativas y positivas a ambos lados de cero y conserva la mezcla por categoría.|Comparar respuestas Likert sobre la atención de cinco servicios.|Mostrar simultáneamente dirección y composición de las opiniones.|likert
basic|normalized-stacked-area|Áreas apiladas al 100 %|composition|Normaliza cada periodo a 100 % para comparar composición sin representar el volumen absoluto.|Seguir la cuota mensual de plataformas de streaming.|Examinar cambio de mezcla sin efecto del tamaño total.|porcentajes
basic|cumulative-line|Línea acumulada|temporal|Suma cada periodo a los anteriores para mostrar el total progresivo, no el valor puntual.|Seguir donaciones acumuladas durante una campaña.|Ver velocidad de progreso hacia una meta.|acumulado
basic|indexed-line|Líneas indexadas|temporal|Rebasa cada serie a 100 en su periodo inicial para comparar crecimiento relativo, no valores absolutos.|Comparar crecimiento de ventas de tiendas de tamaños distintos.|Separar crecimiento relativo de escala absoluta.|índice
basic|control-chart|Gráfica de control|performance|Muestra una serie con límites de proceso y línea central.|Monitorear tiempo de respuesta de un servicio.|Detectar variación fuera de control.|calidad
basic|pareto|Diagrama de Pareto|comparison|Ordena frecuencias de mayor a menor y superpone su porcentaje acumulado para priorizar las causas principales.|Priorizar las causas de incidencias reportadas en una plataforma durante el trimestre.|Encontrar qué pocas causas explican la mayor parte de las incidencias.|priorización
advanced|box-plot|Caja y bigotes|statistical|Resume mediana, cuartiles y extremos de una distribución.|Comparar tiempos de espera entre hospitales.|Contrastar dispersión y valores extremos.|cuartiles
advanced|violin|Violín|distribution|Combina distribución de densidad y resumen por grupo.|Comparar notas de varias asignaturas con formas diferentes.|Detectar multimodalidad y diferencias de dispersión.|densidad
advanced|heatmap|Mapa de calor|multidimensional|Codifica valores de una matriz mediante intensidad de color.|Analizar actividad por día de semana y hora.|Detectar patrones en dos dimensiones categóricas.|matriz
advanced|calendar-heatmap|Calendario de calor|temporal|Sitúa intensidad diaria en semanas y meses de calendario.|Ver días de mayor actividad de una plataforma.|Reconocer estacionalidad y hábitos diarios.|calendario
advanced|scatterplot-matrix|Matriz de dispersión|multidimensional|Cruza cada pareja de métricas en paneles para revelar relaciones multivariadas.|Comparar precio, autonomía y peso de modelos de teléfonos.|Descubrir asociaciones diferentes entre pares de variables.|pares
advanced|ternary-plot|Diagrama ternario|composition|Sitúa mezclas de tres componentes que suman un total fijo dentro de un triángulo.|Comparar proporciones de arena, limo y arcilla de muestras de suelo.|Analizar intercambios entre tres partes restringidas al 100 %.|ternario
advanced|fan-chart|Gráfica de abanico|statistical|Anida bandas de cuantiles para mostrar cómo crece la incertidumbre de un pronóstico.|Presentar escenarios de demanda eléctrica en los próximos meses.|Distinguir mediana y niveles de incertidumbre por horizonte.|cuantiles
advanced|network-graph|Grafo de red|network|Sitúa entidades como nodos unidos por vínculos.|Explorar colaboraciones entre investigadores.|Encontrar comunidades y nodos centrales.|nodos
advanced|qq-plot|Gráfica Q-Q|distribution|Compara cuantiles observados con cuantiles teóricos en una diagonal de referencia.|Evaluar si los tiempos de espera se aproximan a una distribución normal.|Detectar colas y asimetrías frente a una distribución esperada.|cuantiles
advanced|funnel|Embudo|performance|Ordena etapas de un proceso por volumen decreciente.|Medir usuarios desde visita hasta compra.|Localizar pérdidas en un proceso secuencial.|conversión
advanced|pyramid|Pirámide|composition|Compara niveles ordenados que forman una estructura escalonada.|Mostrar población por grupos etarios y sexo.|Contrastar distribución entre dos lados de niveles.|población
advanced|waterfall|Cascada|financial|Conecta incrementos y decrementos con un total inicial y final.|Explicar cambio de utilidad entre dos trimestres.|Atribuir variaciones a causas positivas y negativas.|variación
advanced|candlestick|Velas financieras|financial|Resume apertura, cierre, máximo y mínimo por periodo.|Examinar cotización diaria de una acción.|Leer dirección y amplitud de cada sesión.|ohlc
advanced|ohlc|Barras OHLC|financial|Marca apertura, máximo, mínimo y cierre con trazos compactos.|Comparar sesiones bursátiles densas en el tiempo.|Inspeccionar cuatro precios por periodo.|ohlc
advanced|gauge|Medidor|performance|Sitúa una medida actual frente a umbrales de una escala fija.|Mostrar cumplimiento de disponibilidad de un servicio.|Leer estado respecto a objetivo y límites.|objetivo
advanced|gantt|Gantt|projectManagement|Ubica tareas como intervalos sobre un calendario.|Planificar fases de desarrollo y dependencias del proyecto.|Detectar solapamientos y retrasos.|tareas
advanced|streamgraph|Gráfica de corrientes|composition|Desplaza áreas de magnitud absoluta alrededor de una línea base centrada; el espesor conserva el valor de cada serie.|Mostrar popularidad de géneros musicales en el tiempo.|Explorar cambios orgánicos de composición sin baseline cero.|series
advanced|parallel-coordinates|Coordenadas paralelas|multidimensional|Une valores de cada registro a través de varios ejes.|Comparar atributos de modelos de teléfonos.|Buscar perfiles y agrupaciones multivariadas.|perfil
advanced|hexbin|Hexágonos de densidad|correlation|Agrupa puntos de dispersión en celdas hexagonales.|Analizar miles de viajes por distancia y duración.|Reducir sobreposición en conjuntos masivos.|densidad
advanced|density|Curva de densidad|distribution|Estima una distribucion continua suavizada mediante KDE gaussiana; depende del bandwidth, no de bins.|Examinar la forma suavizada de los tiempos de atencion de clientes.|Ver modos y colas sin agrupar observaciones en intervalos fijos.|densidad
advanced|bullet|Gráfica bullet|performance|Compara valor, meta y bandas de rendimiento en poco espacio.|Evaluar ventas logradas frente a objetivo trimestral.|Mostrar avance y contexto de desempeño.|meta
advanced|range-area|Área de rango|statistical|Rellena el intervalo entre límites inferior y superior cambiantes.|Presentar banda de pronóstico de temperatura semanal.|Comunicar incertidumbre que varía con el tiempo.|intervalo
advanced|ridgeline|Gráfica de crestas|distribution|Apila curvas de densidad de múltiples grupos.|Comparar distribución de actividad por mes.|Detectar cambios de forma entre muchos grupos.|densidad
advanced|contour|Curvas de nivel|multidimensional|Une puntos de igual valor en una superficie bidimensional.|Mostrar concentración de contaminación sobre un área.|Reconocer gradientes y zonas de igual intensidad.|superficie
advanced|calibration-plot|Gráfica de calibración|performance|Compara probabilidades predichas con frecuencias observadas por intervalos.|Evaluar probabilidades de abandono estimadas por un modelo.|Detectar predicciones sistemáticamente optimistas o pesimistas.|calibración
''';
