# Contrato de catálogo — 65 conceptos × 4 librerías

## Progreso de implementación

Batches 1-13 are complete. Batch 13 adds `funnel`, `pyramid` (population pyramid), `gauge`, `bullet`, and `timeline`. Current total: **260/260 demos (100%)**: 65 concepts, 40 basic + 25 advanced, implemented once per each of the four libraries.

The production catalog contains 40 basic and 25 advanced concepts with data profiles and support classification for each library. The implementation now has all **260 of 260** demos, with exactly 65 registrations per library and four registrations per concept.

Batch 5 conserva el significado analítico de cada visualización. `bar-line` comparte periodos y usa ventas en millones COP con un margen porcentual; FL Chart superpone dos gráficas alineadas con escalas explícitas, Syncfusion y Graphify declaran el segundo eje, y Graphic reescala el porcentaje sobre el eje común y lo identifica en la leyenda. `area-line` muestra consumo real como área y meta como línea, ambos en kWh. Las dos clases small multiples usan paneles titulados, mismo dominio/categorías y escalas globales; el layout pasa de una a dos columnas a 420 px. Graphify usa una instancia JSON serializable por panel para mantener la configuración pequeña y permite generar SVG con ECharts SSR de forma independiente. `sparkline` acompaña cada minigráfica sin ejes completos con nombre, valor y unidad; Syncfusion usa `SfSparkLineChart` nativo. Las opciones Graphify de Batch 5 serializan y se aceptan en el wrapper; se generaron **14 SVG (48 850 bytes)** con el ECharts 5.5.0 empaquetado para bar-line, area-line, cada panel small multiples y cada KPI sparkline. El WebView/iframe real sigue pendiente.

Batch 6 incorpora cinco semánticas radiales diferenciadas. `pie` compara cuatro canales como partes de 100 reservas; `donut` muestra ingresos por línea con `$100 M` como total central; `waffle` usa una cuadrícula fija 10×10 de celdas cuadradas, con 73 activas; `polar-area` asigna sectores de ángulo igual y radio proporcional a magnitudes absolutas que no necesitan sumar 100; `radar` compara Cartagena y Medellín sobre seis dimensiones compartidas de 0 a 10. Las celdas Waffle usan ScatterChart/ScatterSeries, HeatmapShape y ECharts scatter; Graphic y Graphify usan marcas/series polares para las semánticas radiales. Radar de Syncfusion se construye con LineSeries cartesianas sobre coordenadas calculadas antes del renderizado; FL Chart usa RadarChart y Graphify su serie radar. Se serializaron y construyeron las cinco opciones Graphify y se produjeron **5 SVG (45 846 bytes)** con el ECharts 5.5.0 incluido. Las demos FL Chart, Syncfusion y Graphic se montan a 320 y 500 px. La política de evidencia de WebView/iframe real no cambió: sigue pendiente.

## Batch 7 - Distribution Basics

The sample contains 46 individual tourist customer service times in minutes, kept in original order for the strip plot. Histogram, frequency polygon, and ogive share six Dart-computed bins. Bins are `[lower, upper)` except the final `[lower, upper]`; all observations, including the maximum, are counted. A constant sample becomes one centered bin of width one. The frequency polygon uses the same bins at `(midpoint, frequency)`. The ogive uses each upper bound and cumulative percentage and ends at 100%.

The strip plot retains all 46 X values and adds a deterministic repeating vertical jitter pattern bounded by +/-0.12; jitter is visual only. Density uses Gaussian KDE with an explicit bandwidth of 2.4 minutes and a 100-point grid from `min-3h` to `max+3h`; trapezoidal integration is approximately 1. The renderer labels density separately from frequency.

All four renderers consume the shared Dart transformations. Syncfusion histogram is classified custom (`C`) because the shared-bin contract uses precomputed `ColumnSeries` data rather than its internal `HistogramSeries`. Other support classifications remain unchanged. Graphify JSON serialization and widget construction passed; the five options also generated SVG in the bundled ECharts 5.5.0 SSR (8,045; 8,129; 7,461; 22,323; and 9,106 bytes). The actual WebView/iframe remains unverified.

