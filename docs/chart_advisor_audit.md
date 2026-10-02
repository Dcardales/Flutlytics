# Auditoría de Chart Advisor — 30 de septiembre de 2026

> Registro histórico del catálogo anterior. El contrato vigente y las sustituciones aplicadas están en [chart_advisor_contract.md](chart_advisor_contract.md).

Actualización Batch 12: `calendar-heatmap` pasa de `SSSN` a `CCCN` en la matriz vigente. FL Chart y Syncfusion usan marcas cuadradas de dispersión y Graphic usa `SquareShape` sobre semanas/días calculados en Dart. Cada una es una sola gráfica de su biblioteca con transformación de calendario; Graphify conserva `N` mediante `calendar` + `heatmap` de ECharts 5.5.0. La tabla histórica de abajo conserva su clasificación original.

## Alcance y criterio

Esta matriz es una **evaluación de viabilidad técnica**, no 260 demos ejecutadas. `N` = tipo u opción documentada de la librería; `C` = transformación, marcas/series y geometría propias dentro del motor de esa librería; `S` = composición de sus gráficas con widgets auxiliares que conserva el objetivo visual; `U` = no hay ruta razonable dentro de la integración actual sin sustituir el motor principal. Una demo cuenta solo si la librería elegida dibuja las marcas principales. Un `CustomPainter` autónomo etiquetado cuatro veces no cuenta como cuatro implementaciones.

La columna `Revisión` marca conceptos próximos que deben diferenciarse mediante datos y objetivo; no implica eliminarlos automáticamente. Categorías: `cmp` comparación, `tmp` temporal, `com` composición, `dis` distribución, `cor` correlación, `jer` jerarquía, `fin` finanzas, `mul` multidimensional, `red` relaciones, `pro` planificación, `est` estadística, `ren` rendimiento. Las primeras 40 filas son básicas; las 25 restantes, avanzadas.

