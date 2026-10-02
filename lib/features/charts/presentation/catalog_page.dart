import 'package:flutter/material.dart';

import '../../../core/flutlytics_theme.dart';
import '../data/chart_catalog.dart';
import '../domain/chart_concept.dart';
import '../domain/chart_filters.dart';
import 'chart_detail_page.dart';
import 'combinations_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, this.initialLevel});
  final ChartLevel? initialLevel;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _problemController = TextEditingController();
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
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    var draftLevel = level;
    var draftCategory = category;
    var draftLibrary = library;
    _problemController.text = problem;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, updateSheet) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
            ),
            child: SizedBox(
              height: MediaQuery.sizeOf(sheetContext).height * 0.78,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filtros',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Nivel',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _choice(
                                'Todos',
                                draftLevel == null,
                                () => updateSheet(() => draftLevel = null),
                              ),
                              for (final value in ChartLevel.values)
                                _choice(
                                  value.label == 'Básica'
                                      ? 'Básicas'
                                      : 'Avanzadas',
                                  draftLevel == value,
                                  () => updateSheet(() => draftLevel = value),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Categoría',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<ChartCategory?>(
                            initialValue: draftCategory,
                            isExpanded: true,
                            decoration: const InputDecoration(),
                            items: [
                              const DropdownMenuItem<ChartCategory?>(
                                value: null,
                                child: Text('Todas las categorías'),
                              ),
                              for (final value in ChartCategory.values)
                                DropdownMenuItem<ChartCategory?>(
                                  value: value,
                                  child: Text(value.label),
                                ),
                            ],
                            onChanged: (value) =>
                                updateSheet(() => draftCategory = value),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Librería',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _choice(
                                'Todas',
                                draftLibrary == null,
                                () => updateSheet(() => draftLibrary = null),
                              ),
                              for (final value in ChartLibrary.values)
                                _choice(
                                  value.label,
                                  draftLibrary == value,
                                  () => updateSheet(() => draftLibrary = value),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _problemController,
                            decoration: const InputDecoration(
                              labelText: 'Problema o caso de uso',
                              prefixIcon: Icon(Icons.question_answer_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            level = null;
                            category = null;
                            library = null;
                            problem = '';
                          });
                          Navigator.pop(sheetContext);
                        },
                        child: const Text('Limpiar'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              level = draftLevel;
                              category = draftCategory;
                              library = draftLibrary;
                              problem = _problemController.text;
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Aplicar filtros'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _choice(String label, bool selected, VoidCallback onTap) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
  );

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
      appBar: AppBar(title: const Text('Visualizaciones')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('catalog-search'),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Buscar visualizaciones',
                      ),
                      onChanged: (value) => setState(() => query = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    key: const Key('catalog-filters'),
                    tooltip: 'Filtros',
                    onPressed: _openFilters,
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
              if (level != null ||
                  category != null ||
                  library != null ||
                  problem.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (level != null)
                      InputChip(
                        label: Text(level!.label),
                        onDeleted: () => setState(() => level = null),
                      ),
                    if (category != null)
                      InputChip(
                        label: Text(category!.label),
                        onDeleted: () => setState(() => category = null),
                      ),
                    if (library != null)
                      InputChip(
                        label: Text(library!.label),
                        onDeleted: () => setState(() => library = null),
                      ),
                    if (problem.isNotEmpty)
                      InputChip(
                        label: Text(problem),
                        onDeleted: () => setState(() => problem = ''),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(
                '${results.length} visualizaciones',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CombinationsPage()),
                  ),
                  icon: const Icon(Icons.layers_rounded),
                  label: const Text('Ver combinaciones'),
                ),
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No hay visualizaciones para estos filtros.'),
                ),
              for (final concept in results) ...[
                _conceptCard(context, concept),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _conceptCard(BuildContext context, ChartConcept concept) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChartDetailPage(concept: concept)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(concept.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _badge(
                  concept.level.label,
                  concept.level == ChartLevel.basic
                      ? const Color(0xFFDDF7FA)
                      : const Color(0xFFEDE9FE),
                  concept.level == ChartLevel.basic
                      ? const Color(0xFF075E68)
                      : const Color(0xFF5B21B6),
                ),
                _badge(
                  concept.category.label,
                  FlutlyticsColors.background,
                  FlutlyticsColors.secondaryText,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              concept.useCase,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final lib in concept.supportedLibraries)
                  _badge(
                    lib.label,
                    FlutlyticsColors.primary.withValues(alpha: 0.07),
                    FlutlyticsColors.primaryDark,
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _badge(String label, Color background, Color foreground) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: foreground,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