## Batch 8 - Advanced Distribution & Density

Batch 8 adds 20 demos for `box-plot`, `violin`, `ridgeline`, `hexbin`, and `heatmap`, bringing the catalog to 160/260 (61.54%). Box plot statistics use linear quantiles at `(n - 1) * p` with interpolation, then 1.5-IQR fences; whiskers end at observed in-fence values and outliers are derived from the fence rule. FL Chart and Graphic consume those shared values; Syncfusion uses `BoxAndWhiskerSeries` in inclusive mode; Graphify uses ECharts `boxplot` plus the computed outlier scatter series.

Violin and ridgeline reuse Batch 7's Gaussian KDE. Violins share one X grid and bandwidth, with group-normalized, symmetric widths. Ridgelines share one X domain, bandwidth, and global density-height normalization, with deterministic vertical baselines. Hexbin uses 300 deterministic duration/spending observations, normalized pointy-top axial coordinates and cube rounding; all points are assigned once and counts are conserved. FL Chart uses its scatter marker painter, Syncfusion uses positioned chart annotations with clipped hex cells, Graphic uses `PolygonMark` with a six-sided shape, and Graphify uses a serializable hexagonal `path://` scatter symbol. Heatmap uses a complete 7×6 weekday/period matrix and a common low-to-high intensity scale; Graphic `HeatmapShape` and ECharts `heatmap` are native, while FL Chart and Syncfusion encode cells through chart scatter marks.

All five datasets and 20 registrations are covered. The FL Chart, Syncfusion, and Graphic widgets passed at 320 and 500 px. Graphify options serialize to JSON, the wrappers/options construct, and all five options generated SVG with the bundled ECharts 5.5.0 SSR (5,247; 13,989; 12,355; 26,124; and 34,047 bytes). No support-matrix code changed: `box-plot` remains `CNCN`, `violin`, `ridgeline`, and `hexbin` remain `CCCC`, and `heatmap` remains `CCNN`. This validates Graphify's JSON, SSR, and wrapper construction only; real WebView/iframe rendering remains unverified.

## Batch 9 - Relationships & Intervals

The deterministic datasets cover 32 tourist stays (nights vs total spend), eight destinations (visitors vs per-visitor spend, bubble area encodes registered establishments), 12 monthly occupancy/tariff observations (numeric X/Y connected in a separate period order), five services with ten observed wait times each, and seven daily temperature low/high ranges.

Bubble radii are computed once by mapping magnitude linearly to visible area and taking the square root for radius. A zero magnitude remains visible at the documented minimum radius. Connected-scatter points are sorted by unique order without modifying numeric coordinates. Error bars show each sample mean with an approximate normal 95% interval, `mean +/- 1.96 * sampleSD / sqrt(n)`; sample standard deviation uses denominator `n-1` and requires at least two finite values. Range columns encode only low/high; they do not invent a central estimate.

FL Chart renders scatter/bubble/connected points and uses chart primitives to compose error intervals and the low-to-high rods. Syncfusion uses native Scatter, Bubble, Line, custom ErrorBar, and RangeColumn series. Graphic uses Point/Line/Interval marks and shared Dart encodings. Graphify uses serializable ECharts scatter, line, and stacked-bar options; error bounds and bubble sizes are precomputed in Dart without callbacks. Error Bar support is `CNCC`: FL Chart uses a custom LineChart composition, Syncfusion's installed package provides `ErrorBarSeries`, Graphic composes marks, and Graphify composes serializable line/scatter series. Other Batch 9 support codes remain as declared in `ChartSupportMatrix`.

All 20 registrations are covered; the FL Chart, Syncfusion, and Graphic demos passed responsive widget mounts at 320 and 500 px. The five Graphify configurations serialize and construct their GraphifyView wrappers and generated SVG with bundled ECharts 5.5.0 SSR. These checks do not verify actual WebView/iframe execution.

## Batch 10 - Ranges, Financial & Planning

