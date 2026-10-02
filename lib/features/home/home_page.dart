import 'package:flutter/material.dart';

import '../advisor/presentation/advisor_panel.dart';
import '../charts/domain/chart_concept.dart';
import '../charts/presentation/catalog_page.dart';
import '../comparison/comparison_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chart Advisor')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Aprende a elegir con tus datos',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '¿Qué gráfica necesito?',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Describe tu problema o elige una opción. El asistente te guiará con reglas locales.',
            ),
            const SizedBox(height: 18),
            Text('Explorar', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Catálogo completo'),
                  avatar: const Icon(Icons.grid_view),
                  onPressed: () => _open(context, const CatalogPage()),
                ),
                ActionChip(
                  label: const Text('Básicas'),
                  avatar: const Icon(Icons.bar_chart),
                  onPressed: () => _open(
                    context,
                    const CatalogPage(initialLevel: ChartLevel.basic),
                  ),
                ),
                ActionChip(
                  label: const Text('Avanzadas'),
                  avatar: const Icon(Icons.insights),
                  onPressed: () => _open(
                    context,
                    const CatalogPage(initialLevel: ChartLevel.advanced),
                  ),
                ),
                ActionChip(
                  label: const Text('Comparar librerías'),
                  avatar: const Icon(Icons.compare_arrows),
                  onPressed: () => _open(context, const ComparisonPage()),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const AdvisorPanel(),
          ],
        ),
      ),
    ),
  );

  void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