| # | ID | Nombre | Cat. | Propósito distintivo | FL | SF | Graphic | Graphify | Revisión |
|---:|---|---|---|---|:--:|:--:|:--:|:--:|---|
| 1 | line | Línea | tmp | Tendencia cronológica continua | N | N | N | N | base de 2, 28, 37, 38 |
| 2 | multi-line | Líneas múltiples | tmp | Comparar trayectorias simultáneas | N | N | N | N | mismo trazo que 1, objetivo multiserie |
| 3 | area | Área | tmp | Magnitud de una serie a lo largo del tiempo | N | N | N | N | relleno de 1; defender lectura de volumen |
| 4 | stacked-area | Áreas apiladas | com | Evolución de un total y sus partes | C | N | N | N | distinta de 36 por escala absoluta |
| 5 | step-line | Línea escalonada | tmp | Valores constantes entre cambios | N | N | N | N | interpolación distinta de 1 |
| 6 | slope | Gráfica de pendiente | cmp | Cambio entre exactamente dos momentos | C | C | C | C | distinguir de 14 por eje temporal |
| 7 | bar | Barras | cmp | Magnitudes por categoría | N | N | N | N | ya implementada |
| 8 | grouped-bar | Barras agrupadas | cmp | Subgrupos lado a lado | N | N | N | N | comparar frente a 34 |
| 9 | stacked-bar | Barras apiladas | com | Partes y total por categoría | N | N | N | N | distinguir de 10 |
| 10 | normalized-stacked-bar | Barras apiladas al 100 % | com | Proporciones sin tamaño total | C | N | C | C | transformación de 9 |
| 11 | diverging-bar | Barras divergentes | cmp | Valores a ambos lados de cero | C | C | C | C | distinto de 9 si se preserva signo |
| 12 | dot-plot | Gráfica de puntos | cmp | Valor único por categoría en escala común | C | C | C | C | no confundir con 23 |
| 13 | lollipop | Gráfica lollipop | cmp | Ranking con marca y tallo desde base | C | C | C | C | principalmente decoración de 7/12: **revisar** |
| 14 | dumbbell | Gráfica dumbbell | cmp | Brecha entre dos valores por categoría | C | C | C | C | distinto de 6 si hay pares categóricos |
| 15 | pie | Circular | com | Participaciones de un único total | N | N | N | N | distinguir de 16 |
| 16 | donut | Anillo con indicador central | com | Partes y total contextual en el centro | C | C | C | C | 15 + hueco y etiqueta: **revisar** |
| 17 | waffle | Waffle | com | Proporción en unidades discretas | C | C | C | C | cuadrícula de marcas, no imagen estática |
| 18 | scatter | Dispersión | cor | Relación entre dos variables numéricas | N | N | N | N | base de 19 y 30 |
| 19 | bubble | Burbujas | cor | Tercera variable codificada por área | C | N | N | C | tamaño debe representar área, no radio |
| 20 | histogram | Histograma | dis | Frecuencia de intervalos continuos | C | N | C | C | bins calculados y etiquetados |
| 21 | frequency-polygon | Polígono de frecuencias | dis | Forma de frecuencias por intervalos | C | C | C | C | distinto de 20 al comparar cohortes |
| 22 | ogive | Ojiva acumulada | dis | Porcentaje acumulado hasta umbral | C | C | C | C | distinto de 37: distribución acumulada |
| 23 | strip-plot | Diagrama de tiras | dis | Cada observación de muestra pequeña | C | C | C | C | preservar observaciones, no promedios |
| 24 | radar | Radar | mul | Perfil de varios ejes radiales | N | C | C | N | ejes con unidades comparables |
| 25 | polar-area | Área polar | cmp | Magnitud por dirección cíclica | C | C | C | N | radio/área: codificación explícita |
| 26 | range-column | Columnas de rango | est | Mínimo y máximo por categoría | C | N | C | C | intervalo observado, no error estadístico |
| 27 | error-bar | Barras de error | est | Estimación más incertidumbre | C | N | C | C | FL Chart compone intervalo, caps y estimado con líneas/puntos; Syncfusion dispone de ErrorBarSeries nativa |
| 28 | sparkline | Minigráfica de tendencia | ren | Tendencia dentro de tarjeta KPI | S | N | S | S | 1 sin ejes: **revisar** |
| 29 | timeline | Línea de eventos | tmp | Hitos fechados sin magnitud ficticia | S | S | S | S | marcas de evento y etiquetas |
| 30 | connected-scatter | Dispersión conectada | cor | Trayectoria bivariada ordenada | C | C | C | C | orden temporal visible |
| 31 | bar-line | Barras y línea | ren | Volumen y tasa en dos ejes | C | C | C | C | escala y unidades claras |
| 32 | area-line | Área y línea | tmp | Consumo frente a meta | C | C | C | C | 3 + referencia: **revisar** |
| 33 | small-multiples-line | Líneas en paneles | tmp | Comparar patrones con escala compartida | S | S | S | S | 2 en paneles: **revisar** |
| 34 | small-multiples-bar | Barras en paneles | cmp | Categorías por subgrupo con escala común | S | S | S | S | 8 en paneles: **revisar** |
| 35 | mosaic | Mosaico | com | Tabla de contingencia por área | U | U | C | C | polígonos de ancho variable |
| 36 | normalized-stacked-area | Áreas apiladas al 100 % | com | Cambio temporal de participaciones | C | N | C | C | transformación de 4 |
| 37 | cumulative-line | Línea acumulada | tmp | Progreso por suma sucesiva | C | C | C | C | transformación de 1: **revisar** |
| 38 | indexed-line | Líneas indexadas | tmp | Crecimiento relativo desde base 100 | C | C | C | C | transformación de 2: **revisar** |
| 39 | control-chart | Gráfica de control | ren | Señales frente a límites estadísticos | C | C | C | C | límites calculados, no adorno |
| 40 | pareto | Diagrama de Pareto | cmp | Priorizar causas con frecuencia y acumulado | C | C | C | C | orden + porcentaje acumulado |
| 41 | box-plot | Caja y bigotes | est | Cuartiles, mediana y extremos | C | N | C | N | no reemplazar por barras de rango |
| 42 | violin | Violín | dis | Densidad espejada por grupo | C | C | C | C | KDE y escala de densidad explícitos |
| 43 | heatmap | Mapa de calor | mul | Intensidad en matriz de categorías | C | C | N | N | no confundir con 44 |
| 44 | calendar-heatmap | Calendario de calor | tmp | Actividad diaria en semanas/meses | S | S | S | N | calendario real, no matriz arbitraria |
| 45 | treemap | Mapa de árbol | jer | Peso dentro de jerarquía anidada | U | U | C | N | layout squarify + polígonos en Graphic |
| 46 | sunburst | Sunburst | jer | Jerarquía ponderada por anillos | U | U | C | N | anillos y sectores con marca polar personalizada |
| 47 | sankey | Sankey | red | Flujos ponderados entre etapas | U | U | U | N | enlaces de ancho proporcional y conservación |
| 48 | network-graph | Grafo de red | red | Nodos y aristas explícitas | C | C | C | N | layout fijo reproducible + interacción |
| 49 | chord | Diagrama de cuerdas | red | Flujos entre sectores circulares | U | U | U | U | ECharts 5 empaquetado no expone serie chord |
| 50 | funnel | Embudo | ren | Pérdidas entre etapas secuenciales | C | N | N | N | etapas ordenadas, volumen decreciente |
| 51 | pyramid | Pirámide | com | Población por edad y sexo, a dos lados | C | C | C | C | nombre coincide con componente de SF/Graphic, **semántica no** |
| 52 | waterfall | Cascada | fin | Atribuir variaciones a un total | C | N | C | C | bases flotantes + conectores |
| 53 | candlestick | Velas financieras | fin | OHLC por período, con cuerpo | N | N | N | N | no confundir con 54 |
| 54 | ohlc | Barras OHLC | fin | OHLC con trazos compactos | C | N | C | C | mismos datos que 53, codificación distinta |
| 55 | gauge | Medidor | ren | Estado respecto a umbrales | C | C | C | N | umbrales, meta y escala fijos |
| 56 | gantt | Gantt | pro | Duración y solapamiento de tareas | C | C | C | C | fechas y dependencias visibles |
| 57 | streamgraph | Gráfica de corrientes | com | Series apiladas con base centrada | C | C | C | N | 4 con otra base: **revisar** |
| 58 | parallel-coordinates | Coordenadas paralelas | mul | Perfil multivariable por registro | C | C | C | N | ejes y registros legibles |
| 59 | hexbin | Hexágonos de densidad | cor | Conteos en teselación hexagonal | C | C | C | C | hexágonos reales, no círculos |
| 60 | density | Curva de densidad | dis | Densidad estimada de variable continua | C | C | C | C | KDE normalizada |
| 61 | bullet | Gráfica bullet | ren | Valor, meta y bandas cualitativas | C | C | C | C | distinguir de 55 por escala lineal |
| 62 | range-area | Área de rango | est | Banda cambiante inferior/superior | C | N | C | C | intervalo en cada instante |
| 63 | ridgeline | Gráfica de crestas | dis | Densidades de muchos grupos en paralelo | C | C | C | C | 60 en paneles: **revisar** |
| 64 | contour | Curvas de nivel | mul | Isolíneas de campo bidimensional | C | C | C | C | marching squares previo, líneas reales |
| 65 | marimekko | Marimekko | com | Anchura y altura proporcionales | U | U | C | C | polígonos de ancho variable; próximo a 35 |