The hotel occupancy forecast uses eight ordered monthly low/high points and fills only the continuous interval between them. Range Column retains separate daily rods. Candlestick and OHLC share the same 12 fictional educational sessions with validated open/high/low/close. Candlestick renders an open–close body and low–high wick; OHLC renders the low–high line with an open tick on the left and a close tick on the right, without a body.

The hotel waterfall starts at 100 million COP and applies nonnegative magnitudes as increases or decreases in a shared Dart transform. Each contribution begins at the prior running total; the calculated final result is 85 million COP. The six task Gantt plan uses DateTime start/end values, real durations and overlaps in October 2026, with horizontal intervals and date labels. No dependency arrows are part of this batch.

FL Chart uses BetweenBarsData, its native CandlestickChart, line segments for OHLC, fromY/toY rods for Waterfall, and rotated range rods for Gantt. Syncfusion uses RangeAreaSeries, CandleSeries, HiloOpenCloseSeries, WaterfallSeries, and a transposed RangeColumnSeries inside the existing charts package. Graphic uses AreaMark, built-in CandlestickShape, LineMark, and IntervalMark. Graphify uses JSON-only ECharts line/area, candlestick, line segments, and stacked bars. Support codes remain `CNCC`, `NNNN`, `CNCC`, `CNCC`, and `CCCC` respectively; no Batch 10 classification changed.

All 20 registrations and shared dataset contracts passed. FL Chart, Syncfusion, and Graphic mounted at 320 and 500 px. The five Graphify options serialized to JSON, constructed GraphifyView configurations, and generated SVG with bundled ECharts 5.5.0 SSR (8,068; 8,764; 22,522; 10,378; and 8,332 bytes). Real WebView/iframe rendering remains unverified.

## Batch 11 - Advanced Comparison & Analytical Structures

Five Likert dimensions contain five ordinal response counts each. A shared transform normalizes each row to 100% and splits Neutral equally across zero. The left stack contains negative responses, the right stack positive responses. This differs from `diverging-bar`, which encodes one signed measure per category. FL Chart uses chart rod stacks, Syncfusion stacked bars, Graphic interval marks and Graphify signed ECharts stacks.

Scatterplot Matrix uses 24 destination observations and four numeric variables. Its full 4×4 matrix has 12 scatter panels and four diagonal summaries; each variable has one shared numeric range across all of its panels. The native Flutter renderers use 12 small library charts in a scrollable 16-cell layout. Graphify uses 16 ECharts grids, 12 scatter series and four diagonal titles in a scrollable 720 px view.

Ternary Plot uses 12 budget mixtures constrained to 100%: A = lodging at (0.5, √3/2), B = food at (0,0), C = transport at (1,0). A point is the barycentric combination x = 0.5·A + C, y = √3/2·A after normalizing percentages. All four renderers draw the triangle with their chart primitives and place the transformed points within it.

Fan Chart uses 12 future monthly hotel occupancy forecasts. Every period validates lower95 ≤ lower80 ≤ lower50 ≤ median ≤ upper50 ≤ upper80 ≤ upper95. The 95%, 80% and 50% bands overlay from outer to inner, with a separate median and legend. Range Area has only one low/high interval. Calibration Plot groups 100 deterministic binary cancellation predictions into five half-open probability bins, including 1.0 in the final bin. Every renderer places average predicted probability against observed frequency on 0–1 axes with the ideal y=x diagonal.

All 20 registrations, mathematical contracts and 30 responsive mounts at 320/500 px passed. Graphify options are JSON-only, construct GraphifyView, and generated SVG in bundled ECharts SSR (19,120; 173,977; 6,354; 18,923; and 7,806 bytes). The support codes remain `CCCC`, `SSSS`, `CCCC`, `CCCC`, and `CCCC` respectively. No Batch 11 classification changed. WebView/iframe execution remains unverified.

## Batch 12 - Networks, Diagnostics & Spatial Structures

