import 'package:flutter/material.dart';

import '../../charts/data/chart_catalog.dart';
import '../../charts/presentation/chart_detail_page.dart';
import '../domain/advisor_engine.dart';

class AdvisorPanel extends StatefulWidget {
  const AdvisorPanel({super.key});

  @override
  State<AdvisorPanel> createState() => _AdvisorPanelState();
}

class _AdvisorPanelState extends State<AdvisorPanel> {
  final _engine = AdvisorEngine();
  final _input = TextEditingController();
  final List<(bool, String)> _messages = [
    (false, AdvisorEngine.nodes[AdvisorEngine.start]!.prompt),
  ];
  String? _nodeId = AdvisorEngine.start;
  AdvisorRecommendation? _result;
  bool _showAlternatives = false;

  void _choose(AdvisorOption option) {
    setState(() {
      _messages.add((true, option.label));
      _advance(option.nextId);
    });
  }

  void _submit() {
    final message = _input.text.trim();
    if (message.isEmpty) return;
    _input.clear();
    setState(() {
      _messages.add((true, message));
      final next = _engine.interpret(message);
      if (next == null) {
        _messages.add((
          false,
          'No reconozco aún ese problema. Elige una de las opciones para continuar.',
        ));
      } else {
        _advance(next);
      }
    });
  }

  void _advance(String id) {
    _showAlternatives = false;
    _result = AdvisorEngine.recommendations[id];
    _nodeId = _result == null ? id : null;
    if (_nodeId != null) {
      _messages.add((false, AdvisorEngine.nodes[id]!.prompt));
    }
  }

  void _restart() {
    setState(() {
      _messages
        ..clear()
        ..add((false, AdvisorEngine.nodes[AdvisorEngine.start]!.prompt));
      _nodeId = AdvisorEngine.start;
      _result = null;
      _showAlternatives = false;
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final node = _nodeId == null ? null : AdvisorEngine.nodes[_nodeId];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome),
                const SizedBox(width: 8),
                Text(
                  'Asistente de gráficas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Reiniciar conversación',
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final message in _messages)
              Align(
                alignment: message.$1
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.$1
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(message.$2),
                ),
              ),
            if (node != null)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final option in node.options)
                    ActionChip(
                      label: Text(option.label),
                      onPressed: () => _choose(option),
                    ),
                ],
              ),
            if (result != null) ...[
              const SizedBox(height: 8),
              Text(
                'Recomendación: ${ChartCatalog.byId(result.conceptId).name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(result.reason),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChartDetailPage(
                          concept: ChartCatalog.byId(result.conceptId),
                        ),
                      ),
                    ),
                    child: const Text('Ver ejemplo'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _showAlternatives = !_showAlternatives),
                    child: const Text('Ver alternativas'),
                  ),
                ],
              ),
              if (_showAlternatives)
                Wrap(
                  spacing: 6,
                  children: [
                    for (final id in result.alternatives)
                      ActionChip(
                        label: Text(ChartCatalog.byId(id).name),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChartDetailPage(concept: ChartCatalog.byId(id)),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      hintText: 'Ej.: comparar ventas por categoría',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Enviar mensaje',
                  onPressed: _submit,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