| Librería | N | C | S | U | Realizable del catálogo actual |
|---|---:|---:|---:|---:|---:|
| FL Chart | 12 | 42 | 5 | 6 | 59/65 |
| Syncfusion | 23 | 32 | 4 | 6 | 59/65 |
| Graphic | 14 | 44 | 5 | 2 | 63/65 |
| Graphify | 24 | 36 | 4 | 1 | 64/65 |

**Rutas de implementación.** Para las filas `C` cartesianas, usar series y marcas de línea, barra, dispersión o área, con transformaciones compartidas (bins, KDE, porcentajes, acumulados, límites, coordenadas y escalas). FL Chart ofrece `betweenBarsData`, rod stacks/rangos, spots y títulos; Syncfusion ofrece series combinables y anotaciones; Graphic permite marcas, transformaciones y shapes. En Graphic, `PolygonMark` admite mosaicos y rectángulos de treemap precomputados; el sunburst requiere una marca polar personalizada. Una red pequeña puede usar puntos y segmentos con posiciones precomputadas y hit testing. `S` usa varios widgets de la misma librería con ejes/escala sincronizados. En Graphify, `C` debe ser **JSON serializable**: series ECharts, `graphic` y datos precomputados; su puente no acepta funciones Dart como `renderItem` de ECharts. Las filas `U` se excluyen cuando el resultado dependería casi entero de un motor de layout/pintura externo. Son rutas diseñadas, pendientes de prototipo visual en su lote.