Network Graph has seven tourist destinations/services and eight validated edges. Shared Dart geometry places nodes in stable input order around a circle, not by a force simulation. FL Chart, Syncfusion and Graphic draw actual node and edge marks; Graphify uses ECharts `graph` with `layout: none` and the same precomputed positions.

Q-Q uses 48 service times, plotting positions `(i-0.5)/n`, inverse normal quantiles and sample-standardized observations. The ideal line is `y=x` because both axes are in z units. Parallel Coordinates compares ten destinations over five heterogeneous dimensions; each dimension is min-max normalized, and a constant dimension maps to 0.5. Each destination draws one polyline across ordered vertical axes. ECharts uses native `parallel` axes and series.

Contour evaluates a deterministic sum of three smooth Gaussian peaks on a 25×20 abstract XY grid. Marching Squares extracts six levels using linear edge interpolation; the chart libraries draw the resulting isoline segments. The surface is an abstract tourism-demand field, not a geographic map. Calendar Heatmap has 181 unique dates from October 2025 through March 2026, mapped to Monday-first week and weekday coordinates with weekend and seasonal intensity. FL Chart and Syncfusion draw square marks, Graphic draws square PointMarks, and Graphify uses ECharts native `calendar` plus `heatmap`.

All 20 registrations and 30 responsive mounts at 320/500 px passed. Graphify options serialize to JSON, construct GraphifyView, and generated SVG with bundled ECharts 5.5.0 SSR (7,301; 26,843; 12,301; 89,753; and 55,249 bytes). Actual WebView/iframe execution remains unverified. Support codes are `CCCN`, `CCCC`, `CCCN`, `CCCC`, and `CCCN` in the order above. Calendar Heatmap changed from `SSSN` to `CCCN`: one chart per library now draws all daily cells from shared calendar coordinates, so the first three implementations are custom chart compositions rather than simulated multi-chart layouts.
## Batch 13 - Performance, Process & Functional Completion

`funnel` models five ordered reservation stages and derives conversion from the previous stage, conversion from the initial stage and drop-off. FL Chart and Graphic use library-native line/area marks to produce a centered narrowing shape, while Syncfusion and Graphify use their native funnel series. The final Graphify stage keeps a visible terminal width proportional to its real value.

`pyramid` is explicitly a **population pyramid**, not a triangular funnel/pyramid series: national tourists are rendered to the left and international tourists to the right from a zero baseline, while source values remain positive. All four implementations are custom bilateral bar encodings. `gauge` represents hotel occupancy on a fixed 0–100 scale with a target at 80%; Graphify uses native ECharts `gauge`, while the other libraries compose chart primitives without adding a gauges package. `bullet` uses one linear scale, qualitative bands, an actual value and a distinct target marker. `timeline` places six point events on real `DateTime` positions; it represents milestones rather than Gantt task durations.

Batch 13 support codes are `CNNN`, `CCCC`, `CCCN`, `CCCC`, and `CCCC` respectively. The final Cartesian test verifies **65 concepts × 4 libraries = 260 unique registrations**, 65 demos per library, four demos per concept, no missing keys, no duplicates and zero `unsupported` classifications. The 38 Batch 13 tests passed in the originating Flutter environment, including 30 responsive mounts at 320/500 px. Graphify options are JSON-only and the five Batch 13 configs generated valid SVG with the bundled ECharts 5.5.0 engine; real WebView/iframe execution remains unverified.

## Regla de aceptación

Una demo cuenta si la librería dibuja las marcas principales. Se admiten datos transformados, varias series o charts del mismo motor y guías auxiliares. Un `CustomPainter` externo completo, una imagen, WebView ajena a Graphify o JavaScript arbitrario no cuentan. `N` = tipo/función incorporada; `C` = marcas/series de la librería más transformación propia; `S` = composición de paneles de la misma librería, ya sean varios widgets o varias cuadrículas en un gráfico. `U` queda prohibido en el contrato final. Las clasificaciones completas están en `ChartSupportMatrix.codes`; los tests exigen una entrada por ID y cuatro soportes no `unsupported`.

