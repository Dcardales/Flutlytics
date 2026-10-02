import 'package:flutter/material.dart';

import '../data/chart_catalog.dart';
import '../data/chart_combinations.dart';
import '../data/sample_datasets.dart';
import '../domain/chart_concept.dart';
import 'chart_renderer.dart';

class ChartDetailPage extends StatefulWidget {
  const ChartDetailPage({super.key, required this.concept});
  final ChartConcept concept;

  @override
  State<ChartDetailPage> createState() => _ChartDetailPageState();
}

class _ChartDetailPageState extends State<ChartDetailPage> {
  ChartLibrary selected = ChartLibrary.flChart;

  @override
  Widget build(BuildContext context) {
    final concept = widget.concept;
    final dataset = ChartDatasetRegistry.forConcept(concept.id);
    final related = ChartCatalog.concepts
        .where((c) => c.id != concept.id && c.category == concept.category)
        .take(3);
    return Scaffold(
      appBar: AppBar(title: Text(concept.name)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                concept.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text('${concept.level.label} · ${concept.category.label}'),
              const SizedBox(height: 14),
              Text(concept.description),
              const SizedBox(height: 14),
              _section(context, 'Problema que resuelve', concept.problemSolved),
              _section(context, 'Cuándo utilizarla', concept.recommendedFor),
              _section(context, 'Cuándo evitarla', concept.avoidWhen),
              _section(context, 'Caso de uso', concept.useCase),
              const SizedBox(height: 8),
              Text(
                'Ejemplo por librería',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              DropdownButton<ChartLibrary>(
                key: const Key('library-selector'),
                value: selected,
                isExpanded: true,
                items: [
                  for (final library in ChartLibrary.values)
                    DropdownMenuItem(
                      value: library,
                      child: Text(library.label),
                    ),
                ],
                onChanged: (value) => setState(() => selected = value!),
              ),
              Text('Soporte: ${concept.support[selected]!.label}'),
              const SizedBox(height: 8),
              Card(
                child: SizedBox(
                  height: switch (concept.id) {
                    'small-multiples-line' || 'small-multiples-bar' =>
                      MediaQuery.sizeOf(context).width < 420 ? 500 : 280,
                    'sparkline' =>
                      MediaQuery.sizeOf(context).width < 420 ? 440 : 220,
                    'pie' || 'donut' || 'waffle' || 'polar-area' || 'radar' =>
                      MediaQuery.sizeOf(context).width < 420 ? 390 : 330,
                    _ => 270,
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ChartRenderer.buildChart(
                      concept: concept,
                      library: selected,
                    ),
                  ),
                ),
              ),
              if (dataset != null) ...[
                Text(
                  'Dataset local',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('${dataset.title} (${dataset.unit})'),
                Text(dataset.scenario),
                Text(dataset.description),
                Text(dataset.sourceNote),
                Text(
                  dataset.rows
                      .map(
                        (row) => row.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join(', '),
                      )
                      .join(' · '),
                ),
                Text('Condiciones: ${dataset.invariants.join(' · ')}'),
              ] else
                const Text('Dataset de demostración pendiente.'),
              const SizedBox(height: 12),
              _section(
                context,
                'Variables',
                '${concept.dataTypes.join(' · ')} · ${concept.variablesCount} variables aproximadas',
              ),
              Text('Librerías', style: Theme.of(context).textTheme.titleMedium),
              for (final library in ChartLibrary.values)
                Text(
                  '${library.label}: ${concept.support[library]!.label}${ChartRenderer.hasDemo(concept.id, library) ? ' · demo disponible' : ''}',
                ),
              const SizedBox(height: 16),
              Text(
                'Gráficas relacionadas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 6,
                children: [
                  for (final item in related)
                    ActionChip(
                      label: Text(item.name),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChartDetailPage(concept: item),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Combinaciones con sentido',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (concept.compatibleCombinations.isEmpty)
                const Text('No hay una combinación registrada aún.'),
              for (final id in concept.compatibleCombinations)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(ChartCombinations.all[id]!.name),
                  subtitle: Text(ChartCombinations.all[id]!.reason),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(body),
      ],
    ),
  );
}