## Diferencias entre código actual y matriz

`ChartCatalog._supportFor` solo contiene `native` y `unsupported`; esos valores describen evidencia previa, no esta auditoría. El catálogo reporta varias `native` que requieren matiz: `donut` necesita indicador central; `pyramid` del catálogo es una pirámide de población bilateral, distinta de `SfPyramidChart`/`FunnelShape`. FL Chart documenta escalones y barras de error; Syncfusion ofrece `ErrorBarSeries`; Graphic documenta `HeatmapShape`, `FunnelShape`, `CandlestickShape` y escalones: faltan en el mapa nativo actual. La matriz no se aplica automáticamente a `support` hasta aprobar sustituciones y validar prototipos. `supportedLibraries` y el filtro por librería hoy interpretan `unsupported` como exclusión, de modo que el usuario ve una disponibilidad académica incompleta.

## Sustituciones para llegar a 65 en las cuatro librerías

| Actual | Nuevo propuesto | Nivel | Caso de uso y diferencia conceptual | Ruta común |
|---|---|---|---|---|
| `mosaic` | `diverging-stacked-bar` | básica | Respuestas Likert: composición positiva, neutra y negativa alrededor de cero; no es `diverging-bar`, que codifica un único saldo | barras apiladas a ambos lados de cero |
| `treemap` | `scatterplot-matrix` | avanzada | Relaciones bivariadas entre todas las parejas de variables; no es `parallel-coordinates`, que muestra perfiles por registro | paneles de dispersión con escalas por variable |
| `sunburst` | `ternary-plot` | avanzada | Mezclas de tres ingredientes que suman 100 %; coordenadas baricéntricas sobre triángulo | dispersión transformada + ejes triangulares |
| `sankey` | `fan-chart` | avanzada | Cuantiles de pronóstico a varios horizontes, con bandas anidadas; más que un único `range-area` | bandas de área entre curvas de cuantiles |
| `chord` | `qq-plot` | avanzada | Contrastar cuantiles observados con una distribución teórica; diagnóstico distinto de `scatter` genérico | dispersión de pares de cuantiles + diagonal |
| `marimekko` | `calibration-plot` | avanzada | Comparar probabilidad predicha con frecuencia observada por deciles; distinto de `control-chart` | puntos/línea de fiabilidad + diagonal + conteos |

Cada sustituto usa marcas centrales de las cuatro librerías y un dataset específico. **No están aplicadas**. El cambio conserva 40 básicas y 25 avanzadas y elimina los seis bloqueos compartidos por FL Chart y Syncfusion; el objetivo de 65/65 por librería queda condicionado a prototipos y pruebas visuales, no demostrado por la matriz sola.

## Lotes de cinco conceptos

Los lotes cubren cada ID actual una vez. Las filas sustituidas usarían el nuevo ID en el mismo lote tras la decisión de catálogo.

1. Comparación por barras: `bar` (hecha), `grouped-bar`, `stacked-bar`, `normalized-stacked-bar`, `diverging-bar`.
2. Comparación por marcas: `dot-plot`, `lollipop`, `dumbbell`, `slope`, `pareto`.
3. Tiempo base: `line` (hecha), `multi-line`, `area`, `stacked-area`, `step-line`.
4. Tiempo transformado: `cumulative-line`, `indexed-line`, `normalized-stacked-area`, `streamgraph`, `control-chart`.
5. Tiempo compuesto: `bar-line`, `area-line`, `small-multiples-line`, `small-multiples-bar`, `sparkline`.
6. Composición radial/unidades: `pie`, `donut`, `waffle`, `polar-area`, `radar`.
7. Distribución base: `histogram`, `frequency-polygon`, `ogive`, `strip-plot`, `density`.
8. Distribución avanzada: `box-plot`, `violin`, `ridgeline`, `hexbin`, `heatmap`.
9. Relación e intervalos: `scatter`, `bubble`, `connected-scatter`, `error-bar`, `range-column`.
10. Intervalos y finanzas: `range-area`, `candlestick`, `ohlc`, `waterfall`, `gantt`.
11. Composición estructural: `mosaic`, `marimekko`, `treemap`, `sunburst`, `sankey`.
12. Redes y espacio: `network-graph`, `chord`, `parallel-coordinates`, `contour`, `calendar-heatmap`.
13. Rendimiento y procesos: `funnel`, `pyramid`, `gauge`, `bullet`, `timeline`.