## Decisión sobre los seis conceptos

| ID anterior | Decisión | ID final | Razón |
|---|---|---|---|
| `mosaic` | reemplazar | `diverging-stacked-bar` | FL Chart y Syncfusion no aportan rectángulos de anchura variable como gráfico principal; dos pilas por signo sí usan barras de la librería. |
| `treemap` | reemplazar | `scatterplot-matrix` | El layout de rectángulos jerárquicos dominaría el render en FL Chart/Syncfusion; cada panel nuevo usa dispersión real. |
| `sunburst` | reemplazar | `ternary-plot` | Los sectores jerárquicos requerirían un motor radial propio en FL Chart/Syncfusion; puntos y contorno triangular usan sus series. |
| `sankey` | reemplazar | `fan-chart` | Los enlaces de ancho variable requerirían un motor de flujos; las bandas de cuantiles usan áreas reales. |
| `chord` | reemplazar | `qq-plot` | El bundle ECharts 5.5.0 de Graphify carece de la serie necesaria; cuantiles y diagonal usan líneas/puntos JSON. |
| `marimekko` | reemplazar | `calibration-plot` | Anchuras variables no tienen ruta nativa defendible en FL Chart/Syncfusion; el gráfico nuevo usa dispersión y línea con datos calibrados. |

## Estrategias por librería

Todas las estrategias siguientes evitan un `CustomPainter` externo para las marcas principales. `Sí` significa ruta técnica defendible; las columnas de prototipo distinguen lo probado de lo pendiente de comprobación visual en dispositivo.

