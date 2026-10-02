import 'package:flutter/material.dart';

import '../data/chart_combinations.dart';
import '../data/chart_catalog.dart';
import 'combination_detail_page.dart';

class CombinationsPage extends StatefulWidget {
  const CombinationsPage({super.key});
  @override
  State<CombinationsPage> createState() => _CombinationsPageState();
}

class _CombinationsPageState extends State<CombinationsPage> {
  CombinationCategory? selected;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Combinaciones')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'combinaciones avanzadas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              const Text('Una capa adicional a los 65 conceptos base.'),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(context, 'Todos', null),
                    for (final category in CombinationCategory.values)
                      _filterChip(context, _categoryLabel(category), category),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final items = ChartCombinations.all.values
                  .where(
                    (combination) =>
                        selected == null || combination.category == selected,
                  )
                  .toList();
              return GridView.builder(
                key: const Key('combination-grid'),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth >= 430 ? 2 : 1,
                  mainAxisExtent: 156,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _combinationCard(context, items[index]),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _filterChip(
    BuildContext context,
    String label,
    CombinationCategory? category,
  ) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: FilterChip(
      label: Text(label),
      selected: selected == category,
      onSelected: (_) => setState(() => selected = category),
    ),
  );

  Widget _combinationCard(BuildContext context, ChartCombination combination) =>
      Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('combination-${combination.id}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CombinationDetailPage(combination: combination),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.layers_rounded, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        combination.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _categoryLabel(combination.category),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  combination.componentConceptIds
                      .map((id) => ChartCatalog.byId(id).name)
                      .join(' + '),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    combination.reason,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Ver combinación',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  String _categoryLabel(CombinationCategory category) => switch (category) {
    CombinationCategory.comparison => 'Comparación',
    CombinationCategory.time => 'Tiempo',
    CombinationCategory.distribution => 'Distribución',
    CombinationCategory.relationships => 'Relaciones',
    CombinationCategory.finance => 'Finanzas',
    CombinationCategory.planning => 'Planificación',
    CombinationCategory.performance => 'Rendimiento',
  };
}