## Datos, registro y gates para cada lote

Los datasets actuales tienen etiquetas y unidad en el detalle, pero solo seis meses de ventas y cuatro categorías. El siguiente contrato debe asociar cada concepto con **escenario, unidades, fuente o indicación sintética, campos tipados, datos y validación de invariantes** (por ejemplo, sumas de partes, fechas ordenadas, OHLC válido, intervalos inferiores/superiores). Compartir un dataset solo cuando la comparación de codificaciones sea la enseñanza buscada. El detalle debe leer el dataset del registro de concepto, no de un `switch` que crecería a 65 casos.

El mapa `(conceptId, library) → builder` es adecuado; los registros ahora se conservan en una lista auditable antes de construir el mapa. Para crecer, ubicar builders en `presentation/demos/fl_chart/`, `syncfusion/`, `graphic/`, `graphify/`, con primitivas/transformaciones compartidas fuera de esos directorios y un registro de cinco conceptos por lote. `chart_renderer.dart` debe limitarse a agregación, lookup y fallback. Verificar por lote las 20 claves, dataset, interacción, tamaños estrechos y captura visual en dispositivo para Graphify. El chatbot conserva un árbol de nodos y recomendaciones en mapas; validar IDs y disponibilidad final tras cada sustitución, y partir sus reglas por intención si aumentan mucho.

## Fuentes técnicas

- [FL Chart 1.2.0: tipos publicados](https://pub.dev/packages/fl_chart) y [API de FL Chart](https://pub.dev/documentation/fl_chart/latest/fl_chart/).
- [Syncfusion Flutter Charts 35.1.37: más de 30 tipos y sparklines](https://pub.dev/packages/syncfusion_flutter_charts/versions/35.1.37).
- [Syncfusion: `ErrorBarSeries`](https://pub.dev/documentation/syncfusion_flutter_charts/latest/charts/ErrorBarSeries-class.html).
- [Graphic 2.7.0: marcas, coordenadas y shapes extensibles](https://pub.dev/documentation/graphic/latest/graphic/) y [ejemplos oficiales](https://pub.dev/packages/graphic/example).
- [Graphic: `PolygonMark` para teselar superficies](https://pub.dev/documentation/graphic/latest/graphic/PolygonMark-class.html), [FL Chart: escalones](https://pub.dev/documentation/fl_chart/latest/fl_chart/LineChartStepData-class.html) y [barras de error](https://pub.dev/documentation/fl_chart/latest/fl_chart/FlErrorIndicatorData-class.html).
- [Graphic: `CandlestickShape`](https://pub.dev/documentation/graphic/latest/graphic/CandlestickShape-class.html) y [ejemplo oficial de selección y tooltip](https://github.com/entronad/graphic/blob/main/example/lib/pages/interaction_stream_dynamic.dart).
- [Graphify 1.2.1: opciones ECharts en JSON](https://pub.dev/packages/graphify) y [ECharts: series y componentes](https://echarts.apache.org/en/cheat-sheet.html).
- El paquete Graphify descargado en `Pub/Cache` incluye ECharts **5.5.0** y serializa `initialOptions` con `jsonEncode`; por eso [custom series con `renderItem` JavaScript](https://echarts.apache.org/handbook/en/how-to/custom-series/) no es ruta disponible mediante su API actual. [ECharts 6 documenta `chord`](https://echarts.apache.org/en/option.html), lo que no demuestra esa serie en el bundle de Graphify.