| Concepto | Librería | Primitivas concretas | Transformación y composición | Tipo | Prototipo | Realizable |
|---|---|---|---|:--:|---|:--:|
| `diverging-stacked-bar` | FL Chart | `BarChart`, `BarChartGroupData(groupVertically: true)`, dos `BarChartRodData`, `BarChartRodStackItem` | Sumar segmentos negativos y positivos por separado desde cero | C | Widget 280×240 | Sí |
| `diverging-stacked-bar` | Syncfusion | `SfCartesianChart`, `StackedColumnSeries` negativas y positivas | Normalizar respuestas Likert por categoría; conservar signo | C | Widget 280×240 | Sí |
| `diverging-stacked-bar` | Graphic | `Chart`, `IntervalMark` con `Varset(from)+Varset(to)` y `ColorEncode` | Calcular intervalos acumulados por cada lado de cero; no usar `StackModifier` entre signos | C | Widget 280×240 | Sí |
| `diverging-stacked-bar` | Graphify | ECharts `bar` con stacks `negative` y `positive` en `GraphifyView` | Separar valores firmados antes de enviar JSON | C | ECharts SVG 280×240 | Sí |
| `scatterplot-matrix` | FL Chart | Doce `ScatterChart` en cuadrícula 2×2 | Seleccionar pares distintos de ≥3 métricas, ejes compartidos por variable | S | Widget 280×240 | Sí |
| `scatterplot-matrix` | Syncfusion | Doce `SfCartesianChart` con `ScatterSeries` | Facetas por par; mantener rango comparable por métrica | S | Widget 280×240 | Sí |
| `scatterplot-matrix` | Graphic | Doce `Chart` con `PointMark` | Facetas; marcas de Graphic en cada panel | S | API documentada | Sí |
| `scatterplot-matrix` | Graphify | Un `GraphifyView` con 16 `grid`, 16 pares `xAxis`/`yAxis` y `scatter` con índices de eje | Una sola WebView; pares de métricas transformados a series JSON | S | ECharts SVG 280×240 | Sí |
| `ternary-plot` | FL Chart | `LineChart` con `LineChartBarData` del triángulo y otra serie de puntos (`barWidth: 0`, `FlDotData`) | Coordenadas baricéntricas `x=A/2+C`, `y=A√3/2`; exigir A+B+C=1 | C | Widget 280×240 | Sí |
| `ternary-plot` | Syncfusion | `SfCartesianChart`, `LineSeries` del contorno y `ScatterSeries` de muestras | Mismas coordenadas baricéntricas; ejes numéricos acotados | C | Widget 280×240 | Sí |
| `ternary-plot` | Graphic | `Chart` con `LineMark` del contorno y `PointMark` de muestras, posiciones independientes | Datos con columnas de borde y de observación; escalas numéricas idénticas | C | API documentada | Sí |
| `ternary-plot` | Graphify | ECharts `line` del triángulo y `scatter` de puntos en ejes `value` | Coordenadas calculadas en Dart; opciones solo JSON | C | ECharts SVG 280×240 | Sí |
| `fan-chart` | FL Chart | `LineChart`, siete curvas y tres `BetweenBarsData` | Ordenar q10≤q25≤q50≤q75≤q90 por horizonte y rellenar bandas anidadas | C | Widget 280×240 | Sí |
| `fan-chart` | Syncfusion | Tres `RangeAreaSeries` en `SfCartesianChart` | Banda 10–90 y 25–75, mediana con `LineSeries` en demo final | C | Widget 280×240 | Sí |
| `fan-chart` | Graphic | Dos `AreaMark` con posición `x*(low+high)` y la misma `LinearScale` Y | Bandas anidadas desde cuantiles; escala compartida verificada | C | Widget 280×240 | Sí |
| `fan-chart` | Graphify | ECharts `line` con `stack` y `areaStyle`; base invisible y amplitud de cada banda | Precalcular límites inferiores y diferencias; JSON sin `renderItem` | C | ECharts SVG 280×240 | Sí |
| `qq-plot` | FL Chart | `LineChart` con diagonal `y=x` y segunda serie de puntos sin trazo | Ordenar cuantiles teóricos y observados por probabilidad | C | Widget 280×240 | Sí |
| `qq-plot` | Syncfusion | `ScatterSeries` y `LineSeries` de referencia en `SfCartesianChart` | Cuantiles pareados y misma escala en ambos ejes | C | Series documentadas | Sí |
| `qq-plot` | Graphic | `PointMark` observado y `LineMark` de referencia, con escalas iguales | Variables separadas para cuantiles y referencia | C | Widget 280×240 | Sí |
| `qq-plot` | Graphify | ECharts `scatter` y `line` con ejes `value` en `GraphifyView` | Pares y diagonal expresados como arreglos JSON | C | ECharts SVG 280×240 | Sí |
| `calibration-plot` | FL Chart | `LineChart` diagonal y puntos sin trazo | Agrupar predicciones por bins y calcular tasa observada ponderada | C | Mismo patrón técnico probado por Q-Q | Sí |
| `calibration-plot` | Syncfusion | `ScatterSeries` y `LineSeries` diagonal en `SfCartesianChart` | Bins de probabilidad y tasa empírica | C | Series documentadas | Sí |
| `calibration-plot` | Graphic | `PointMark` y `LineMark` de referencia en `Chart` | Escalas X/Y 0–1 compartidas, peso por conteo opcional | C | Mismo patrón técnico probado por Q-Q | Sí |
| `calibration-plot` | Graphify | ECharts `scatter` y `line` JSON en `GraphifyView` | Tasas calculadas previamente; tooltips declarativos | C | ECharts SVG 280×240 | Sí |

## Diferencias conceptuales frente al catálogo restante

- `diverging-stacked-bar` muestra **composición ordinal por signo**; `diverging-bar` muestra un saldo por categoría.
- `scatterplot-matrix` presenta **todas las parejas** de varias métricas con paneles y escalas coordinadas; `scatter` presenta una pareja.
- `ternary-plot` exige **tres componentes con suma fija**; una dispersión XY no codifica esa restricción.
- `fan-chart` muestra **varios intervalos de cuantiles anidados** que se ensanchan según el horizonte; `range-area` muestra un único intervalo.
- `qq-plot` compara **cuantiles con una distribución de referencia**; sus desviaciones de la diagonal tienen interpretación estadística específica.
- `calibration-plot` usa **probabilidades agrupadas y frecuencias observadas**; la diagonal expresa calibración, no tendencia temporal.

