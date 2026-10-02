# Auditoría final — Chart Advisor / Flutlytics

## Estado

**FUNCTIONAL IMPLEMENTATION COMPLETE — 260/260 demos.**

La auditoría histórica de viabilidad fue reemplazada por este estado final. El catálogo productivo contiene **65 conceptos** explícitos: **40 básicos + 25 avanzados**. Cada concepto tiene exactamente una ruta para cada una de las cuatro librerías: FL Chart, Syncfusion Flutter Charts, Graphic y Graphify.

La cobertura objetivo es por producto cartesiano:

`65 conceptos × 4 librerías = 260 demos`.

El test final de Batch 13 verifica exactamente ese producto cartesiano, sin claves duplicadas ni combinaciones faltantes. También exige cuatro demos por concepto, 65 demos por librería y cero soportes `unsupported`.

## Sustituciones cerradas

Las seis sustituciones definidas durante la auditoría de factibilidad **sí están aplicadas** en el catálogo final:

| ID retirado | ID final | Motivo de cierre |
|---|---|---|
| `mosaic` | `diverging-stacked-bar` | composición Likert bilateral realizable con barras reales en las cuatro librerías |
| `treemap` | `scatterplot-matrix` | matriz de dispersiones con escalas compartidas, sin motor jerárquico externo |
| `sunburst` | `ternary-plot` | transformación baricéntrica y primitivas cartesianas reales en las cuatro librerías |
| `sankey` | `fan-chart` | bandas probabilísticas anidadas sin motor de flujo externo |
| `chord` | `qq-plot` | cuantiles teóricos/observados y diagonal con series disponibles en ECharts 5.5 y Flutter |
| `marimekko` | `calibration-plot` | binning de probabilidades y diagonal de calibración sin anchos categóricos variables |

Los seis IDs retirados ya no forman parte del catálogo y los seis IDs finales sí forman parte de los 65 conceptos.

## Matriz final de soporte

`ChartSupportMatrix.codes` es la fuente canónica de clasificación. La matriz contiene 65 filas, cuatro códigos por fila y ninguna `U`/combinación `unsupported`.

| Librería | Native (N) | Custom (C) | Simulated (S) | Unsupported | Total realizable |
|---|---:|---:|---:|---:|---:|
| FL Chart | 11 | 50 | 4 | 0 | 65/65 |
| Syncfusion | 22 | 40 | 3 | 0 | 65/65 |
| Graphic | 14 | 47 | 4 | 0 | 65/65 |
| Graphify | 20 | 41 | 4 | 0 | 65/65 |

`N` significa que el tipo o primitive principal está incorporado/documentado por la librería; `C` usa primitives reales de esa librería con transformaciones o composición propia; `S` usa varios charts/paneles del mismo motor para conservar la semántica. Una pintura externa completa no cuenta como implementación de librería.

## Batch 13

El lote final implementa `funnel`, `pyramid`, `gauge`, `bullet` y `timeline` en las cuatro librerías.

- **Funnel (`CNNN`)**: cinco etapas ordenadas de conversión. El modelo deriva conversión desde etapa previa, conversión desde inicio y drop-off. FL Chart usa curvas superior/inferior y relleno entre ambas; Graphic usa área/líneas de su motor; Syncfusion usa `SfFunnelChart`; Graphify usa ECharts `funnel`.
- **Population Pyramid (`CCCC`)**: el ID se conserva como `pyramid`, pero el concepto visible es una pirámide poblacional bilateral. Los valores fuente permanecen positivos; solo la coordenada izquierda se vuelve negativa para dibujar nacionales a la izquierda e internacionales a la derecha sobre una escala simétrica. No usa `PyramidSeries` triangular.
- **Gauge (`CCCN`)**: ocupación hotelera en escala 0–100 con valor actual 78 y target 80. Graphify usa `gauge` nativo. FL Chart, Syncfusion Charts y Graphic lo componen con primitives ya instaladas; no se agregó `syncfusion_flutter_gauges`.
- **Bullet (`CCCC`)**: actual 82 M COP, meta 90 y tres bandas cualitativas sobre una sola escala lineal. La marca de target es geométricamente distinta de la barra actual.
- **Timeline (`CCCC`)**: seis hitos puntuales con `DateTime` real, orden temporal determinístico y labels alternados. Se diferencia de Gantt, que codifica intervalos start/end.

