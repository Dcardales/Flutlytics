import 'package:flutter_test/flutter_test.dart';
import 'package:flutlytics_v1/features/advisor/domain/advisor_engine.dart';
import 'package:flutlytics_v1/features/charts/data/chart_catalog.dart';
import 'package:flutlytics_v1/features/charts/data/chart_combinations.dart';
import 'package:flutlytics_v1/features/charts/data/chart_data_profiles.dart';
import 'package:flutlytics_v1/features/charts/data/chart_support_matrix.dart';
import 'package:flutlytics_v1/features/charts/data/sample_datasets.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_concept.dart';
import 'package:flutlytics_v1/features/charts/domain/chart_filters.dart';
import 'package:flutlytics_v1/features/charts/presentation/chart_renderer.dart';

void main() {
  test('catálogo tiene 40 básicas y 25 avanzadas con IDs y slugs únicos', () {
    final concepts = ChartCatalog.concepts;
    expect(concepts, hasLength(65));
    expect(concepts.where((c) => c.level == ChartLevel.basic), hasLength(40));
    expect(
      concepts.where((c) => c.level == ChartLevel.advanced),
      hasLength(25),
    );
    expect(concepts.map((c) => c.id).toSet(), hasLength(65));
    expect(concepts.map((c) => c.slug).toSet(), hasLength(65));
    for (final c in concepts) {
      expect(c.name.trim(), isNotEmpty);
      expect(c.description.trim(), isNotEmpty);
      expect(c.useCase.trim(), isNotEmpty);
      expect(c.problemSolved.trim(), isNotEmpty);
      expect(ChartCategory.values, contains(c.category));
      expect(c.support.keys.toSet(), ChartLibrary.values.toSet());
      expect(
        c.compatibleCombinations.every(ChartCombinations.all.containsKey),
        isTrue,
      );
    }
  });

  test('reglas y alternativas apuntan a conceptos existentes', () {
    final engine = AdvisorEngine();
    expect(engine.referencesAreValid, isTrue);
    for (final node in AdvisorEngine.nodes.values) {
      for (final option in node.options) {
        expect(
          AdvisorEngine.nodes.containsKey(option.nextId) ||
              AdvisorEngine.recommendations.containsKey(option.nextId),
          isTrue,
        );
      }
    }
    expect(
      engine.interpret('Quiero descubrir si dos variables tienen relación'),
      'correlation',
    );
    expect(engine.interpret('Tengo tres variables'), 'bubble');
    expect(AdvisorEngine.recommendations['scatter']!.conceptId, 'scatter');
  });

  test('filtros combinan nombre, nivel, categoría, librería y problema', () {
    final all = ChartCatalog.concepts;
    expect(const ChartFilters(query: 'línea').apply(all), isNotEmpty);
    expect(
      const ChartFilters(level: ChartLevel.advanced).apply(all),
      hasLength(25),
    );
    expect(
      const ChartFilters(category: ChartCategory.correlation)
          .apply(all)
          .every((c) => c.category == ChartCategory.correlation),
      isTrue,
    );
    expect(
      const ChartFilters(library: ChartLibrary.flChart)
          .apply(all)
          .every((c) => c.supportedLibraries.contains(ChartLibrary.flChart)),
      isTrue,
    );
    expect(
      const ChartFilters(problem: 'ventas mensuales').apply(all),
      isNotEmpty,
    );
    expect(const ChartFilters(query: 'inexistente').apply(all), isEmpty);
  });

  test('demos de línea y barras registradas por cada librería', () {
    for (final library in ChartLibrary.values) {
      expect(ChartRenderer.hasDemo('line', library), isTrue);
      expect(ChartRenderer.hasDemo('bar', library), isTrue);
      expect(ChartRenderer.hasDemo('qq-plot', library), isTrue);
    }
  });

  test('registro de demos tiene claves únicas y referencias válidas', () {
    final registrations = ChartRenderer.registrations;
    final conceptIds = ChartCatalog.concepts.map((c) => c.id).toSet();
    final keys = registrations.map((r) => (r.conceptId, r.library)).toList();

    expect(keys.toSet(), hasLength(registrations.length));
    expect(registrations, hasLength(260));
    expect(ChartLibrary.values, hasLength(4));
    for (final library in ChartLibrary.values) {
      expect(registrations.where((r) => r.library == library), hasLength(65));
    }
    for (final concept in ChartCatalog.concepts) {
      expect(
        registrations.where((r) => r.conceptId == concept.id),
        hasLength(4),
      );
      for (final library in ChartLibrary.values) {
        expect(keys, contains((concept.id, library)));
      }
    }
    for (final registration in registrations) {
      expect(conceptIds, contains(registration.conceptId));
      expect(ChartLibrary.values, contains(registration.library));
      expect(
        ChartRenderer.hasDemo(registration.conceptId, registration.library),
        isTrue,
      );
    }
  });

  test('nivel explícito permanece igual al cambiar el orden de filas', () {
    const rows = '''
advanced|qq-plot|Q-Q|distribution|Descripción|Caso|Problema|cuantiles
basic|line|Línea|temporal|Descripción|Caso|Problema|tiempo
''';
    final parsed = ChartCatalog.parseRows(rows);
    expect(parsed.map((c) => c.id), ['qq-plot', 'line']);
    expect(parsed.map((c) => c.level), [ChartLevel.advanced, ChartLevel.basic]);
  });

  test(
    'matriz productiva cubre 65 conceptos por cada librería sin unsupported',
    () {
      final concepts = ChartCatalog.concepts;
      final ids = concepts.map((c) => c.id).toSet();
      expect(ids, hasLength(65));
      expect(ChartSupportMatrix.codes.keys.toSet(), ids);
      expect(ChartDataProfiles.byId.keys.toSet(), ids);
      for (final concept in concepts) {
        expect(concept.supportedLibraries, hasLength(4));
      }
      for (final library in ChartLibrary.values) {
        expect(
          concepts.where(
            (c) => c.support[library] != ChartSupportType.unsupported,
          ),
          hasLength(65),
        );
        expect(
          concepts.where(
            (c) => c.support[library] == ChartSupportType.unsupported,
          ),
          isEmpty,
        );
      }
    },
  );

  test('sustituciones conservan unicidad y contratos de datos específicos', () {
    final ids = ChartCatalog.concepts.map((c) => c.id).toSet();
    const oldIds = {
      'mosaic',
      'treemap',
      'sunburst',
      'sankey',
      'chord',
      'marimekko',
    };
    const newIds = {
      'diverging-stacked-bar',
      'scatterplot-matrix',
      'ternary-plot',
      'fan-chart',
      'qq-plot',
      'calibration-plot',
    };
    expect(ids.intersection(oldIds), isEmpty);
    expect(ids.intersection(newIds), newIds);
    expect(ChartCatalog.byId('candlestick').dataTypes, [
      'fecha',
      'open',
      'high',
      'low',
      'close',
    ]);
    expect(ChartCatalog.byId('bubble').variablesCount, 3);
    expect(
      ChartCatalog.byId('radar').dataProfile.structure,
      contains('tres o más'),
    );
    expect(
      ChartCatalog.byId('qq-plot').dataProfile.structure,
      contains('cuantiles'),
    );
    expect(
      ChartCatalog.byId('ternary-plot').dataProfile.invariant,
      contains('100 %'),
    );
  });

  test('datasets registrados pertenecen al catálogo y tienen contexto', () {
    final ids = ChartCatalog.concepts.map((c) => c.id).toSet();
    for (final entry in ChartDatasetRegistry.all.entries) {
      expect(ids, contains(entry.key));
      expect(entry.value.conceptId, entry.key);
      expect(entry.value.scenario, isNotEmpty);
      expect(entry.value.unit, isNotEmpty);
      expect(entry.value.rows, isNotEmpty);
      expect(entry.value.invariants, isNotEmpty);
    }
    expect(ChartDatasetRegistry.pointsFor('line'), hasLength(12));
    expect(ChartDatasetRegistry.pointsFor('bar'), hasLength(4));
  });

  test('asistente distingue ubicación discreta de campo continuo', () {
    final engine = AdvisorEngine();
    expect(engine.interpret('Tengo ubicaciones geográficas'), 'spatial');
    expect(engine.interpret('Tengo un campo continuo espacial'), 'contour');
    expect(
      AdvisorEngine.nodes['spatial']!.options.map((o) => o.nextId),
      containsAll(['contour', 'geographic-unavailable']),
    );
    expect(
      AdvisorEngine.nodes['geographic-unavailable']!.prompt,
      contains('no tiene un mapa geográfico'),
    );
  });
}