## Rutas para conceptos conservados con geometría exigente

La matriz histórica enumera los otros 59 conceptos y su propósito. Para los casos en que una serie estándar no basta, estas son las rutas que mantienen las marcas principales dentro de cada motor. Los cálculos indicados se hacen en Dart antes de construir el gráfico; no se admite un `CustomPainter` externo que reemplace el gráfico.

| Conceptos | FL Chart | Syncfusion | Graphic | Graphify/ECharts |
|---|---|---|---|---|
| `violin`, `density`, `ridgeline` | Estimar KDE; `LineChart` con curvas de densidad, dos mitades espejadas para violín y paneles para crestas. | KDE en `SfCartesianChart` con `SplineAreaSeries`/`SplineSeries`; facetas para crestas. | KDE en `AreaMark`/`LineMark`; coordenadas reflejadas y facetas. | KDE precalculada en series `line` con `areaStyle`; `grid` por grupo para crestas. |
| `hexbin` | Agregar puntos en celdas axiales; `ScatterChart` con `ScatterSpot.dotPainter` hexagonal, dibujado por el motor de FL Chart. | Agregar celdas; `ScatterSeries` con `onCreateRenderer` y segmento/marker hexagonal dentro del renderizador de Syncfusion. | Celdas precalculadas como `PolygonMark` con color por conteo. | Celdas precalculadas en `scatter` con `symbol: path://` hexagonal y color por conteo; todo serializable. |
| `contour` | Marching squares sobre campo regular; cada isolínea como `LineChartBarData`. | Marching squares; una `LineSeries` por nivel o tramo en `SfCartesianChart`. | Marching squares; `LineMark` agrupada por nivel y segmento. | Marching squares; series `line` de coordenadas para cada isolínea. |
| `network-graph` | Layout de nodos precomputado; `ScatterChart` para nodos y `LineChart` para aristas, superpuestos con los mismos límites numéricos. | `ScatterSeries` para nodos y `LineSeries` para aristas en el mismo `SfCartesianChart`. | `PointMark` y `LineMark` con posiciones compartidas. | Serie `graph` incluida en ECharts. |
| `parallel-coordinates` | Normalizar cada dimensión a 0–1; una `LineChartBarData` por registro, ejes verticales como guías. | Una `LineSeries` por registro en `SfCartesianChart`; dimensiones categóricas horizontales y valores normalizados. | Una `LineMark` por registro y ejes auxiliares. | Serie `parallel` y componente `parallelAxis`. |
| `gantt` | Fechas convertidas a offsets; `BarChart` con barras flotantes por tarea (`BarChartRodStackItem` transparente de inicio y segmento de duración). | `RangeColumnSeries` con inicio/fin por tarea y `SfCartesianChart(isTransposed: true)`. | `IntervalMark` con `Varset(inicio)+Varset(fin)`. | Serie `bar` apilada con base transparente y duración visible. |
| `heatmap`, `calendar-heatmap` | Celdas representadas por `BarChart` en filas/paneles; cada barra coloreada por intensidad y con ancho constante; para calendario, semana/día reales. | `SfCartesianChart` con columnas por día en paneles semanales; color por dato, no por serie única. | `PolygonMark`/`HeatmapShape` con coordenadas de fila y columna. | Series `heatmap`; para calendario, `calendar` como sistema de coordenadas. |
| `box-plot`, `error-bar`, `range-area` | `CandlestickChart` con cuartiles/mediana y marcas auxiliares para caja; Error Bar se compone con `LineChart` verticales, caps y punto estimado; rango con `BetweenBarsData`. | `BoxAndWhiskerSeries`, `ErrorBarSeries`, `RangeAreaSeries`. | Cuartiles, límites y banda mediante `IntervalMark`/`AreaMark` más línea de mediana. | `boxplot` para caja; `scatter` con barras de error precomputadas como líneas; `line` apilada con `areaStyle` para banda. |
| `gauge`, `bullet` | `PieChart` de arcos y umbrales para gauge; `BarChart` con bandas de fondo y marca de meta para bullet. | `SfCircularChart` con anillos/umbrales para gauge; `SfCartesianChart` con barra, bandas y objetivo para bullet. | Marcas de intervalo con coordenadas polares para gauge y cartesianas para bullet. | Serie `gauge`; barra y `markLine`/bandas para bullet. |

