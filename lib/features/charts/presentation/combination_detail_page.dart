import 'package:flutter/material.dart';

import '../data/chart_catalog.dart';
import '../data/chart_combinations.dart';
import '../domain/chart_concept.dart';
import 'combination_renderer.dart';

class CombinationDetailPage extends StatefulWidget {
  const CombinationDetailPage({super.key, required this.combination});
  final ChartCombination combination;
  @override
  State<CombinationDetailPage> createState() => _CombinationDetailPageState();
}

class _CombinationDetailPageState extends State<CombinationDetailPage> {
  ChartLibrary selected = ChartLibrary.flChart;
  @override
  Widget build(BuildContext context) {
    final combination = widget.combination;
    return Scaffold(
      appBar: AppBar(title: Text(combination.name)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        combination.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(combination.reason),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('Combina', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final id in combination.componentConceptIds)
                    Chip(label: Text(ChartCatalog.byId(id).name)),
                ],
              ),
              _section(context, 'Caso de uso', combination.useCase),
              _section(context, 'Cuándo usar', combination.whenToUse),
              _section(context, 'Cuándo NO usar', combination.whenNotToUse),
              _section(
                context,
                'Composición',
                combination.layout == CombinationLayoutType.overlay
                    ? 'Overlay: las capas comparten el área de trazado.'
                    : 'Vistas coordinadas: cada panel aporta una lectura distinta del mismo conjunto de observaciones.',
              ),
              DropdownButtonFormField<ChartLibrary>(
                key: const Key('combination-library-selector'),
                initialValue: selected,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Librería'),
                items: [
                  for (final library in ChartLibrary.values)
                    DropdownMenuItem(
                      value: library,
                      child: Text(library.label),
                    ),
                ],
                onChanged: (value) => setState(() => selected = value!),
              ),
              const SizedBox(height: 12),
              Card(
                child: SizedBox(
                  height: 360,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ChartCombinationRegistry.build(
                      combination.id,
                      selected,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _section(context, 'Capas y paneles', combination.layers),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String heading, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(body),
      ],
    ),
  );
}
