import 'package:flutter/material.dart';

import '../../core/flutlytics_theme.dart';
import '../advisor/presentation/advisor_panel.dart';
import '../charts/domain/chart_concept.dart';
import '../charts/presentation/catalog_page.dart';
import '../charts/presentation/combinations_page.dart';
import '../comparison/comparison_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _advisorKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_rounded, color: FlutlyticsColors.primary),
            SizedBox(width: 8),
            Text('Flutlytics'),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [FlutlyticsColors.primary, Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encuentra la gráfica ideal para tus datos',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explora 65 conceptos de visualización, 260 implementaciones comparables y 4 librerías Flutter.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: FlutlyticsColors.primaryDark,
                          ),
                          onPressed: _goToAdvisor,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Recomiéndame una gráfica'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _open(context, const CatalogPage()),
                          child: const Text('Explorar catálogo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Acciones rápidas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 600 ? 2 : 4;
                  const gap = 10.0;
                  final itemWidth =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      _quickAction(
                        context,
                        itemWidth,
                        Icons.grid_view_rounded,
                        'Catálogo',
                        () => _open(context, const CatalogPage()),
                      ),
                      _quickAction(
                        context,
                        itemWidth,
                        Icons.bar_chart_rounded,
                        'Básicas',
                        () => _open(
                          context,
                          const CatalogPage(initialLevel: ChartLevel.basic),
                        ),
                      ),
                      _quickAction(
                        context,
                        itemWidth,
                        Icons.insights_rounded,
                        'Avanzadas',
                        () => _open(
                          context,
                          const CatalogPage(initialLevel: ChartLevel.advanced),
                        ),
                      ),
                      _quickAction(
                        context,
                        itemWidth,
                        Icons.compare_arrows_rounded,
                        'Comparar librerías',
                        () => _open(context, const ComparisonPage()),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.layers_rounded,
                    color: FlutlyticsColors.primary,
                  ),
                  title: const Text('Explorar combinaciones'),
                  subtitle: const Text('gráficas compuestas adicionales'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _open(context, const CombinationsPage()),
                ),
              ),
              const SizedBox(height: 16),
              AdvisorPanel(key: _advisorKey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goToAdvisor() async {
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    if (!mounted) return;
    final target = _advisorKey.currentContext;
    if (target != null && target.mounted) {
      await Scrollable.ensureVisible(
        target,
        alignment: 0.05,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  Widget _quickAction(
    BuildContext context,
    double width,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) => SizedBox(
    width: width,
    height: 94,
    child: Material(
      color: FlutlyticsColors.primary.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: FlutlyticsColors.primary),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: FlutlyticsColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