El test de Batch 13 contiene 38 pruebas: contratos de datos, soporte, producto cartesiano 65×4, opciones Graphify y 30 montajes responsive para FL Chart/Syncfusion/Graphic a 320 y 500 px. Según la evidencia del entorno de desarrollo de origen, las 38 pruebas pasaron y `flutter analyze` reportó 0 issues.

## Graphify

La política de evidencia se mantiene separada:

1. **JSON/ECharts**: opciones serializables y sin callbacks JavaScript ni `renderItem`.
2. **SSR**: configuraciones renderizadas con el ECharts 5.5.0 empaquetado por Graphify.
3. **Widget**: construcción de `GraphifyView`.
4. **WebView/iframe real**: **no validado** en navegador/dispositivo.

Para Batch 13 existen artefactos SSR de los cinco conceptos. En esta auditoría se volvió a ejecutar el motor ECharts incluido en el snapshot usando las opciones exportadas y todos produjeron SVG válido: funnel, pyramid, gauge, bullet y timeline. El script normal de exportación no es portable fuera del equipo de origen porque `.dart_tool/package_config.json` contiene rutas absolutas de Windows; esto es una limitación del snapshot de build, no de las opciones ECharts.

## Integridad de catálogo, datos y Advisor

- Catálogo: 65 IDs únicos, 40 básicos y 25 avanzados.
- `ChartDataProfiles`: el contrato de tests exige exactamente los mismos 65 IDs.
- `ChartDatasetRegistry`: los datasets registrados deben pertenecer al catálogo y tener escenario, unidad, filas e invariantes.
- Advisor: `referencesAreValid` comprueba que recomendaciones y alternativas apunten a conceptos existentes; `catalog_test.dart` cubre ese contrato.
- Render registry: la lista auditable se convierte después al mapa `(conceptId, library) → builder`; el test final exige unicidad antes del lookup.
- Navegación básica y detalle están cubiertos por `app_widget_test.dart` y tests de catálogo/renderizadores existentes.

## Validación disponible en este cierre

Evidencia del entorno Flutter de origen inmediatamente antes de agotarse la cuota de Codex:

- Batch 13 focused: **38/38 PASS**, incluidos 30 mounts responsive.
- `flutter analyze`: **0 issues**.
- Exportador Graphify Batch 13: PASS.
- ECharts SSR Batch 13: cinco SVG válidos.
- Batch 12 había cerrado con suite completa: **435 PASS, 1 skipped, 0 failures**.

En este entorno de revisión no hay Flutter/Dart SDK instalado, por lo que no se puede volver a ejecutar aquí `flutter test` ni `flutter analyze`. Sí se auditó el código fuente, el catálogo, la matriz y los artefactos SSR del ZIP. Por rigor, no se afirma una nueva corrida de la suite completa posterior a Batch 13 desde este entorno.

## Riesgos residuales

1. **Graphify WebView/iframe real** sigue pendiente. SSR y construcción del widget no sustituyen una ejecución real en Chrome/dispositivo.
2. **Regresión Flutter completa post-Batch-13**: el último full suite demostrado corresponde al cierre de Batch 12; Batch 13 tiene su suite enfocada verde. Antes de la entrega académica final conviene ejecutar una vez `flutter test` en un equipo con Flutter SDK para obtener la cifra final consolidada.
3. El ZIP incluye `.dart_tool` generado en Windows con rutas absolutas; no debe tratarse como artefacto portable. `flutter pub get` regenerará esa metadata en otro equipo.

## Veredicto

**260/260 FUNCTIONAL DEMOS IMPLEMENTED.**

**BATCH 13 COMPLETE — READY FOR FINAL DELIVERY VALIDATION.**

El alcance funcional académico está completo y la matriz 65×4 está cerrada. La única validación operativa que no se declara realizada es el WebView/iframe real de Graphify y, por limitación de este entorno, una nueva ejecución consolidada de `flutter test` posterior a Batch 13.