Estas rutas son diseños de implementación, no prototipos adicionales. En particular, `hexbin` exige que el marcador hexagonal se dibuje **dentro** del renderizador de cada librería; un overlay de hexágonos independiente invalidaría el contrato.

## Evidencia y límites

Batch 1, Batch 2, Batch 3 y Batch 4 montan FL Chart, Syncfusion y Graphic a 320 y 500 px. Batch 4 utiliza `StackedArea100Series` para el área normalizada, `RangeAreaSeries` para bandas centradas de Syncfusion y un offset negativo explícito con `stackStrategy: all` en Graphify. Esta última ruta es una transformación de datos sobre series `line`, por lo que `streamgraph` en Graphify se clasifica como custom (`C`), no como nativo (`N`). Las opciones de Batch 4 se serializaron y construyeron como `GraphifyView`; las cinco opciones produjeron SVG mediante el ECharts 5.5.0 empaquetado, en SSR (entre 6,614 y 14,487 bytes). El test web sigue omitido en runner VM; SSR no valida visualmente el WebView/iframe real.

Los prototipos ejecutables están en `test/substitution_prototypes_test.dart`. La prueba de widgets valida montaje, clase de gráfica principal y ausencia de excepciones a 280×240 para FL Chart, Syncfusion y Graphic. Para Graphify valida que las seis opciones son JSON serializable, que declaran series ECharts y que `GraphifyView` puede construirse con ellas. Además, se ejecutó el ECharts **5.5.0 empaquetado por Graphify** en modo SVG SSR con las seis opciones extraídas del test: todas produjeron SVG a 280×240 sin excepción (entre **3446 y 17699 bytes**). Esto no equivale a verificar píxeles del iframe o el WebView; la validación real de Graphify en Chrome/dispositivo sigue pendiente. El test web está marcado como omitido en el runner VM. `flutter test --platform chrome` quedó detenido al cargar el test tanto dentro como fuera del sandbox y se canceló.

La tabla final de soportes se consulta en `lib/features/charts/data/chart_support_matrix.dart` y suma:

| Librería | N | C | S | U | Realizable |
|---|---:|---:|---:|---:|---:|
| FL Chart | 11 | 50 | 4 | 0 | 65/65 |
| Syncfusion | 22 | 40 | 3 | 0 | 65/65 |
| Graphic | 14 | 47 | 4 | 0 | 65/65 |
| Graphify | 20 | 41 | 4 | 0 | 65/65 |

## Fuentes

- [FL Chart 1.2.0](https://pub.dev/packages/fl_chart), [`BetweenBarsData`](https://pub.dev/documentation/fl_chart/latest/fl_chart/BetweenBarsData-class.html) y [`BarChartRodStackItem`](https://pub.dev/documentation/fl_chart/latest/fl_chart/BarChartRodStackItem-class.html).
- [Syncfusion Flutter Charts 35.1.37](https://pub.dev/packages/syncfusion_flutter_charts/versions/35.1.37) y [`RangeAreaSeries`](https://pub.dev/documentation/syncfusion_flutter_charts/latest/charts/RangeAreaSeries-class.html).
- [Graphic 2.7.0: marcas y escalas](https://pub.dev/documentation/graphic/latest/graphic/). Su `StackModifier` documenta que todos los valores del grupo deben tener el mismo signo; para Likert bilateral el prototipo utiliza intervalos precomputados.
- [Graphify 1.2.1](https://pub.dev/packages/graphify) envuelve ECharts por opciones JSON. [ECharts permite varias cuadrículas](https://echarts.apache.org/en/option.html) y [series de línea y dispersión](https://echarts.apache.org/en/cheat-sheet.html).
