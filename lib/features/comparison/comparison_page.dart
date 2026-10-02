import 'package:flutter/material.dart';

import '../charts/data/chart_catalog.dart';
import '../charts/domain/chart_concept.dart';
import '../charts/presentation/chart_renderer.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  String conceptId = 'line';

  static const notes =
      <ChartLibrary, (String, String, String, String, String, String)>{
        ChartLibrary.flChart: (
          'Baja para tipos comunes (API de widgets)',
          'Toques configurables',
          'Estilos por elemento',
          'Transiciones de datos',
          'Control detallado de elementos',
          'Más composición manual para tipos especiales',
        ),
        ChartLibrary.syncfusion: (
          'Baja para series predefinidas',
          'Tooltips y selección',
          'Amplias opciones de series',
          'Animación de series',
          'Muchos tipos listos para usar',
          'Requiere licencia comercial o comunitaria',
        ),
        ChartLibrary.graphic: (
          'Media: requiere aprender su gramática',
          'Eventos y selecciones',
          'Marcas y escalas componibles',
          'Transiciones de marcas',
          'Composición flexible',
          'Curva de aprendizaje de su gramática',
        ),
        ChartLibrary.graphify: (
          'Media: configuración ECharts y WebView',
          'Interacción en WebView',
          'Opciones de ECharts',
          'Animaciones de ECharts',
          'Amplio ecosistema de ECharts',
          'Depende de WebView y configuración JSON',
        ),
      };

  @override
  Widget build(BuildContext context) {
    final concept = ChartCatalog.byId(conceptId);
    return Scaffold(
      appBar: AppBar(title: const Text('Comparar librerías')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Comparación cualitativa de APIs y funciones documentadas. Sin métricas de rendimiento.',
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: conceptId,
                isExpanded: true,
                items: [
                  for (final item in ChartCatalog.concepts)
                    DropdownMenuItem(value: item.id, child: Text(item.name)),
                ],
                onChanged: (value) => setState(() => conceptId = value!),
              ),
              const SizedBox(height: 8),
              for (final library in ChartLibrary.values)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          library.label,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Soporte: ${concept.support[library]!.label} · ${ChartRenderer.hasDemo(concept.id, library) ? 'demo disponible' : 'demo pendiente'}',
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 210,
                          child: ChartRenderer.buildChart(
                            concept: concept,
                            library: library,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Dificultad aproximada: ${notes[library]!.$1}'),
                        Text('Interactividad: ${notes[library]!.$2}'),
                        Text('Personalización: ${notes[library]!.$3}'),
                        Text('Animaciones: ${notes[library]!.$4}'),
                        Text('Ventaja: ${notes[library]!.$5}'),
                        Text('Limitación: ${notes[library]!.$6}'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
