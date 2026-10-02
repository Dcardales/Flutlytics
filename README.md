# Flutlytics

Aplicación Flutter educativa para aprender a elegir y comparar visualizaciones de datos.

## Características

- 65 conceptos base: 40 básicos y 25 avanzados.
- 4 bibliotecas y 260 implementaciones comparables, una por concepto base y biblioteca.
- combinaciones avanzadas adicionales, con detalle navegable y selector de biblioteca.
- Asistente local basado en reglas para recomendar gráficas.
- Catálogo con búsqueda y filtros por nivel, categoría y biblioteca.
- Comparación cualitativa de las cuatro bibliotecas.

## Bibliotecas

- FL Chart
- Syncfusion Flutter Charts
- Graphic
- Graphify

## Ejecutar

```sh
flutter pub get
flutter run
```

## Calidad

```sh
flutter analyze
flutter test
```

## Arquitectura

`lib/features/charts/data` contiene el catálogo y los conjuntos de datos locales. `lib/features/charts/presentation` contiene el catálogo, el detalle y el registro de renderizadores. `lib/features/advisor` implementa el asistente basado en reglas; `lib/features/comparison` presenta las demos y notas de cada biblioteca.

Cada uno de los 65 conceptos base tiene una demo registrada para FL Chart, Syncfusion, Graphic y Graphify: 65 × 4 = 260 implementaciones comparables. Las  combinaciones avanzadas forman una capa aparte y suman 120 rutas de visualización adicionales. Algunas usan overlays, con capas que comparten un área de trazado; otras coordinan varios paneles derivados de las mismas observaciones. Las demos de Graphify requieren WebView para visualizarse en un dispositivo o navegador compatible.
