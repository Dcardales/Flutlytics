# Chart Advisor

Aplicacion academica Flutter para elegir visualizaciones segun un problema real y comparar cuatro librerias. El catalogo contiene 65 conceptos (40 basicos y 25 avanzados). Batches 1-13 estan completos: 260/260 demos (100 %). La implementacion funcional de graficas esta completa; la auditoria final documentada se encuentra en `docs/chart_advisor_audit.md`.

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

El registro en `chart_renderer.dart` usa `(conceptId, ChartLibrary)` como clave. Cada demo tiene un builder y un dataset local. El catálogo declara una ruta realizable para las cuatro librerías en cada concepto. La matriz final no contiene combinaciones `unsupported`: cada concepto tiene exactamente una demo registrada por FL Chart, Syncfusion, Graphic y Graphify. `native` se reserva a tipos publicados por el paquete o su ejemplo oficial; `custom` y `simulated` documentan composiciones construidas con primitivas reales de la librería.

El asistente interpreta frases comunes y después ofrece preguntas cerradas. Las recomendaciones y alternativas son IDs de conceptos existentes. No utiliza IA, backend ni APIs externas. Graphify integra ECharts con recursos JavaScript empaquetados por el paquete y renderiza mediante WebView.

## Fuentes de compatibilidad

- [FL Chart, tipos publicados](https://pub.dev/packages/fl_chart)
- [Syncfusion Flutter Charts, tipos publicados](https://pub.dev/packages/syncfusion_flutter_charts)
- [Graphic, ejemplos oficiales](https://pub.dev/packages/graphic/example)
- [Graphify, ejemplos oficiales](https://pub.dev/packages/graphify/example)

Syncfusion requiere una licencia comercial o comunitaria conforme a sus condiciones. La comparación describe el estilo de API y funciones documentadas; no presenta benchmarks. Las demos Graphify requieren WebView. Los tests montan FL Chart, Syncfusion y Graphic a 320 y 500 px, validan las opciones JSON y construyen el widget Graphify. Las opciones de Batches 4-13 se renderizaron con ECharts SSR. La visualización real del WebView/iframe de Graphify en navegador o dispositivo sigue pendiente y se conserva como riesgo residual explícito.

## Pruebas

```sh
dart format .
flutter analyze
flutter test
```

The academic requirement is complete: 65 concepts × 4 libraries = 260 registered demos. Each library has 65 demos, each concept has four registrations, there are no duplicate or missing `(conceptId, library)` keys, and the production support matrix has zero `unsupported` entries. Functional chart implementation is complete; the remaining known limitation is real Graphify WebView/iframe execution outside the VM/SSR evidence.
