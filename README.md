# Chart Advisor

Aplicacion academica Flutter para elegir visualizaciones segun un problema real y comparar cuatro librerias. El catalogo contiene 65 conceptos (40 basicos y 25 avanzados). Batches 1-12 estan completos: 240/260 demos (92.31 %).

## Ejecutar

```sh
flutter pub get
flutter run
```

## Estructura

- `lib/core`: tema Material 3 y raíz de la app.
- `lib/features/advisor`: árbol de decisión local y conversación guiada.
- `lib/features/charts/domain`: modelo, enums y filtros puros.
- `lib/features/charts/data`: catálogo, datasets y combinaciones justificadas.
- `lib/features/charts/presentation`: catálogo, detalle y registro de renderizadores.
- `lib/features/comparison`: comparador cualitativo.
- `lib/features/home`: entrada principal.

El registro en `chart_renderer.dart` usa `(conceptId, ChartLibrary)` como clave. Cada demo tiene un builder y un dataset local. El catálogo declara soporte para las cuatro librerías en cada concepto. `unsupported` se muestra como **sin soporte verificado**: significa que aún no hay evidencia revisada ni demo en el proyecto, no que sea técnicamente imposible. `native` se reserva a tipos publicados por el paquete o su ejemplo oficial. El selector muestra además si la demo ya existe.

El asistente interpreta frases comunes y después ofrece preguntas cerradas. Las recomendaciones y alternativas son IDs de conceptos existentes. No utiliza IA, backend ni APIs externas. Graphify integra ECharts con recursos JavaScript empaquetados por el paquete y renderiza mediante WebView.

## Fuentes de compatibilidad

- [FL Chart, tipos publicados](https://pub.dev/packages/fl_chart)
- [Syncfusion Flutter Charts, tipos publicados](https://pub.dev/packages/syncfusion_flutter_charts)
- [Graphic, ejemplos oficiales](https://pub.dev/packages/graphic/example)
- [Graphify, ejemplos oficiales](https://pub.dev/packages/graphify/example)

Syncfusion requiere una licencia comercial o comunitaria conforme a sus condiciones. La comparación describe el estilo de API y funciones documentadas; no presenta benchmarks. Las demos Graphify requieren WebView. Los tests montan FL Chart, Syncfusion y Graphic a 320 y 500 px, validan las opciones JSON y construyen el widget Graphify. Las opciones de Batches 4-12 se renderizaron con ECharts SSR. La visualización real del WebView en navegador o dispositivo sigue pendiente.

## Pruebas

```sh
dart format .
flutter analyze
flutter test
```

The academic requirement is 65 demos per library: 40 basic and 25 advanced, 260 total. Batch 12 adds network-graph, qq-plot, parallel-coordinates, contour, and calendar-heatmap. The catalog now contains 240 demos; 20 remain.
