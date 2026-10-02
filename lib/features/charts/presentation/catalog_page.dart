import 'package:flutter/material.dart';

import '../data/chart_catalog.dart';
import '../domain/chart_concept.dart';
import '../domain/chart_filters.dart';
import 'chart_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, this.initialLevel});
  final ChartLevel? initialLevel;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String query = '';
  String problem = '';
  ChartLevel? level;
  ChartCategory? category;
  ChartLibrary? library;

  @override
  void initState() {
    super.initState();
    level = widget.initialLevel;
  }

  @override
  Widget build(BuildContext context) {
    final results = ChartFilters(
      query: query,
      problem: problem,
      level: level,
      category: category,
      library: library,
    ).apply(ChartCatalog.concepts);
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de visualizaciones')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                key: const Key('catalog-search'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Buscar por nombre o etiqueta',
                ),
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.question_answer_outlined),
                  labelText: 'Filtrar por problema o caso de uso',
                ),
                onChanged: (value) => setState(() => problem = value),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  DropdownButton<ChartLevel?>(
                    value: level,
                    hint: const Text('Nivel'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos los niveles'),
                      ),
                      for (final value in ChartLevel.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged: (value) => setState(() => level = value),
                  ),
                  DropdownButton<ChartCategory?>(
                    value: category,
                    hint: const Text('Categoría'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas las categorías'),
                      ),
                      for (final value in ChartCategory.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged: (value) => setState(() => category = value),
                  ),
                  DropdownButton<ChartLibrary?>(
                    value: library,
                    hint: const Text('Librería'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas las librerías'),
                      ),
                      for (final value in ChartLibrary.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged: (value) => setState(() => library = value),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${results.length} conceptos',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No hay conceptos para estos filtros.'),
                ),
              for (final concept in results)
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChartDetailPage(concept: concept),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            concept.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${concept.level.label} · ${concept.category.label}',
                          ),
                          const SizedBox(height: 6),
                          Text(concept.useCase),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              for (final tag in concept.tags)
                                Chip(
                                  label: Text(tag),
                                  visualDensity: VisualDensity.compact,
                                ),
                              for (final lib in concept.supportedLibraries)
                                Chip(
                                  label: Text(lib.label),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ],
                      ),
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
